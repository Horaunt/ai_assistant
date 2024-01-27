import 'package:applications/openai_service.dart';
import 'package:flutter/material.dart';
import 'package:applications/palette.dart';
import 'package:applications/feature_box.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();

  String lastWords = '';
  final OpenAIService openAIService = OpenAIService();
  String? generatedContent;
  String? generatedImageUrl;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTexttoSpeech();
  }

  Future<void> initTexttoSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    try {
      await speechToText.initialize();
    } catch (e) {
      // Handle initialization errors
      print("SpeechToText initialization failed: $e");
    }
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
      print(lastWords);
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  void dispose() {
    speechToText.stop();
    super.dispose();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant'),
        leading: const Icon(Icons.menu),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Center(
                  child: Container(
                    height: 120,
                    width: 120,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      color: Palette.assistantCircleColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/virtualAssistant.png'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Visibility(
              visible: generatedImageUrl == null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(
                  top: 30,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Palette.borderColor,
                  ),
                  borderRadius: BorderRadius.circular(20).copyWith(
                    topLeft: Radius.zero,
                  ),
                ),
                child: Text(
                  generatedContent == null
                  ? 'Good morning, what can I do for you'
                  : generatedContent!,
                  style: TextStyle(
                    fontFamily: 'Cera Pro',
                    color: Palette.mainFontColor,
                    fontSize: generatedContent == null ? 20 : 15,
                  ),
                ),
              ),
            ),
            if(generatedImageUrl != null) Padding(
              padding: const EdgeInsets.all(10.0),
              child: ClipRRect(borderRadius: BorderRadius.circular(20),child: Image.network(generatedImageUrl!)),
            ),
            Visibility(
              visible: generatedImageUrl == null && generatedContent == null,
              child: Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(
                  top: 10,
                  left: 22,
                ),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Here are a few features',
                  style: TextStyle(
                    fontFamily: 'Cera Pro',
                    color: Palette.mainFontColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Visibility(
              visible: generatedContent == null && generatedImageUrl == null,
              child: const Column(
                children: [
                  FeatureBox(
                    color: Palette.firstSuggestionBoxColor,
                    headerText: 'ChatGPT',
                    descriptionText:
                        'A smarter way to stay organized with ChatGPT',
                  ),
                  FeatureBox(
                    color: Palette.secondSuggestionBoxColor,
                    headerText: 'Dall-E',
                    descriptionText:
                        'Get inspired and stay creative with your personal assistant powered by Dall-E',
                  ),
                  FeatureBox(
                    color: Palette.thirdSuggestionBoxColor,
                    headerText: 'Smart Voice Assistant',
                    descriptionText:
                        'Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT',
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Palette.firstSuggestionBoxColor,
        onPressed: () async {
          if (await speechToText.hasPermission && speechToText.isNotListening) {
            await startListening();
            print('started listening');
          } else if (speechToText.isListening) {
            await stopListening();
            final speech = await openAIService.isArtPromptAPI(lastWords);
            if (speech.contains('https')){
              generatedImageUrl = speech;
              generatedContent = null;
              setState(() {

              });
            } else{
              generatedImageUrl = null;
              generatedContent = speech;
              setState(() {

              });
              await systemSpeak(speech);
            }
            print('speech');

            // print(lastWords);
          } else {
            initSpeechToText();
            print('initialized speech to text');
          }
        },
        child:  Icon(speechToText.isListening ? Icons.stop : Icons.mic),
      ),
    );
  }
}
