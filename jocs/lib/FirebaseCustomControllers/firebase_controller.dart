import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/src/list_extensions.dart';
import 'package:download/download.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jocs/Dashboard/Controllers/dashboard_controller.dart';
import 'package:jocs/Dashboard/Modals/screen_adapter.dart';
import 'package:jocs/Dashboard/Screens/tickets_screen.dart';
import 'package:jocs/FirebaseCustomControllers/ChatModels/person_model.dart';
import 'package:jocs/FirebaseCustomControllers/ChatModels/user_chat_model.dart';
import 'package:jocs/FirebaseCustomControllers/ChatModels/user_details_model.dart';
import 'package:jocs/FirebaseCustomControllers/DataModels/article_category.dart';
import 'package:jocs/FirebaseCustomControllers/DataModels/detailed_metadata.dart';
import 'package:jocs/FirebaseCustomControllers/FirebaseInterface/firebase_controller_interface.dart';
import 'package:jocs/Registration/Controllers/login_controller.dart';
import 'package:jocs/Registration/Controllers/register_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import '../firebase_options.dart';

class FirebaseController implements FirebaseControllerInterface{
  late CollectionReference collectionReference;
  late LoginController _loginController;
  late RegisterController _registerController;

  @override
  Rx<CurrentUserDetails> currentUserDetails = CurrentUserDetails(userId: "", email: "", username: "").obs;
  late var data;

  @override
  late FirebaseAuth auth;

  @override
  List<StreamSubscription> chatScreenMainStreams = [];

  FirebaseController();

  @override
  void addArticleCategory(Map<String, dynamic> data, String collectionName) {
    collectionReference = FirebaseFirestore.instance.collection(collectionName);
    collectionReference
        .add(data)
        .then((value) {
          print("${collectionName} Added");
        })
        .catchError((error) => print("Failed to add ${collectionName}: $error"));
  }

  @override
  Future<void> addDataToFirebase(data, String collectionName, String metadataKey, int lastId) async {
    // data["id"] = lastId;
    collectionReference = FirebaseFirestore.instance.collection(collectionName);
    collectionReference
        .add(data)
        .then((value) {
          print("${collectionName} Added");
          setMetadataInDatabase({metadataKey: lastId + 1});
        })
        .catchError((error) => print("Failed to add Ticket: $error"));
  }

  @override
  Future<void> addFriend(List friendData) async {
    String friendUniqueId = DateTime.now().toUtc().millisecondsSinceEpoch.toString() + auth.currentUser!.uid;
    var tempData = <String, dynamic>{};
    tempData["chatId"] = friendUniqueId;
    tempData["unread"] = [];
    tempData["friendName"] = friendData[0];
    collectionReference = FirebaseFirestore.instance.collection("Users");
    collectionReference
        .doc(auth.currentUser!.uid)
        .collection("Friends").doc(friendData[1])
        .set(tempData)
        .then((value){
          print("Group Created");
          var tempData = <String, dynamic>{};
          tempData["chatId"] = friendUniqueId;
          tempData["unread"] = [];
          tempData["friendName"] = auth.currentUser!.email;
          collectionReference = FirebaseFirestore.instance.collection("Users");
          collectionReference.
          doc(friendData[1]).
          collection("Friends").doc(auth.currentUser!.uid)
              .set(tempData)
              .then((value){
            print("Group Created");
            createNewChat(friendUniqueId);
          })
          .catchError((error) => print("Failed to add Group: $error"));
        })
        .catchError((error) => print("Failed to add Group: $error"));
  }

  @override
  Future<void> addFriendToGroup(List friendData, groupId, String groupName) async {
    var tempData = <String, dynamic>{};
    tempData["chatId"] = groupId;
    tempData["unread"] = [];
    tempData["groupName"] = groupName;
    collectionReference = FirebaseFirestore.instance.collection("Users");
    collectionReference
        .doc(friendData[1])
        .collection("Groups").doc(groupId)
        .set(tempData)
        .then((value){
          print("Friend Added");
        })
        .catchError((error) => print("Failed to add Friend to group $error"));
  }

  @override
  bool checkFirebaseLoggedIn(){
    if (auth.currentUser != null){
      return true;
    }
    return false;
  }

