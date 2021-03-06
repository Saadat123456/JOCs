import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:jocs/Registration/Controllers/login_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:jocs/Registration/Interfaces/login_controller_interface.dart';

import 'Controllers/login_controller_windows.dart';

/// [Login] A widget that paints the Login Screen
/// It contains simple form with two input fields
/// When Login is pressed User is Logged in to
/// Firebase Account (If Account Exists)
class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

/// The State of [Login] Screen is Controlled By [LoginControllerInterface]
/// The Login Controller for Windows is [LoginControllerWindows]
/// The Login Controller for Other Devices is [LoginController]
class _LoginState extends State<Login> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  late var _loginController;

  final _formKey = GlobalKey<FormState>();

  /// The [LoginControllerInterface] is initialized based on the Platform
  @override
  void initState() {
    super.initState();
    if (defaultTargetPlatform == TargetPlatform.windows && !kIsWeb){
      _loginController = Get.find<LoginControllerWindows>();
    }else {
      _loginController = Get.find<LoginController>();
    }
  }

  /// The [TextEditingController]s are disposed to prevent any memory leak
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
              'JOC',
            style: Theme.of(context).textTheme.headline4,
          ),
        ),
        body: SafeArea(
          child: Container(
            height: double.infinity,
            width: double.infinity,
            child: Form(
              key: _formKey,
              child: Center(
                /// The [SingleChildScrollView] make sure that the Login
                /// Form Always remain in the view even if screen is very small.
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  controller: ScrollController(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 350,
                          child: TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter Your Email',
                            ),

                            /// Validator Checks if User entered a Valid Email
                            /// The [GetUtils.isEmail] is a GetX Library Function
                            validator: (value){
                              if (GetUtils.isEmail(value!)){
                                return null;
                              }
                              return 'Enter a valid email address';
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 350,
                          child: TextFormField(
                            obscureText: true,
                            enableSuggestions: false,
                            autocorrect: false,
                            controller: passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter Password'
                            ),

                            /// Validator Checks if User entered a Valid Password
                            /// If Password Length is Greater than or Equal to 8
                            /// than user can login
                            validator: (value){
                              if (value!.isEmpty) {
                                return 'Please enter password';
                              } else {
                                if (value.length < 8){
                                  return 'Password must contain at least 8 characters';
                                }else {
                                  return null;
                                }
                              }
                            },

                          ),
                        ),
                      ),

                      Container(
                        margin: const EdgeInsets.only(top: 32.0),
                        child: TextButton(
                          /// The [onPressed] parameter controls the login after
                          /// getting user Details.
                          onPressed: () {
                            /// The details entered by the user are First
                            /// Validated.
                            /// [_formKey.currentState!.validate()] run
                            /// validator for each [TextFormField]
                            if (_formKey.currentState!.validate()){
                              String email = emailController.text;
                              String password = passwordController.text;
                              /// To Login [login] defined in
                              /// [LoginController] or [LoginControllerWindows]
                              /// is called passing the necessary
                              /// details
                              _loginController.login(email, password);
                              emailController.clear();
                              passwordController.clear();
                            }

                          },
                          child: Text(
                              "Login",
                            style: Theme.of(context).textTheme.bodyText1,
                          ),

                        ),
                      ),
                      // Container(
                      //   margin: const EdgeInsets.only(top:32.0),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.center, //Center Row contents horizontally,
                      //     crossAxisAlignment: CrossAxisAlignment.center, //Center Row contents vertically,
                      //     children: [
                      //       Padding(
                      //         padding: const EdgeInsets.all(8.0),
                      //         child: Text("Do not have account?", style: Theme.of(context).textTheme.bodyText2,),
                      //       ),
                      //       TextButton(
                      //         /// If a User want to create a new account than
                      //         /// [Get.offNamed('/register')] will take the user
                      //         /// to Registration Screen
                      //         onPressed: () => Get.offNamed('/register'),
                      //         child: Text("Register", style: Theme.of(context).textTheme.bodyText1,),
                      //       )
                      //     ],
                      //   ),
                      // ),
                      Obx( () => Container(
                          margin: const EdgeInsets.only(top: 32.0),
                          child: _loginController.loginErrorMessage == "" ?  const SizedBox(width: 0, height: 0):Container(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "${_loginController.loginErrorMessage}",
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                            ),
                          ),
                        ),
                      )

                    ],
                  ),
                ),
              ),
            ),
          ),
        )

    );
  }
}

