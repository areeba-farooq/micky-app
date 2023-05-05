import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:micky/secrets.dart';

class OpenAIService {
//to store our entire messages history
  final List<Map<String, String>> msgs = [];

  //we have to recognize that user wants to generate some art or not
  Future<String> isArtPromptAPI(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $openAiApiKey"
        },
        body: jsonEncode(
          {
            "model": "gpt-3.5-turbo",
            "messages": [
              {
                "role": "user",
                "content":
                    "Does this command wants to generate an AI picture, image , art or anything similar? $prompt. Simply answer with a yes or no.",
              }
            ]
          },
        ),
      );
      print(response.body);
      if (response.statusCode == 200) {
        String content =
            jsonDecode(response.body)['choices'][0]['message']['content'];
        content = content.trim();
        switch (content) {
          case 'Yes':
          case 'yes':
          case 'yes.':
          case 'Yes.':
            final res = await dallEAPI(prompt);
            return res;

          default:
            final res = await chatGPTAPI(prompt);
            return res;
        }
      }
      return 'An internal error occurred!';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    msgs.add({'role': 'user', 'content': prompt});
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $openAiApiKey"
        },
        body: jsonEncode(
          {
            "model": "gpt-3.5-turbo",
            "messages": msgs,
          },
        ),
      );
      print(response.body);
      if (response.statusCode == 200) {
        String content =
            jsonDecode(response.body)['choices'][0]['message']['content'];
        content = content.trim();
        msgs.add({
          'role': 'assistant',
          'content': content,
        });
        return content;
      }
      return 'An internal error occurred!';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> dallEAPI(String prompt) async {
    msgs.add({'role': 'user', 'content': prompt});
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $openAiApiKey"
        },
        body: jsonEncode({
          "prompt": prompt,
          "n": 1,
          // "size": "1024x1024"
        }),
      );
      print(response.body);
      if (response.statusCode == 200) {
        String imgURL = jsonDecode(response.body)['data'][0]['url'];
        imgURL = imgURL.trim();
        msgs.add({
          'role': 'assistant',
          'content': imgURL,
        });
        return imgURL;
      }
      return 'An internal error occurred!';
    } catch (e) {
      return e.toString();
    }
  }
}