  createChatListener(String collectionName){
    collectionReference.doc(auth.currentUser!.uid).collection(collectionName).get().then((value){
      for (var element in value.docs) {
        chatScreenMainStreams.add(collectionReference.doc(auth.currentUser!.uid).collection(collectionName).doc(element.id).
        snapshots().listen((DocumentSnapshot snapshot){
          print(snapshot.data());
        })
        );
      }
    });

  }

  @override
  void createNewArticle(Map<String, dynamic> data, int lastId) async {
    // data['time'] = DateTime.now().toUtc().millisecondsSinceEpoch.toString();
    collectionReference = FirebaseFirestore.instance.collection("articles");
    collectionReference.add(data).then((value) {

      setMetadataInDatabase({'articlesCount': lastId + 1});

      collectionReference = FirebaseFirestore.instance.collection("category");
      collectionReference.where("category-name", isEqualTo: data['category-name']).get().then((QuerySnapshot snapshot){
        for (var element in snapshot.docs) {
          List articles = element["articles"];
          Map<String, String> tempArticle = {
            'topic': data['topic'],
            'id': value.id
          };
          articles.add(tempArticle);
          collectionReference = FirebaseFirestore.instance.collection("category");
          element.reference.update({"articles": articles});
        }
      });
    });
  }

  @override
  Future<void> createNewChat(id) async {
    collectionReference = FirebaseFirestore.instance.collection("Chat");
    collectionReference
        .doc(id)
        .set(<String, dynamic>{})
        .then((value){
          print("Chat Created");
        })
        .catchError((error) => print("Failed to add Chat Id: $error"));
  }

  @override
  Future<void> createNewGroup(groupData) async {
    String groupUniqueId = DateTime.now().toUtc().millisecondsSinceEpoch.toString() + auth.currentUser!.uid;
    groupData["chatId"] = groupUniqueId;
    groupData["unread"] = [];
    collectionReference = FirebaseFirestore.instance.collection("Users");
    collectionReference
        .doc(auth.currentUser!.uid)
        .collection("Groups")
        .doc(groupUniqueId)
        .set(groupData)
        .then((value){
          print("Group Created");
          createNewChat(groupUniqueId);
        })
        .catchError((error) => print("Failed to add Group: $error"));
  }

  @override
  Stream<List<PersonModel>> friendListStream(){
    collectionReference = FirebaseFirestore.instance.collection("Users");
    return collectionReference.
    doc(auth.currentUser!.uid)
        .collection("Friends")
        .snapshots()
        .map((QuerySnapshot query){
          List<PersonModel> retVal = [];
          for (var element in query.docs) {
            retVal.add(PersonModel(chatId: element["chatId"], unreadMessages: element["unread"], modelId: element.id, modelName: element["friendName"], modelType: "Friend"));
          }
          return retVal;
        });
  }

  @override
  Future<DocumentSnapshot> getArticle(String documentId) async {
    collectionReference = FirebaseFirestore.instance.collection("articles");
    DocumentSnapshot snapshot = await collectionReference.doc(documentId).get();
    return snapshot;
  }

  @override
  Future getArticleByTime(time) async {
    collectionReference = FirebaseFirestore.instance.collection("articles");
    QuerySnapshot snapshot = await collectionReference.where('time', isEqualTo: time).get();
    return snapshot.docs.first;
  }

  @override
  Stream<List<ArticleCategory>> getCategoryData() {
    collectionReference = FirebaseFirestore.instance.collection("category");
    return collectionReference.snapshots().map((QuerySnapshot snapshot){
      List<ArticleCategory> retVal = [];
      for (var category in snapshot.docs){
        retVal.add(ArticleCategory.fromDocumentSnapshot(documentSnapshot: category));
      }
      return retVal;
    });
  }

  @override
  Future<List<MessageModel>> getChat(String chatId, [MessageModel? lastMessage]) async {
    List<MessageModel> temp = [];
    collectionReference = FirebaseFirestore.instance.collection("Chat");
    if (lastMessage!=null){
      await collectionReference.doc(chatId).collection("messages").where("time", isLessThan:lastMessage.timeStamp).orderBy("time", descending: true).limit(20).get().then((value){
        for (var element in value.docs) {
          print(element["message"]);
          temp.add(MessageModel(element["message"], element["sender"], element["time"], element["senderName"]));
        }

      }
      );
    }else{
      await collectionReference.doc(chatId).collection("messages").orderBy("time", descending: true).limit(20).get().then((value){
        for (var element in value.docs) {
          print(element["message"]);
          temp.add(MessageModel(element["message"], element["sender"], element["time"], element["senderName"]));
        }

      }
      );
    }

    return temp;
  }

