import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fit_now/components/bottom_navbar.dart';
import 'package:fit_now/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:iconsax/iconsax.dart';

class ChatPage extends StatefulWidget {
  final String email;
  const ChatPage({super.key, required this.email});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  int _currentIndex = 2;
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _chatHistory = [];
  String? _file;

  late final GenerativeModel _model;
  late final GenerativeModel _visionModel;
  late final ChatSession _chat;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
    model: 'gemini-pro', apiKey: 'AIzaSyCJ64OWpDfyxn51aOM39_hpeEM9hazz7NI');
    _visionModel = GenerativeModel(
    model: 'gemini-pro-vision', apiKey: 'AIzaSyCJ64OWpDfyxn51aOM39_hpeEM9hazz7NI');
    _chat = _model.startChat();
    super.initState();
  }

  void getAnswer(text) async {
    late final response;
    if (_file != null){
      final firstImage = await (File(_file!).readAsBytes());
      final prompt = TextPart(text);
      final imageParts = [
        DataPart('image/jpeg', firstImage)
      ];
      response = await _visionModel.generateContent([
        Content.multi([prompt, ...imageParts])
      ]);

      _file = null;
    }
    else {
      var content = Content.text(text.toString());
      response = await _chat.sendMessage(content);
    }

    setState(() {
      _chatHistory.add({
      "time": DateTime.now(),
      "message": response.text,
      "isSender": false,
      "isImage": false
      });
      _file = null;
    });

    _scrollController.jumpTo(
      _scrollController.position.maxScrollExtent
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: Container(
          decoration: BoxDecoration(
            color: darkBlue,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: AppBar(
            title: Center(
              child: Text(
                'ChatBot',
                style: TextStyle(
                  color: orange,
                  fontFamily: 'ReadexPro-Medium',
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      backgroundColor: white,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height - 160,
              child: ListView.builder(
                itemCount: _chatHistory.length,
                shrinkWrap: true,
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                itemBuilder: (context, index){
                  return Container(
                    padding: EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
                    child: Align(
                      alignment: (_chatHistory[index]['isSender'] ? Alignment.topRight : Alignment.topLeft),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3)
                            )
                          ],
                          color: (_chatHistory[index]['isSender'] ? orange : white)
                        ),
                        padding: EdgeInsets.all(16),
                        child: _chatHistory[index]['isImage'] 
                            ? Image.file(File(_chatHistory[index]['message']), width: 200) 
                            : Text(_chatHistory[index]['message'],
                                style: TextStyle(
                                  fontSize: 15,
                                  color: _chatHistory[index]['isSender'] ? Colors.white : Colors.black
                                ),
                              )
                      ),
                    ),
                  );
                }
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                height: 60,
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  children: [
                    MaterialButton(
                      onPressed: () async {
                        FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['jpg', 'jpeg', 'png'],
                        );
                        if (result != null) {
                          setState(() {
                            _file = result.files.first.path;
                          });
                        }
                      },
                      minWidth: 42,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(80.0),
                      ),
                      padding: EdgeInsets.all(0),
                      child: Ink(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFF69170),
                              Color(0xFF7D96E6)
                            ]
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(30))
                        ),
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 42,
                            minHeight: 36
                          ),
                          alignment: Alignment.center,
                          child: Icon(_file == null ? Icons.image : Icons.check, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: GradientBoxBorder(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFF69170),
                                Color(0xFF7D96E6),
                              ]
                            )
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(50))
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Type a message',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(8)
                            ),
                            controller: _chatController,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 4,),
                    MaterialButton(
                      onPressed: (){
                        setState(() {
                          if (_chatController.text.isNotEmpty) {
                            if (_file != null){
                              _chatHistory.add({
                                "time": DateTime.now(),
                                "message": _file,
                                "isSender": true,
                                "isImage": true
                            });
                          }
                        
                          _chatHistory.add({
                            "time": DateTime.now(),
                            "message": _chatController.text,
                            "isSender": true,
                            "isImage": false
                            });
                          }
                          });
                          
                          _scrollController.jumpTo(
                          _scrollController.position.maxScrollExtent,
                          );

                          getAnswer(_chatController.text);
                          _chatController.clear();
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80)),
                      padding: EdgeInsets.all(0),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFF69170),
                              Color(0xFF7D96E6),
                            ]
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(50))
                        ),
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 88.0, minHeight: 36.0),
                          alignment: Alignment.center,
                          child: const Icon(Icons.send, color: Colors.white,)
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        )
      ),
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              _currentIndex = 2;
            });
          },
          backgroundColor: darkBlue,
          child: Icon(
            Iconsax.messages_1, 
            color: _currentIndex == 2 ? orange : white,
            size: 35,
          ),
          shape: CircleBorder(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex, 
        onTabSelected: (index){
          setState(() {
            _currentIndex = index;
          });
        },
        selectedColor: orange,
        unselectedColor: white,
        backgroundColor: darkBlue,
        email: widget.email,
      )
    );
  }
}