// ignore_for_file: file_names, prefer_const_constructors, avoid_print, unnecessary_string_interpolations, annotate_overrides, no_logic_in_create_state

import 'dart:convert';
import 'package:final_project/PostDetail.dart';
import 'package:final_project/createPost.dart';
import 'package:final_project/cubit/main_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class PostPage extends StatefulWidget {
  const PostPage({Key? key, required this.channel}) : super(key: key);
  final WebSocketChannel channel;

  State<StatefulWidget> createState() {
    return _PostPageState(channel);
  }
}

class _PostPageState extends State<PostPage> {
  _PostPageState(this.channel);
  WebSocketChannel channel;
  TextEditingController name = TextEditingController();
  bool isFavorite = false;
  bool favouriteClicked = false;

  List posts = [];
  List favoritePosts = [];

  void getPosts() {
    channel.stream.listen((message) {
      final decodedMessage = jsonDecode(message);
      setState(() {
        posts = decodedMessage['data']['posts'];
      });
      channel.sink.close();
    });

    channel.sink.add('{"type": "get_posts"}');
  }

  // sortDate() {
  //   for (int i = 0; i >= posts.length; i++) {}
  // }

  @override
  void initState() {
    super.initState();
    getPosts();
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MainCubit(),
      child: Scaffold(
        drawer: Drawer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 200,
                color: Colors.grey,
                child: Image.network(
                    'https://img.rawpixel.com/s3fs-private/rawpixel_images/website_content/rm168-adj-27b.jpg?w=1000&dpr=1&fit=default&crop=default&q=65&vib=3&con=3&usm=15&bg=F4F4F3&ixlib=js-2.2.1&s=2007e7ebd87a87c042993f595f9d1eb7'),
              ),
            ],
          ),
        ),
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    if (favouriteClicked == true) {
                      favouriteClicked = false;
                    } else {
                      favouriteClicked = true;
                    }
                  });
                },
                icon: Icon(Icons.favorite)),
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => CreatePost(channel: channel)));
              },
              icon: Icon(Icons.add_comment_outlined),
            ),
            IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return BlocProvider(
                        create: (context) => MainCubit(),
                        child: BlocBuilder<MainCubit, String>(
                          builder: (context, state) {
                            return AlertDialog(
                              title: const Text(
                                "About Us",
                                style: TextStyle(color: Colors.cyan),
                              ),
                              content: Text(
                                  "View list of postcards. Create your own and post je la."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Ok"),
                                )
                              ],
                            );
                          },
                        ),
                      );
                    });
              },
              icon: Icon(Icons.person),
            ),
          ],
          title: Center(
            child: Text(
              'Degenerates',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ),
          backgroundColor: Colors.cyan,
        ),
        body: (favouriteClicked == false)
            ? BlocBuilder<MainCubit, String>(
                builder: (context, index) {
                  print(posts.length);
                  return ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 20.0,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PostDetails(
                                    name: posts[index]['author'],
                                    title: posts[index]['title'],
                                    description: posts[index]['description'],
                                    url: posts[index]['image'],
                                  ),
                                ),
                              );
                              // Move to post details page
                            },
                            onLongPress: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return BlocProvider(
                                      create: (context) => MainCubit(),
                                      child: BlocBuilder<MainCubit, String>(
                                        builder: (context, state) {
                                          return AlertDialog(
                                            title: const Text("Delete Post"),
                                            content: Column(
                                              // ignore: prefer_const_literals_to_create_immutables
                                              children: [
                                                TextFormField(
                                                  controller: name,
                                                ),
                                                Text(
                                                    "Do you want to delete this post?"),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    context
                                                        .read<MainCubit>()
                                                        .delete(posts[index]
                                                            ['_id']);

                                                    Navigator.of(context).pop();
                                                  });
                                                },
                                                child: Text('Delete'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text("Cancel"),
                                              )
                                            ],
                                          );
                                        },
                                      ),
                                    );
                                  });
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.cyan.shade50,
                                    borderRadius: BorderRadius.circular(20)),
                                padding: EdgeInsets.all(10.0),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(Uri.parse(
                                                    posts[index]['image'])
                                                .isAbsolute &&
                                            posts[index].containsKey('image')
                                        ? '${posts[index]['image']}'
                                        : 'https://i1.sndcdn.com/avatars-oD4sdrytOwNUI6ls-MsjKNA-t240x240.jpg'),
                                  ),
                                  title: Text(
                                    '${posts[index]["title"].toString().characters.take(20)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                      'Created by ${posts[index]["author"].toString().characters.take(15)} on ${posts[index]["date"].toString().characters.take(10)}'),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      FavoriteButton(
                                          iconSize: 70.0,
                                          valueChanged: (isFavorite) {
                                            setState(() {
                                              isFavorite = true;
                                              if (favoritePosts
                                                  .contains(posts[index])) {
                                                favoritePosts
                                                    .remove(posts[index]);
                                                print('item already added');
                                              } else {
                                                favoritePosts.add(posts[index]);
                                              }
                                              print(favoritePosts);
                                            });
                                          }),
                                    ],
                                  ),
                                )),
                          ),
                        );
                      });
                },
              )
            : BlocBuilder<MainCubit, String>(
                builder: (context, state) {
                  return ListView.builder(
                      itemCount: favoritePosts.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 10.0,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PostDetails(
                                    name: posts[index]['author'],
                                    title: posts[index]['title'],
                                    description: posts[index]['description'],
                                    url: posts[index]['image'],
                                  ),
                                ),
                              );
                              // Move to post details page
                            },
                            onLongPress: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return BlocProvider(
                                      create: (context) => MainCubit(),
                                      child: BlocBuilder<MainCubit, String>(
                                        builder: (context, state) {
                                          return AlertDialog(
                                            title: const Text("Delete Post"),
                                            content: Text(
                                                "Do you want to delete this post?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    context.read().delete(
                                                        posts[index]['_id']);

                                                    Navigator.of(context).pop();
                                                  });
                                                },
                                                child: Text('Delete'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text("Cancel"),
                                              )
                                            ],
                                          );
                                        },
                                      ),
                                    );
                                  });
                            },
                            child: Container(
                                padding: EdgeInsets.all(10.0),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(Uri.parse(
                                                    posts[index]['image'])
                                                .isAbsolute &&
                                            posts[index].containsKey('image')
                                        ? '${posts[index]['image']}'
                                        : 'https://image.freepik.com/free-vector/bye-bye-cute-emoji-cartoon-character-yellow-backround_106878-540.jpg'),
                                  ),
                                  title: Text(
                                    '${posts[index]["title"].toString().characters.take(20)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                      'Created by ${posts[index]["author"].toString().characters.take(15)} on ${posts[index]["date"].toString().characters.take(10)}'),
                                )),
                          ),
                        );
                      });
                },
              ),
      ),
    );
  }
}
