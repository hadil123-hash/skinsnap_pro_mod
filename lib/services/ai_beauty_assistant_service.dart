import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class AiBeautyAssistantService {
  static const String _geminiApiKey = 'AIzaSyDu6pUhvqHvz-gT1RNBYDjxe0zyH3h0xA4';
  static const String _model = 'gemini-1.5-flash';

  bool get hasApiKey {
    return _geminiApiKey.trim().isNotEmpty &&
        !_geminiApiKey.contains('COLLE_TA_CLE');
  }

  Future<String> answer({
    required String message,
    required String languageCode,
    List<Map<String, String>> history = const [],
  }) async {
    final cleanMessage = message.trim();

    if (cleanMessage.isEmpty) {
      return _emptyAnswer(languageCode);
    }

    if (!hasApiKey) {
      return _fallback(cleanMessage, languageCode);
    }

    try {
      final geminiAnswer = await _callGemini(
        message: cleanMessage,
        languageCode: languageCode,
        history: history,
      );

      if (geminiAnswer.trim().isNotEmpty) {
        return geminiAnswer.trim();
      }

      return _fallback(cleanMessage, languageCode);
    } on TimeoutException {
      return _apiTimeout(languageCode);
    } catch (_) {
      return _fallback(cleanMessage, languageCode);
    }
  }

  Future<String> _callGemini({
    required String message,
    required String languageCode,
    required List<Map<String, String>> history,
  }) async {
    final uri = Uri.https(
      'generativelanguage.googleapis.com',
      '/v1beta/models/$_model:generateContent',
      {'key': _geminiApiKey.trim()},
    );

    final body = {
      'systemInstruction': {
        'parts': [
          {'text': _systemPrompt(languageCode)}
        ],
      },
      'contents': [
        ..._buildHistory(history),
        {
          'role': 'user',
          'parts': [
            {'text': message}
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.7,
        'topP': 0.9,
        'topK': 40,
        'maxOutputTokens': 900,
      },
      'safetySettings': [
        {
          'category': 'HARM_CATEGORY_HARASSMENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
        },
        {
          'category': 'HARM_CATEGORY_HATE_SPEECH',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
        },
        {
          'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
        },
        {
          'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
        },
      ],
    };

    final response = await http
        .post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    )
        .timeout(const Duration(seconds: 25));

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Clé Gemini invalide ou non autorisée.');
    }

    if (response.statusCode == 404) {
      throw Exception('Modèle Gemini introuvable.');
    }

    if (response.statusCode == 429) {
      return _rateLimitMessage(languageCode);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erreur Gemini ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Réponse Gemini invalide.');
    }

    final candidates = decoded['candidates'];

    if (candidates is! List || candidates.isEmpty) {
      if (decoded['promptFeedback'] != null) {
        return _blockedMessage(languageCode);
      }

      throw Exception('Aucune réponse Gemini.');
    }

    final firstCandidate = candidates.first;

    if (firstCandidate is! Map<String, dynamic>) {
      throw Exception('Candidat Gemini invalide.');
    }

    if (firstCandidate['finishReason']?.toString() == 'SAFETY') {
      return _blockedMessage(languageCode);
    }

    final content = firstCandidate['content'];

    if (content is! Map<String, dynamic>) {
      throw Exception('Contenu Gemini invalide.');
    }

    final parts = content['parts'];

    if (parts is! List || parts.isEmpty) {
      throw Exception('Réponse Gemini vide.');
    }

    final text = parts.map((part) {
      if (part is Map<String, dynamic>) {
        return part['text']?.toString() ?? '';
      }

      return '';
    }).join('\n').trim();

    if (text.isEmpty) {
      throw Exception('Texte Gemini vide.');
    }

    return text;
  }

  List<Map<String, dynamic>> _buildHistory(List<Map<String, String>> history) {
    final cleanedHistory = history.where((item) {
      final text = item['text']?.trim() ?? '';
      return text.isNotEmpty;
    }).toList();

    final lastMessages = cleanedHistory.length > 10
        ? cleanedHistory.sublist(cleanedHistory.length - 10)
        : cleanedHistory;

    return lastMessages.map((item) {
      final role = item['role'] == 'assistant' ? 'model' : 'user';

      return {
        'role': role,
        'parts': [
          {'text': item['text'] ?? ''}
        ],
      };
    }).toList();
  }

  String _systemPrompt(String languageCode) {
    final language = _languageName(languageCode);

    return '''
You are SkinSnap Assistant, a professional assistant inside a skincare, makeup and beauty mobile application.

Always answer in $language.

Your role:
- Answer every user message clearly and naturally.
- Be especially strong in skincare, makeup, beauty routines, product scans, ingredients, hair care, wellness and app usage.
- If the user asks about something general, answer briefly and clearly.
- If the user asks about skincare or makeup, give practical steps.
- If the user asks for a routine, structure it as morning and evening.
- If the user asks about a scanned product, explain that barcode/product information depends on online product databases.
- If the user asks about ingredients, explain benefits, possible irritation and compatibility without inventing facts.
- If the user asks about the app, explain SkinSnap features simply.

Safety:
- Do not diagnose medical diseases.
- Do not claim certainty about skin conditions from a simple message.
- For serious acne, burns, allergy, infection, pain, bleeding, severe irritation or pregnancy-related treatment questions, recommend consulting a dermatologist or pharmacist.
- Avoid dangerous advice.
- Do not invent exact product ingredients if the user did not provide them.

Style:
- Warm, modern, professional and useful.
- Use short sections.
- Avoid very long answers.
- Give examples when helpful.
- End with one useful next step.
''';
  }

  String _languageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'Arabic';
      default:
        return 'French';
    }
  }

  String _emptyAnswer(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'Write your question and I will help you with skincare, makeup, routine, products, ingredients or any other topic.';
      case 'ar':
        return 'اكتبي سؤالك وسأساعدك في البشرة أو المكياج أو الروتين أو المنتجات أو المكونات أو أي موضوع آخر.';
      default:
        return 'Écris ta question et je vais t’aider pour la peau, le makeup, la routine, les produits, les ingrédients ou tout autre sujet.';
    }
  }

  String _apiTimeout(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'The AI assistant is taking too long to respond. Please check your internet connection and try again.';
      case 'ar':
        return 'المساعد الذكي يستغرق وقتا طويلا في الرد. تحققي من اتصال الإنترنت ثم حاولي مرة أخرى.';
      default:
        return 'L’assistant IA met trop de temps à répondre. Vérifie ta connexion Internet puis réessaie.';
    }
  }

  String _rateLimitMessage(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'The AI assistant received too many requests. Please wait a moment and try again.';
      case 'ar':
        return 'تلقى المساعد الذكي عددا كبيرا من الطلبات. انتظري قليلا ثم حاولي مرة أخرى.';
      default:
        return 'L’assistant IA a reçu trop de demandes. Attends quelques instants puis réessaie.';
    }
  }

  String _blockedMessage(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'I cannot answer that safely. You can ask me another question about skincare, makeup, products or your routine.';
      case 'ar':
        return 'لا يمكنني الإجابة على ذلك بأمان. يمكنك سؤالي عن البشرة أو المكياج أو المنتجات أو الروتين.';
      default:
        return 'Je ne peux pas répondre à cela de manière sûre. Tu peux me poser une autre question sur la peau, le makeup, les produits ou ta routine.';
    }
  }

  String _fallback(String message, String languageCode) {
    final q = _normalize(message);

    if (_containsAny(q, [
      'bonjour',
      'salut',
      'hello',
      'hi',
      'مرحبا',
      'سلام',
    ])) {
      return _helloAnswer(languageCode);
    }

    if (_containsAny(q, [
      'peau grasse',
      'grasse',
      'oily',
      'sebum',
      'sébum',
      'brillance',
      'pores',
      'دهنية',
      'لمعان',
    ])) {
      return _oilySkinAnswer(languageCode);
    }

    if (_containsAny(q, [
      'peau seche',
      'peau sèche',
      'seche',
      'sèche',
      'dry',
      'tiraillement',
      'جافة',
    ])) {
      return _drySkinAnswer(languageCode);
    }

    if (_containsAny(q, [
      'peau sensible',
      'sensible',
      'sensitive',
      'rougeur',
      'irritation',
      'حساسة',
      'احمرار',
    ])) {
      return _sensitiveSkinAnswer(languageCode);
    }

    if (_containsAny(q, [
      'peau mixte',
      'mixte',
      'combination',
      'zone t',
      't-zone',
      'مختلطة',
    ])) {
      return _combinationSkinAnswer(languageCode);
    }

    if (_containsAny(q, [
      'acne',
      'acné',
      'bouton',
      'boutons',
      'imperfection',
      'imperfections',
      'حب الشباب',
      'حبوب',
    ])) {
      return _acneAnswer(languageCode);
    }

    if (_containsAny(q, [
      'routine',
      'matin',
      'soir',
      'morning',
      'evening',
      'night',
      'روتين',
      'صباح',
      'مساء',
    ])) {
      return _routineAnswer(languageCode);
    }

    if (_containsAny(q, [
      'makeup',
      'maquillage',
      'fond de teint',
      'foundation',
      'blush',
      'gloss',
      'mascara',
      'مكياج',
      'فاونديشن',
    ])) {
      return _makeupAnswer(languageCode);
    }

    if (_containsAny(q, [
      'scan',
      'scanner',
      'barcode',
      'code barre',
      'code-barres',
      'produit',
      'product',
      'باركود',
      'منتج',
    ])) {
      return _scanAnswer(languageCode);
    }

    if (_containsAny(q, [
      'ingredient',
      'ingrédient',
      'ingredients',
      'inci',
      'retinol',
      'rétinol',
      'niacinamide',
      'salicylique',
      'مكونات',
      'مكون',
    ])) {
      return _ingredientAnswer(languageCode);
    }

    if (_containsAny(q, [
      'cheveux',
      'coiffure',
      'hair',
      'شعر',
    ])) {
      return _hairAnswer(languageCode);
    }

    if (_containsAny(q, [
      'bien etre',
      'bien-être',
      'wellness',
      'stress',
      'sommeil',
      'sleep',
      'eau',
      'water',
      'نوم',
      'ماء',
    ])) {
      return _wellnessAnswer(languageCode);
    }

    return _generalAnswer(languageCode);
  }

  String _helloAnswer(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'Hello! I am your SkinSnap assistant. Ask me about skincare, makeup, routines, scanned products, ingredients, hair care, wellness or any other question.';
      case 'ar':
        return 'مرحبا! أنا مساعد SkinSnap. اسأليني عن البشرة أو المكياج أو الروتين أو المنتجات الممسوحة أو المكونات أو الشعر أو أي سؤال آخر.';
      default:
        return 'Bonjour ! Je suis ton assistant SkinSnap. Tu peux me poser une question sur la peau, le makeup, la routine, les produits scannés, les ingrédients, les cheveux ou tout autre sujet.';
    }
  }

  String _oilySkinAnswer(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'For oily skin, keep the routine light and consistent.\n\nMorning:\n• Gentle cleanser\n• Lightweight moisturizer\n• Mattifying SPF\n\nEvening:\n• Cleanser\n• Niacinamide or salicylic acid a few nights per week\n• Light moisturizer\n\nAvoid heavy oils and very rich creams.';
      case 'ar':
        return 'للبشرة الدهنية، اجعلي الروتين خفيفا ومنتظما.\n\nصباحا:\n• غسول لطيف\n• مرطب خفيف\n• واقي شمس مطفي\n\nمساء:\n• غسول\n• نياسيناميد أو حمض الساليسيليك بعض الليالي في الأسبوع\n• مرطب خفيف\n\nتجنبي الزيوت الثقيلة والكريمات الغنية جدا.';
      default:
        return 'Pour une peau grasse, garde une routine légère et régulière.\n\nMatin :\n• Nettoyant doux\n• Hydratant léger\n• SPF matifiant\n\nSoir :\n• Nettoyant\n• Niacinamide ou acide salicylique quelques soirs par semaine\n• Hydratant léger\n\nÉvite les huiles lourdes et les crèmes trop riches.';
    }
  }

  String _drySkinAnswer(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'For dry skin, focus on repairing the skin barrier.\n\nMorning:\n• Gentle cleanser or just rinse\n• Hydrating serum\n• Rich moisturizer\n• SPF\n\nEvening:\n• Gentle cleanser\n• Nourishing cream\n\nAvoid harsh exfoliation and drying cleansers.';
      case 'ar':
        return 'للبشرة الجافة، ركزي على ترميم حاجز البشرة.\n\nصباحا:\n• غسول لطيف أو شطف بالماء فقط\n• سيروم مرطب\n• كريم غني\n• واقي شمس\n\nمساء:\n• غسول لطيف\n• كريم مغذي\n\nتجنبي التقشير القوي والغسولات التي تجفف البشرة.';
      default:
        return 'Pour une peau sèche, l’objectif est de réparer la barrière cutanée.\n\nMatin :\n• Nettoyant doux ou rinçage simple\n• Sérum hydratant\n• Crème plus riche\n• SPF\n\nSoir :\n• Nettoyant doux\n• Crème nourrissante\n\nÉvite les exfoliants agressifs et les nettoyants asséchants.';
    }
  }

  String _sensitiveSkinAnswer(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'For sensitive skin, reduce the number of products.\n\nUse:\n• Gentle cleanser\n• Barrier-repair moisturizer\n• Fragrance-free SPF\n\nAvoid strong exfoliants, fragrance and alcohol-heavy products. Patch test every new product first.';
      case 'ar':
        return 'للبشرة الحساسة، قللي عدد المنتجات.\n\nاستعملي:\n• غسول لطيف\n• مرطب يدعم حاجز البشرة\n• واقي شمس بدون عطر\n\nتجنبي المقشرات القوية والعطور والمنتجات الغنية بالكحول. جربي أي منتج جديد على منطقة صغيرة أولا.';
      default:
        return 'Pour une peau sensible, réduis le nombre de produits.\n\nUtilise :\n• Nettoyant doux\n• Hydratant réparateur de barrière\n• SPF sans parfum\n\nÉvite les exfoliants forts, le parfum et les produits très alcoolisés. Teste chaque nouveau produit sur une petite zone.';
    }
  }

  String _combinationSkinAnswer(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'For combination skin, balance the T-zone and cheeks.\n\nMorning:\n• Gentle cleanser\n• Lightweight moisturizer\n• SPF\n\nEvening:\n• Cleanser\n• Light treatment on oily areas if needed\n• More comfort cream only on dry areas.';
      case 'ar':
        return 'للبشرة المختلطة، وازني بين منطقة T والخدين.\n\nصباحا:\n• غسول لطيف\n• مرطب خفيف\n• واقي شمس\n\nمساء:\n• غسول\n• علاج خفيف على المناطق الدهنية إذا احتجت\n• كريم أغنى فقط على المناطق الجافة.';
      default:
        return 'Pour une peau mixte, équilibre la zone T et les joues.\n\nMatin :\n• Nettoyant doux\n• Hydratant léger\n• SPF\n\nSoir :\n• Nettoyant\n• Soin léger sur les zones grasses si besoin\n• Crème plus confortable seulement sur les zones sèches.';
    }
  }

  String _acneAnswer(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'For breakouts, simplify first.\n\nUse:\n• Gentle cleanser\n• Light non-comedogenic moisturizer\n• SPF every morning\n• Salicylic acid or benzoyl peroxide carefully, not all at once\n\nIf acne is painful, severe or persistent, consult a dermatologist.';
      case 'ar':
        return 'للحبو ب، ابدئي بتبسيط الروتين.\n\nاستعملي:\n• غسول لطيف\n• مرطب خفيف غير كوميدوجيني\n• واقي شمس صباحا\n• حمض الساليسيليك أو البنزويل بيروكسيد بحذر وليس كل شيء معا\n\nإذا كانت الحبوب مؤلمة أو شديدة أو مستمرة، استشيري طبيب جلدية.';
      default:
        return 'Pour les boutons, commence par simplifier.\n\nUtilise :\n• Nettoyant doux\n• Hydratant léger non comédogène\n• SPF chaque matin\n• Acide salicylique ou peroxyde de benzoyle avec prudence, pas tout en même temps\n\nSi l’acné est douloureuse, importante ou persistante, consulte un dermatologue.';
    }
  }

  String _routineAnswer(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'A professional simple routine:\n\nMorning:\n1. Cleanse\n2. Moisturize\n3. Sunscreen\n\nEvening:\n1. Remove makeup or cleanse\n2. Targeted treatment if needed\n3. Moisturize\n\nKeep it consistent for at least 3 to 4 weeks before judging results.';
      case 'ar':
        return 'روتين بسيط واحترافي:\n\nصباحا:\n1. تنظيف\n2. ترطيب\n3. واقي شمس\n\nمساء:\n1. إزالة المكياج أو تنظيف البشرة\n2. علاج موجه عند الحاجة\n3. ترطيب\n\nحافظي عليه 3 إلى 4 أسابيع قبل الحكم على النتيجة.';
      default:
        return 'Routine simple et professionnelle :\n\nMatin :\n1. Nettoyer\n2. Hydrater\n3. Protéger avec SPF\n\nSoir :\n1. Démaquiller ou nettoyer\n2. Soin ciblé si besoin\n3. Hydrater\n\nGarde la même routine 3 à 4 semaines avant de juger les résultats.';
    }
  }

  String _makeupAnswer(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'For a clean makeup look:\n\n1. Prep with moisturizer and SPF.\n2. Use a foundation texture adapted to your skin type.\n3. Apply thin layers.\n4. Add blush for freshness.\n5. Finish with mascara and lip gloss.\n\nFor oily skin, powder only the T-zone.';
      case 'ar':
        return 'لمكياج نظيف:\n\n1. حضري البشرة بمرطب وواقي شمس.\n2. اختاري فاونديشن مناسب لنوع بشرتك.\n3. ضعي طبقات خفيفة.\n4. أضيفي بلاشر لإشراقة طبيعية.\n5. انهي بماسكارا وغلوس.\n\nللبشرة الدهنية، ضعي البودرة فقط على منطقة T.';
      default:
        return 'Pour un makeup propre :\n\n1. Prépare la peau avec hydratant et SPF.\n2. Choisis une texture de fond de teint adaptée à ton type de peau.\n3. Applique en couches fines.\n4. Ajoute du blush pour l’effet frais.\n5. Termine avec mascara et gloss.\n\nPour peau grasse, poudre seulement la zone T.';
    }
  }

  String _scanAnswer(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'To analyze a product, scan its barcode in SkinSnap. The app reads the code and searches product databases. If the product is missing, try manual barcode entry or add the product yourself.';
      case 'ar':
        return 'لتحليل منتج، امسحي الباركود في SkinSnap. يقرأ التطبيق الكود ويبحث في قواعد بيانات المنتجات. إذا لم يكن المنتج موجودا، جربي إدخال الباركود يدويا أو أضيفي المنتج بنفسك.';
      default:
        return 'Pour analyser un produit, scanne son code-barres dans SkinSnap. L’application lit le code et cherche dans les bases produits. Si le produit n’existe pas, essaie la saisie manuelle ou ajoute le produit toi-même.';
    }
  }

  String _ingredientAnswer(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'To judge ingredients, check three things:\n\n1. The role of the ingredient.\n2. Its concentration.\n3. Your skin tolerance.\n\nOne ingredient is not automatically good or bad. The full formula matters.';
      case 'ar':
        return 'لتقييم المكونات، انتبهي إلى ثلاثة أشياء:\n\n1. دور المكون.\n2. تركيزه.\n3. تحمل بشرتك له.\n\nالمكون الواحد ليس جيدا أو سيئا تلقائيا. الصيغة الكاملة مهمة.';
      default:
        return 'Pour évaluer des ingrédients, regarde trois éléments :\n\n1. Le rôle de l’ingrédient.\n2. Sa concentration.\n3. La tolérance de ta peau.\n\nUn ingrédient seul n’est pas automatiquement bon ou mauvais. La formule complète compte.';
    }
  }

  String _hairAnswer(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'For hair care, start with your hair type: oily, dry, curly, damaged or colored.\n\nBasic routine:\n• Gentle shampoo\n• Conditioner on lengths\n• Weekly mask if dry or damaged\n• Heat protection before styling\n\nAvoid too much heat and tight hairstyles every day.';
      case 'ar':
        return 'للعناية بالشعر، ابدئي بتحديد نوعه: دهني، جاف، مجعد، متضرر أو مصبوغ.\n\nروتين بسيط:\n• شامبو لطيف\n• بلسم على الأطراف\n• ماسك أسبوعي إذا كان الشعر جافا أو متضررا\n• حماية من الحرارة قبل التصفيف\n\nتجنبي الحرارة المفرطة والتسريحات المشدودة يوميا.';
      default:
        return 'Pour les cheveux, commence par ton type : gras, sec, bouclé, abîmé ou coloré.\n\nRoutine simple :\n• Shampoing doux\n• Après-shampoing sur les longueurs\n• Masque hebdomadaire si cheveux secs ou abîmés\n• Protection chaleur avant coiffage\n\nÉvite la chaleur excessive et les coiffures trop serrées tous les jours.';
    }
  }

  String _wellnessAnswer(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'Wellness affects skin quality. Focus on sleep, hydration, stress management and consistency.\n\nSimple habits:\n• Sleep enough\n• Drink water regularly\n• Avoid touching your face often\n• Keep pillowcases clean\n• Keep your routine simple';
      case 'ar':
        return 'الصحة العامة تؤثر على البشرة. ركزي على النوم، شرب الماء، التحكم في التوتر والاستمرارية.\n\nعادات بسيطة:\n• نامي جيدا\n• اشربي الماء بانتظام\n• تجنبي لمس الوجه كثيرا\n• حافظي على نظافة غطاء الوسادة\n• اجعلي الروتين بسيطا';
      default:
        return 'Le bien-être influence la qualité de la peau. Travaille surtout le sommeil, l’hydratation, le stress et la régularité.\n\nHabitudes simples :\n• Dormir suffisamment\n• Boire de l’eau régulièrement\n• Éviter de toucher souvent le visage\n• Garder les taies d’oreiller propres\n• Garder une routine simple';
    }
  }

  String _generalAnswer(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'I can help. To give you the best answer, tell me more details: your skin type, your concern, your goal, or the product you are using.';
      case 'ar':
        return 'يمكنني مساعدتك. لأعطيك أفضل إجابة، اذكري تفاصيل أكثر: نوع بشرتك، المشكلة، الهدف، أو المنتج الذي تستعملينه.';
      default:
        return 'Je peux t’aider. Pour te donner la meilleure réponse, donne-moi plus de détails : ton type de peau, ton problème, ton objectif ou le produit que tu utilises.';
    }
  }

  bool _containsAny(String source, List<String> words) {
    return words.any((word) => source.contains(_normalize(word)));
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('ç', 'c')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ô', 'o')
        .replaceAll('ö', 'o');
  }
}
