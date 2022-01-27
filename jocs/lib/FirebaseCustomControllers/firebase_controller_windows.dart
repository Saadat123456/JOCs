import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firedart/auth/exceptions.dart';
import 'package:firedart/auth/firebase_auth.dart';
import 'package:firedart/auth/user_gateway.dart';
import 'package:firedart/firestore/firestore.dart';
import 'package:firedart/firestore/models.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:jocs/FirebaseCustomControllers/ChatModels/person_model.dart';
import 'package:jocs/FirebaseCustomControllers/ChatModels/user_chat_model.dart';
import 'package:jocs/FirebaseCustomControllers/DataModels/article_category.dart';
import 'package:jocs/FirebaseCustomControllers/FirebaseInterface/firebase_controller_interface.dart';
import 'package:jocs/Registration/Controllers/hive_store.dart';
import 'package:jocs/Registration/Controllers/login_controller_windows.dart';
import 'package:jocs/Registration/Controllers/register_controller_windows.dart';

import 'ChatModels/user_details_model.dart';

class FirebaseControllerWindows implements FirebaseControllerInterface{

  @override
  late FirebaseAuth auth;
  late Firestore firestore;
  late LoginControllerWindows _loginController;
  late RegisterControllerWindows _registerControllerWindows;

  @override
  List<StreamSubscription> chatScreenMainStreams = [];

  FirebaseControllerWindows(){
    initializeFirebase();
  }

  @override
  void addArticleCategory(Map<String, String> data, String collectionName) async {
    var reference = firestore.collection(collectionName);
    await reference.add(data);
  }

  @override
  Future<void> addDataToFirebase(data, String collectionName) async {
    var reference = firestore.collection(collectionName);
    data["id"] = await getLastId(collectionName);
    var docReference = await reference.add(data);
  }

  @override
  Future<void> addFriend(List friendData) async {
    String friendUniqueId = DateTime.now().toUtc().millisecondsSinceEpoch.toString() + auth.userId;
    var tempData = <String, dynamic>{};
    tempData["chatId"] = friendUniqueId;
    tempData["unread"] = [];
    tempData["friendName"] = friendData[0];
    var reference = firestore.collection('Users');
    reference.document(auth.userId)
        .collection("Friends")
        .document(friendData[1])
        .set(tempData)
        .then((value) async {
          User user = await auth.getUser();
          tempData["chatId"] = friendUniqueId;
          tempData["unread"] = [];
          tempData["friendName"] = user.email;
          var reference = firestore.collection('Users');
          reference.document(friendData[1])
              .collection("Friends")
              .document(auth.userId)
              .set(tempData)
              .then((value){
                createNewChat(friendUniqueId);
              })
              .catchError((error) => print("Failed to add Group: $error"));
        })
        .catchError((error) => print("Failed to add Group: $error"));
  }

  @override
  Future<void> addFriendToGroup(List friendData, String groupId, String groupName) async {
    var tempData = <String, dynamic>{};
    tempData["chatId"] = groupId;
    tempData["unread"] = [];
    tempData["groupName"] = groupName;
    var reference = firestore.collection('Users');
    reference.document(friendData[1])
        .collection("Groups")
        .document(groupId).set(tempData)
        .then((value) => print("Friend Added"))
        .catchError((error) => print("Failed to add Friend to group $error"));
  }

  @override
  bool checkFirebaseLoggedIn() {
    if (auth.isSignedIn){
      return true;
    }
    return false;
  }

  createChatListener(String collectionName){
    var reference = firestore.collection('Users');
    reference.document(auth.userId).collection(collectionName).get().then((docs){
      for (var element in docs) {
        chatScreenMainStreams.add(reference.document(auth.userId)
            .collection(collectionName)
            .document(element.id)
            .stream
            .listen((document) {
              print(document);
            })
            );
      }
    });

  }

  @override
  void createNewArticle(Map<String, String> data) {
    // TODO: implement createNewArticle
  }

  @override
  Future<void> createNewChat(id) async {
    var reference = firestore.collection('Chat');
    reference
        .document(id)
        .set(<String, dynamic>{})
        .then((value){
          print("Chat Created");
        })
        .catchError((error) => print("Failed to add Chat Id: $error"));
  }