  @override
  Future<int> getDashboardData(String documentName, {String filter= ""}) async {
    collectionReference = FirebaseFirestore.instance.collection("tickets");
    QuerySnapshot<Object?> tempData;

    if (filter.isNotEmpty){
      tempData = await collectionReference.where(documentName, isEqualTo: filter).get();
    }else{
      tempData = await collectionReference.orderBy(documentName, descending: true).get();
    }
    return tempData.docs.length;

  }

  @override
  Stream<dynamic> getData(
      String collectionName
      , int page
      , int length
      , {String filter = ""
        , Map<String, String> customFilter = const <String, String>{}}
        ) {
    collectionReference = FirebaseFirestore.instance.collection(collectionName);

    Query ref;
    if (page > 1) {
      ref = collectionReference.orderBy("time", descending: true)
          .where("time", isLessThan: filter)
          .limit(length+10);
    } else {
      ref = collectionReference.orderBy("time", descending: true)
          .where("time", isLessThanOrEqualTo: filter)
          .limit(length+10);
    }

    customFilter.forEach((key, value) {
      if (key != "S" && key != "P"){
        ref = ref.where(key, isEqualTo: value);
      }
    });

    return ref.snapshots();
  }

  @override
  Stream<dynamic> getNewData(String timeStamp, String screenName) {
    collectionReference = FirebaseFirestore.instance.collection(screenName);
    Stream<QuerySnapshot> snapshot = collectionReference.where("time", isGreaterThan: timeStamp).snapshots();
    return snapshot;
  }

  @override
  Stream<DetailedMetadata> getMetaDataFromDatabase(){
    //DashboardController _dashboardController = Get.find<DashboardController>();
    collectionReference = FirebaseFirestore.instance.collection("metadata");
    return collectionReference.doc("data").snapshots().map((DocumentSnapshot snapshot) {
      //_dashboardController.getUpdatedTableData();
      return DetailedMetadata.fromDataSnapshot(snapshot);
    });
  }

  // @override
  // Future<int> getLastId(String collectionName) async {
  //   int lastId = 1;
  //   collectionReference = FirebaseFirestore.instance.collection(collectionName);
  //   var dataTemp = await collectionReference.orderBy("time", descending: true).limit(1).get();
  //   for (var doc in dataTemp.docs) {
  //     lastId = doc["id"];
  //     lastId += 1;
  //   }
  //   return lastId;
  // }

  @override
  Future<List<MessageModel>> getRecentChat(String chatId, String mostRecentMessageTimeStamp) async {
    List<MessageModel> temp = [];
    collectionReference = FirebaseFirestore.instance.collection("Chat");
    await collectionReference.doc(chatId).collection("messages").where("time", isGreaterThan:mostRecentMessageTimeStamp).orderBy("time", descending: true).get().then((value){
      for (var element in value.docs) {
        print(element["message"]);
        temp.add(MessageModel(element["message"], element["sender"], element["time"], element["senderName"]));
      }

    });
    return temp;
  }

  @override
  Stream<List<PersonModel>> groupListStream(){
    collectionReference = FirebaseFirestore.instance.collection("Users");
    return collectionReference.
    doc(auth.currentUser!.uid).
    collection("Groups").snapshots().map((QuerySnapshot query){
      List<PersonModel> retVal = [];

      for (var element in query.docs) {
        retVal.add(PersonModel(chatId: element["chatId"], unreadMessages: element["unread"], modelId: element.id, modelName: element["groupName"], modelType: "Group"));
      }
      return retVal;
    });
  }

