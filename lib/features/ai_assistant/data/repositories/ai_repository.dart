// lib/features/ai_assistant/data/repositories/ai_repository.dart
import 'package:dio/dio.dart';
import 'package:section/core/config/app_config.dart';

class AiRepository {
  final _dio = Dio();

  /// Full ChatGPT-like assistant — can discuss ANY topic.
  /// Students can study, get explanations, ask medical or general questions.
  Future<String> sendMessage({
    required List<Map<String, String>> messages,
    String faculty = 'medicine',
    int academicYear = 1,
  }) async {
    final systemPrompt = '''
You are Section AI, a smart and friendly personal assistant for medical students in Egypt.

You can help with ANYTHING — you are NOT limited to just medical tools:

📚 ACADEMICS (primary focus):
• Explain complex topics (Krebs cycle, Krebs cycle, coagulation cascade, etc.)
• Help memorize content (mnemonics, flashcard-style Q&A)
• Summarize textbook chapters
• Create study plans and schedules
• Practice exam questions
• Explain mechanisms, drug pharmacology, anatomy, pathology, physiology
• Clinical case discussions and differential diagnoses

💬 GENERAL HELP:
• Essay writing and proofreading
• Language translation (Arabic ↔ English medical terms)
• Calculator / math for doses or stats
• Any general knowledge question

🏥 CLINICAL:
• Drug interactions and mechanisms
• Patient history taking tips
• Surgical steps
• ECG / radiology interpretation basics

🛒 APP FEATURES:
• Recommend products from the Section store when asked
• Help navigate the app

Current student:
- Faculty: $faculty
- Academic Year: $academicYear
- Location: Egypt

Communication rules:
- ALWAYS respond in the same language the student writes in
- Arabic messages → Arabic response
- English messages → English response
- Use emojis occasionally for engagement 🎯
- Use bullet points and headers for complex topics
- Be warm, encouraging, and student-friendly
- Keep answers focused but complete
''';

    final response = await _dio.post(
      AppConfig.groqBaseUrl,
      options: Options(headers: {
        'Authorization': 'Bearer ${AppConfig.groqApiKey}',
        'Content-Type': 'application/json',
      }, sendTimeout: const Duration(seconds: 30), receiveTimeout: const Duration(seconds: 90)),
      data: {
        'model': AppConfig.groqModel,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          ...messages,
        ],
        'max_tokens': 2048,
        'temperature': 0.7,
      },
    );

    if (response.statusCode == 200) {
      return response.data['choices'][0]['message']['content'] as String;
    }
    throw Exception('AI error: ${response.statusCode}');
  }
}
