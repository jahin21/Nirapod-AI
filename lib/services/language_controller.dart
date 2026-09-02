import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_translations.dart';

class AppLanguageController {
  AppLanguageController._();

  static const _preferenceKey = 'nirapod_language';
  static final language = ValueNotifier<String>('en');
  static const supportedLocales = [Locale('en'), Locale('ms'), Locale('bn')];
  static Locale get locale => Locale(language.value);

  static String get nativeName => switch (language.value) {
        'ms' => 'Bahasa Melayu',
        'bn' => 'বাংলা',
        _ => 'English',
      };

  static Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(_preferenceKey);
    language.value = const {'en', 'ms', 'bn'}.contains(saved) ? saved! : 'en';
  }

  static Future<void> setLanguage(String value) async {
    if (!const {'en', 'ms', 'bn'}.contains(value)) return;
    language.value = value;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_preferenceKey, value);
  }

  static String text(String key) => translate(_keys[key] ?? key);

  /// Translates application-owned copy. URLs, email addresses, user input and
  /// scan evidence are deliberately left unchanged.
  static String translate(String source) {
    if (language.value == 'en' || source.trim().isEmpty) return source;
    if (const {
      'ZAKARYA JAHIN',
      'UNIVERSITY OF CYBERJAYA',
      'YUDI BUDI SUSILO',
    }.contains(source)) {
      return source;
    }
    final table = language.value == 'bn' ? _bn : _ms;
    final exact = table[source];
    if (exact != null) return exact;
    final additional = additionalTranslations[source]?[language.value];
    if (additional != null) return additional;

    final repeatedInspection = RegExp(
      r'^Repeat (Wi-Fi|Bluetooth) Inspection \((\d+)\)$',
    ).firstMatch(source);
    if (repeatedInspection != null) {
      final device = repeatedInspection.group(1)!;
      final count = repeatedInspection.group(2)!;
      return language.value == 'bn'
          ? '$device পরিদর্শন পুনরাবৃত্তি করুন ($count)'
          : 'Ulangi Pemeriksaan $device ($count)';
    }

    final templated = _translateTemplate(source);
    if (templated != null) return templated;

    final hello = RegExp(r'^Hello, (.+)!').firstMatch(source);
    if (hello != null) {
      return language.value == 'bn'
          ? 'হ্যালো, ${hello.group(1)}! 👋'
          : 'Helo, ${hello.group(1)}! 👋';
    }
    final showing =
        RegExp(r'^Showing (\d+) of (\d+) scans$').firstMatch(source);
    if (showing != null) {
      return language.value == 'bn'
          ? '${showing.group(2)}টি স্ক্যানের মধ্যে ${showing.group(1)}টি দেখানো হচ্ছে'
          : 'Menunjukkan ${showing.group(1)} daripada ${showing.group(2)} imbasan';
    }
    final supportTicket =
        RegExp(r'^Support ticket #(\d+) was saved successfully\.$')
            .firstMatch(source);
    if (supportTicket != null) {
      return language.value == 'bn'
          ? 'সহায়তা টিকিট #${supportTicket.group(1)} সফলভাবে সংরক্ষিত হয়েছে।'
          : 'Tiket sokongan #${supportTicket.group(1)} berjaya disimpan.';
    }
    final authError =
        RegExp(r'^Authentication was not completed: (.+)$').firstMatch(source);
    if (authError != null) {
      return language.value == 'bn'
          ? 'প্রমাণীকরণ সম্পন্ন হয়নি: ${authError.group(1)}'
          : 'Pengesahan tidak selesai: ${authError.group(1)}';
    }
    if (source.startsWith('No ') && source.endsWith(' records yet.')) {
      final type = source.substring(3, source.length - 13);
      return language.value == 'bn'
          ? 'এখনও কোনো ${translate(type)} রেকর্ড নেই।'
          : 'Belum ada rekod ${translate(type)}.';
    }
    return source;
  }

  static String? _translateTemplate(String source) {
    final placeholder = RegExp(r'\$\{[^}]+\}|\$[A-Za-z_]\w*');
    for (final entry in additionalTranslations.entries) {
      final matches = placeholder.allMatches(entry.key).toList();
      if (matches.isEmpty) continue;
      final pattern = StringBuffer('^');
      var cursor = 0;
      for (final match in matches) {
        pattern.write(RegExp.escape(entry.key.substring(cursor, match.start)));
        pattern.write('(.*?)');
        cursor = match.end;
      }
      pattern.write(RegExp.escape(entry.key.substring(cursor)));
      pattern.write(r'$');
      final sourceMatch = RegExp(pattern.toString()).firstMatch(source);
      if (sourceMatch == null) continue;
      final template = entry.value[language.value];
      if (template == null) return null;
      var translated = template;
      for (var index = 0; index < matches.length; index++) {
        translated = translated.replaceAll(
          matches[index].group(0)!,
          sourceMatch.group(index + 1) ?? '',
        );
      }
      return translated;
    }
    return null;
  }

  static const _keys = <String, String>{
    'settings': 'Settings',
    'settings_subtitle':
        'Customize your app experience and security preferences',
    'scan_preferences': 'Scan Preferences',
    'security': 'Security',
    'appearance': 'Appearance & Language',
    'language': 'Language',
    'language_subtitle': 'Choose the language used by Nirapod AI',
    'choose_language': 'Choose language',
    'language_saved': 'Language changed to English.',
    'safety_matters': 'Your Safety Matters',
    'safety_text':
        'These settings help us protect you better. You can change them anytime.',
  };

  static const _ms = <String, String>{
    'Settings': 'Tetapan',
    'Customize your app experience and security preferences':
        'Sesuaikan pengalaman aplikasi dan pilihan keselamatan anda',
    'Scan Preferences': 'Pilihan Imbasan',
    'Security': 'Keselamatan',
    'Appearance & Language': 'Paparan & Bahasa',
    'Language': 'Bahasa',
    'Choose the language used by Nirapod AI':
        'Pilih bahasa yang digunakan oleh Nirapod AI',
    'Choose language': 'Pilih bahasa',
    'Language changed to English.': 'Bahasa ditukar kepada Bahasa Melayu.',
    'Your Safety Matters': 'Keselamatan Anda Penting',
    'These settings help us protect you better. You can change them anytime.':
        'Tetapan ini membantu kami melindungi anda. Anda boleh mengubahnya pada bila-bila masa.',
    'Home': 'Utama',
    'History': 'Sejarah',
    'Scan': 'Imbas',
    'Reports': 'Laporan',
    'Profile': 'Profil',
    'Login': 'Log Masuk',
    'Log Out': 'Log Keluar',
    'Sign Up': 'Daftar',
    'Email Address': 'Alamat E-mel',
    'Password': 'Kata Laluan',
    'Forgot Password?': 'Lupa Kata Laluan?',
    'Welcome Back!': 'Selamat Kembali!',
    'Enter your email': 'Masukkan e-mel anda',
    'Enter your password': 'Masukkan kata laluan anda',
    'or login with': 'atau log masuk dengan',
    'Already have an account? Log in': 'Sudah mempunyai akaun? Log masuk',
    'Don’t have an account?': 'Belum mempunyai akaun?',
    'Create Account': 'Cipta Akaun',
    'Stay safe online. We’ve got your back.':
        'Kekal selamat dalam talian. Kami melindungi anda.',
    'Total Scans': 'Jumlah Imbasan',
    'This month': 'Bulan ini',
    'Safe': 'Selamat',
    'Suspicious': 'Mencurigakan',
    'Phishing': 'Pancingan Data',
    'Dangerous': 'Berbahaya',
    'Quick Scan': 'Imbasan Pantas',
    'Choose a scan type to get started': 'Pilih jenis imbasan untuk bermula',
    'URL / Link': 'URL / Pautan',
    'QR Code': 'Kod QR',
    'Message': 'Mesej',
    'Screenshot': 'Tangkapan Skrin',
    'Room Check': 'Pemeriksaan Bilik',
    'Room Checks': 'Pemeriksaan Bilik',
    'Recent Scans': 'Imbasan Terkini',
    'View All': 'Lihat Semua',
    'Select Scan Type': 'Pilih Jenis Imbasan',
    'Choose what you want to scan': 'Pilih perkara yang ingin diimbas',
    'URL / Link Scanner': 'Pengimbas URL / Pautan',
    'QR Code Scanner': 'Pengimbas Kod QR',
    'Message / Text Scanner': 'Pengimbas Mesej / Teks',
    'Screenshot / OCR': 'Tangkapan Skrin / OCR',
    'Hidden Camera Safety Check': 'Pemeriksaan Keselamatan Kamera Tersembunyi',
    'Scan URL': 'Imbas URL',
    'Scan QR Code': 'Imbas Kod QR',
    'Scan Message': 'Imbas Mesej',
    'Scan Email': 'Imbas E-mel',
    'Choose Image': 'Pilih Imej',
    'Use Camera': 'Gunakan Kamera',
    'Take a Photo': 'Ambil Foto',
    'Try Again': 'Cuba Lagi',
    'Enter URL to Scan': 'Masukkan URL untuk Diimbas',
    'Paste text here...': 'Tampal teks di sini...',
    'Paste Text': 'Tampal Teks',
    'SMS': 'SMS',
    'Email': 'E-mel',
    'Search scans...': 'Cari imbasan...',
    'All': 'Semua',
    'Links': 'Pautan',
    'QR Codes': 'Kod QR',
    'Messages': 'Mesej',
    'Screenshots': 'Tangkapan Skrin',
    'No scans yet.': 'Belum ada imbasan.',
    'Start a scan to create history.':
        'Mulakan imbasan untuk mencipta sejarah.',
    'No matching records were found.': 'Tiada rekod sepadan ditemui.',
    'Load More': 'Muat Lagi',
    'Retry': 'Cuba Semula',
    'Insights and statistics about your security':
        'Cerapan dan statistik tentang keselamatan anda',
    'Threats': 'Ancaman',
    'Safe Items': 'Item Selamat',
    'Scans Over Time': 'Imbasan Mengikut Masa',
    'Recent Threats': 'Ancaman Terkini',
    'Account Information': 'Maklumat Akaun',
    'Notifications': 'Pemberitahuan',
    'Privacy Settings': 'Tetapan Privasi',
    'Help Center': 'Pusat Bantuan',
    'Support & More': 'Sokongan & Lain-lain',
    'Dark Mode': 'Mod Gelap',
    'Use dark theme throughout the app':
        'Gunakan tema gelap di seluruh aplikasi',
    'Text Size': 'Saiz Teks',
    'Accent Color': 'Warna Aksen',
    'App Lock': 'Kunci Aplikasi',
    'Threat Intelligence Updates': 'Kemas Kini Perisikan Ancaman',
    'Cloud Protection': 'Perlindungan Awan',
    'Auto Scan Links': 'Imbas Pautan Secara Automatik',
    'Scan Notifications': 'Pemberitahuan Imbasan',
    'Wi-Fi Scan Warning': 'Amaran Imbasan Wi-Fi',
    'Default Browser': 'Pelayar Lalai',
    'Save Scan History': 'Simpan Sejarah Imbasan',
    'Help Articles': 'Artikel Bantuan',
    'Popular Topics': 'Topik Popular',
    'Search for help articles...': 'Cari artikel bantuan...',
    'Contact Support': 'Hubungi Sokongan',
    'Done': 'Selesai',
    'Cancel': 'Batal',
    'Save': 'Simpan',
    'Submit': 'Hantar',
    'Mark all as read': 'Tandakan semua sebagai dibaca',
    'Community Reports': 'Laporan Komuniti',
    'Learning Centre': 'Pusat Pembelajaran',
    'Scan Result': 'Keputusan Imbasan',
    'Risk Score': 'Skor Risiko',
    'Scan Again': 'Imbas Lagi',
    'Ask AI': 'Tanya AI',
    'Nirapod Guide': 'Panduan Nirapod',
    'AI cybersecurity assistant': 'Pembantu keselamatan siber AI',
    'Ask any security question…': 'Tanya apa-apa soalan keselamatan…',
    'Thinking…': 'Sedang berfikir…',
    'Analyzing...': 'Menganalisis...',
    'Please wait while we scan': 'Sila tunggu sementara kami mengimbas',
    'Upload Screenshot or Image': 'Muat Naik Tangkapan Skrin atau Imej',
    'Additional Information': 'Maklumat Tambahan',
    'Categories': 'Kategori',
    'Popular Articles': 'Artikel Popular',
    'Trending Now': 'Popular Sekarang',
    'Recently Reported': 'Baru Dilaporkan',
    'Together We Stay Safe': 'Bersama Kita Kekal Selamat',
    'See the latest scams reported by our community.':
        'Lihat penipuan terkini yang dilaporkan oleh komuniti kami.',
    'What are you reporting?': 'Apakah yang anda laporkan?',
    'Status': 'Status',
    'Back to Login': 'Kembali ke Log Masuk',
    'Forgot Password': 'Lupa Kata Laluan',
    'Go Home': 'Kembali ke Utama',
    'OK': 'OK',
    'or': 'atau',
    'Enter a URL before scanning.': 'Masukkan URL sebelum mengimbas.',
    'Enter a valid email and password.':
        'Masukkan e-mel dan kata laluan yang sah.',
    'No notifications yet. New scan results will appear here.':
        'Belum ada pemberitahuan. Keputusan imbasan baharu akan muncul di sini.',
    'No matching help articles were found.':
        'Tiada artikel bantuan sepadan ditemui.',
    'Your activity chart will appear here':
        'Carta aktiviti anda akan muncul di sini',
    'Last 30 days': '30 hari terakhir',
    'JPG, PNG, WEBP up to 10MB': 'JPG, PNG, WEBP sehingga 10MB',
    'Toggle flashlight': 'Hidupkan atau matikan lampu suluh',
    'Scan website links': 'Imbas pautan laman web',
    'Scan QR codes': 'Imbas kod QR',
    'Scan messages': 'Imbas mesej',
    'Scan images': 'Imbas imej',
    'Scanned just now': 'Baru sahaja diimbas',
    'Version 1.0.0': 'Versi 1.0.0',
  };

  static const _bn = <String, String>{
    'Settings': 'সেটিংস',
    'Customize your app experience and security preferences':
        'অ্যাপের অভিজ্ঞতা ও নিরাপত্তার পছন্দ পরিবর্তন করুন',
    'Scan Preferences': 'স্ক্যান পছন্দ',
    'Security': 'নিরাপত্তা',
    'Appearance & Language': 'চেহারা ও ভাষা',
    'Language': 'ভাষা',
    'Choose the language used by Nirapod AI':
        'Nirapod-এ ব্যবহারের ভাষা নির্বাচন করুন',
    'Choose language': 'ভাষা নির্বাচন করুন',
    'Language changed to English.': 'ভাষা বাংলায় পরিবর্তন করা হয়েছে।',
    'Your Safety Matters': 'আপনার নিরাপত্তা গুরুত্বপূর্ণ',
    'These settings help us protect you better. You can change them anytime.':
        'এই সেটিংস আপনাকে আরও ভালোভাবে সুরক্ষিত রাখতে সাহায্য করে। যেকোনো সময় পরিবর্তন করতে পারবেন।',
    'Home': 'হোম',
    'History': 'ইতিহাস',
    'Scan': 'স্ক্যান',
    'Reports': 'রিপোর্ট',
    'Profile': 'প্রোফাইল',
    'Login': 'লগ ইন',
    'Log Out': 'লগ আউট',
    'Sign Up': 'নিবন্ধন',
    'Email Address': 'ইমেইল ঠিকানা',
    'Password': 'পাসওয়ার্ড',
    'Forgot Password?': 'পাসওয়ার্ড ভুলে গেছেন?',
    'Welcome Back!': 'আবার স্বাগতম!',
    'Enter your email': 'আপনার ইমেইল লিখুন',
    'Enter your password': 'আপনার পাসওয়ার্ড লিখুন',
    'or login with': 'অথবা লগ ইন করুন',
    'Already have an account? Log in': 'আগেই অ্যাকাউন্ট আছে? লগ ইন করুন',
    'Don’t have an account?': 'অ্যাকাউন্ট নেই?',
    'Create Account': 'অ্যাকাউন্ট তৈরি করুন',
    'Stay safe online. We’ve got your back.':
        'অনলাইনে নিরাপদ থাকুন। আমরা আপনার পাশে আছি।',
    'Total Scans': 'মোট স্ক্যান',
    'This month': 'এই মাসে',
    'Safe': 'নিরাপদ',
    'Suspicious': 'সন্দেহজনক',
    'Phishing': 'ফিশিং',
    'Dangerous': 'বিপজ্জনক',
    'Quick Scan': 'দ্রুত স্ক্যান',
    'Choose a scan type to get started': 'শুরু করতে স্ক্যানের ধরন বেছে নিন',
    'URL / Link': 'URL / লিংক',
    'QR Code': 'QR কোড',
    'Message': 'বার্তা',
    'Screenshot': 'স্ক্রিনশট',
    'Room Check': 'কক্ষ পরীক্ষা',
    'Room Checks': 'কক্ষ পরীক্ষা',
    'Recent Scans': 'সাম্প্রতিক স্ক্যান',
    'View All': 'সব দেখুন',
    'Select Scan Type': 'স্ক্যানের ধরন নির্বাচন করুন',
    'Choose what you want to scan': 'আপনি কী স্ক্যান করতে চান তা বেছে নিন',
    'URL / Link Scanner': 'URL / লিংক স্ক্যানার',
    'QR Code Scanner': 'QR কোড স্ক্যানার',
    'Message / Text Scanner': 'বার্তা / টেক্সট স্ক্যানার',
    'Screenshot / OCR': 'স্ক্রিনশট / OCR',
    'Hidden Camera Safety Check': 'গোপন ক্যামেরা নিরাপত্তা পরীক্ষা',
    'Scan URL': 'URL স্ক্যান করুন',
    'Scan QR Code': 'QR কোড স্ক্যান করুন',
    'Scan Message': 'বার্তা স্ক্যান করুন',
    'Scan Email': 'ইমেইল স্ক্যান করুন',
    'Choose Image': 'ছবি বেছে নিন',
    'Use Camera': 'ক্যামেরা ব্যবহার করুন',
    'Take a Photo': 'ছবি তুলুন',
    'Try Again': 'আবার চেষ্টা করুন',
    'Enter URL to Scan': 'স্ক্যান করার URL লিখুন',
    'Paste text here...': 'এখানে টেক্সট পেস্ট করুন...',
    'Paste Text': 'টেক্সট পেস্ট',
    'SMS': 'এসএমএস',
    'Email': 'ইমেইল',
    'Search scans...': 'স্ক্যান খুঁজুন...',
    'All': 'সব',
    'Links': 'লিংক',
    'QR Codes': 'QR কোড',
    'Messages': 'বার্তা',
    'Screenshots': 'স্ক্রিনশট',
    'No scans yet.': 'এখনও কোনো স্ক্যান নেই।',
    'Start a scan to create history.':
        'ইতিহাস তৈরি করতে একটি স্ক্যান শুরু করুন।',
    'No matching records were found.': 'কোনো মিলযুক্ত রেকর্ড পাওয়া যায়নি।',
    'Load More': 'আরও দেখুন',
    'Retry': 'আবার চেষ্টা করুন',
    'Insights and statistics about your security':
        'আপনার নিরাপত্তার তথ্য ও পরিসংখ্যান',
    'Threats': 'হুমকি',
    'Safe Items': 'নিরাপদ আইটেম',
    'Scans Over Time': 'সময়ের সাথে স্ক্যান',
    'Recent Threats': 'সাম্প্রতিক হুমকি',
    'Account Information': 'অ্যাকাউন্ট তথ্য',
    'Notifications': 'বিজ্ঞপ্তি',
    'Privacy Settings': 'গোপনীয়তা সেটিংস',
    'Help Center': 'সহায়তা কেন্দ্র',
    'Support & More': 'সহায়তা ও আরও',
    'Dark Mode': 'ডার্ক মোড',
    'Use dark theme throughout the app': 'পুরো অ্যাপে গাঢ় থিম ব্যবহার করুন',
    'Text Size': 'লেখার আকার',
    'Accent Color': 'প্রধান রং',
    'App Lock': 'অ্যাপ লক',
    'Threat Intelligence Updates': 'হুমকি তথ্যের আপডেট',
    'Cloud Protection': 'ক্লাউড সুরক্ষা',
    'Auto Scan Links': 'লিংক স্বয়ংক্রিয় স্ক্যান',
    'Scan Notifications': 'স্ক্যান বিজ্ঞপ্তি',
    'Wi-Fi Scan Warning': 'Wi-Fi স্ক্যান সতর্কতা',
    'Default Browser': 'ডিফল্ট ব্রাউজার',
    'Save Scan History': 'স্ক্যান ইতিহাস সংরক্ষণ',
    'Help Articles': 'সহায়তা নিবন্ধ',
    'Popular Topics': 'জনপ্রিয় বিষয়',
    'Search for help articles...': 'সহায়তা নিবন্ধ খুঁজুন...',
    'Contact Support': 'সহায়তায় যোগাযোগ করুন',
    'Done': 'সম্পন্ন',
    'Cancel': 'বাতিল',
    'Save': 'সংরক্ষণ',
    'Submit': 'জমা দিন',
    'Mark all as read': 'সব পড়া হয়েছে হিসেবে চিহ্নিত করুন',
    'Community Reports': 'কমিউনিটি রিপোর্ট',
    'Learning Centre': 'শিক্ষা কেন্দ্র',
    'Scan Result': 'স্ক্যানের ফলাফল',
    'Risk Score': 'ঝুঁকির স্কোর',
    'Scan Again': 'আবার স্ক্যান করুন',
    'Ask AI': 'AI-কে জিজ্ঞাসা করুন',
    'Nirapod Guide': 'Nirapod গাইড',
    'AI cybersecurity assistant': 'AI সাইবার নিরাপত্তা সহকারী',
    'Ask any security question…': 'যেকোনো নিরাপত্তা প্রশ্ন করুন…',
    'Thinking…': 'ভাবছি…',
    'Analyzing...': 'বিশ্লেষণ করা হচ্ছে...',
    'Please wait while we scan': 'স্ক্যান চলাকালীন অপেক্ষা করুন',
    'Upload Screenshot or Image': 'স্ক্রিনশট বা ছবি আপলোড করুন',
    'Additional Information': 'অতিরিক্ত তথ্য',
    'Categories': 'বিভাগ',
    'Popular Articles': 'জনপ্রিয় নিবন্ধ',
    'Trending Now': 'এখন জনপ্রিয়',
    'Recently Reported': 'সম্প্রতি রিপোর্ট করা',
    'Together We Stay Safe': 'একসাথে আমরা নিরাপদ',
    'See the latest scams reported by our community.':
        'কমিউনিটির রিপোর্ট করা সর্বশেষ প্রতারণা দেখুন।',
    'What are you reporting?': 'আপনি কী রিপোর্ট করছেন?',
    'Status': 'অবস্থা',
    'Back to Login': 'লগ ইনে ফিরে যান',
    'Forgot Password': 'পাসওয়ার্ড ভুলে গেছেন',
    'Go Home': 'হোমে যান',
    'OK': 'ঠিক আছে',
    'or': 'অথবা',
    'Enter a URL before scanning.': 'স্ক্যান করার আগে একটি URL লিখুন।',
    'Enter a valid email and password.': 'সঠিক ইমেইল ও পাসওয়ার্ড লিখুন।',
    'No notifications yet. New scan results will appear here.':
        'এখনও কোনো বিজ্ঞপ্তি নেই। নতুন স্ক্যানের ফলাফল এখানে দেখা যাবে।',
    'No matching help articles were found.':
        'কোনো মিলযুক্ত সহায়তা নিবন্ধ পাওয়া যায়নি।',
    'Your activity chart will appear here':
        'আপনার কার্যকলাপের চার্ট এখানে দেখা যাবে',
    'Last 30 days': 'গত ৩০ দিন',
    'JPG, PNG, WEBP up to 10MB': 'JPG, PNG, WEBP সর্বোচ্চ ১০MB',
    'Toggle flashlight': 'ফ্ল্যাশলাইট চালু/বন্ধ করুন',
    'Scan website links': 'ওয়েবসাইট লিংক স্ক্যান করুন',
    'Scan QR codes': 'QR কোড স্ক্যান করুন',
    'Scan messages': 'বার্তা স্ক্যান করুন',
    'Scan images': 'ছবি স্ক্যান করুন',
    'Scanned just now': 'এইমাত্র স্ক্যান করা হয়েছে',
    'Version 1.0.0': 'সংস্করণ ১.০.০',
  };
}