  @override
  Future<void> createNewGroup(groupData) async {
    String groupUniqueId = DateTime.now().toUtc().millisecondsSinceEpoch.toString() + auth.userId;
    groupData["chatId"] = groupUniqueId;
    groupData["unread"] = [];
    var reference = firestore.collection('Users');
    reference
        .document(auth.userId)
        .collection("Groups")
        .document(groupUniqueId)
        .set(groupData)
        .then((value){
          print("Group Created");
          createNewChat(groupUniqueId);
        })
        .catchError((error) => print("Failed to add Group: $error"));
  }

  @override
  Stream<List<PersonModel>> friendListStream() {
    var reference = firestore.collection('Users');

    return reference
        .document(auth.userId)
        .collection("Friends")
        .stream.map((List<Document> documents){
          List<PersonModel> retVal = [];
          for (Document document in documents){
            retVal.add(PersonModel(chatId: document["chatId"], unreadMessages: document["unread"], modelId: document.id, modelName: document["friendName"], modelType: "Friend"));
          }
          return retVal;
        });
  }

  @override
  Stream<List<ArticleCategory>> getCategoryData(){
    var reference = firestore.collection('category');
    return reference.stream.map((List<Document> documents){
      List<ArticleCategory> retVal = [];
      for (Document document in documents){
        retVal.add(ArticleCategory(document["category-name"], document["description"]));
      }
      return retVal;
    });
  }
  @override
  Future<List<MessageModel>> getChat(String chatId, [MessageModel? lastMessage]) async {
    List<MessageModel> temp = [];
    var collectionReference = firestore.collection("Chat");
    if (lastMessage!=null){
      await collectionReference.document(chatId)
          .collection("messages")
          .where("time", isLessThan:lastMessage.timeStamp)
          .orderBy("time", descending: true)
          .limit(2)
          .get()
          .then((documents){
            for (var element in documents) {
              print(element["message"]);
              temp.add(MessageModel(element["message"], element["sender"], element["time"], element["senderName"]));
            }
          });
    }else{
      await collectionReference.document(chatId)
          .collection("messages")
          .orderBy("time", descending: true)
          .limit(2)
          .get()
          .then((documents){
            for (var element in documents) {
              print(element["message"]);
              temp.add(MessageModel(element["message"], element["sender"], element["time"], element["senderName"]));
            }
          });
    }

    return temp;
  }

  @override
  Future<int> getDashboardData(String documentName, {String filter = ""}) async {
    var collectionReference = firestore.collection("tickets");
    List<Document> tempData;
    if (filter == ""){
      tempData = await collectionReference.where(documentName, isEqualTo: filter).get();
    }else{
      tempData = await collectionReference.orderBy(documentName, descending: true).get();
    }
    print(documentName+ "${tempData.length}");
    return tempData.length;
  }

  @override
  getData(String collectionName, int page, int length, {String filter = "", Map<String, String> customFilter = const <String, String>{}}) async {
    var collectionReference = firestore.collection(collectionName);
    List<Document> data = <Document>[];
    if (page > 1) {
      data = await collectionReference.orderBy("time", descending: true).where("time", isLessThan: filter).limit(length).get();
    } else {
      data = await collectionReference.orderBy("time", descending: true).limit(length).get();
    }
    print(data.first.map);
    var returnData = [];
    for (var element in data) {
      returnData.add(element.map);
    }
    return returnData;
  }

  @override
  Future<int> getLastId(String collectionName) async {
    int lastId = 1;
    var collectionReference = firestore.collection(collectionName);
    var dataTemp = await collectionReference.orderBy("time", descending: true).limit(1).get();
    for (var doc in dataTemp) {
      lastId = doc.map["id"];
      lastId += 1;
    }
    return lastId;
  }

