import 'package:flutter/material.dart';

class AppLocales {
  AppLocales._();

  static const fr = Locale('fr');
  static const en = Locale('en');
  static const ar = Locale('ar');
  static const all = [fr, en, ar];

  static String label(Locale locale) {
    switch (locale.languageCode) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      default:
        return locale.languageCode;
    }
  }

  static bool isRtl(Locale locale) => locale.languageCode == 'ar';
}

class Tr {
  Tr._();

  static const _data = <String, Map<String, String>>{
    'app_name': {'fr': 'SkinSnap', 'en': 'SkinSnap', 'ar': 'سكين سناب'},
    'skip': {'fr': 'Passer', 'en': 'Skip', 'ar': 'تخطي'},
    'next': {'fr': 'Suivant', 'en': 'Next', 'ar': 'التالي'},
    'start': {'fr': 'Commencer', 'en': 'Start', 'ar': 'ابدأ'},
    'home': {'fr': 'Accueil', 'en': 'Home', 'ar': 'الرئيسية'},
    'routine': {'fr': 'Routine', 'en': 'Routine', 'ar': 'الروتين'},
    'makeup': {'fr': 'Makeup', 'en': 'Makeup', 'ar': 'المكياج'},
    'profile': {'fr': 'Profil', 'en': 'Profile', 'ar': 'الملف الشخصي'},
    'history': {'fr': 'Historique', 'en': 'History', 'ar': 'السجل'},
    'settings': {'fr': 'Paramètres', 'en': 'Settings', 'ar': 'الإعدادات'},
    'about': {'fr': 'À propos', 'en': 'About', 'ar': 'حول التطبيق'},
    'language': {'fr': 'Langue', 'en': 'Language', 'ar': 'اللغة'},
    'dark_mode': {'fr': 'Mode sombre', 'en': 'Dark mode', 'ar': 'الوضع الداكن'},
    'notifications': {'fr': 'Notifications', 'en': 'Notifications', 'ar': 'الإشعارات'},
    'sounds': {'fr': 'Effets sonores', 'en': 'Sound effects', 'ar': 'المؤثرات الصوتية'},
    'vibration': {'fr': 'Vibration', 'en': 'Vibration', 'ar': 'الاهتزاز'},
    'tagline': {'fr': 'Analyse peau, routine et makeup dans une seule app', 'en': 'Skin analysis, routine and makeup in one app', 'ar': 'تحليل البشرة والروتين والمكياج في تطبيق واحد'},
    'welcome_title': {'fr': 'Bienvenue sur SkinSnap', 'en': 'Welcome to SkinSnap', 'ar': 'مرحبا بك في سكين سناب'},
    'welcome_subtitle': {'fr': 'Une application beauté avec compte, scan, routine et makeup.', 'en': 'A beauty app with account, scan, routine and makeup.', 'ar': 'تطبيق جمال مع حساب وفحص وروتين ومكياج.'},
    'create_account': {'fr': 'Créer un compte', 'en': 'Create account', 'ar': 'إنشاء حساب'},
    'sign_in': {'fr': 'Se connecter', 'en': 'Sign in', 'ar': 'تسجيل الدخول'},
    'sign_out': {'fr': 'Se déconnecter', 'en': 'Sign out', 'ar': 'تسجيل الخروج'},
    'email': {'fr': 'Email', 'en': 'Email', 'ar': 'البريد الإلكتروني'},
    'password': {'fr': 'Mot de passe', 'en': 'Password', 'ar': 'كلمة المرور'},
    'full_name': {'fr': 'Nom complet', 'en': 'Full name', 'ar': 'الاسم الكامل'},
    'required_field': {'fr': 'Champ obligatoire', 'en': 'Required field', 'ar': 'حقل إجباري'},
    'invalid_email': {'fr': 'Email invalide', 'en': 'Invalid email', 'ar': 'بريد غير صالح'},
    'password_min': {'fr': '6 caractères minimum', 'en': 'Minimum 6 characters', 'ar': '6 أحرف على الأقل'},
    'forgot_password': {'fr': 'Mot de passe oublié ?', 'en': 'Forgot password?', 'ar': 'نسيت كلمة المرور؟'},
    'login_title': {'fr': 'Connexion SkinSnap', 'en': 'SkinSnap sign in', 'ar': 'تسجيل الدخول إلى سكين سناب'},
    'login_subtitle': {'fr': 'Retrouvez vos analyses, routines et recommandations beauté.', 'en': 'Find your analyses, routines and beauty recommendations.', 'ar': 'اعثري على تحاليلك وروتينك وتوصيات الجمال.'},
    'register_title': {'fr': 'Créer votre profil beauté', 'en': 'Create your beauty profile', 'ar': 'أنشئي ملفك الجمالي'},
    'register_subtitle': {'fr': 'Inscription avec Firebase Authentication comme demandé dans le TP8.', 'en': 'Sign up with Firebase Authentication as requested in TP8.', 'ar': 'تسجيل باستخدام Firebase Authentication كما في TP8.'},
    'create_my_account': {'fr': 'Créer mon compte', 'en': 'Create my account', 'ar': 'إنشاء حسابي'},
    'already_account': {'fr': 'Déjà un compte ? Se connecter', 'en': 'Already have an account? Sign in', 'ar': 'لديك حساب؟ تسجيل الدخول'},
    'no_account': {'fr': 'Pas encore de compte ? Créer un compte', 'en': 'No account yet? Create one', 'ar': 'ليس لديك حساب؟ أنشئ حسابا'},
    'dashboard_subtitle': {'fr': 'Que souhaitez-vous faire aujourd hui ?', 'en': 'What would you like to do today?', 'ar': 'ماذا تريدين أن تفعلي اليوم؟'},
    'hello': {'fr': 'Bonjour', 'en': 'Hello', 'ar': 'مرحبا'},
    'from_phone': {'fr': 'Depuis votre téléphone', 'en': 'From your phone', 'ar': 'من هاتفك'},
    'scan_face': {'fr': 'Scan visage', 'en': 'Face scan', 'ar': 'فحص الوجه'},
    'scan_face_sub': {'fr': 'Découvrez votre peau en prenant une photo', 'en': 'Discover your skin by taking a photo', 'ar': 'اكتشفي بشرتك من خلال صورة'},
    'assistant': {'fr': 'Assistant Beauté', 'en': 'Beauty assistant', 'ar': 'مساعد الجمال'},
    'assistant_sub': {'fr': 'Posez des questions sur les produits et ingrédients', 'en': 'Ask questions about products and ingredients', 'ar': 'اسألي عن المنتجات والمكونات'},
    'scan_product': {'fr': 'Scan de produit', 'en': 'Product scan', 'ar': 'فحص منتج'},
    'scan_product_sub': {'fr': 'Scannez un produit et obtenez ses informations', 'en': 'Scan a product and get its information', 'ar': 'افحصي منتجا واحصلي على معلوماته'},
    'my_routine': {'fr': 'Ma routine de soin', 'en': 'My skincare routine', 'ar': 'روتين العناية'},
    'my_routine_sub': {'fr': 'Suivez vos progrès et entretenez vos habitudes', 'en': 'Track your progress and habits', 'ar': 'تابعي تقدمك وعاداتك'},
    'shop_new': {'fr': 'Découvrez la nouvelle façon de shopper ✨', 'en': 'Discover a new way to shop ✨', 'ar': 'اكتشفي طريقة جديدة للتسوق ✨'},
    'categories': {'fr': 'Catégories', 'en': 'Categories', 'ar': 'الفئات'},
    'see_all': {'fr': 'Voir tout', 'en': 'See all', 'ar': 'عرض الكل'},
    'best_match': {'fr': 'Meilleurs Match', 'en': 'Best matches', 'ar': 'أفضل تطابق'},
    'for_me': {'fr': 'pour moi', 'en': 'for me', 'ar': 'لي'},
    'search_match': {'fr': 'trouvez mon meilleur match', 'en': 'find my best match', 'ar': 'اعثري على أفضل تطابق'},
    'active_routine_none': {'fr': 'Aucune routine active', 'en': 'No active routine', 'ar': 'لا يوجد روتين مفعل'},
    'scan_to_create_routine': {'fr': 'Faites un scan visage pour créer une routine adaptée.', 'en': 'Scan your face to create a tailored routine.', 'ar': 'افحصي وجهك لإنشاء روتين مناسب.'},
    'onb_selfie_title': {'fr': 'Depuis un selfie', 'en': 'From a selfie', 'ar': 'من صورة سيلفي'},
    'onb_selfie_subtitle': {'fr': 'Analysez votre peau avec ML Kit en quelques secondes.', 'en': 'Analyze your skin with ML Kit in seconds.', 'ar': 'حللي بشرتك باستخدام ML Kit في ثوان.'},
    'onb_match_title': {'fr': 'Trouvez le meilleur match pour vous', 'en': 'Find the best match for you', 'ar': 'اعثري على أفضل تطابق لك'},
    'onb_match_subtitle': {'fr': 'Comparez les produits et repérez ceux qui correspondent à votre peau.', 'en': 'Compare products and find what suits your skin.', 'ar': 'قارني المنتجات واعثري على ما يناسب بشرتك.'},
    'onb_safety_title': {'fr': 'Protégez votre peau des ingrédients nocifs', 'en': 'Protect your skin from harmful ingredients', 'ar': 'احمي بشرتك من المكونات الضارة'},
    'onb_safety_subtitle': {'fr': 'Scannez un produit et voyez les niveaux de risque clairement.', 'en': 'Scan a product and clearly see risk levels.', 'ar': 'افحصي منتجا وشاهدي مستويات المخاطر بوضوح.'},
    'onb_plan_title': {'fr': 'Obtenez une routine personnalisée pour vous', 'en': 'Get a personalized routine for you', 'ar': 'احصلي على روتين مخصص لك'},
    'onb_plan_subtitle': {'fr': 'Une routine matin et soir adaptée à votre score et vos besoins.', 'en': 'A morning and evening routine adapted to your score and needs.', 'ar': 'روتين صباحي ومسائي مناسب لنتيجتك واحتياجاتك.'},
    'onb_routine_title': {'fr': 'Ne manquez jamais une étape de votre routine', 'en': 'Never miss a step in your routine', 'ar': 'لا تفوتي أي خطوة في روتينك'},
    'onb_routine_subtitle': {'fr': 'Suivez votre progression et recevez des rappels quotidiens.', 'en': 'Track progress and receive daily reminders.', 'ar': 'تابعي التقدم واحصلي على تذكيرات يومية.'},
    'camera': {'fr': 'Caméra', 'en': 'Camera', 'ar': 'الكاميرا'},
    'gallery': {'fr': 'Galerie', 'en': 'Gallery', 'ar': 'المعرض'},
    'analyze_skin_now': {'fr': 'Analyser ma peau maintenant', 'en': 'Analyze my skin now', 'ar': 'حللي بشرتي الآن'},
    'choose_face': {'fr': 'Choisissez ou prenez une photo avant l analyse.', 'en': 'Choose or take a photo before analysis.', 'ar': 'اختاري أو التقطي صورة قبل التحليل.'},
    'assistant_title': {'fr': 'Assistant Beauté', 'en': 'Beauty assistant', 'ar': 'مساعد الجمال'},
    'assistant_intro': {'fr': 'Posez vos questions skincare ou makeup. L assistant répond directement depuis l application.', 'en': 'Ask skincare or makeup questions. The assistant answers directly in the app.', 'ar': 'اسألي عن العناية أو المكياج. يجيب المساعد داخل التطبيق.'},
    'quick_questions': {'fr': 'Questions rapides', 'en': 'Quick questions', 'ar': 'أسئلة سريعة'},
    'write_question': {'fr': 'Écrire une question...', 'en': 'Write a question...', 'ar': 'اكتبي سؤالا...'},
    'assistant_answer': {'fr': 'Réponse de l assistant', 'en': 'Assistant answer', 'ar': 'إجابة المساعد'},
    'send': {'fr': 'Envoyer', 'en': 'Send', 'ar': 'إرسال'},
    'product_detected': {'fr': 'Produit détecté', 'en': 'Detected product', 'ar': 'المنتج المكتشف'},
    'product_info': {'fr': 'Informations du produit', 'en': 'Product information', 'ar': 'معلومات المنتج'},
    'compatible_products': {'fr': 'Produits compatibles', 'en': 'Compatible products', 'ar': 'منتجات مناسبة'},
    'ingredients_detected': {'fr': 'Ingrédients détectés', 'en': 'Detected ingredients', 'ar': 'المكونات المكتشفة'},
    'safety_score': {'fr': 'Score sécurité ingrédients', 'en': 'Ingredients safety score', 'ar': 'درجة أمان المكونات'},
    'add_routine': {'fr': 'Ajouter à ma routine', 'en': 'Add to my routine', 'ar': 'أضف إلى روتيني'},
    'added_routine': {'fr': 'Produit ajouté à My Routine', 'en': 'Product added to My Routine', 'ar': 'تمت إضافة المنتج إلى الروتين'},
    'makeup_title': {'fr': 'Makeup look recommandé', 'en': 'Recommended makeup look', 'ar': 'مظهر المكياج المقترح'},
    'makeup_products': {'fr': 'Produits makeup recommandés', 'en': 'Recommended makeup products', 'ar': 'منتجات المكياج المقترحة'},
    'calendar': {'fr': 'Calendrier', 'en': 'Calendar', 'ar': 'التقويم'},
    'morning': {'fr': 'Matin ☀️', 'en': 'Morning ☀️', 'ar': 'الصباح ☀️'},
    'evening': {'fr': 'Soir 🌙', 'en': 'Evening 🌙', 'ar': 'المساء 🌙'},
    'done': {'fr': 'J ai fait', 'en': 'Done', 'ar': 'تم'},
    'reset': {'fr': 'Réinitialiser', 'en': 'Reset', 'ar': 'إعادة'},
    'progress_week': {'fr': 'Progrès cette semaine', 'en': 'This week progress', 'ar': 'تقدم هذا الأسبوع'},
    'empty_routine': {'fr': 'Aucun produit ajouté. Ajoutez un produit depuis Meilleur Match.', 'en': 'No product added. Add a product from Best Match.', 'ar': 'لم تتم إضافة أي منتج. أضيفي منتجا من أفضل تطابق.'},

    'manual_barcode': {'fr': 'Entrer le code-barres', 'en': 'Enter barcode', 'ar': 'إدخال الباركود'},
    'enter_barcode': {'fr': 'Entrer un code-barres', 'en': 'Enter a barcode', 'ar': 'أدخلي الباركود'},
    'barcode_hint': {'fr': 'Exemple : 3337872411991', 'en': 'Example: 3337872411991', 'ar': 'مثال: 3337872411991'},
    'search': {'fr': 'Chercher', 'en': 'Search', 'ar': 'بحث'},
    'cancel': {'fr': 'Annuler', 'en': 'Cancel', 'ar': 'إلغاء'},
    'scan_real_product_help': {'fr': 'Scannez le code-barres d un produit cosmétique. SkinSnap interroge Open Beauty Facts et affiche les ingrédients.', 'en': 'Scan a cosmetic product barcode. SkinSnap calls Open Beauty Facts and shows the ingredients.', 'ar': 'افحصي باركود منتج تجميلي. يستعمل التطبيق Open Beauty Facts ويعرض المكونات.'},
    'source': {'fr': 'Source', 'en': 'Source', 'ar': 'المصدر'},
    'demo_data': {'fr': 'Données demo locales', 'en': 'Local demo data', 'ar': 'بيانات تجريبية محلية'},
    'skin_types': {'fr': 'Types de peau', 'en': 'Skin types', 'ar': 'أنواع البشرة'},
    'concerns': {'fr': 'Besoins', 'en': 'Concerns', 'ar': 'الاحتياجات'},
    'penalty_high': {'fr': 'Pénalité forte', 'en': 'High penalty', 'ar': 'خطورة عالية'},
    'penalty_medium': {'fr': 'Pénalité moyenne', 'en': 'Medium penalty', 'ar': 'خطورة متوسطة'},
    'penalty_low': {'fr': 'Pénalité faible', 'en': 'Low penalty', 'ar': 'خطورة منخفضة'},
    'penalty_none': {'fr': 'Pas de pénalité', 'en': 'No penalty', 'ar': 'لا توجد خطورة'},
    'filter_recommendations': {'fr': 'Filtrer les recommandations', 'en': 'Filter recommendations', 'ar': 'تصفية التوصيات'},
    'ideal_skin_type': {'fr': 'Idéal pour type de peau', 'en': 'Ideal skin type', 'ar': 'مناسب لنوع البشرة'},
    'skin_conditions': {'fr': 'Conditions de peau', 'en': 'Skin conditions', 'ar': 'مشاكل البشرة'},
    'texture': {'fr': 'Texture', 'en': 'Texture', 'ar': 'القوام'},
    'description': {'fr': 'Description', 'en': 'Description', 'ar': 'الوصف'},
    'category_bien_etre': {'fr': 'Bien être', 'en': 'Wellness', 'ar': 'الصحة والجمال'},
    'category_coiffure': {'fr': 'Coiffure', 'en': 'Hair care', 'ar': 'العناية بالشعر'},
    'category_skincare': {'fr': 'Skincare', 'en': 'Skincare', 'ar': 'العناية بالبشرة'},
    'category_makeup': {'fr': 'Makeup', 'en': 'Makeup', 'ar': 'المكياج'},
    'category_advice': {'fr': 'Cette catégorie ouvre des conseils adaptés dans l assistant.', 'en': 'This category opens tailored advice in the assistant.', 'ar': 'هذه الفئة تفتح نصائح مخصصة في المساعد.'},
    'notif_title': {'fr': 'Il est temps de suivre votre routine', 'en': 'Time to follow your routine', 'ar': 'حان وقت الروتين'},
    'notif_body': {'fr': 'Pensez à votre routine matin ou soir.', 'en': 'Remember your morning or evening routine.', 'ar': 'تذكري روتين الصباح أو المساء.'},

    'favorites': {'fr': 'Favoris', 'en': 'Favorites', 'ar': 'المفضلة'},
    'empty_favorites': {'fr': 'Aucun favori pour le moment', 'en': 'No favorites yet', 'ar': 'لا توجد مفضلات بعد'},
    'empty_favorites_hint': {'fr': 'Touchez le cœur sur un produit pour le retrouver ici.', 'en': 'Tap the heart on a product to find it here.', 'ar': 'اضغطي على القلب في المنتج ليظهر هنا.'},
    'favorite_added': {'fr': 'Produit ajouté aux favoris', 'en': 'Product added to favorites', 'ar': 'تمت إضافة المنتج إلى المفضلة'},
    'favorite_removed': {'fr': 'Produit retiré des favoris', 'en': 'Product removed from favorites', 'ar': 'تم حذف المنتج من المفضلة'},
    'notifications_hint': {'fr': 'Activez un rappel quotidien pour votre routine.', 'en': 'Enable a daily reminder for your routine.', 'ar': 'فعّلي تذكيرا يوميا للروتين.'},
    'sounds_hint': {'fr': 'Joue un son lors des actions importantes.', 'en': 'Play a sound for important actions.', 'ar': 'تشغيل صوت عند الإجراءات المهمة.'},
    'vibration_hint': {'fr': 'Fait vibrer le téléphone pendant les confirmations.', 'en': 'Vibrate the phone on confirmations.', 'ar': 'اهتزاز الهاتف عند التأكيد.'},
    'language_hint': {'fr': 'La langue choisie s applique aux écrans principaux.', 'en': 'The selected language applies to the main screens.', 'ar': 'تُطبق اللغة المختارة على الشاشات الرئيسية.'},
    'notifications_on': {'fr': 'Notifications activées', 'en': 'Notifications enabled', 'ar': 'تم تفعيل الإشعارات'},
    'notifications_off': {'fr': 'Notifications désactivées', 'en': 'Notifications disabled', 'ar': 'تم إيقاف الإشعارات'},
    'notifications_denied': {'fr': 'Permission notification refusée', 'en': 'Notification permission denied', 'ar': 'تم رفض إذن الإشعارات'},
    'notif_enabled_title': {'fr': 'Notifications SkinSnap activées', 'en': 'SkinSnap notifications enabled', 'ar': 'تم تفعيل إشعارات سكين سناب'},
    'notif_enabled_body': {'fr': 'Vous recevrez vos rappels de routine.', 'en': 'You will receive your routine reminders.', 'ar': 'ستصلك تذكيرات الروتين.'},
    'test_feedback': {'fr': 'Tester son et vibration', 'en': 'Test sound and vibration', 'ar': 'اختبار الصوت والاهتزاز'},
    'test_notification': {'fr': 'Tester notification', 'en': 'Test notification', 'ar': 'اختبار الإشعار'},
    'feedback_ok': {'fr': 'Test effectué', 'en': 'Test done', 'ar': 'تم الاختبار'},
    'profile_title': {'fr': 'Mon profil beauté', 'en': 'My beauty profile', 'ar': 'ملفي الجمالي'},
    'history_title': {'fr': 'Historique des analyses', 'en': 'Analysis history', 'ar': 'سجل التحاليل'},
    'history_subtitle': {'fr': 'Voir vos anciens scans', 'en': 'View your previous scans', 'ar': 'عرض الفحوصات السابقة'},
    'settings_subtitle': {'fr': 'Mode sombre, langue, sons et notifications', 'en': 'Dark mode, language, sounds and notifications', 'ar': 'الوضع الداكن واللغة والصوت والإشعارات'},
    'about_subtitle': {'fr': 'Informations sur SkinSnap', 'en': 'Information about SkinSnap', 'ar': 'معلومات عن سكين سناب'},
    'about_intro': {'fr': 'SkinSnap vous aide à analyser votre peau, scanner des produits cosmétiques, créer une routine et choisir des produits adaptés.', 'en': 'SkinSnap helps you analyze your skin, scan cosmetic products, build a routine and choose suitable products.', 'ar': 'يساعدك سكين سناب على تحليل البشرة وفحص منتجات التجميل وإنشاء روتين واختيار منتجات مناسبة.'},
    'about_face_title': {'fr': 'Analyse visage', 'en': 'Face analysis', 'ar': 'تحليل الوجه'},
    'about_face_body': {'fr': 'Utilise Google ML Kit pour détecter le visage et générer une recommandation beauté.', 'en': 'Uses Google ML Kit to detect the face and create a beauty recommendation.', 'ar': 'يستخدم Google ML Kit لاكتشاف الوجه وإنشاء توصية جمالية.'},
    'about_product_title': {'fr': 'Scan produit réel', 'en': 'Real product scan', 'ar': 'فحص منتج حقيقي'},
    'about_product_body': {'fr': 'Lit le code-barres avec ML Kit et récupère les informations depuis Open Beauty Facts.', 'en': 'Reads the barcode with ML Kit and gets information from Open Beauty Facts.', 'ar': 'يقرأ الباركود بواسطة ML Kit ويحصل على المعلومات من Open Beauty Facts.'},
    'about_routine_title': {'fr': 'Routine personnalisée', 'en': 'Personalized routine', 'ar': 'روتين مخصص'},
    'about_routine_body': {'fr': 'Sauvegarde vos produits, favoris et progression de routine sur votre téléphone.', 'en': 'Saves your products, favorites and routine progress on your phone.', 'ar': 'يحفظ المنتجات والمفضلة وتقدم الروتين على هاتفك.'},
    'about_language_title': {'fr': 'Multilingue', 'en': 'Multilingual', 'ar': 'متعدد اللغات'},
    'about_language_body': {'fr': 'Les écrans principaux sont disponibles en français, anglais et arabe.', 'en': 'Main screens are available in French, English and Arabic.', 'ar': 'الشاشات الرئيسية متوفرة بالفرنسية والإنجليزية والعربية.'},
    'about_privacy_title': {'fr': 'Confidentialité', 'en': 'Privacy', 'ar': 'الخصوصية'},
    'about_privacy_1': {'fr': 'Vos favoris et routines restent liés à votre compte.', 'en': 'Your favorites and routines stay linked to your account.', 'ar': 'تبقى المفضلة والروتين مرتبطة بحسابك.'},
    'about_privacy_2': {'fr': 'Les images locales servent uniquement à afficher les produits.', 'en': 'Local images are only used to display products.', 'ar': 'تُستخدم الصور المحلية فقط لعرض المنتجات.'},
    'about_privacy_3': {'fr': 'Les conseils ne remplacent pas un dermatologue.', 'en': 'Advice does not replace a dermatologist.', 'ar': 'النصائح لا تعوض طبيب الجلدية.'},
    'wellness_advice': {'fr': 'Conseils bien-être : hydratez-vous, dormez suffisamment et gardez une routine simple pour protéger votre barrière cutanée.', 'en': 'Wellness tips: drink water, sleep well and keep a simple routine to protect your skin barrier.', 'ar': 'نصائح الرفاهية: اشربي الماء، نامي جيدا وحافظي على روتين بسيط لحماية حاجز البشرة.'},
    'hair_advice': {'fr': 'Conseils coiffure : choisissez des produits doux, évitez la chaleur excessive et adaptez vos soins au cuir chevelu.', 'en': 'Hair care tips: choose gentle products, avoid excessive heat and adapt care to your scalp.', 'ar': 'نصائح الشعر: اختاري منتجات لطيفة وتجنبي الحرارة الزائدة وكيّفي العناية مع فروة الرأس.'},

    'empty_categories_firestore': {'fr': 'Aucune catégorie trouvée. Ajoutez les documents dans Firestore > categories.', 'en': 'No categories found. Add documents in Firestore > categories.', 'ar': 'لم يتم العثور على فئات. أضيفي المستندات في Firestore > categories'},
    'empty_products_firestore': {'fr': 'Aucun produit trouvé en temps réel. Ajoutez vos produits dans Firestore > products.', 'en': 'No real-time products found. Add your products in Firestore > products.', 'ar': 'لم يتم العثور على منتجات مباشرة. أضيفي المنتجات في Firestore > products'},
    'empty_routine_steps_firestore': {'fr': 'Aucune étape trouvée. Ajoutez les étapes dans Firestore > routine_steps.', 'en': 'No routine steps found. Add steps in Firestore > routine_steps.', 'ar': 'لم يتم العثور على خطوات. أضيفي الخطوات في Firestore > routine_steps'},
    'product_not_found': {'fr': 'Produit non trouvé', 'en': 'Product not found', 'ar': 'المنتج غير موجود'},
    'makeup_local_hint': {'fr': 'Look adapté à votre type de peau.', 'en': 'Look adapted to your skin type.', 'ar': 'مظهر مناسب لنوع بشرتك.'},
    'makeup_analysis_hint': {'fr': 'Look adapté à votre analyse :', 'en': 'Look adapted to your analysis:', 'ar': 'مظهر مناسب لتحليلك:'},
  };

  static String of(String key, Locale locale) {
    final entry = _data[key];
    if (entry == null) return key;
    return entry[locale.languageCode] ?? entry['fr'] ?? key;
  }
}
