import 'package:flutter/material.dart';

import '../models/beauty_plan.dart';
import '../models/makeup_recommendation.dart';
import '../models/skin_analysis_result.dart';

class BeautyAdvisorService {
  String _t(
    Locale locale, {
    required String fr,
    required String en,
    required String ar,
  }) {
    switch (locale.languageCode) {
      case 'en':
        return en;
      case 'ar':
        return ar;
      default:
        return fr;
    }
  }

  String _normalize(String value) {
    const replacements = {
      'a': ['à', 'â', 'ä'],
      'c': ['ç'],
      'e': ['é', 'è', 'ê', 'ë'],
      'i': ['î', 'ï'],
      'o': ['ô', 'ö'],
      'u': ['ù', 'û', 'ü'],
    };

    var result = value.toLowerCase();
    for (final entry in replacements.entries) {
      for (final char in entry.value) {
        result = result.replaceAll(char, entry.key);
      }
    }
    return result;
  }

  bool _containsAny(String source, List<String> patterns) {
    return patterns.any(source.contains);
  }

  String _inferSkinType(SkinAnalysisResult result) {
    final note = _normalize(result.analysisNote ?? '');
    final labels =
        _normalize(result.imageLabels.map((item) => item.label).join(' '));

    if (_containsAny(note, ['seche', 'sec', 'dry', 'dehydr', 'tirail'])) {
      return 'dry';
    }
    if (_containsAny(note, ['grasse', 'gras', 'huile', 'oil', 'brill'])) {
      return 'oily';
    }
    if (_containsAny(note, ['mixte', 'combination'])) {
      return 'combination';
    }
    if (_containsAny(note, ['sensible', 'sensitive', 'reactive', 'rougeur']) ||
        _containsAny(labels, ['redness'])) {
      return 'sensitive';
    }
    if (result.skinScore >= 78) {
      return 'normal';
    }
    if (result.skinScore <= 48) {
      return 'sensitive';
    }
    return 'combination';
  }

  List<String> _inferConcernCodes(SkinAnalysisResult result, String skinType) {
    final note = _normalize(result.analysisNote ?? '');
    final labels =
        _normalize(result.imageLabels.map((item) => item.label).join(' '));
    final concerns = <String>[];

    if (skinType == 'dry' ||
        result.skinScore < 65 ||
        _containsAny(note, ['seche', 'dry', 'dehydr', 'tirail'])) {
      concerns.add('dehydration');
    }

    if (_containsAny(note, ['rouge', 'red', 'sensible', 'reactive']) ||
        _containsAny(labels, ['redness'])) {
      concerns.add('redness');
    }

    if (skinType == 'oily' ||
        _containsAny(note, ['grasse', 'gras', 'huile', 'shine', 'brill'])) {
      concerns.add('shine');
    }

    if (result.skinScore < 72) {
      concerns.add('texture');
    }

    if (skinType == 'sensitive' || result.skinScore < 55) {
      concerns.add('barrier');
    }

    if (_containsAny(note, ['bouton', 'acne', 'imperfection', 'blemish'])) {
      concerns.add('imperfections');
    }

    if (concerns.isEmpty) {
      concerns.addAll(['radiance', 'balance']);
    }

    return concerns.toSet().toList();
  }

  String _localizedSkinType(String code, Locale locale) {
    switch (code) {
      case 'dry':
        return _t(locale, fr: 'Peau seche', en: 'Dry skin', ar: 'بشرة جافة');
      case 'oily':
        return _t(locale, fr: 'Peau grasse', en: 'Oily skin', ar: 'بشرة دهنية');
      case 'combination':
        return _t(locale,
            fr: 'Peau mixte', en: 'Combination skin', ar: 'بشرة مختلطة');
      case 'sensitive':
        return _t(locale,
            fr: 'Peau sensible', en: 'Sensitive skin', ar: 'بشرة حساسة');
      default:
        return _t(locale,
            fr: 'Peau normale', en: 'Normal skin', ar: 'بشرة عادية');
    }
  }

