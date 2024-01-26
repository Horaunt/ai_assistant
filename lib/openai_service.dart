import 'dart:convert';

import 'package:applications/secrets.dart';
import 'package:http/http.dart' as http;

class OpenAIService{
  Future<String> isArtPromptAPI(String prompt) async {
    try{
      final res = await http.post(Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        ' Content-type ': ' application/json ',
        ' Authorization ' : 'Bearer $openAIAPKey',
      },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages" : [{
            'role': 'user',
            'content' : 'Does this message want to generate an AI picture, image, art or anything similar?'
          }]
        })
      );
    }catch(e){
      return e.toString();
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    return 'Chat GPT API';}

  Future<String> dallEAPI(String prompt) async {
    return 'DallE API';}
}