  @override
  Future<List<MessageModel>> getRecentChat(String chatId, String mostRecentMessageTimeStamp) async {
    List<MessageModel> temp = [];
    var collectionReference = firestore.collection("Chat");
    await collectionReference
        .document(chatId)
        .collection("messages")
        .where("time", isGreaterThan:mostRecentMessageTimeStamp)
        .orderBy("time", descending: true).get().then((value){
          for (var element in value) {
            print(element["message"]);
            temp.add(MessageModel(element["message"], element["sender"], element["time"], element["senderName"]));
          }
        });
    return temp;
  }

  @override
  Stream<List<PersonModel>> groupListStream() {
    var reference = firestore.collection('Users');

    return reference
        .document(auth.userId)
        .collection("Groups")
        .stream.map((List<Document> documents){
      List<PersonModel> retVal = [];
      for (Document document in documents){
        retVal.add(PersonModel(chatId: document["chatId"], unreadMessages: document["unread"], modelId: document.id, modelName: document["groupName"], modelType: "Friend"));
      }
      return retVal;
    });
  }

  @override
  initializeFirebase() async {
    var path = Directory.current.path;
    Hive
        .init(path);
    try {
      Hive.registerAdapter(TokenAdapter());
    }on HiveError catch(e){
      print(e.message);
    }

    try {
      auth = FirebaseAuth.initialize('AIzaSyBqcQEfEXhRUn2Bn4900aOP7BZfxphsKss', await HiveStore.create());
      firestore = Firestore("jocit-b0c8a", auth: auth);
    }on Exception catch (e){
      print("Already Initialized");
    }
  }

  @override
  initializeLoginController(){
    _loginController = Get.find<LoginControllerWindows>();
    _loginController.initializeLogin();
  }

  @override
  initializeRegisterController(){
    _registerControllerWindows = Get.find<RegisterControllerWindows>();
  }

  @override
  login(String email, String password) async {
    try {
      await FirebaseAuth.instance.signIn(email, password);
    }on AuthException catch (e){
      print(e.message);
      if (e.message == 'EMAIL_NOT_FOUND') {
        print('No user found for that email.');
        _loginController.loginErrorMessage.value = 'No user found for that email.';
      } else if (e.message == 'INVALID_PASSWORD') {
        print('Wrong password provided for that user.');
        _loginController.loginErrorMessage.value = 'Wrong password provided for that user.';
      }
    }
    if (FirebaseAuth.instance.isSignedIn){
      Get.toNamed("/dashboard");
    }
  }

  @override
  void newChatListener() {
    var collectionReference = firestore.collection("Users");
    createChatListener("Friends");
    createChatListener("Groups");
  }

  @override
  register(String username, String email, String password) async {
    try {
      User user = await FirebaseAuth.instance.signUp(email, password);
      var reference = firestore.collection('Users');
      var docReference = await reference.add(user.toMap());
    }on AuthException catch(e){
      _registerControllerWindows.registerErrorMessage.value = e.message;
    }

  }

  @override
  Future<List<String>> searchFriend(String email) async {
    var collectionReference = firestore.collection("Users");
    var foundUser = await collectionReference.where("email", isEqualTo: email).limit(1).get();
    for (var element in foundUser) {
      return [element["email"], element.id];
    }
    return ["", ""];
  }

  @override
  void sendMessage(String chatId, String messageText) async {
    String uniqueMessageId = DateTime.now().toUtc().millisecondsSinceEpoch.toString();
    User user = await auth.getUser();
    Map<String, dynamic> message = <String, dynamic>{
      "sender": auth.userId,
      "message": messageText,
      "time": uniqueMessageId,
      "senderName": user.email
    };
    var collectionReference = firestore.collection("Chat");
    collectionReference.document(chatId).collection("messages").document(uniqueMessageId).set(message);
  }

  @override
  String getCurrentUserId() {
    return auth.userId;
  }

  @override
  void getCurrentUserData() {
    // TODO: implement getCurrentUserData
  }

  @override
  CurrentUserDetails currentUserDetails = CurrentUserDetails(userId: "", email: "", username: "");

  @override
  void uploadImage(Uint8List fileBytes, String extension) {
    // TODO: implement uploadImage
  }

  @override
  void updateUserData(Map<String, dynamic> data) {
    // TODO: implement updateUserData
  }

}