  String _localizedConcern(String code, Locale locale) {
    switch (code) {
      case 'dehydration':
        return _t(locale, fr: 'Deshydratation', en: 'Dehydration', ar: 'جفاف');
      case 'redness':
        return _t(locale, fr: 'Rougeurs', en: 'Redness', ar: 'احمرار');
      case 'shine':
        return _t(locale, fr: 'Brillance', en: 'Excess shine', ar: 'لمعان');
      case 'texture':
        return _t(locale,
            fr: 'Texture irreguliere',
            en: 'Uneven texture',
            ar: 'ملمس غير منتظم');
      case 'barrier':
        return _t(locale,
            fr: 'Barriere cutanee', en: 'Skin barrier', ar: 'حاجز البشرة');
      case 'imperfections':
        return _t(locale,
            fr: 'Imperfections', en: 'Imperfections', ar: 'شوائب');
      case 'radiance':
        return _t(locale, fr: 'Eclat', en: 'Radiance', ar: 'اشراقة');
      default:
        return _t(locale, fr: 'Equilibre', en: 'Balance', ar: 'توازن');
    }
  }

  ProductSuggestion _cleanser(String skinType, Locale locale) {
    final name = skinType == 'oily'
        ? _t(locale,
            fr: 'Gel nettoyant purifiant',
            en: 'Purifying gel cleanser',
            ar: 'غسول جل منقي')
        : _t(
            locale,
            fr: 'Nettoyant doux sans sulfate',
            en: 'Gentle sulfate-free cleanser',
            ar: 'منظف لطيف بدون سلفات',
          );

    return ProductSuggestion(
      category: _t(locale, fr: 'Nettoyage', en: 'Cleanser', ar: 'التنظيف'),
      name: name,
      reason: _t(
        locale,
        fr: 'Nettoie sans agresser la peau avant les soins suivants.',
        en: 'Cleans without stripping the skin before the next products.',
        ar: 'ينظف البشرة بدون تجفيفها قبل باقي الخطوات.',
      ),
      usage: _t(
        locale,
        fr: 'Matin et soir, 30 secondes.',
        en: 'Morning and night, 30 seconds.',
        ar: 'صباحا ومساء لمدة 30 ثانية.',
      ),
    );
  }

  ProductSuggestion _serum(List<String> concerns, Locale locale) {
    if (concerns.contains('redness') || concerns.contains('barrier')) {
      return ProductSuggestion(
        category: _t(locale, fr: 'Serum', en: 'Serum', ar: 'سيروم'),
        name: _t(locale,
            fr: 'Serum apaisant a la niacinamide',
            en: 'Soothing niacinamide serum',
            ar: 'سيروم مهدئ بالنياسيناميد'),
        reason: _t(
          locale,
          fr: 'Aide a calmer les rougeurs et a renforcer la barriere cutanee.',
          en: 'Helps calm redness and support the skin barrier.',
          ar: 'يساعد على تهدئة الاحمرار ودعم حاجز البشرة.',
        ),
        usage: _t(
          locale,
          fr: 'Appliquer avant la creme, une a deux pressions.',
          en: 'Apply before cream, one to two pumps.',
          ar: 'يوضع قبل الكريم بكمية بسيطة.',
        ),
      );
    }

    if (concerns.contains('shine') || concerns.contains('imperfections')) {
      return ProductSuggestion(
        category: _t(locale, fr: 'Serum', en: 'Serum', ar: 'سيروم'),
        name: _t(locale,
            fr: 'Serum equilibrant au zinc',
            en: 'Balancing zinc serum',
            ar: 'سيروم متوازن بالزنك'),
        reason: _t(
          locale,
          fr: 'Regule l exces de sebum et affine l aspect de la peau.',
          en: 'Helps regulate excess oil and refine skin appearance.',
          ar: 'يساعد على تنظيم الدهون وتحسين مظهر البشرة.',
        ),
        usage: _t(
          locale,
          fr: 'Matin ou soir sur peau propre.',
          en: 'Use morning or night on clean skin.',
          ar: 'يستخدم صباحا او مساء على بشرة نظيفة.',
        ),
      );
    }

    return ProductSuggestion(
      category: _t(locale, fr: 'Serum', en: 'Serum', ar: 'سيروم'),
      name: _t(
        locale,
        fr: 'Serum hydratant a l acide hyaluronique',
        en: 'Hydrating hyaluronic serum',
        ar: 'سيروم مرطب بحمض الهيالورونيك',
      ),
      reason: _t(
        locale,
        fr: 'Repulpe la peau et limite les sensations de tiraillement.',
        en: 'Plumps the skin and reduces tightness.',
        ar: 'يرطب البشرة ويقلل الاحساس بالشد.',
      ),
      usage: _t(
        locale,
        fr: 'Sur peau legerement humide, matin et soir.',
        en: 'Apply on slightly damp skin, morning and night.',
        ar: 'يوضع على بشرة رطبة قليلا صباحا ومساء.',
      ),
    );
  }