  @override
  initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    auth = FirebaseAuth.instance;
    collectionReference = FirebaseFirestore.instance.collection('tickets');
  }

  @override
  initializeLoginController(){
    _loginController = Get.find<LoginController>();
    // _loginController.initializeLogin();
  }

  @override
  initializeRegisterController(){
    _registerController = Get.find<RegisterController>();
  }

  @override
  login(String email, String password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email,
          password: password
      ).then((value) {
        print(value);
        return Future.value(value);
      });
      if (auth.currentUser != null){
        Get.toNamed("/dashboard");
      }
      print("success");
      print(auth.currentUser);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        _loginController.loginErrorMessage.value = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        _loginController.loginErrorMessage.value = 'Wrong password provided for that user.';
      }
    }
  }

  @override
  void logOut() {
    Get.offAllNamed('/login');
    // Signing Out
    auth.signOut();
  }

  // @override
  // void newChatListener(){
  //   collectionReference = FirebaseFirestore.instance.collection("Users");
  //   createChatListener("Friends");
  //   createChatListener("Groups");
  // }

  @override
  register(String username, String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).then((value) {
        collectionReference = FirebaseFirestore.instance.collection("Users");
        collectionReference.doc(value.user!.uid).set({"email": value.user!.email, "username": username, "imageName": ""});
        return value;
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        _registerController.registerErrorMessage.value = "The password provided is too weak.";

      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        _registerController.registerErrorMessage.value = "The account already exists for that email.";
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void removeDataFromTable(String screenName, String time, Map<String, int> map) async {
    collectionReference = FirebaseFirestore.instance.collection(screenName);
    await collectionReference.where("time", isEqualTo: time).get().then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((element) async {
        await element.reference.delete();
      });
      setMetadataInDatabase(map);
    });
  }

  @override
  void removeArticleFromCategory(String categoryName, reference) async {
    DocumentReference ref = reference as DocumentReference;
    collectionReference = FirebaseFirestore.instance.collection('category');
    await collectionReference.where('category-name', isEqualTo: categoryName).get().then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((QueryDocumentSnapshot categoryData) {
        List<dynamic> articleList = categoryData['articles'];
        articleList.forEachIndexed((int index, element) {
          if (element["id"] == ref.id){
            categoryData.reference.update({
              'articles': FieldValue.arrayRemove([element])
            });
          }
        });
      });
    });

  }

  @override
  Future<List<String>> searchFriend(String email) async {
    collectionReference = FirebaseFirestore.instance.collection("Users");
    var foundUser = await collectionReference.where("email", isEqualTo: email).limit(1).get();
    for (var element in foundUser.docs) {
      return [element["email"], element.id];
    }
    return ["", ""];
  }

  /// 1. To a send a message to friend or a group [sendMessage] reference the chat
  /// using [chatId].
  /// 2. A [uniqueMessageId] is created which refer the current time in milliseconds.
  /// 3. The message using the [uniqueMessageId] is added to the database.
  @override
  sendMessage(String chatId, String messageText){
    String uniqueMessageId = DateTime.now().toUtc().millisecondsSinceEpoch.toString();
    Map<String, dynamic> message = <String, dynamic>{
      "sender": auth.currentUser!.uid,
      "message": messageText,
      "time": uniqueMessageId,
      "senderName": auth.currentUser!.email
    };
    collectionReference = FirebaseFirestore.instance.collection("Chat");
    collectionReference.doc(chatId).collection("messages").doc(uniqueMessageId).set(message);
  }

  @override
  void sendReview(String review, String time, String collectionName) {
    collectionReference = FirebaseFirestore.instance.collection(collectionName);
    collectionReference.where('time', isEqualTo: time).get().then((QuerySnapshot snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.collection('reviews').add({
          'review': review,
          'sender': auth.currentUser!.email,
          'time': DateTime.now().toUtc().millisecondsSinceEpoch.toString()
        });
      }
    });
  }

  @override
  Future<Stream<List<Map<String, dynamic>>>> getReviews(String time, String collectionName) async {
    collectionReference = FirebaseFirestore.instance.collection(collectionName);
    QuerySnapshot ref = await collectionReference.where('time', isEqualTo: time).get();
    return ref.docs.first.reference.collection('reviews').snapshots().map((QuerySnapshot snapshot) {
      List<Map<String, dynamic>> reviewsList = [];
      for (var doc in snapshot.docs) {
        reviewsList.add({
          'review': doc['review'],
          'sender': doc['sender'],
          'time': doc['time'],
        });
      }
      return reviewsList;
    });
  }

  @override
  void setMetadataInDatabase(Map<String, int> metaDataMap) {
    collectionReference = FirebaseFirestore.instance.collection("metadata");
    collectionReference.doc("data").update(metaDataMap);
  }
  
  @override
  String getCurrentUserId() {
    return auth.currentUser!.uid;
  }

  @override
  StreamSubscription? currentUserStream;

  /// Get The User Data from Users Collection
  /// The Email, UserName and User Profile image are fetched and stored in
  /// [currentUserDetails] using [CurrentUserDetails.fromDocumentSnapshot]
  @override
  void getCurrentUserData() {
    collectionReference = FirebaseFirestore.instance.collection("Users");
    currentUserStream = collectionReference
        .doc(auth.currentUser!.uid)
        .snapshots()
        .map((DocumentSnapshot snapshot) async {

          currentUserDetails.value = CurrentUserDetails.fromDocumentSnapshot(snapshot);
          currentUserDetails.value.downloadUrl.value = await FirebaseStorage.instance
              .ref('uploads/${currentUserDetails.value.imageUrl}')
              .getDownloadURL();
        }).listen((event) {

        });
  }

  @override
  void uploadImage(Uint8List fileBytes, String extension) async {
    Map<String, String> imagePath = <String, String>{};
    imagePath["imageName"] = '${getCurrentUserId()}.$extension';
    collectionReference = FirebaseFirestore.instance.collection("Users");
    collectionReference.doc(getCurrentUserId()).update(imagePath);
    await FirebaseStorage.instance.ref('uploads/${getCurrentUserId()}.$extension').putData(fileBytes);
  }

  @override
  void updateUserData(Map<String, dynamic> data) {
    if (data["email"] != null && data["email"] != ""){
      auth.currentUser!.updateEmail(data["email"]);
    }
    collectionReference = FirebaseFirestore.instance.collection("Users");
    collectionReference.doc(getCurrentUserId()).update(data);
  }

  @override
  void updateTableData(String collectionName, String time, Map<String, String> newData) {
    collectionReference = FirebaseFirestore.instance.collection(collectionName);
    collectionReference.where("time", isEqualTo: time).get().then((QuerySnapshot snapshot) {
      for (var element in snapshot.docs) {
        element.reference.update(newData);
      }
    });
  }

  @override
  UploadTask uploadFile(Uint8List fileData, String fileName) {
    return  FirebaseStorage.instance.ref('uploads/articles/${fileName}').putData(fileData);
  }

  @override
  void downloadFile(String fileName)  async {
    String downloadUrl = await FirebaseStorage.instance
        .ref('uploads/articles/$fileName').getDownloadURL();

    if (kIsWeb) {
      var response = await http.get(Uri.parse(downloadUrl));
      download(Stream.fromIterable(response.bodyBytes.toList()), fileName);
    } else {
      var status = await Permission.storage.status;
      if (status.isDenied) {
        await Permission.storage.request();
      }
      if (await Permission.storage.isGranted) {

        Directory? appDocDir = await getExternalStorageDirectory();
        if (appDocDir != null) {
          Directory dir = Directory('/storage/emulated/0/Download/JocIt');
          if (! await dir.exists()) {
            dir.create();
          }
          File downloadToFile = File('${dir.path}/$fileName');

          if (! await downloadToFile.exists()) {
            downloadToFile.create();
          }

          try {
            await FirebaseStorage.instance
                .ref('uploads/articles/$fileName')
                .writeToFile(downloadToFile);
          } on FirebaseException catch (e) {
            // e.g, e.code == 'canceled'
          }
        }

      }
    }



    // Directory appDocDir = await getApplicationDocumentsDirectory();
    // File downloadToFile = File('${appDocDir.path}/$fileName');
    //
    // try {
    //   await FirebaseStorage.instance
    //       .ref('uploads/articles/$fileName')
    //       .writeToFile(downloadToFile);
    // } on FirebaseException catch (e) {
    //   // e.g, e.code == 'canceled'
    // }
  }

  @override
  Future<String> getLatestTimeStamp(String screenName) async {
    collectionReference = FirebaseFirestore.instance.collection(screenName);
    var data = await collectionReference.orderBy('time', descending: true).limit(1).get();
    return data.docs.first['time'];
  }

}