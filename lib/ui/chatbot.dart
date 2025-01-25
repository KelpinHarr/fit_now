import 'package:fit_now/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:iconsax/iconsax.dart';

class ChatBotPage extends StatefulWidget {
  final String email;
  const ChatBotPage({super.key, required this.email});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> with SingleTickerProviderStateMixin {
  late final  AnimationController _animationController = AnimationController(
    vsync: this,
    duration: Duration(seconds: 1),
    lowerBound: 0.25,
    upperBound: 1.0
  );

  late final _provider = GeminiProvider(
    model: GenerativeModel(
      model: 'gemini-1.5-pro', 
      apiKey: 'AIzaSyCJ64OWpDfyxn51aOM39_hpeEM9hazz7NI'
    )
  );

  void _clearHistory(){
    _provider.history = [];
  }

  @override
  void initState() {
    super.initState();
    _resetAnimation();
  }

  void _resetAnimation(){
    _animationController.value = 1.0;
    _animationController.reverse();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
            leading: IconButton(
              onPressed: (){
                Navigator.pop(context);
              }, 
              icon: Icon(
                Iconsax.arrow_left_2,
                color: white,
              )
            ),
            title: Text(
              'ChatBot',
              style: TextStyle(
                color: orange,
                fontFamily: 'ReadexPro-Medium',
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              IconButton(
                onPressed: _clearHistory, 
                icon: Icon(
                  Icons.history,
                  color: Color(0xFFe0eaf5),
                )
              )
            ],
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => Stack(
          children: [
            LlmChatView(
              provider: _provider,
              style: style,
              welcomeMessage: 'Welcome to FitNow',
            ),
          ],
        ),
      ),
    );
  }
  LlmChatViewStyle get style {
    final TextStyle textStyle = TextStyle(
      color: white,
      fontSize: 14,
      fontFamily: 'ReadexPro-Medium'
    );

    return LlmChatViewStyle(
      backgroundColor: white,
      progressIndicatorColor: darkBlue,
      chatInputStyle: ChatInputStyle(
        backgroundColor: _animationController.isAnimating
            ? Colors.transparent
            : darkBlue,
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(20)
        ),
        textStyle: TextStyle(
          color: darkBlue,
          fontFamily: 'ReadexPro-Medium',
          fontSize: 16
        ),
        hintText: 'How to do push up?',
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontFamily: 'ReadexPro-Medium',
          fontSize: 14
        ),
      ),
      userMessageStyle: UserMessageStyle(
        textStyle: TextStyle(
          color: darkBlue,
          fontFamily: 'ReadexPro-Medium',
          fontSize: 16
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade300,
              Colors.grey.shade400,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(128),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ]
        ),
      ),
      llmMessageStyle: LlmMessageStyle(
        icon: Iconsax.weight_1,
        iconColor: white,
        iconDecoration: BoxDecoration(
          color: blue,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            bottomLeft: Radius.circular(8),
            topRight: Radius.zero,
            bottomRight: Radius.circular(8),
          ),
        ),
        decoration: BoxDecoration(
          color: blue,
          borderRadius: BorderRadius.only(
            topLeft: Radius.zero,
            bottomLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(76),
              blurRadius: 8,
              offset: Offset(2, 2),
            ),
          ]
        ),
        markdownStyle: MarkdownStyleSheet(
          p: textStyle,
          listBullet: textStyle,
        )
      )
    );
  }
}