  ProductSuggestion _cream(String skinType, Locale locale) {
    final name = skinType == 'oily'
        ? _t(locale,
            fr: 'Fluide hydratant leger',
            en: 'Lightweight hydrating fluid',
            ar: 'مرطب خفيف')
        : _t(locale,
            fr: 'Creme barriere reparatrice',
            en: 'Barrier-repair cream',
            ar: 'كريم مرمم للحاجز');

    return ProductSuggestion(
      category: _t(locale, fr: 'Hydratation', en: 'Moisturizer', ar: 'الترطيب'),
      name: name,
      reason: _t(
        locale,
        fr: 'Conforte la peau et maintient l hydratation dans la journee.',
        en: 'Keeps the skin comfortable and hydrated throughout the day.',
        ar: 'يحافظ على راحة البشرة وترطيبها خلال اليوم.',
      ),
      usage: _t(
        locale,
        fr: 'Appliquer apres le serum, matin et soir.',
        en: 'Apply after serum, morning and night.',
        ar: 'يوضع بعد السيروم صباحا ومساء.',
      ),
    );
  }

  ProductSuggestion _spf(Locale locale) {
    return ProductSuggestion(
      category:
          _t(locale, fr: 'Protection', en: 'Sun protection', ar: 'الحماية'),
      name: _t(locale,
          fr: 'Ecran solaire SPF 50',
          en: 'SPF 50 sunscreen',
          ar: 'واقي شمسي SPF 50'),
      reason: _t(
        locale,
        fr: 'Protege la peau et stabilise les progres de la routine.',
        en: 'Protects the skin and preserves the routine results.',
        ar: 'يحمي البشرة ويحافظ على نتائج الروتين.',
      ),
      usage: _t(
        locale,
        fr: 'Derniere etape du matin, a reappliquer si besoin.',
        en: 'Last morning step, reapply when needed.',
        ar: 'اخر خطوة صباحا ويعاد عند الحاجة.',
      ),
    );
  }

  ProductSuggestion _nightRepair(List<String> concerns, Locale locale) {
    final name = concerns.contains('redness') || concerns.contains('barrier')
        ? _t(locale,
            fr: 'Baume apaisant reparateur',
            en: 'Soothing repair balm',
            ar: 'بلسم مهدئ مرمم')
        : _t(locale,
            fr: 'Creme nuit confort',
            en: 'Comfort night cream',
            ar: 'كريم ليلي مريح');

    return ProductSuggestion(
      category:
          _t(locale, fr: 'Soin nuit', en: 'Night care', ar: 'عناية ليلية'),
      name: name,
      reason: _t(
        locale,
        fr: 'Aide la peau a recuperer pendant la nuit.',
        en: 'Supports overnight recovery.',
        ar: 'يساعد البشرة على التعافي ليلا.',
      ),
      usage: _t(
        locale,
        fr: 'Le soir uniquement, en couche fine.',
        en: 'At night only, in a thin layer.',
        ar: 'يستخدم مساء بطبقة خفيفة.',
      ),
    );
  }

