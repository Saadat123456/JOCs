import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Registration/bindings/login_bindings.dart';
import 'Registration/login.dart';
import 'firebase_options.dart';

Future<void> main() async {

  // First to make sure Flutter is Initialized WidgetsFlutterBinding.ensureInitialized() will be called
  // It is required for Firebase Initialization
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase is initialized using firebase_options.dart
  // firebase_options.dart is generated automatically by flutterfire configure command
  // It contains all the details to connect with Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  // Entry Point For App
  // Firebase will go to Login Page initially
  runApp(
      GetMaterialApp(
        /**
         * Using GetX Library for advanced State Management
         * getPages parameter is used to set all the Routes of the Application
         *
        * */
        getPages: [
          GetPage(

            /**
             * name parameter is the name That will be used to refer the page
             * page parameter contains reference to the page
             * binding parameter binds All the Services or Class Instances so
             * that we can easily recognize the page of a Class Instance
             * **/
            name: '/login',
            page: ()=>const Login(),
            binding: LoginBindings()
          )
        ],
        initialRoute: '/login',
      )
  );
}