// ignore_for_file: camel_case_types, avoid_print, prefer_const_constructors, unnecessary_null_comparison, unrelated_type_equality_checks

import 'package:final_project/PostDetail.dart';
import 'package:final_project/cubit/main_cubit.dart';
import 'package:final_project/postPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_socket_channel/io.dart';
import 'package:final_project/aboutPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/postdetails': (context) => PostDetails(
              url: '',
              name: '',
              title: '',
              description: '',
            ),
      },
      debugShowCheckedModeBanner: false,
      title: 'Final Mobile Project',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: BlocProvider(
        create: (context) => MainCubit(),
        child: signInPage(),
      ),
    );
  }
}

class signInPage extends StatefulWidget {
  const signInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<signInPage> {
  TextEditingController username = TextEditingController();
  final channel =
      IOWebSocketChannel.connect('ws://besquare-demo.herokuapp.com');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.purple,
        child: Column(
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            const Padding(
              padding: EdgeInsets.all(50.0),
              child: Text(
                'Degenerates',
                style: TextStyle(
                  fontSize: 50,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                    child: Container(
                      color: Colors.white,
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        controller: username,
                        decoration: const InputDecoration(
                          hintText: 'Username',
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      (username.text.isEmpty)
                          ? {print('username is empty')}
                          : {
                              _signInUser(),
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          PostPage(channel: channel)))
                            };
                    },
                    child: const Text(
                      'Sign-In',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _signInUser() {
// Sending user sign in request
    context.read<MainCubit>().login(username.text);
  }
}