  BeautyPlan buildPlan({
    required SkinAnalysisResult result,
    required Locale locale,
  }) {
    final skinTypeCode = _inferSkinType(result);
    final concernCodes = _inferConcernCodes(result, skinTypeCode);
    final skinType = _localizedSkinType(skinTypeCode, locale);
    final concerns =
        concernCodes.map((code) => _localizedConcern(code, locale)).toList();
    final cleanser = _cleanser(skinTypeCode, locale);
    final serum = _serum(concernCodes, locale);
    final cream = _cream(skinTypeCode, locale);
    final spf = _spf(locale);
    final nightRepair = _nightRepair(concernCodes, locale);

    final summary = _t(
      locale,
      fr: 'Analyse du jour : $skinType avec un niveau de confort global de ${result.skinScore}/100. Les priorites observees sont ${concerns.take(2).join(' et ')}.',
      en: 'Today analysis: $skinType with an overall comfort level of ${result.skinScore}/100. The main priorities are ${concerns.take(2).join(' and ')}.',
      ar: 'تحليل اليوم يشير الى $skinType بمستوى عام ${result.skinScore}/100. الاولويات الحالية هي ${concerns.take(2).join(' و ')}.',
    );

    final coachMessage = _t(
      locale,
      fr: 'Sois reguliere matin et soir pendant au moins 10 a 14 jours pour voir une vraie evolution. La protection solaire reste la cle si tu veux stabiliser les resultats.',
      en: 'Stay consistent morning and evening for at least 10 to 14 days to see real progress. Sunscreen is the key step to keep the results stable.',
      ar: 'حافظي على الانتظام صباحا ومساء لمدة 10 الى 14 يوما على الاقل لرؤية تحسن واضح. واقي الشمس هو الخطوة الاهم للحفاظ على النتيجة.',
    );

    return BeautyPlan(
      sourceAnalysisId: result.id,
      createdAt: result.analyzedAt,
      skinType: skinType,
      summary: summary,
      coachMessage: coachMessage,
      concerns: concerns,
      products: [cleanser, serum, cream, spf, nightRepair],
      morningSteps: [
        RoutineStep(
          id: 'morning_cleanser',
          title: _t(locale, fr: 'Nettoyer', en: 'Cleanse', ar: 'تنظيف'),
          description: cleanser.reason,
          productName: cleanser.name,
          moment: RoutineMoment.morning,
        ),
        RoutineStep(
          id: 'morning_serum',
          title: _t(locale, fr: 'Traiter', en: 'Treat', ar: 'علاج'),
          description: serum.reason,
          productName: serum.name,
          moment: RoutineMoment.morning,
        ),
        RoutineStep(
          id: 'morning_cream',
          title: _t(locale, fr: 'Hydrater', en: 'Moisturize', ar: 'ترطيب'),
          description: cream.reason,
          productName: cream.name,
          moment: RoutineMoment.morning,
        ),
        RoutineStep(
          id: 'morning_spf',
          title: _t(locale, fr: 'Proteger', en: 'Protect', ar: 'حماية'),
          description: spf.reason,
          productName: spf.name,
          moment: RoutineMoment.morning,
        ),
      ],
      eveningSteps: [
        RoutineStep(
          id: 'evening_cleanser',
          title: _t(locale, fr: 'Nettoyer', en: 'Cleanse', ar: 'تنظيف'),
          description: cleanser.reason,
          productName: cleanser.name,
          moment: RoutineMoment.evening,
        ),
        RoutineStep(
          id: 'evening_serum',
          title: _t(locale, fr: 'Traiter', en: 'Treat', ar: 'علاج'),
          description: serum.reason,
          productName: serum.name,
          moment: RoutineMoment.evening,
        ),
        RoutineStep(
          id: 'evening_repair',
          title: _t(locale, fr: 'Reparer', en: 'Repair', ar: 'اصلاح'),
          description: nightRepair.reason,
          productName: nightRepair.name,
          moment: RoutineMoment.evening,
        ),
      ],
    );
  }

