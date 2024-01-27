import 'dart:convert';

import 'package:applications/secrets.dart';
import 'package:http/http.dart' as http;

class OpenAIService{
  final List<Map<String, String>> messages = [];
  Future<String> isArtPromptAPI(String prompt) async {
    try{
      final res = await http.post(Uri.parse('https://api.openai.com/v1/chat/completions'),
          headers: {
            'Content-type': 'application/json',
            'Authorization': 'Bearer $openAIAPKey',
          },

          body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages" : [{
            'role': 'user',
            'content' : 'Does this message want to generate an AI picture, image, art or anything similar? $prompt .Simply answer with a yes or a no.'
          }]
        })
      );
      print(res.body);
      if (res.statusCode == 200) {
        String content = jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();
        print(content);
        switch(content) {
          case 'yes':
          case 'Yes':
          case 'YES':
          case 'y':
          case 'yes.':
          case 'Yes.':
            final dallEResponse = await dallEAPI(prompt);
            return dallEResponse;

          default:
            final res = await chatGPTAPI(prompt);
            return res;
        }
      } else {
        print('Request failed with status: ${res.statusCode}');
        print(res.body);
      }

      return "An internal error occurred.";
    }catch(e){
      print("Error in isArtPromptAPI: $e");
      return e.toString();
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try{
      final res = await http.post(Uri.parse('https://api.openai.com/v1/chat/completions'),
          headers: {
            'Content-type': 'application/json',
            'Authorization': 'Bearer $openAIAPKey',
          },

          body: jsonEncode({
            "model": "gpt-3.5-turbo",
            "messages" : messages,
          })
      );

      if (res.statusCode == 200) {
        String content = jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();

        messages.add({
          'role': 'assistant',
          'content': content,
        });
        return content;
      } else {
        print('Request failed with status: ${res.statusCode}');
        print(res.body);
      }

      return "An internal error occurred.";
    }catch(e){
      print("Error in isArtPromptAPI: $e");
      return e.toString();
    }
  }

  Future<String> dallEAPI(String prompt) async {
    return 'DallE API';}
}