  BeautyPlan buildStarterPlan(Locale locale) {
    final fakeResult = SkinAnalysisResult(
      id: 'starter-plan',
      analyzedAt: DateTime.now(),
      imagePath: '',
      faceDetected: true,
      imageLabels: const [],
      segmentationDone: true,
      skinScore: 70,
    );
    return buildPlan(result: fakeResult, locale: locale);
  }

  MakeupRecommendation buildMakeupRecommendation({
    required Locale locale,
    required String eventType,
    required String style,
    BeautyPlan? plan,
  }) {
    final currentPlan = plan ?? buildStarterPlan(locale);
    final isDry = currentPlan.skinType == _localizedSkinType('dry', locale);
    final isOily = currentPlan.skinType == _localizedSkinType('oily', locale);

    final lookName = switch ('$eventType:$style') {
      'wedding:soft_glam' => _t(locale,
          fr: 'Soft glam lumineux',
          en: 'Luminous soft glam',
          ar: 'مكياج ناعم مضيء'),
      'evening:bold' => _t(locale,
          fr: 'Glam de soiree', en: 'Evening glam', ar: 'إطلالة سهرة جريئة'),
      'work:natural' => _t(locale,
          fr: 'Chic discret',
          en: 'Polished natural look',
          ar: 'إطلالة طبيعية مرتبة'),
      _ => _t(locale,
          fr: 'Look adapte a ton evenement',
          en: 'Event-ready beauty look',
          ar: 'إطلالة مناسبة للمناسبة'),
    };

    final overview = _t(
      locale,
      fr: 'Cette proposition est ajustee a ${currentPlan.skinType.toLowerCase()} et vise un rendu ${style.replaceAll('_', ' ')} pour ton evenement.',
      en: 'This suggestion is adjusted to ${currentPlan.skinType.toLowerCase()} and aims for a ${style.replaceAll('_', ' ')} finish for your event.',
      ar: 'هذا الاقتراح مناسب لـ ${currentPlan.skinType} ويعطي نتيجة ${style.replaceAll('_', ' ')} للمناسبة.',
    );

    final skinPrep = isDry
        ? _t(locale,
            fr:
                'Base hydratante + fine couche de baume confort sur les zones seches.',
            en: 'Hydrating base plus a comfort balm on dry areas.',
            ar: 'قاعدة مرطبة مع طبقة خفيفة من البلسم على المناطق الجافة.')
        : isOily
            ? _t(locale,
                fr: 'Primer flouteur sur la zone T et spray fixateur leger.',
                en: 'Blurring primer on the T-zone and a light setting spray.',
                ar: 'برايمر مطفي على منطقة T مع بخاخ تثبيت خفيف.')
            : _t(locale,
                fr: 'Hydratant leger puis primer eclat sur les points hauts.',
                en: 'Light moisturizer followed by a glow primer on high points.',
                ar: 'مرطب خفيف ثم برايمر مضيء على المناطق البارزة.');

    final complexion = isOily
        ? _t(locale,
            fr:
                'Fond de teint satine, correcteur localise et poudre fine uniquement sur la zone T.',
            en:
                'Satin foundation, spot concealer, and powder only on the T-zone.',
            ar: 'فاونديشن ساتان مع كونسيلر موضعي وبودرة خفيفة على منطقة T فقط.')
        : _t(locale,
            fr: 'Base fraiche, correcteur lumineux sous les yeux et finition peau naturelle.',
            en: 'Fresh base, brightening under-eye concealer, and a natural-skin finish.',
            ar: 'قاعدة منعشة مع كونسيلر مضيء تحت العين ولمسة نهائية طبيعية.');

    final eyes = switch (style) {
      'bold' => _t(locale,
          fr: 'Coin externe plus intense, liner allonge et mascara en volume.',
          en: 'Deeper outer corner, elongated liner, and volumizing mascara.',
          ar: 'زاوية خارجية اعمق مع ايلاينر مسحوب وماسكارا مكثفة.'),
      'soft_glam' => _t(locale,
          fr: 'Fards champagne, brun chaud et touche de lumiere au centre.',
          en: 'Champagne shadows, warm brown definition, and light at the center.',
          ar: 'ظلال شامبانيا مع بني دافئ ولمعة خفيفة في الوسط.'),
      'chic' => _t(locale,
          fr: 'Taupe mat, ras de cils fondu et cils bien separes.',
          en: 'Matte taupe, softly defined lash line, and separated lashes.',
          ar: 'لون تاوب مطفي مع تحديد ناعم للرموش وفصل جيد لها.'),
      _ => _t(locale,
          fr: 'Beige lumineux, brun doux et mascara allongeant.',
          en: 'Luminous beige, soft brown, and lengthening mascara.',
          ar: 'بيج مضيء مع بني ناعم وماسكارا مطولة.'),
    };

    final lips = switch (style) {
      'bold' => _t(locale,
          fr: 'Rouge brique ou framboise avec contour net.',
          en: 'Brick or raspberry lip with a clean outline.',
          ar: 'شفاه بترابية حمراء او توتية مع تحديد واضح.'),
      'soft_glam' => _t(locale,
          fr: 'Nude rose satine avec crayon ton sur ton.',
          en: 'Satin rosy nude with a matching lip pencil.',
          ar: 'لون نود وردي ساتان مع محدد مطابق.'),
      'chic' => _t(locale,
          fr: 'Bois de rose elegant au fini creme.',
          en: 'Elegant rosewood cream finish.',
          ar: 'لون وردي خشبي أنيق بلمسة كريمية.'),
      _ => _t(locale,
          fr: 'Baume teinte ou nude peche tres portable.',
          en: 'Tinted balm or a wearable peachy nude.',
          ar: 'بلسم ملون او نود خوخي سهل الارتداء.'),
    };

    final finish = eventType == 'wedding' || eventType == 'evening'
        ? _t(locale,
            fr:
                'Fixer avec un spray longue tenue et illuminer legerement les pommettes.',
            en:
                'Set with a long-wear spray and softly highlight the cheekbones.',
            ar: 'ثبت المكياج ببخاخ ثابت مع اضاءة خفيفة على الوجنتين.')
        : _t(locale,
            fr: 'Garder une finition propre, confortable et facile a retoucher.',
            en: 'Keep the finish clean, comfortable, and easy to touch up.',
            ar: 'حافظي على لمسة نهائية نظيفة ومريحة وسهلة التعديل.');

    final palette = switch (style) {
      'bold' => [
          _t(locale, fr: 'Bronze', en: 'Bronze', ar: 'برونزي'),
          _t(locale, fr: 'Prune', en: 'Plum', ar: 'برقوقي'),
          _t(locale, fr: 'Brique', en: 'Brick', ar: 'قرميدي'),
        ],
      'soft_glam' => [
          _t(locale, fr: 'Champagne', en: 'Champagne', ar: 'شامبانيا'),
          _t(locale, fr: 'Rose beige', en: 'Rose beige', ar: 'بيج وردي'),
          _t(locale, fr: 'Brun chaud', en: 'Warm brown', ar: 'بني دافئ'),
        ],
      'chic' => [
          _t(locale, fr: 'Taupe', en: 'Taupe', ar: 'تاوب'),
          _t(locale, fr: 'Moka', en: 'Mocha', ar: 'موكا'),
          _t(locale, fr: 'Vieux rose', en: 'Dusty rose', ar: 'وردي غباري'),
        ],
      _ => [
          _t(locale, fr: 'Peche', en: 'Peach', ar: 'خوخي'),
          _t(locale, fr: 'Nude', en: 'Nude', ar: 'نود'),
          _t(locale, fr: 'Dore doux', en: 'Soft gold', ar: 'ذهبي ناعم'),
        ],
    };

    return MakeupRecommendation(
      eventType: eventType,
      style: style,
      lookName: lookName,
      overview: overview,
      skinPrep: skinPrep,
      complexion: complexion,
      eyes: eyes,
      lips: lips,
      finish: finish,
      palette: palette,
    );
  }
}
