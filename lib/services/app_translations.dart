// Centralized application-owned translations shared across screens.
// User content, URLs, account data, and scan evidence are deliberately excluded.
const additionalTranslations = <String, Map<String, String>>{
  'Visual analysis': <String, String>{
    'ms': 'Analisis visual',
    'bn': 'ভিজ্যুয়াল বিশ্লেষণ',
  },
  'Stage A recognized an ordinary \$label (\$confidence%). This resemblance is not proof that the device or room is safe.':
      <String, String>{
    'ms':
        'Tahap A mengenal pasti peranti biasa \$label (\$confidence%). Persamaan ini bukan bukti bahawa peranti atau bilik itu selamat.',
    'bn':
        'ধাপ A একটি সাধারণ \$label শনাক্ত করেছে (\$confidence%)। এই সাদৃশ্য ডিভাইস বা কক্ষ নিরাপদ হওয়ার প্রমাণ নয়।',
  },
  'Stage A was below the safety gate (\$confidence%), so the image was treated as unclassified and Stage B visual heuristics were run. Reflection and pinhole patterns can come from ordinary objects and are not conclusive.':
      <String, String>{
    'ms':
        'Tahap A berada di bawah ambang keselamatan (\$confidence%), jadi imej dianggap tidak terkelas dan heuristik visual Tahap B dijalankan. Corak pantulan dan lubang kecil boleh datang daripada objek biasa dan bukan bukti muktamad.',
    'bn':
        'ধাপ A নিরাপত্তা সীমার নিচে ছিল (\$confidence%), তাই ছবিটিকে অশ্রেণিবদ্ধ ধরে ধাপ B-এর ভিজ্যুয়াল হিউরিস্টিক চালানো হয়েছে। প্রতিফলন ও ক্ষুদ্র ছিদ্রের মতো প্যাটার্ন সাধারণ বস্তু থেকেও আসতে পারে এবং চূড়ান্ত প্রমাণ নয়।',
  },
  'Signal evidence and limitations': <String, String>{
    'ms': 'Bukti isyarat dan batasan',
    'bn': 'সংকেতের প্রমাণ ও সীমাবদ্ধতা',
  },
  'Visual heuristic check': <String, String>{
    'ms': 'Pemeriksaan heuristik visual',
    'bn': 'দৃশ্যগত হিউরিস্টিক পরীক্ষা',
  },
  'Network camera-service check': <String, String>{
    'ms': 'Pemeriksaan perkhidmatan kamera rangkaian',
    'bn': 'নেটওয়ার্ক ক্যামেরা-সেবা পরীক্ষা',
  },
  'Bluetooth name check': <String, String>{
    'ms': 'Pemeriksaan nama Bluetooth',
    'bn': 'ব্লুটুথ নাম পরীক্ষা',
  },
  'Thermal accessory check': <String, String>{
    'ms': 'Pemeriksaan aksesori terma',
    'bn': 'থার্মাল অ্যাক্সেসরি পরীক্ষা',
  },
  'Directional RF check': <String, String>{
    'ms': 'Pemeriksaan RF berarah',
    'bn': 'দিকনির্দেশক RF পরীক্ষা',
  },
  'UWB participating-device check': <String, String>{
    'ms': 'Pemeriksaan peranti UWB yang mengambil bahagian',
    'bn': 'অংশগ্রহণকারী UWB ডিভাইস পরীক্ষা',
  },
  'Detected': <String, String>{
    'ms': 'Dikesan',
    'bn': 'শনাক্ত হয়েছে',
  },
  'No hit reported': <String, String>{
    'ms': 'Tiada padanan dilaporkan',
    'bn': 'কোনো সংকেত পাওয়া যায়নি',
  },
  'Caution': <String, String>{
    'ms': 'Berhati-hati',
    'bn': 'সতর্কতা',
  },
  'Reflections can come from ordinary electronics or shiny materials and are not conclusive.':
      <String, String>{
    'ms':
        'Pantulan boleh datang daripada elektronik biasa atau bahan berkilat dan tidak muktamad.',
    'bn':
        'প্রতিফলন সাধারণ ইলেকট্রনিক যন্ত্র বা চকচকে বস্তু থেকেও আসতে পারে এবং এটি চূড়ান্ত প্রমাণ নয়।',
  },
  'An exposed streaming port can belong to an authorized camera or unrelated service.':
      <String, String>{
    'ms':
        'Port penstriman terbuka mungkin milik kamera yang dibenarkan atau perkhidmatan yang tidak berkaitan.',
    'bn':
        'উন্মুক্ত স্ট্রিমিং পোর্ট অনুমোদিত ক্যামেরা বা সম্পর্কহীন সেবারও হতে পারে।',
  },
  'Bluetooth names can be spoofed or misleading and are not conclusive.':
      <String, String>{
    'ms':
        'Nama Bluetooth boleh dipalsukan atau mengelirukan dan tidak muktamad.',
    'bn':
        'ব্লুটুথ নাম নকল বা বিভ্রান্তিকর হতে পারে এবং এটি চূড়ান্ত প্রমাণ নয়।',
  },
  'Heat can come from normal electronics; thermal evidence requires compatible calibrated hardware and context.':
      <String, String>{
    'ms':
        'Haba boleh datang daripada elektronik biasa; bukti terma memerlukan perkakasan serasi yang ditentukur dan konteks.',
    'bn':
        'স্বাভাবিক ইলেকট্রনিক যন্ত্র থেকেও তাপ আসতে পারে; থার্মাল প্রমাণের জন্য ক্যালিব্রেট করা সামঞ্জস্যপূর্ণ হার্ডওয়্যার ও প্রাসঙ্গিক তথ্য দরকার।',
  },
  'Radio signals may come from legitimate nearby devices and require specialist directional hardware.':
      <String, String>{
    'ms':
        'Isyarat radio mungkin datang daripada peranti sah berdekatan dan memerlukan perkakasan arah khusus.',
    'bn':
        'রেডিও সংকেত কাছাকাছি বৈধ ডিভাইস থেকেও আসতে পারে এবং বিশেষ দিকনির্দেশক হার্ডওয়্যার প্রয়োজন।',
  },
  'UWB detects only compatible participating devices and cannot identify an ordinary hidden camera.':
      <String, String>{
    'ms':
        'UWB hanya mengesan peranti serasi yang mengambil bahagian dan tidak dapat mengenal pasti kamera tersembunyi biasa.',
    'bn':
        'UWB কেবল সামঞ্জস্যপূর্ণ অংশগ্রহণকারী ডিভাইস শনাক্ত করে এবং সাধারণ গোপন ক্যামেরা চিহ্নিত করতে পারে না।',
  },
  'One supporting signal was reported. It is not conclusive by itself; verify it without touching the object.':
      <String, String>{
    'ms':
        'Satu isyarat sokongan dilaporkan. Ia tidak muktamad dengan sendirinya; sahkan tanpa menyentuh objek tersebut.',
    'bn':
        'একটি সহায়ক সংকেত পাওয়া গেছে। একা এটি চূড়ান্ত নয়; বস্তুটি স্পর্শ না করে যাচাই করুন।',
  },
  'If an account exists for that email, a single-use reset token has been sent. It expires in 30 minutes.':
      <String, String>{
    'ms':
        'Jika akaun wujud untuk e-mel itu, token tetapan semula sekali guna telah dihantar. Token tamat tempoh dalam 30 minit.',
    'bn':
        'এই ইমেইলের জন্য অ্যাকাউন্ট থাকলে একবার ব্যবহারযোগ্য রিসেট টোকেন পাঠানো হয়েছে। এটি ৩০ মিনিটে মেয়াদোত্তীর্ণ হবে।',
  },
  'Password recovery email is not configured on this server.': <String, String>{
    'ms': 'E-mel pemulihan kata laluan belum dikonfigurasi pada pelayan ini.',
    'bn': 'এই সার্ভারে পাসওয়ার্ড পুনরুদ্ধার ইমেইল কনফিগার করা নেই।',
  },
  'Password recovery email is temporarily unavailable.': <String, String>{
    'ms': 'E-mel pemulihan kata laluan tidak tersedia buat sementara waktu.',
    'bn': 'পাসওয়ার্ড পুনরুদ্ধার ইমেইল সাময়িকভাবে অনুপলভ্য।',
  },
  'Password reset successfully. Sign in with your new password.':
      <String, String>{
    'ms':
        'Kata laluan berjaya ditetapkan semula. Log masuk dengan kata laluan baharu anda.',
    'bn': 'পাসওয়ার্ড সফলভাবে রিসেট হয়েছে। নতুন পাসওয়ার্ড দিয়ে লগইন করুন।',
  },
  'This password reset token is invalid or expired.': <String, String>{
    'ms':
        'Token tetapan semula kata laluan ini tidak sah atau telah tamat tempoh.',
    'bn': 'এই পাসওয়ার্ড রিসেট টোকেনটি অবৈধ অথবা মেয়াদোত্তীর্ণ।',
  },
  'Enter a valid email address.': <String, String>{
    'ms': 'Masukkan alamat e-mel yang sah.',
    'bn': 'একটি বৈধ ইমেইল ঠিকানা লিখুন।',
  },
  'Enter the reset token and at least 8 password characters.': <String, String>{
    'ms':
        'Masukkan token tetapan semula dan kata laluan sekurang-kurangnya 8 aksara.',
    'bn': 'রিসেট টোকেন এবং কমপক্ষে ৮ অক্ষরের পাসওয়ার্ড লিখুন।',
  },
  'Please wait...': <String, String>{
    'ms': 'Sila tunggu...',
    'bn': 'অনুগ্রহ করে অপেক্ষা করুন...',
  },
  'Reset Token': <String, String>{
    'ms': 'Token Tetapan Semula',
    'bn': 'রিসেট টোকেন',
  },
  'Paste the token from your email': <String, String>{
    'ms': 'Tampal token daripada e-mel anda',
    'bn': 'আপনার ইমেইল থেকে টোকেনটি পেস্ট করুন',
  },
  'New Password': <String, String>{
    'ms': 'Kata Laluan Baharu',
    'bn': 'নতুন পাসওয়ার্ড',
  },
  'At least 8 characters': <String, String>{
    'ms': 'Sekurang-kurangnya 8 aksara',
    'bn': 'কমপক্ষে ৮ অক্ষর',
  },
  'Reset Password': <String, String>{
    'ms': 'Tetapkan Semula Kata Laluan',
    'bn': 'পাসওয়ার্ড রিসেট করুন',
  },
  'Google sign-in is coming soon': <String, String>{
    'ms': 'Log masuk Google akan datang tidak lama lagi',
    'bn': 'Google সাইন-ইন শীঘ্রই আসছে',
  },
  'Facebook sign-in is coming soon': <String, String>{
    'ms': 'Log masuk Facebook akan datang tidak lama lagi',
    'bn': 'Facebook সাইন-ইন শীঘ্রই আসছে',
  },
  'Microsoft / Outlook sign-in is coming soon': <String, String>{
    'ms': 'Log masuk Microsoft / Outlook akan datang tidak lama lagi',
    'bn': 'Microsoft / Outlook সাইন-ইন শীঘ্রই আসছে',
  },
  'This release supports secure email and password sign-in. Google OAuth has not been enabled yet.':
      <String, String>{
    'ms':
        'Versi ini menyokong log masuk e-mel dan kata laluan yang selamat. Google OAuth belum diaktifkan.',
    'bn':
        'এই সংস্করণে নিরাপদ ইমেইল ও পাসওয়ার্ড সাইন-ইন রয়েছে। Google OAuth এখনও চালু করা হয়নি।',
  },
  'This release supports secure email and password sign-in. Facebook OAuth has not been enabled yet.':
      <String, String>{
    'ms':
        'Versi ini menyokong log masuk e-mel dan kata laluan yang selamat. Facebook OAuth belum diaktifkan.',
    'bn':
        'এই সংস্করণে নিরাপদ ইমেইল ও পাসওয়ার্ড সাইন-ইন রয়েছে। Facebook OAuth এখনও চালু করা হয়নি।',
  },
  'This release supports secure email and password sign-in. Microsoft / Outlook OAuth has not been enabled yet.':
      <String, String>{
    'ms':
        'Versi ini menyokong log masuk e-mel dan kata laluan yang selamat. Microsoft / Outlook OAuth belum diaktifkan.',
    'bn':
        'এই সংস্করণে নিরাপদ ইমেইল ও পাসওয়ার্ড সাইন-ইন রয়েছে। Microsoft / Outlook OAuth এখনও চালু করা হয়নি।',
  },
  ' and Privacy Policy.': <String, String>{
    'ms': 'dan Dasar Privasi.',
    'bn': 'এবং গোপনীয়তা নীতি।',
  },
  '\$_firstName! ': <String, String>{
    'ms': '\$_firstName !',
    'bn': '\$_firstName!',
  },
  '\$_totalScans': <String, String>{
    'ms': '\$_totalScans',
    'bn': '\$_totalScans',
  },
  '\$dangerous': <String, String>{
    'ms': '\$dangerous',
    'bn': '\$dangerous',
  },
  '\$provider developer account. Add those credentials before release.':
      <String, String>{
    'ms':
        'Akaun pembangun \$provider. Tambahkan bukti kelayakan tersebut sebelum dikeluarkan.',
    'bn': '\$provider বিকাশকারী অ্যাকাউন্ট। মুক্তির আগে সেই শংসাপত্র যোগ করুন।',
  },
  '\$provider sign-in requires OAuth credentials from your own ':
      <String, String>{
    'ms': 'Log masuk\$providermemerlukan kelayakan OAuth daripada anda sendiri',
    'bn':
        '\$provider সাইন-ইন করার জন্য আপনার নিজের থেকে OAuth শংসাপত্র প্রয়োজন৷',
  },
  '\$safe': <String, String>{
    'ms': '\$safe',
    'bn': '\$safe',
  },
  '\$score': <String, String>{
    'ms': '\$score',
    'bn': '\$score',
  },
  '\$suspicious': <String, String>{
    'ms': '\$suspicious',
    'bn': '\$suspicious',
  },
  '\$threats': <String, String>{
    'ms': '\$threats',
    'bn': '\$threats',
  },
  '\$total': <String, String>{
    'ms': '\$total',
    'bn': '\$total',
  },
  '\$value (\${(value / total * 100).round()}%)': <String, String>{
    'ms': '\$value (\${(value / total * 100).round()}%)',
    'bn': '\$value (\${(value / total * 100).round()}%)',
  },
  '\${(prediction.confidence * 100).round()}%': <String, String>{
    'ms': '\${(prediction.confidence * 100).round()} %',
    'bn': '\${(prediction.confidence * 100).round()} %',
  },
  '\${_usbAccessories.length} USB device(s) connected; none are treated as sensors until a verified adapter identifies them.':
      <String, String>{
    'ms':
        '\${_usbAccessories.length} Peranti USB disambungkan; tiada yang dianggap sebagai penderia sehingga penyesuai yang disahkan mengenal pastinya.',
    'bn':
        '\${_usbAccessories.length} USB ডিভাইস(গুলি) সংযুক্ত; একটি যাচাইকৃত অ্যাডাপ্টার তাদের সনাক্ত না করা পর্যন্ত কোনটিকেই সেন্সর হিসাবে গণ্য করা হয় না।',
  },
  '\${difference.inDays}d ago': <String, String>{
    'ms': '\${difference.inDays} d lalu',
    'bn': '\${difference.inDays} দিন আগে',
  },
  '\${difference.inHours}h ago': <String, String>{
    'ms': '\${difference.inHours} h lalu',
    'bn': '\${difference.inHours} ঘন্টা আগে',
  },
  '\${difference.inMinutes}m ago': <String, String>{
    'ms': '\${difference.inMinutes} m yang lalu',
    'bn': '\${difference.inMinutes} মি আগে',
  },
  '\${entry.key}: \${entry.value}': <String, String>{
    'ms': '\${entry.key} : \${entry.value}',
    'bn': '\${entry.key} : \${entry.value}',
  },
  '\${findings.length} device(s) need your review.': <String, String>{
    'ms': 'Peranti\${findings.length}memerlukan semakan anda.',
    'bn': '\${findings.length} ডিভাইস(গুলি) আপনার পর্যালোচনা প্রয়োজন.',
  },
  '\${findings.length} nearby Bluetooth device(s) found.': <String, String>{
    'ms': '\${findings.length} peranti Bluetooth berdekatan ditemui.',
    'bn': '\${findings.length} কাছাকাছি ব্লুটুথ ডিভাইস(গুলি) পাওয়া গেছে।',
  },
  '\${months[date.month - 1]} \${date.day}': <String, String>{
    'ms': '\${months[date.month - 1]} \${date.day}',
    'bn': '\${months[date.month - 1]} \${date.day}',
  },
  '\${parsed.day}/\${parsed.month}/\${parsed.year}': <String, String>{
    'ms': '\${parsed.day} /\${parsed.month}/ \${parsed.year}',
    'bn': '\${parsed.day} /\${parsed.month}/ \${parsed.year}',
  },
  '\${prediction.urlIntelligence![': <String, String>{
    'ms': '\${prediction.urlIntelligence![',
    'bn': '\${prediction.urlIntelligence![',
  },
  '\${value.replaceFirst(': <String, String>{
    'ms': '\${value.replaceFirst(',
    'bn': '\${value.replaceFirst(',
  },
  '1. Visual lens-reflection inspection': <String, String>{
    'ms': '1. Pemeriksaan pantulan kanta visual',
    'bn': '1. ভিজ্যুয়াল লেন্স-প্রতিফলন পরিদর্শন',
  },
  '152 reports': <String, String>{
    'ms': '152 laporan',
    'bn': '152 রিপোর্ট',
  },
  '2. Inspect nearby devices (Android)': <String, String>{
    'ms': '2. Periksa peranti berdekatan (Android)',
    'bn': '2. কাছাকাছি ডিভাইসগুলি পরিদর্শন করুন (Android)',
  },
  '3. Advanced sensor hardware': <String, String>{
    'ms': '3. Perkakasan sensor lanjutan',
    'bn': '3. উন্নত সেন্সর হার্ডওয়্যার',
  },
  '34m ago': <String, String>{
    'ms': '34m yang lalu',
    'bn': '34মি আগে',
  },
  '4. Record visual observations': <String, String>{
    'ms': '4. Merekod pemerhatian visual',
    'bn': '4. চাক্ষুষ পর্যবেক্ষণ রেকর্ড করুন',
  },
  '74 reports': <String, String>{
    'ms': '74 laporan',
    'bn': '74 রিপোর্ট',
  },
  '98 reports': <String, String>{
    'ms': '98 laporan',
    'bn': '98 রিপোর্ট',
  },
  'A normal phone camera cannot measure heat. Connect a supported thermal camera accessory with its approved Android SDK to enable real temperature measurements.':
      <String, String>{
    'ms':
        'Kamera telefon biasa tidak boleh mengukur haba. Sambungkan aksesori kamera terma yang disokong dengan SDK Android yang diluluskan untuk mendayakan pengukuran suhu sebenar.',
    'bn':
        'একটি সাধারণ ফোন ক্যামেরা তাপ পরিমাপ করতে পারে না। প্রকৃত তাপমাত্রা পরিমাপ সক্ষম করতে এটির অনুমোদিত Android SDK এর সাথে একটি সমর্থিত তাপীয় ক্যামেরা আনুষঙ্গিক সংযোগ করুন৷',
  },
  'A phone cannot certify that a room is camera-free. Thermal or RF detection requires compatible specialist hardware.':
      <String, String>{
    'ms':
        'Telefon tidak boleh mengesahkan bahawa bilik adalah bebas kamera. Pengesanan haba atau RF memerlukan perkakasan pakar yang serasi.',
    'bn':
        'একটি ফোন প্রত্যয়িত করতে পারে না যে একটি রুম ক্যামেরা-মুক্ত। তাপ বা আরএফ সনাক্তকরণের জন্য সামঞ্জস্যপূর্ণ বিশেষজ্ঞ হার্ডওয়্যার প্রয়োজন।',
  },
  'A small, sharp reflection appeared from an object.': <String, String>{
    'ms': 'Pantulan kecil dan tajam muncul dari objek.',
    'bn': 'একটি বস্তু থেকে একটি ছোট, তীক্ষ্ণ প্রতিফলন দেখা গেল।',
  },
  'A trained URL model calculates phishing risk.': <String, String>{
    'ms': 'Model URL terlatih mengira risiko pancingan data.',
    'bn': 'একটি প্রশিক্ষিত URL মডেল ফিশিং ঝুঁকি গণনা করে।',
  },
  'AI Analysis': <String, String>{
    'ms': 'Analisis AI',
    'bn': 'এআই বিশ্লেষণ',
  },
  'AI cybersecurity assistant': <String, String>{
    'ms': 'Pembantu keselamatan siber AI',
    'bn': 'এআই সাইবার নিরাপত্তা সহকারী',
  },
  'AI-Powered Cybersecurity': <String, String>{
    'ms': 'Keselamatan Siber Dikuasakan AI',
    'bn': 'এআই-চালিত সাইবার নিরাপত্তা',
  },
  'AI-Powered Detection': <String, String>{
    'ms': 'Pengesanan Dikuasakan AI',
    'bn': 'এআই-চালিত সনাক্তকরণ',
  },
  'AI-powered detection|Clear risk results|Simple explanations':
      <String, String>{
    'ms': 'Pengesanan berkuasa AI|Hasil risiko yang jelas|Penjelasan mudah',
    'bn': 'এআই-চালিত সনাক্তকরণ|স্বচ্ছ ঝুঁকি ফলাফল|সরল ব্যাখ্যা',
  },
  'AI-powered protection against phishing attacks, malicious links, and scam attempts.':
      <String, String>{
    'ms':
        'Perlindungan dikuasakan AI terhadap serangan pancingan data, pautan berniat jahat dan percubaan penipuan.',
    'bn':
        'ফিশিং আক্রমণ, দূষিত লিঙ্ক এবং কেলেঙ্কারী প্রচেষ্টার বিরুদ্ধে AI-চালিত সুরক্ষা।',
  },
  'About Nirapod AI': <String, String>{
    'ms': 'Mengenai Nirapod AI',
    'bn': 'নিরাপোদ এআই সম্পর্কে',
  },
  'About the fingerprint symbol': <String, String>{
    'ms': 'Mengenai simbol cap jari',
    'bn': 'আঙুলের ছাপ প্রতীক সম্পর্কে',
  },
  'Accent Color': <String, String>{
    'ms': 'Warna Aksen',
    'bn': 'অ্যাকসেন্ট রঙ',
  },
  'Accent color': <String, String>{
    'ms': 'Warna aksen',
    'bn': 'অ্যাকসেন্ট রঙ',
  },
  'Account Information': <String, String>{
    'ms': 'Maklumat Akaun',
    'bn': 'অ্যাকাউন্ট তথ্য',
  },
  'Account created. You can now sign in.': <String, String>{
    'ms': 'Akaun dibuat. Anda kini boleh log masuk.',
    'bn': 'অ্যাকাউন্ট তৈরি করা হয়েছে। আপনি এখন সাইন ইন করতে পারেন.',
  },
  'Acknowledgements': <String, String>{
    'ms': 'Ucapan terima kasih',
    'bn': 'স্বীকৃতি',
  },
  'Add a subject and a detailed message.': <String, String>{
    'ms': 'Tambah subjek dan mesej terperinci.',
    'bn': 'একটি বিষয় এবং একটি বিস্তারিত বার্তা যোগ করুন.',
  },
  'Additional Information': <String, String>{
    'ms': 'Maklumat Tambahan',
    'bn': 'অতিরিক্ত তথ্য',
  },
  'Advanced AI identifies phishing links,\nfake websites, and risky messages.':
      <String, String>{
    'ms':
        'AI lanjutan mengenal pasti pautan pancingan data, tapak web palsu\ndan mesej berisiko.',
    'bn':
        'উন্নত AI ফিশিং লিঙ্ক,\nজাল ওয়েবসাইট এবং ঝুঁকিপূর্ণ বার্তা সনাক্ত করে।',
  },
  'Advanced hardware check could not finish: \$error': <String, String>{
    'ms': 'Pemeriksaan perkakasan lanjutan tidak dapat diselesaikan: \$error',
    'bn': 'উন্নত হার্ডওয়্যার চেক শেষ করা যায়নি: \$error',
  },
  'Advanced sensor checks require a supported Android phone and compatible accessory.':
      <String, String>{
    'ms':
        'Pemeriksaan penderia lanjutan memerlukan telefon Android yang disokong dan aksesori yang serasi.',
    'bn':
        'উন্নত সেন্সর চেকের জন্য একটি সমর্থিত অ্যান্ড্রয়েড ফোন এবং সামঞ্জস্যপূর্ণ আনুষঙ্গিক প্রয়োজন।',
  },
  'Against Phishing': <String, String>{
    'ms': 'Menentang Phishing',
    'bn': 'ফিশিং এর বিরুদ্ধে',
  },
  'All': <String, String>{
    'ms': 'Semua',
    'bn': 'সব',
  },
  'Almost Done...': <String, String>{
    'ms': 'Hampir Selesai...',
    'bn': 'প্রায় শেষ...',
  },
  'Already have an account? ': <String, String>{
    'ms': 'Sudah mempunyai akaun?',
    'bn': 'ইতিমধ্যে একটি অ্যাকাউন্ট আছে?',
  },
  'Already have an account? Log in': <String, String>{
    'ms': 'Sudah mempunyai akaun? Log masuk',
    'bn': 'ইতিমধ্যে একটি অ্যাকাউন্ট আছে? লগ ইন করুন',
  },
  'Always double-check links from unknown sources to stay safe online.':
      <String, String>{
    'ms':
        'Sentiasa semak semula pautan daripada sumber yang tidak diketahui untuk kekal selamat dalam talian.',
    'bn':
        'অনলাইনে নিরাপদ থাকার জন্য সর্বদা অজানা উত্স থেকে লিঙ্কগুলি দুবার চেক করুন৷',
  },
  'An altered object, unexpected wire, pinhole, or device points toward a private area.':
      <String, String>{
    'ms':
        'Objek yang diubah, wayar yang tidak dijangka, lubang jarum atau peranti menghala ke kawasan peribadi.',
    'bn':
        'একটি পরিবর্তিত বস্তু, অপ্রত্যাশিত তার, পিনহোল বা ডিভাইস একটি ব্যক্তিগত এলাকার দিকে নির্দেশ করে।',
  },
  'Analyze': <String, String>{
    'ms': 'Menganalisis',
    'bn': 'বিশ্লেষণ করুন',
  },
  'Analyze SMS, email, and chat content for social-engineering and credential theft.':
      <String, String>{
    'ms':
        'Analisis kandungan SMS, e-mel dan sembang untuk kejuruteraan sosial dan kecurian kelayakan.',
    'bn':
        'সামাজিক-প্রকৌশল এবং শংসাপত্র চুরির জন্য এসএমএস, ইমেল এবং চ্যাট সামগ্রী বিশ্লেষণ করুন।',
  },
  'Analyze SMS, email, and chat messages\nfor suspicious content.':
      <String, String>{
    'ms':
        'Analisis SMS, e-mel dan mesej sembang\nuntuk kandungan yang mencurigakan.',
    'bn':
        'সন্দেহজনক বিষয়বস্তুর জন্য এসএমএস, ইমেল এবং চ্যাট বার্তা\nবিশ্লেষণ করুন।',
  },
  'Analyze SMS, emails or\nmessages for threats': <String, String>{
    'ms': 'Analisis SMS, e-mel atau mesej\nuntuk ancaman',
    'bn': 'হুমকির জন্য এসএমএস, ইমেল বা\nবার্তা বিশ্লেষণ করুন',
  },
  'Analyze SMS, emails or messages\nto detect suspicious content.':
      <String, String>{
    'ms':
        'Analisis SMS, e-mel atau mesej\nuntuk mengesan kandungan yang mencurigakan.',
    'bn':
        'সন্দেহজনক বিষয়বস্তু সনাক্ত করতে SMS, ইমেল বা বার্তা\nবিশ্লেষণ করুন।',
  },
  'Analyze email body or suspicious content': <String, String>{
    'ms': 'Analisis kandungan e-mel atau kandungan yang mencurigakan',
    'bn': 'ইমেইল বডি বা সন্দেহজনক বিষয়বস্তু বিশ্লেষণ করুন',
  },
  'Analyze for Risks': <String, String>{
    'ms': 'Analisis untuk Risiko',
    'bn': 'ঝুঁকির জন্য বিশ্লেষণ করুন',
  },
  'Analyze suspicious SMS, email, and chat messages. Nirapod AI explains the warning signs and recommends what to do next.':
      <String, String>{
    'ms':
        'Analisis SMS, e-mel dan mesej sembang yang mencurigakan. Nirapod AI menerangkan tanda amaran dan mengesyorkan perkara yang perlu dilakukan seterusnya.',
    'bn':
        'সন্দেহজনক এসএমএস, ইমেল এবং চ্যাট বার্তা বিশ্লেষণ করুন। Nirapod AI সতর্কতা চিহ্নগুলি ব্যাখ্যা করে এবং পরবর্তীতে কী করতে হবে তা সুপারিশ করে৷',
  },
  'Analyzing...': <String, String>{
    'ms': 'Menganalisis...',
    'bn': 'বিশ্লেষণ করা হচ্ছে...',
  },
  'Android Protection Tools': <String, String>{
    'ms': 'Alat Perlindungan Android',
    'bn': 'অ্যান্ড্রয়েড সুরক্ষা সরঞ্জাম',
  },
  'Android notifications are working correctly.': <String, String>{
    'ms': 'Pemberitahuan Android berfungsi dengan betul.',
    'bn': 'অ্যান্ড্রয়েড বিজ্ঞপ্তি সঠিকভাবে কাজ করছে.',
  },
  'Android only': <String, String>{
    'ms': 'Android sahaja',
    'bn': 'শুধুমাত্র অ্যান্ড্রয়েড',
  },
  'App Lock': <String, String>{
    'ms': 'Kunci Apl',
    'bn': 'অ্যাপ লক',
  },
  'App lock': <String, String>{
    'ms': 'Kunci apl',
    'bn': 'অ্যাপ লক',
  },
  'App lock is tested on an Android phone or emulator.': <String, String>{
    'ms': 'Kunci apl diuji pada telefon Android atau emulator.',
    'bn': 'অ্যাপ লক একটি অ্যান্ড্রয়েড ফোন বা এমুলেটরে পরীক্ষা করা হয়।',
  },
  'Apr': <String, String>{
    'ms': 'Apr',
    'bn': 'এপ্রিল',
  },
  'Ask AI': <String, String>{
    'ms': 'Tanya AI',
    'bn': 'এআইকে জিজ্ঞাসা করুন',
  },
  'Ask Nirapod Guide': <String, String>{
    'ms': 'Tanya Panduan Nirapod',
    'bn': 'নীরপদ গাইডকে জিজ্ঞাসা করুন',
  },
  'Ask any security question…': <String, String>{
    'ms': 'Tanya sebarang soalan keselamatan…',
    'bn': 'কোনো নিরাপত্তা প্রশ্ন জিজ্ঞাসা করুন...',
  },
  'Aug': <String, String>{
    'ms': 'Ogos',
    'bn': 'অগাস্ট',
  },
  'Authentication was not completed: \$error': <String, String>{
    'ms': 'Pengesahan tidak selesai: \$error',
    'bn': 'প্রমাণীকরণ সম্পূর্ণ হয়নি: \$error',
  },
  'Authorized Nearby Checks': <String, String>{
    'ms': 'Cek Berdekatan yang Dibenarkan',
    'bn': 'অনুমোদিত কাছাকাছি চেক',
  },
  'Auto Scan Links': <String, String>{
    'ms': 'Pautan Imbas Auto',
    'bn': 'অটো স্ক্যান লিঙ্ক',
  },
  'Automatic': <String, String>{
    'ms': 'Automatik',
    'bn': 'স্বয়ংক্রিয়',
  },
  'Automatically scan copied links': <String, String>{
    'ms': 'Imbas pautan yang disalin secara automatik',
    'bn': 'স্বয়ংক্রিয়ভাবে অনুলিপি করা লিঙ্ক স্ক্যান করুন',
  },
  'Available': <String, String>{
    'ms': 'Tersedia',
    'bn': 'পাওয়া যায়',
  },
  'Back to Login': <String, String>{
    'ms': 'Kembali ke Log Masuk',
    'bn': 'লগইন এ ফিরে যান',
  },
  'Bahasa Melayu': <String, String>{
    'ms': 'Bahasa Melayu',
    'bn': 'বাহাসা মেলায়ু',
  },
  'Billing is not activated yet. Connect a payment provider ': <String, String>{
    'ms': 'Pengebilan belum diaktifkan lagi. Sambungkan penyedia pembayaran',
    'bn': 'বিলিং এখনও সক্রিয় করা হয়নি. একটি পেমেন্ট প্রদানকারী সংযুক্ত করুন',
  },
  'Biometric': <String, String>{
    'ms': 'Biometrik',
    'bn': 'বায়োমেট্রিক',
  },
  'Biometrics require a supported Android or iOS device': <String, String>{
    'ms': 'Biometrik memerlukan peranti Android atau iOS yang disokong',
    'bn': 'বায়োমেট্রিক্সের জন্য একটি সমর্থিত Android বা iOS ডিভাইস প্রয়োজন',
  },
  'Biometrics, notifications, nearby devices and protection service':
      <String, String>{
    'ms':
        'Biometrik, pemberitahuan, peranti berdekatan dan perkhidmatan perlindungan',
    'bn': 'বায়োমেট্রিক্স, বিজ্ঞপ্তি, কাছাকাছি ডিভাইস এবং সুরক্ষা পরিষেবা',
  },
  'Blue': <String, String>{
    'ms': 'Biru',
    'bn': 'নীল',
  },
  'Bluetooth inspection completed: \${findings.length} nearby device(s) observed. Presence alone is not evidence of a hidden camera.':
      <String, String>{
    'ms':
        'Pemeriksaan Bluetooth selesai:\${findings.length}peranti berdekatan diperhatikan. Kehadiran sahaja bukan bukti kamera tersembunyi.',
    'bn':
        'ব্লুটুথ পরিদর্শন সম্পন্ন হয়েছে:\${findings.length}কাছাকাছি ডিভাইস(গুলি) পর্যবেক্ষণ করা হয়েছে৷ একা উপস্থিতি একটি গোপন ক্যামেরার প্রমাণ নয়।',
  },
  'Bluetooth inspection could not finish: \$error': <String, String>{
    'ms': 'Pemeriksaan Bluetooth tidak dapat diselesaikan: \$error',
    'bn': 'ব্লুটুথ পরিদর্শন শেষ করা যায়নি: \$error',
  },
  'Camera permission was denied. Allow camera access in the browser address bar, then try again.':
      <String, String>{
    'ms':
        'Kebenaran kamera telah ditolak. Benarkan akses kamera dalam bar alamat penyemak imbas, kemudian cuba lagi.',
    'bn':
        'ক্যামেরার অনুমতি প্রত্যাখ্যান করা হয়েছে। ব্রাউজার অ্যাড্রেস বারে ক্যামেরা অ্যাক্সেসের অনুমতি দিন, তারপর আবার চেষ্টা করুন।',
  },
  'Camera unavailable: \${error.errorDetails?.message ?? error.errorCode.name}':
      <String, String>{
    'ms':
        'Kamera tidak tersedia: \${error.errorDetails?.message ?? error.errorCode.name}',
    'bn':
        'ক্যামেরা অনুপলব্ধ: \${error.errorDetails?.message ?? error.errorCode.name}',
  },
  'Cancel': <String, String>{
    'ms': 'Batal',
    'bn': 'বাতিল করুন',
  },
  'Capture the full message, email, or alert for better accuracy.':
      <String, String>{
    'ms':
        'Tangkap mesej penuh, e-mel atau makluman untuk ketepatan yang lebih baik.',
    'bn': 'আরও সঠিকতার জন্য সম্পূর্ণ বার্তা, ইমেল বা সতর্কতা ক্যাপচার করুন।',
  },
  'Categories': <String, String>{
    'ms': 'Kategori',
    'bn': 'ক্যাটাগরি',
  },
  'Check Before You Click': <String, String>{
    'ms': 'Semak Sebelum Anda Klik',
    'bn': 'আপনি ক্লিক করার আগে চেক করুন',
  },
  'Check Every': <String, String>{
    'ms': 'Semak Setiap',
    'bn': 'প্রতিটি পরীক্ষা করুন',
  },
  'Check Room': <String, String>{
    'ms': 'Bilik Semak',
    'bn': 'চেক রুম',
  },
  'Check camera indicators': <String, String>{
    'ms': 'Periksa penunjuk kamera',
    'bn': 'ক্যামেরা সূচক পরীক্ষা করুন',
  },
  'Check if a website link\nis safe or phishing': <String, String>{
    'ms': 'Semak sama ada pautan tapak web\nselamat atau pancingan data',
    'bn': 'একটি ওয়েবসাইট লিঙ্ক\nনিরাপদ বা ফিশিং কিনা তা পরীক্ষা করুন৷',
  },
  'Check if a website link is safe\nbefore you open it.': <String, String>{
    'ms': 'Semak sama ada pautan tapak web selamat\nsebelum anda membukanya.',
    'bn':
        'আপনি একটি ওয়েবসাইট লিংক\nখোলার আগে এটি নিরাপদ কিনা তা পরীক্ষা করুন।',
  },
  'Check suspicious SMS or text messages': <String, String>{
    'ms': 'Semak SMS atau mesej teks yang mencurigakan',
    'bn': 'সন্দেহজনক এসএমএস বা টেক্সট মেসেজ চেক করুন',
  },
  'Checking Hardware...': <String, String>{
    'ms': 'Menyemak Perkakasan...',
    'bn': 'হার্ডওয়্যার পরীক্ষা করা হচ্ছে...',
  },
  'Checking URL': <String, String>{
    'ms': 'Menyemak URL',
    'bn': 'ইউআরএল চেক করা হচ্ছে',
  },
  'Checking the local network…': <String, String>{
    'ms': 'Menyemak rangkaian tempatan…',
    'bn': 'স্থানীয় নেটওয়ার্ক পরীক্ষা করা হচ্ছে...',
  },
  'Checks common web and camera-service ports on your local network':
      <String, String>{
    'ms':
        'Menyemak web biasa dan port perkhidmatan kamera pada rangkaian tempatan anda',
    'bn':
        'আপনার স্থানীয় নেটওয়ার্কে সাধারণ ওয়েব এবং ক্যামেরা-সার্ভিস পোর্ট চেক করে',
  },
  'Choose Image': <String, String>{
    'ms': 'Pilih Imej',
    'bn': 'ছবি নির্বাচন করুন',
  },
  'Choose a scan type to get started': <String, String>{
    'ms': 'Pilih jenis imbasan untuk bermula',
    'bn': 'শুরু করতে একটি স্ক্যান টাইপ বেছে নিন',
  },
  'Choose a tool below. Scans only run when you request them.':
      <String, String>{
    'ms':
        'Pilih alat di bawah. Imbasan hanya dijalankan apabila anda memintanya.',
    'bn':
        'নীচের একটি টুল চয়ন করুন. আপনি তাদের অনুরোধ করলেই স্ক্যানগুলি চালানো হয়।',
  },
  'Choose how threat information is refreshed': <String, String>{
    'ms': 'Pilih cara maklumat ancaman dimuat semula',
    'bn': 'হুমকির তথ্য কীভাবে রিফ্রেশ করা হয় তা বেছে নিন',
  },
  'Choose what you want to scan': <String, String>{
    'ms': 'Pilih perkara yang anda mahu imbas',
    'bn': 'আপনি কি স্ক্যান করতে চান তা বেছে নিন',
  },
  'Choose where verified links open': <String, String>{
    'ms': 'Pilih tempat pautan yang disahkan dibuka',
    'bn': 'যাচাই করা লিঙ্কগুলি কোথায় খুলবে তা বেছে নিন',
  },
  'Clear conversation': <String, String>{
    'ms': 'Perbualan yang jelas',
    'bn': 'পরিষ্কার কথোপকথন',
  },
  'Clear search': <String, String>{
    'ms': 'Kosongkan carian',
    'bn': 'সাফ অনুসন্ধান',
  },
  'Cloud Protection': <String, String>{
    'ms': 'Perlindungan Awan',
    'bn': 'ক্লাউড সুরক্ষা',
  },
  'Community Reports': <String, String>{
    'ms': 'Laporan Komuniti',
    'bn': 'কমিউনিটি রিপোর্ট',
  },
  'Comparing Threat Intelligence': <String, String>{
    'ms': 'Membandingkan Perisikan Ancaman',
    'bn': 'হুমকি বুদ্ধিমত্তা তুলনা',
  },
  'Complete Safety Check': <String, String>{
    'ms': 'Semakan Keselamatan Lengkap',
    'bn': 'সম্পূর্ণ নিরাপত্তা পরীক্ষা',
  },
  'Complete your first scan and its result will appear here.': <String, String>{
    'ms':
        'Lengkapkan imbasan pertama anda dan hasilnya akan dipaparkan di sini.',
    'bn': 'আপনার প্রথম স্ক্যান সম্পূর্ণ করুন এবং এর ফলাফল এখানে প্রদর্শিত হবে।',
  },
  'Completed scans are saved automatically.': <String, String>{
    'ms': 'Imbasan yang lengkap disimpan secara automatik.',
    'bn': 'সম্পূর্ণ স্ক্যান স্বয়ংক্রিয়ভাবে সংরক্ষিত হয়.',
  },
  'Confidence': <String, String>{
    'ms': 'Keyakinan',
    'bn': 'আত্মবিশ্বাস',
  },
  'Connect with \$provider': <String, String>{
    'ms': 'Berhubung dengan \$provider',
    'bn': '\$provider এর সাথে সংযোগ করুন',
  },
  'Connection error': <String, String>{
    'ms': 'Ralat sambungan',
    'bn': 'সংযোগ ত্রুটি',
  },
  'Contact Support': <String, String>{
    'ms': 'Hubungi Sokongan',
    'bn': 'সহায়তার সাথে যোগাযোগ করুন',
  },
  'Continue to Login': <String, String>{
    'ms': 'Teruskan Log Masuk',
    'bn': 'লগইন চালিয়ে যান',
  },
  'Copied text: \$text': <String, String>{
    'ms': 'Teks yang disalin: \$text',
    'bn': 'অনুলিপি করা পাঠ্য: \$text',
  },
  'Could not complete the action: \$error': <String, String>{
    'ms': 'Tidak dapat menyelesaikan tindakan: \$error',
    'bn': 'ক্রিয়াটি সম্পূর্ণ করা যায়নি: \$error',
  },
  'Could not export data. Check the backend.': <String, String>{
    'ms': 'Tidak dapat mengeksport data. Semak bahagian belakang.',
    'bn': 'ডেটা এক্সপোর্ট করা যায়নি। ব্যাকএন্ড চেক করুন।',
  },
  'Could not load help articles. Check the backend.': <String, String>{
    'ms': 'Tidak dapat memuatkan artikel bantuan. Semak bahagian belakang.',
    'bn': 'সাহায্য নিবন্ধ লোড করা যায়নি. ব্যাকএন্ড চেক করুন।',
  },
  'Could not load history. Make sure the backend is running.': <String, String>{
    'ms': 'Tidak dapat memuatkan sejarah. Pastikan bahagian belakang berjalan.',
    'bn': 'ইতিহাস লোড করা যায়নি। নিশ্চিত করুন যে ব্যাকএন্ড চলছে।',
  },
  'Could not load notifications.': <String, String>{
    'ms': 'Tidak dapat memuatkan pemberitahuan.',
    'bn': 'বিজ্ঞপ্তি লোড করা যায়নি.',
  },
  'Could not load profile from the backend.': <String, String>{
    'ms': 'Tidak dapat memuatkan profil dari bahagian belakang.',
    'bn': 'ব্যাকএন্ড থেকে প্রোফাইল লোড করা যায়নি।',
  },
  'Could not load recent scans. Check the backend.': <String, String>{
    'ms': 'Tidak dapat memuatkan imbasan terbaru. Semak bahagian belakang.',
    'bn': 'সাম্প্রতিক স্ক্যানগুলি লোড করা যায়নি৷ ব্যাকএন্ড চেক করুন।',
  },
  'Could not load settings from the server.': <String, String>{
    'ms': 'Tidak dapat memuatkan tetapan daripada pelayan.',
    'bn': 'সার্ভার থেকে সেটিংস লোড করা যায়নি৷',
  },
  'Could not load the assistant. Check the backend.': <String, String>{
    'ms': 'Tidak dapat memuatkan pembantu. Semak bahagian belakang.',
    'bn': 'সহকারী লোড করা যায়নি। ব্যাকএন্ড চেক করুন।',
  },
  'Could not read that QR image: \$error': <String, String>{
    'ms': 'Tidak dapat membaca imej QR itu: \$error',
    'bn': 'সেই QR চিত্রটি পড়তে পারেনি: \$error',
  },
  'Could not save profile. Check the backend.': <String, String>{
    'ms': 'Tidak dapat menyimpan profil. Semak bahagian belakang.',
    'bn': 'প্রোফাইল সংরক্ষণ করা যায়নি. ব্যাকএন্ড চেক করুন।',
  },
  'Could not save the room check. Confirm the backend is running. \$error':
      <String, String>{
    'ms':
        'Tidak dapat menyimpan cek bilik. Sahkan bahagian belakang sedang berjalan.  \$error',
    'bn': 'রুম চেক সংরক্ষণ করতে পারেনি. নিশ্চিত করুন ব্যাকএন্ড চলছে।  \$error',
  },
  'Could not submit. Check the backend connection.': <String, String>{
    'ms': 'Tidak dapat menyerahkan. Semak sambungan hujung belakang.',
    'bn': 'জমা দিতে পারিনি। ব্যাকএন্ড সংযোগ পরীক্ষা করুন।',
  },
  'Could not take the photo.': <String, String>{
    'ms': 'Tidak dapat mengambil gambar.',
    'bn': 'ছবি তুলতে পারিনি।',
  },
  'Create Account': <String, String>{
    'ms': 'Buat Akaun',
    'bn': 'অ্যাকাউন্ট তৈরি করুন',
  },
  'Create a strong password': <String, String>{
    'ms': 'Buat kata laluan yang kukuh',
    'bn': 'একটি শক্তিশালী পাসওয়ার্ড তৈরি করুন',
  },
  'Creating Account...': <String, String>{
    'ms': 'Mencipta Akaun...',
    'bn': 'অ্যাকাউন্ট তৈরি করা হচ্ছে...',
  },
  'Customize alerts and updates': <String, String>{
    'ms': 'Sesuaikan makluman dan kemas kini',
    'bn': 'সতর্কতা এবং আপডেট কাস্টমাইজ করুন',
  },
  'Dangerous': <String, String>{
    'ms': 'bahaya',
    'bn': 'বিপজ্জনক',
  },
  'Inconclusive': <String, String>{
    'ms': 'Tidak dapat dipastikan',
    'bn': 'অনির্ণীত',
  },
  'Dark Mode': <String, String>{
    'ms': 'Mod Gelap',
    'bn': 'ডার্ক মোড',
  },
  'Data Export Ready': <String, String>{
    'ms': 'Sedia Eksport Data',
    'bn': 'ডেটা এক্সপোর্ট রেডি',
  },
  'Dec': <String, String>{
    'ms': 'Dis',
    'bn': 'ডিসেম্বর',
  },
  'Decide safely before visiting a website.': <String, String>{
    'ms': 'Buat keputusan dengan selamat sebelum melawat tapak web.',
    'bn': 'ওয়েবসাইট দেখার আগে নিরাপদে সিদ্ধান্ত নিন।',
  },
  'Decoded links go directly to ML analysis.': <String, String>{
    'ms': 'Pautan yang dinyahkod pergi terus ke analisis ML.',
    'bn': 'ডিকোড করা লিঙ্কগুলি সরাসরি এমএল বিশ্লেষণে যায়।',
  },
  'Default Browser': <String, String>{
    'ms': 'Pelayar Lalai',
    'bn': 'ডিফল্ট ব্রাউজার',
  },
  'Default browser': <String, String>{
    'ms': 'Penyemak imbas lalai',
    'bn': 'ডিফল্ট ব্রাউজার',
  },
  'Describe the problem': <String, String>{
    'ms': 'Huraikan masalah tersebut',
    'bn': 'সমস্যা বর্ণনা করুন',
  },
  'Detailed Reports': <String, String>{
    'ms': 'Laporan Terperinci',
    'bn': 'বিস্তারিত রিপোর্ট',
  },
  'Detect common social-engineering patterns.': <String, String>{
    'ms': 'Kesan corak kejuruteraan sosial biasa.',
    'bn': 'সাধারণ সামাজিক-প্রকৌশল নিদর্শন সনাক্ত করুন।',
  },
  'Detect phishing attempts and scams.': <String, String>{
    'ms': 'Kesan percubaan pancingan data dan penipuan.',
    'bn': 'ফিশিং প্রচেষ্টা এবং স্ক্যাম সনাক্ত করুন.',
  },
  'Detect suspicious links, QR codes, and scam messages before it is too late.':
      <String, String>{
    'ms':
        'Kesan pautan yang mencurigakan, kod QR dan mesej penipuan sebelum terlambat.',
    'bn':
        'অনেক দেরি হওয়ার আগেই সন্দেহজনক লিঙ্ক, QR কোড এবং স্ক্যাম মেসেজ শনাক্ত করুন।',
  },
  'Detect. Analyze. Protect.': <String, String>{
    'ms': 'Kesan. Menganalisis. Lindungi.',
    'bn': 'সনাক্ত করুন। বিশ্লেষণ করুন। রক্ষা করুন।',
  },
  'Detected By': <String, String>{
    'ms': 'Dikesan Oleh',
    'bn': 'দ্বারা সনাক্ত করা হয়েছে',
  },
  'Detection Details': <String, String>{
    'ms': 'Butiran Pengesanan',
    'bn': 'সনাক্তকরণ বিবরণ',
  },
  'Developed By': <String, String>{
    'ms': 'Dibangunkan Oleh',
    'bn': 'দ্বারা বিকশিত',
  },
  'Device PIN': <String, String>{
    'ms': 'PIN peranti',
    'bn': 'ডিভাইস পিন',
  },
  'Device Protection': <String, String>{
    'ms': 'Perlindungan Peranti',
    'bn': 'ডিভাইস সুরক্ষা',
  },
  'Dim the room and slowly inspect smoke detectors, clocks, chargers, vents, mirrors, and objects facing beds or bathrooms. Look for a small sharp reflection.':
      <String, String>{
    'ms':
        'Redupkan bilik dan periksa pengesan asap, jam, pengecas, bolong, cermin dan objek yang menghadap katil atau bilik mandi secara perlahan-lahan. Cari pantulan tajam kecil.',
    'bn':
        'ঘরটি ম্লান করুন এবং ধীরে ধীরে ধোঁয়া সনাক্তকারী, ঘড়ি, চার্জার, ভেন্ট, আয়না এবং বিছানা বা বাথরুমের মুখোমুখি বস্তুগুলি পরীক্ষা করুন। একটি ছোট ধারালো প্রতিফলন জন্য দেখুন.',
  },
  'Directional RF measurement': <String, String>{
    'ms': 'Pengukuran RF berarah',
    'bn': 'দিকনির্দেশক আরএফ পরিমাপ',
  },
  'Directional radio locating requires a compatible RF receiver and directional antenna. Bluetooth or Wi-Fi presence alone cannot provide a reliable arrow to a device.':
      <String, String>{
    'ms':
        'Pencarian radio arah memerlukan penerima RF dan antena arah yang serasi. Kehadiran Bluetooth atau Wi-Fi sahaja tidak dapat memberikan anak panah yang boleh dipercayai kepada peranti.',
    'bn':
        'দিকনির্দেশক রেডিও লোকেটিং এর জন্য একটি সামঞ্জস্যপূর্ণ RF রিসিভার এবং দিকনির্দেশক অ্যান্টেনা প্রয়োজন। ব্লুটুথ বা Wi-Fi উপস্থিতি একা একটি ডিভাইসে একটি নির্ভরযোগ্য তীর প্রদান করতে পারে না।',
  },
  'Discover devices on this Wi-Fi': <String, String>{
    'ms': 'Temui peranti pada Wi-Fi ini',
    'bn': 'এই Wi-Fi-এ ডিভাইসগুলি আবিষ্কার করুন৷',
  },
  'Discover nearby Bluetooth devices': <String, String>{
    'ms': 'Temui peranti Bluetooth berdekatan',
    'bn': 'কাছাকাছি ব্লুটুথ ডিভাইস আবিষ্কার করুন',
  },
  'Do not share passwords, OTPs, card numbers, private keys, or recovery codes. AI guidance can make mistakes—verify important actions.':
      <String, String>{
    'ms':
        'Jangan kongsi kata laluan, OTP, nombor kad, kunci peribadi atau kod pemulihan. Panduan AI boleh membuat kesilapan—sahkan tindakan penting.',
    'bn':
        'পাসওয়ার্ড, ওটিপি, কার্ড নম্বর, ব্যক্তিগত কী, বা পুনরুদ্ধার কোড শেয়ার করবেন না। এআই নির্দেশিকা ভুল করতে পারে—গুরুত্বপূর্ণ ক্রিয়া যাচাই করুন।',
  },
  'Do not share personal information. Be cautious of urgent requests or unknown links.':
      <String, String>{
    'ms':
        'Jangan kongsi maklumat peribadi. Berhati-hati dengan permintaan segera atau pautan yang tidak diketahui.',
    'bn':
        'ব্যক্তিগত তথ্য শেয়ার করবেন না। জরুরী অনুরোধ বা অজানা লিঙ্ক থেকে সতর্ক থাকুন।',
  },
  'Do not touch or dismantle it. Leave the room, preserve photos, contact hotel management, and report it to local authorities.':
      <String, String>{
    'ms':
        'Jangan sentuh atau bongkarkannya. Keluar dari bilik, simpan foto, hubungi pengurusan hotel dan laporkan kepada pihak berkuasa tempatan.',
    'bn':
        'এটি স্পর্শ বা ভেঙে ফেলবেন না। রুম ত্যাগ করুন, ছবি সংরক্ষণ করুন, হোটেল ব্যবস্থাপনার সাথে যোগাযোগ করুন এবং স্থানীয় কর্তৃপক্ষকে রিপোর্ট করুন।',
  },
  'Domain': <String, String>{
    'ms': 'Domain',
    'bn': 'ডোমেইন',
  },
  'Done': <String, String>{
    'ms': 'Selesai',
    'bn': 'সম্পন্ন',
  },
  'Don’t have an account?\n': <String, String>{
    'ms': 'Tiada akaun?',
    'bn': 'একটি অ্যাকাউন্ট নেই?',
  },
  'Download scan history and reports': <String, String>{
    'ms': 'Muat turun sejarah imbasan dan laporan',
    'bn': 'স্ক্যান ইতিহাস এবং রিপোর্ট ডাউনলোড করুন',
  },
  'Email': <String, String>{
    'ms': 'E-mel',
    'bn': 'ইমেইল',
  },
  'Email Address': <String, String>{
    'ms': 'Alamat E-mel',
    'bn': 'ইমেইল ঠিকানা',
  },
  'Email Content': <String, String>{
    'ms': 'Kandungan E-mel',
    'bn': 'ইমেল বিষয়বস্তু',
  },
  'Email Scan': <String, String>{
    'ms': 'Imbasan E-mel',
    'bn': 'ইমেল স্ক্যান',
  },
  'Email address': <String, String>{
    'ms': 'Alamat e-mel',
    'bn': 'ইমেইল ঠিকানা',
  },
  'Enable real-time cloud scanning': <String, String>{
    'ms': 'Dayakan pengimbasan awan masa nyata',
    'bn': 'রিয়েল-টাইম ক্লাউড স্ক্যানিং সক্ষম করুন',
  },
  'English': <String, String>{
    'ms': 'Inggeris',
    'bn': 'ইংরেজি',
  },
  'Enter Code Manually': <String, String>{
    'ms': 'Masukkan Kod Secara Manual',
    'bn': 'ম্যানুয়ালি কোড লিখুন',
  },
  'Enter Link': <String, String>{
    'ms': 'Masukkan Pautan',
    'bn': 'লিঙ্ক লিখুন',
  },
  'Enter QR content': <String, String>{
    'ms': 'Masukkan kandungan QR',
    'bn': 'QR বিষয়বস্তু লিখুন',
  },
  'Enter URL to Scan': <String, String>{
    'ms': 'Masukkan URL untuk Diimbas',
    'bn': 'স্ক্যান করতে URL লিখুন',
  },
  'Enter a URL before scanning.': <String, String>{
    'ms': 'Masukkan URL sebelum mengimbas.',
    'bn': 'স্ক্যান করার আগে একটি URL লিখুন।',
  },
  'Enter a valid email and password.': <String, String>{
    'ms': 'Masukkan e-mel dan kata laluan yang sah.',
    'bn': 'একটি বৈধ ইমেল এবং পাসওয়ার্ড লিখুন.',
  },
  'Enter content before \${_actionLabel.toLowerCase()}.': <String, String>{
    'ms': 'Masukkan kandungan sebelum\${_actionLabel.toLowerCase()}.',
    'bn': '\${_actionLabel.toLowerCase()} এর আগে বিষয়বস্তু লিখুন।',
  },
  'Enter the scam URL or content first.': <String, String>{
    'ms': 'Masukkan URL atau kandungan penipuan dahulu.',
    'bn': 'প্রথমে স্ক্যাম URL বা বিষয়বস্তু লিখুন।',
  },
  'Enter your email': <String, String>{
    'ms': 'Masukkan e-mel anda',
    'bn': 'আপনার ইমেইল লিখুন',
  },
  'Enter your email address and we’ll send you a link to reset your password.':
      <String, String>{
    'ms':
        'Masukkan alamat e-mel anda dan kami akan menghantar pautan kepada anda untuk menetapkan semula kata laluan anda.',
    'bn':
        'আপনার ইমেল ঠিকানা লিখুন এবং আমরা আপনাকে আপনার পাসওয়ার্ড পুনরায় সেট করার জন্য একটি লিঙ্ক পাঠাব।',
  },
  'Enter your full name': <String, String>{
    'ms': 'Masukkan nama penuh anda',
    'bn': 'আপনার পুরো নাম লিখুন',
  },
  'Enter your name, a valid email, and at least 8 password characters.':
      <String, String>{
    'ms':
        'Masukkan nama anda, e-mel yang sah dan sekurang-kurangnya 8 aksara kata laluan.',
    'bn': 'আপনার নাম, একটি বৈধ ইমেল এবং কমপক্ষে 8টি পাসওয়ার্ড অক্ষর লিখুন।',
  },
  'Enter your password': <String, String>{
    'ms': 'Masukkan kata laluan anda',
    'bn': 'আপনার পাসওয়ার্ড লিখুন',
  },
  'Examples of what you can scan': <String, String>{
    'ms': 'Contoh perkara yang boleh anda imbas',
    'bn': 'আপনি কি স্ক্যান করতে পারেন তার উদাহরণ',
  },
  'Exception: ': <String, String>{
    'ms': 'Pengecualian:',
    'bn': 'ব্যতিক্রম:',
  },
  'Export My Data': <String, String>{
    'ms': 'Eksport Data Saya',
    'bn': 'আমার ডেটা রপ্তানি করুন',
  },
  'Extract Text (OCR)': <String, String>{
    'ms': 'Ekstrak Teks (OCR)',
    'bn': 'এক্সট্রাক্ট টেক্সট (OCR)',
  },
  'Extract text from images\nand analyze risks': <String, String>{
    'ms': 'Ekstrak teks daripada imej\ndan analisis risiko',
    'bn': 'ছবি থেকে পাঠ্য বের করুন এবং ঝুঁকি বিশ্লেষণ করুন',
  },
  'Extract text from images and analyze\nfor potential risks.':
      <String, String>{
    'ms': 'Ekstrak teks daripada imej dan analisis\nuntuk potensi risiko.',
    'bn': 'ছবি থেকে পাঠ্য বের করুন এবং সম্ভাব্য ঝুঁকির জন্য\nবিশ্লেষণ করুন।',
  },
  'Extracting text from \${file.name}...': <String, String>{
    'ms': 'Mengekstrak teks daripada\${file.name}...',
    'bn': '\${file.name} থেকে পাঠ্য বের করা হচ্ছে...',
  },
  'Face or fingerprint': <String, String>{
    'ms': 'Muka atau cap jari',
    'bn': 'মুখ বা আঙুলের ছাপ',
  },
  'Facebook': <String, String>{
    'ms': 'Facebook',
    'bn': 'Facebook',
  },
  'Fake QR – Parking Scam': <String, String>{
    'ms': 'QR Palsu – Penipuan Tempat Letak Kereta',
    'bn': 'জাল QR - পার্কিং কেলেঙ্কারী',
  },
  'Feb': <String, String>{
    'ms': 'Feb',
    'bn': 'ফেব্রুয়ারী',
  },
  'Find answers and get the help you need': <String, String>{
    'ms': 'Cari jawapan dan dapatkan bantuan yang anda perlukan',
    'bn': 'উত্তর খুঁজুন এবং আপনার প্রয়োজনীয় সাহায্য পান',
  },
  'Foreground protection is active.': <String, String>{
    'ms': 'Perlindungan latar depan aktif.',
    'bn': 'ফোরগ্রাউন্ড সুরক্ষা সক্রিয়।',
  },
  'Forgot Password': <String, String>{
    'ms': 'Terlupa Kata Laluan',
    'bn': 'পাসওয়ার্ড ভুলে গেছি',
  },
  'Forgot Password?': <String, String>{
    'ms': 'Lupa Kata Laluan?',
    'bn': 'পাসওয়ার্ড ভুলে গেছেন?',
  },
  'Full Name': <String, String>{
    'ms': 'Nama Penuh',
    'bn': 'পুরো নাম',
  },
  'Full name': <String, String>{
    'ms': 'Nama penuh',
    'bn': 'পুরো নাম',
  },
  'Get Result': <String, String>{
    'ms': 'Dapatkan Keputusan',
    'bn': 'রেজাল্ট পান',
  },
  'Get Safety Result': <String, String>{
    'ms': 'Dapatkan Keputusan Keselamatan',
    'bn': 'নিরাপত্তা ফলাফল পান',
  },
  'Get Started': <String, String>{
    'ms': 'Mulakan',
    'bn': 'শুরু করুন',
  },
  'Get help and find answers': <String, String>{
    'ms': 'Dapatkan bantuan dan dapatkan jawapan',
    'bn': 'সাহায্য পান এবং উত্তর খুঁজুন',
  },
  'Get notified about scan results': <String, String>{
    'ms': 'Dapatkan pemberitahuan tentang hasil imbasan',
    'bn': 'স্ক্যান ফলাফল সম্পর্কে বিজ্ঞপ্তি পান',
  },
  'Get risk scores and clear explanations\nfor every scan.': <String, String>{
    'ms':
        'Dapatkan skor risiko dan penjelasan yang jelas\nuntuk setiap imbasan.',
    'bn': 'প্রতিটি স্ক্যানের জন্য ঝুঁকির স্কোর এবং স্পষ্ট ব্যাখ্যা\nপান।',
  },
  'Getting Started': <String, String>{
    'ms': 'Bermula',
    'bn': 'শুরু করা',
  },
  'Go Home': <String, String>{
    'ms': 'Pergi Rumah',
    'bn': 'বাড়ি যান',
  },
  'Google': <String, String>{
    'ms': 'Google',
    'bn': 'Google',
  },
  'Green': <String, String>{
    'ms': 'hijau',
    'bn': 'সবুজ',
  },
  'Guided Safety Checklist': <String, String>{
    'ms': 'Senarai Semak Keselamatan Berpandu',
    'bn': 'নির্দেশিত নিরাপত্তা চেকলিস্ট',
  },
  'Guided checks for possible camera indicators\nin hotel rooms and private spaces.':
      <String, String>{
    'ms':
        'Pemeriksaan berpandu untuk kemungkinan penunjuk kamera\ndi bilik hotel dan ruang persendirian.',
    'bn':
        'হোটেল রুম এবং ব্যক্তিগত স্থানগুলিতে সম্ভাব্য ক্যামেরা সূচক\nজন্য নির্দেশিত পরীক্ষা।',
  },
  'Hardware refreshed. \${uwb ? ': <String, String>{
    'ms': 'Perkakasan disegarkan. \${uwb ?',
    'bn': 'হার্ডওয়্যার রিফ্রেশ করা হয়েছে। \${uwb?',
  },
  'Hello, ': <String, String>{
    'ms': 'helo,',
    'bn': 'হ্যালো,',
  },
  'Help Articles': <String, String>{
    'ms': 'Artikel Bantuan',
    'bn': 'সাহায্য প্রবন্ধ',
  },
  'Help Center': <String, String>{
    'ms': 'Pusat Bantuan',
    'bn': 'সহায়তা কেন্দ্র',
  },
  'Help others by reporting new scams.': <String, String>{
    'ms': 'Bantu orang lain dengan melaporkan penipuan baharu.',
    'bn': 'নতুন স্ক্যাম রিপোর্ট করে অন্যদের সাহায্য করুন.',
  },
  'Hidden Camera Check': <String, String>{
    'ms': 'Semakan Kamera Tersembunyi',
    'bn': 'লুকানো ক্যামেরা চেক',
  },
  'Hidden Camera Safety': <String, String>{
    'ms': 'Keselamatan Kamera Tersembunyi',
    'bn': 'গোপন ক্যামেরা নিরাপত্তা',
  },
  'Hidden Camera Safety Check': <String, String>{
    'ms': 'Pemeriksaan Keselamatan Kamera Tersembunyi',
    'bn': 'গোপন ক্যামেরা নিরাপত্তা পরীক্ষা',
  },
  'History': <String, String>{
    'ms': 'Sejarah',
    'bn': 'ইতিহাস',
  },
  'Home': <String, String>{
    'ms': 'Rumah',
    'bn': 'বাড়ি',
  },
  'How can I identify a fake bank message?': <String, String>{
    'ms': 'Bagaimanakah saya boleh mengenal pasti mesej bank palsu?',
    'bn': 'আমি কিভাবে একটি জাল ব্যাঙ্ক বার্তা সনাক্ত করতে পারি?',
  },
  'How do I protect my accounts?': <String, String>{
    'ms': 'Bagaimanakah saya melindungi akaun saya?',
    'bn': 'আমি কিভাবে আমার অ্যাকাউন্ট রক্ষা করব?',
  },
  'How it works': <String, String>{
    'ms': 'Bagaimana ia berfungsi',
    'bn': 'এটা কিভাবে কাজ করে',
  },
  'How scammers use QR codes and how to avoid them.': <String, String>{
    'ms': 'Cara penipu menggunakan kod QR dan cara mengelakkannya.',
    'bn': 'স্ক্যামাররা কীভাবে QR কোড ব্যবহার করে এবং কীভাবে সেগুলি এড়াতে হয়।',
  },
  'How to Identify Fake Websites': <String, String>{
    'ms': 'Cara Mengenalpasti Laman Web Palsu',
    'bn': 'কিভাবে জাল ওয়েবসাইট সনাক্ত করতে হয়',
  },
  'I agree to the ': <String, String>{
    'ms': 'Saya bersetuju dengan',
    'bn': 'আমি রাজি',
  },
  'I clicked a phishing link. What should I do?': <String, String>{
    'ms': 'Saya mengklik pautan pancingan data. Apa yang patut saya buat?',
    'bn': 'আমি একটি ফিশিং লিঙ্ক ক্লিক করেছি. আমি কি করব?',
  },
  'I could not reach the assistant service. Confirm that the backend is running and try again.':
      <String, String>{
    'ms':
        'Saya tidak dapat menghubungi perkhidmatan pembantu. Sahkan bahawa bahagian belakang sedang berjalan dan cuba lagi.',
    'bn':
        'সহকারী সেবায় পৌঁছাতে পারিনি। নিশ্চিত করুন যে ব্যাকএন্ড চলছে এবং আবার চেষ্টা করুন।',
  },
  'Identity verified successfully.': <String, String>{
    'ms': 'Identiti berjaya disahkan.',
    'bn': 'পরিচয় সফলভাবে যাচাই করা হয়েছে।',
  },
  'Identity was not verified.': <String, String>{
    'ms': 'Identiti tidak disahkan.',
    'bn': 'পরিচয় যাচাই করা হয়নি.',
  },
  'If you find something': <String, String>{
    'ms': 'Jika anda menjumpai sesuatu',
    'bn': 'আপনি যদি কিছু খুঁজে পান',
  },
  'Important limitation': <String, String>{
    'ms': 'Had penting',
    'bn': 'গুরুত্বপূর্ণ সীমাবদ্ধতা',
  },
  'Important: ordinary phone cameras cannot reliably detect thermal or infrared cameras. Network and Bluetooth discovery are supporting checks, not proof that a location is camera-free.':
      <String, String>{
    'ms':
        'Penting: kamera telefon biasa tidak boleh mengesan kamera terma atau inframerah dengan pasti. Penemuan rangkaian dan Bluetooth menyokong semakan, bukan bukti bahawa lokasi bebas kamera.',
    'bn':
        'গুরুত্বপূর্ণ: সাধারণ ফোন ক্যামেরা নির্ভরযোগ্যভাবে তাপ বা ইনফ্রারেড ক্যামেরা সনাক্ত করতে পারে না। নেটওয়ার্ক এবং ব্লুটুথ আবিষ্কার চেক সমর্থন করছে, প্রমাণ নয় যে একটি অবস্থান ক্যামেরা-মুক্ত।',
  },
  'In App': <String, String>{
    'ms': 'Dalam Apl',
    'bn': 'অ্যাপে',
  },
  'In-app browser': <String, String>{
    'ms': 'Penyemak imbas dalam apl',
    'bn': 'ইন-অ্যাপ ব্রাউজার',
  },
  'Infrastructure location does not establish the content or organisation location.':
      <String, String>{
    'ms':
        'Lokasi infrastruktur tidak menetapkan kandungan atau lokasi organisasi.',
    'bn': 'অবকাঠামো অবস্থান বিষয়বস্তু বা প্রতিষ্ঠানের অবস্থান স্থাপন করে না।',
  },
  'Insights and statistics about your security': <String, String>{
    'ms': 'Cerapan dan statistik tentang keselamatan anda',
    'bn': 'আপনার নিরাপত্তা সম্পর্কে অন্তর্দৃষ্টি এবং পরিসংখ্যান',
  },
  'Inspect Authorized Wi-Fi': <String, String>{
    'ms': 'Periksa Wi-Fi Dibenarkan',
    'bn': 'অনুমোদিত ওয়াই-ফাই পরীক্ষা করুন',
  },
  'Inspect Nearby Bluetooth': <String, String>{
    'ms': 'Periksa Bluetooth Berdekatan',
    'bn': 'কাছাকাছি ব্লুটুথ পরিদর্শন করুন',
  },
  'Inspect a room for possible\nhidden-camera indicators': <String, String>{
    'ms': 'Periksa bilik untuk kemungkinan penunjuk kamera tersembunyi',
    'bn': 'সম্ভাব্য\nলুকানো-ক্যামেরা সূচকগুলির জন্য একটি রুম পরিদর্শন করুন',
  },
  'Inspecting Bluetooth...': <String, String>{
    'ms': 'Memeriksa Bluetooth...',
    'bn': 'ব্লুটুথ পরীক্ষা করা হচ্ছে...',
  },
  'Inspecting Network...': <String, String>{
    'ms': 'Memeriksa Rangkaian...',
    'bn': 'নেটওয়ার্ক পরিদর্শন করা হচ্ছে...',
  },
  'It represents identifying a threat’s digital fingerprint. Nirapod AI does not collect your biometric fingerprint.':
      <String, String>{
    'ms':
        'Ia mewakili mengenal pasti cap jari digital ancaman. Nirapod AI tidak mengumpul cap jari biometrik anda.',
    'bn':
        'এটি হুমকির ডিজিটাল ফিঙ্গারপ্রিন্ট সনাক্তকরণের প্রতিনিধিত্ব করে। Nirapod AI আপনার বায়োমেট্রিক আঙ্গুলের ছাপ সংগ্রহ করে না।',
  },
  'JPG, PNG, WEBP up to 10MB': <String, String>{
    'ms': 'JPG, PNG, WEBP sehingga 10MB',
    'bn': 'JPG, PNG, WEBP 10MB পর্যন্ত',
  },
  'ZAKARYA JAHIN': <String, String>{
    'ms': 'ZAKARYA JAHIN',
    'bn': 'ZAKARYA JAHIN',
  },
  'Jan': <String, String>{
    'ms': 'Jan',
    'bn': 'জান',
  },
  'Join Nirapod AI and stay protected online.': <String, String>{
    'ms': 'Sertai Nirapod AI dan kekal dilindungi dalam talian.',
    'bn': 'Nirapod AI-তে যোগ দিন এবং অনলাইনে সুরক্ষিত থাকুন।',
  },
  'Jul': <String, String>{
    'ms': 'Jul',
    'bn': 'জুল',
  },
  'Jun': <String, String>{
    'ms': 'Jun',
    'bn': 'জুন',
  },
  'Keep a record on this device': <String, String>{
    'ms': 'Simpan rekod pada peranti ini',
    'bn': 'এই ডিভাইসে একটি রেকর্ড রাখুন',
  },
  'Keep the complete message clearly inside the frame.': <String, String>{
    'ms': 'Simpan mesej lengkap dengan jelas di dalam bingkai.',
    'bn': 'সম্পূর্ণ বার্তাটি ফ্রেমের ভিতরে পরিষ্কারভাবে রাখুন।',
  },
  'Keeps a visible Android protection notification active': <String, String>{
    'ms': 'Memastikan pemberitahuan perlindungan Android yang kelihatan aktif',
    'bn': 'একটি দৃশ্যমান Android সুরক্ষা বিজ্ঞপ্তি সক্রিয় রাখে',
  },
  'Large': <String, String>{
    'ms': 'besar',
    'bn': 'বড়',
  },
  'Last 30 days': <String, String>{
    'ms': '30 hari lepas',
    'bn': 'গত 30 দিন',
  },
  'Learn how phishing attacks work and how to stay safe.': <String, String>{
    'ms':
        'Ketahui cara serangan pancingan data berfungsi dan cara untuk kekal selamat.',
    'bn': 'ফিশিং আক্রমণ কীভাবে কাজ করে এবং কীভাবে নিরাপদ থাকা যায় তা জানুন।',
  },
  'Learn realistic phone-assisted checks and their limitations.':
      <String, String>{
    'ms': 'Ketahui semakan berbantukan telefon yang realistik dan hadnya.',
    'bn': 'বাস্তবসম্মত ফোন-সহায়তা চেক এবং তাদের সীমাবদ্ধতা জানুন।',
  },
  'Learn what not to click or share.': <String, String>{
    'ms': 'Ketahui perkara yang tidak boleh diklik atau dikongsi.',
    'bn': 'কি ক্লিক বা শেয়ার করবেন না শিখুন.',
  },
  'Learning Centre': <String, String>{
    'ms': 'Pusat Pembelajaran',
    'bn': 'শিক্ষা কেন্দ্র',
  },
  'Link Scan': <String, String>{
    'ms': 'Imbasan Pautan',
    'bn': 'লিঙ্ক স্ক্যান',
  },
  'Links': <String, String>{
    'ms': 'Pautan',
    'bn': 'লিঙ্ক',
  },
  'Listening for nearby Bluetooth devices…': <String, String>{
    'ms': 'Mendengar peranti Bluetooth berdekatan…',
    'bn': 'কাছাকাছি ব্লুটুথ ডিভাইসের জন্য শোনা হচ্ছে...',
  },
  'Live camera scanning|Automatic URL checking|Warnings before opening':
      <String, String>{
    'ms':
        'Pengimbasan kamera langsung|Pemeriksaan URL automatik|Amaran sebelum dibuka',
    'bn': 'লাইভ ক্যামেরা স্ক্যানিং|স্বয়ংক্রিয় URL চেকিং|খোলার আগে সতর্কতা',
  },
  'Load More': <String, String>{
    'ms': 'Muatkan Lagi',
    'bn': 'আরো লোড',
  },
  'Loading...': <String, String>{
    'ms': 'Memuatkan...',
    'bn': 'লোড হচ্ছে...',
  },
  'Local security guide': <String, String>{
    'ms': 'Panduan keselamatan tempatan',
    'bn': 'স্থানীয় নিরাপত্তা গাইড',
  },
  'Location privacy notice': <String, String>{
    'ms': 'Notis privasi lokasi',
    'bn': 'অবস্থান গোপনীয়তা বিজ্ঞপ্তি',
  },
  'Log Out': <String, String>{
    'ms': 'Log Keluar',
    'bn': 'লগ আউট করুন',
  },
  'Log in': <String, String>{
    'ms': 'Log masuk',
    'bn': 'লগ ইন করুন',
  },
  'Login': <String, String>{
    'ms': 'Log masuk',
    'bn': 'লগইন করুন',
  },
  'Login to continue protecting yourself\nfrom phishing attacks.':
      <String, String>{
    'ms':
        'Log masuk untuk terus melindungi diri anda\ndaripada serangan pancingan data.',
    'bn': 'ফিশিং আক্রমণ থেকে নিজেকে রক্ষা করতে লগইন করুন৷',
  },
  'Machine learning evaluates links and messages.': <String, String>{
    'ms': 'Pembelajaran mesin menilai pautan dan mesej.',
    'bn': 'মেশিন লার্নিং লিঙ্ক এবং বার্তা মূল্যায়ন করে।',
  },
  'Manage password and 2FA': <String, String>{
    'ms': 'Urus kata laluan dan 2FA',
    'bn': 'পাসওয়ার্ড এবং 2FA পরিচালনা করুন',
  },
  'Manage your account and preferences': <String, String>{
    'ms': 'Urus akaun dan pilihan anda',
    'bn': 'আপনার অ্যাকাউন্ট এবং পছন্দগুলি পরিচালনা করুন',
  },
  'Manage your data and privacy': <String, String>{
    'ms': 'Urus data dan privasi anda',
    'bn': 'আপনার ডেটা এবং গোপনীয়তা পরিচালনা করুন',
  },
  'Manage your payment options': <String, String>{
    'ms': 'Urus pilihan pembayaran anda',
    'bn': 'আপনার অর্থপ্রদানের বিকল্পগুলি পরিচালনা করুন',
  },
  'Manual': <String, String>{
    'ms': 'Manual',
    'bn': 'ম্যানুয়াল',
  },
  'Mar': <String, String>{
    'ms': 'Mac',
    'bn': 'মার',
  },
  'Mark all as read': <String, String>{
    'ms': 'Tandai semua sebagai dibaca',
    'bn': 'সব পড়া হিসেবে চিহ্নিত করুন',
  },
  'May': <String, String>{
    'ms': 'Mei',
    'bn': 'মে',
  },
  'May 2025': <String, String>{
    'ms': 'Mei 2025',
    'bn': 'মে 2025',
  },
  'Medium': <String, String>{
    'ms': 'Sederhana',
    'bn': 'মাঝারি',
  },
  'Member Since': <String, String>{
    'ms': 'Ahli Sejak',
    'bn': 'থেকে সদস্য',
  },
  'Message': <String, String>{
    'ms': 'Mesej',
    'bn': 'বার্তা',
  },
  'Message / Text Scanner': <String, String>{
    'ms': 'Pengimbas Mesej / Teks',
    'bn': 'বার্তা / পাঠ্য স্ক্যানার',
  },
  'Message Scan': <String, String>{
    'ms': 'Imbasan Mesej',
    'bn': 'বার্তা স্ক্যান',
  },
  'Message Scanner': <String, String>{
    'ms': 'Pengimbas Mesej',
    'bn': 'বার্তা স্ক্যানার',
  },
  'Messages': <String, String>{
    'ms': 'Mesej',
    'bn': 'বার্তা',
  },
  'Messages & Inbox': <String, String>{
    'ms': 'Mesej & Peti Masuk',
    'bn': 'বার্তা এবং ইনবক্স',
  },
  'Microsoft / Outlook': <String, String>{
    'ms': 'Microsoft / Outlook',
    'bn': 'Microsoft / Outlook',
  },
  'Multiple possible hidden-camera indicators were reported. Leave the room and seek assistance.':
      <String, String>{
    'ms':
        'Beberapa kemungkinan penunjuk kamera tersembunyi telah dilaporkan. Keluar dari bilik dan dapatkan bantuan.',
    'bn':
        'একাধিক সম্ভাব্য লুকানো-ক্যামেরা সূচক রিপোর্ট করা হয়েছে. রুম ছেড়ে সাহায্য চাইতে.',
  },
  'Native security features for your Android device': <String, String>{
    'ms': 'Ciri keselamatan asli untuk peranti Android anda',
    'bn': 'আপনার Android ডিভাইসের জন্য স্থানীয় নিরাপত্তা বৈশিষ্ট্য',
  },
  'Nearby Bluetooth inspection is available in the Android app, not the web preview.':
      <String, String>{
    'ms':
        'Pemeriksaan Bluetooth berdekatan tersedia dalam apl Android, bukan pratonton web.',
    'bn': 'কাছাকাছি ব্লুটুথ পরিদর্শন Android অ্যাপে উপলব্ধ, ওয়েব প্রিভিউ নয়।',
  },
  'Nearby device': <String, String>{
    'ms': 'Peranti berdekatan',
    'bn': 'কাছাকাছি ডিভাইস',
  },
  'Nearby network inspection is available in the Android app, not the web preview.':
      <String, String>{
    'ms':
        'Pemeriksaan rangkaian berdekatan tersedia dalam apl Android, bukan pratonton web.',
    'bn':
        'আশেপাশের নেটওয়ার্ক পরিদর্শন Android অ্যাপে উপলব্ধ, ওয়েব প্রিভিউ নয়।',
  },
  'Nearby scans are user-initiated and should only be used on networks and places where you have permission.':
      <String, String>{
    'ms':
        'Imbasan berdekatan adalah dimulakan pengguna dan hanya boleh digunakan pada rangkaian dan tempat yang anda mempunyai kebenaran.',
    'bn':
        'আশেপাশের স্ক্যানগুলি ব্যবহারকারীর দ্বারা শুরু করা হয় এবং শুধুমাত্র সেই নেটওয়ার্ক এবং জায়গাগুলিতে ব্যবহার করা উচিত যেখানে আপনার অনুমতি আছে৷',
  },
  'Network inspection completed: \${findings.length} reachable device(s) reviewed. Ordinary web services are not treated as cameras.':
      <String, String>{
    'ms':
        'Pemeriksaan rangkaian selesai:\${findings.length}peranti yang boleh dicapai disemak. Perkhidmatan web biasa tidak dianggap sebagai kamera.',
    'bn':
        'নেটওয়ার্ক পরিদর্শন সম্পন্ন হয়েছে:\${findings.length}অ্যাক্সেসযোগ্য ডিভাইস(গুলি) পর্যালোচনা করা হয়েছে৷ সাধারণ ওয়েব পরিষেবাগুলিকে ক্যামেরা হিসাবে গণ্য করা হয় না।',
  },
  'Network inspection could not finish: \$error': <String, String>{
    'ms': 'Pemeriksaan rangkaian tidak dapat diselesaikan: \$error',
    'bn': 'নেটওয়ার্ক পরিদর্শন শেষ করা যায়নি: \$error',
  },
  'Next': <String, String>{
    'ms': 'Seterusnya',
    'bn': 'পরবর্তী',
  },
  'Nirapod AI': <String, String>{
    'ms': 'Nirapod AI',
    'bn': 'Nirapod AI',
  },
  'Nirapod AI helps you detect malicious\nlinks, QR codes, and scam messages\nbefore it’s too late.':
      <String, String>{
    'ms':
        'Nirapod AI membantu anda mengesan pautan\nberniat jahat, kod QR dan mesej penipuan\nsebelum terlambat.',
    'bn':
        'Nirapod AI আপনাকে ক্ষতিকারক\nলিঙ্ক, QR কোড এবং স্ক্যাম মেসেজ\nঅনেক দেরি হওয়ার আগেই শনাক্ত করতে সাহায্য করে।',
  },
  'Nirapod AI security test': <String, String>{
    'ms': 'Ujian keselamatan Nirapod AI',
    'bn': 'নিরাপোড এআই নিরাপত্তা পরীক্ষা',
  },
  'Nirapod AI uses measurements only from a supported accessory. It never invents an arrow, distance, temperature, or RF signal.':
      <String, String>{
    'ms':
        'Nirapod AI menggunakan ukuran hanya daripada aksesori yang disokong. Ia tidak pernah mencipta anak panah, jarak, suhu atau isyarat RF.',
    'bn':
        'Nirapod AI শুধুমাত্র একটি সমর্থিত আনুষঙ্গিক থেকে পরিমাপ ব্যবহার করে। এটি কখনই তীর, দূরত্ব, তাপমাত্রা বা আরএফ সংকেত আবিষ্কার করে না।',
  },
  'Nirapod Guide': <String, String>{
    'ms': 'Panduan Nirapod',
    'bn': 'নীরপদ গাইড',
  },
  'No \$category yet.': <String, String>{
    'ms': 'Belum ada \$category.',
    'bn': 'এখনও কোন\$categoryনেই।',
  },
  'No Bluetooth Low Energy broadcasts were detected.': <String, String>{
    'ms': 'Tiada siaran Bluetooth Tenaga Rendah dikesan.',
    'bn': 'কোনো ব্লুটুথ লো এনার্জি সম্প্রচার সনাক্ত করা যায়নি।',
  },
  'No Indicators Found': <String, String>{
    'ms': 'Tiada Petunjuk Ditemui',
    'bn': 'কোন সূচক পাওয়া যায়নি',
  },
  'No activity yet.\nComplete a scan to build your security report.':
      <String, String>{
    'ms':
        'Tiada aktiviti lagi.\nLengkapkan imbasan untuk membina laporan keselamatan anda.',
    'bn':
        'এখনো কোনো কার্যকলাপ নেই।\nআপনার নিরাপত্তা প্রতিবেদন তৈরি করতে একটি স্ক্যান সম্পূর্ণ করুন।',
  },
  'No camera was found on this device.': <String, String>{
    'ms': 'Tiada kamera ditemui pada peranti ini.',
    'bn': 'এই ডিভাইসে কোন ক্যামেরা পাওয়া যায়নি.',
  },
  'No compatible UWB peer, thermal camera, or directional RF accessory was detected.':
      <String, String>{
    'ms':
        'Tiada rakan sebaya UWB, kamera terma atau aksesori RF berarah yang serasi dikesan.',
    'bn':
        'কোন সামঞ্জস্যপূর্ণ UWB পিয়ার, থার্মাল ক্যামেরা, বা নির্দেশমূলক RF আনুষঙ্গিক সনাক্ত করা যায়নি।',
  },
  'No devices exposing the checked ports were found. This does not guarantee that a room has no hidden camera.':
      <String, String>{
    'ms':
        'Tiada peranti yang mendedahkan port yang diperiksa ditemui. Ini tidak menjamin bahawa bilik tidak mempunyai kamera tersembunyi.',
    'bn':
        'চেক করা পোর্টগুলি উন্মুক্ত করে এমন কোনো ডিভাইস পাওয়া যায়নি। এটি গ্যারান্টি দেয় না যে একটি ঘরে কোনও গোপন ক্যামেরা নেই।',
  },
  'No matching \$category found.': <String, String>{
    'ms': 'Tiada\$categoryyang sepadan ditemui.',
    'bn': 'কোন মিলিত\$categoryপাওয়া যায়নি.',
  },
  'No matching help articles were found.': <String, String>{
    'ms': 'Tiada artikel bantuan yang sepadan ditemui.',
    'bn': 'কোন মিলিত সাহায্য নিবন্ধ পাওয়া যায়নি.',
  },
  'No notifications yet. New scan results will appear here.': <String, String>{
    'ms':
        'Tiada pemberitahuan lagi. Keputusan imbasan baharu akan dipaparkan di sini.',
    'bn': 'এখনও কোন বিজ্ঞপ্তি নেই. নতুন স্ক্যান ফলাফল এখানে প্রদর্শিত হবে.',
  },
  'No plain text is currently copied.': <String, String>{
    'ms': 'Tiada teks biasa disalin pada masa ini.',
    'bn': 'কোন প্লেইন টেক্সট বর্তমানে কপি করা হয় না.',
  },
  'No readable QR code was found. Choose a clear, uncropped QR image.':
      <String, String>{
    'ms':
        'Tiada kod QR yang boleh dibaca ditemui. Pilih imej QR yang jelas dan tidak dipangkas.',
    'bn':
        'কোনো পাঠযোগ্য QR কোড পাওয়া যায়নি। একটি পরিষ্কার, আনক্রপ করা QR ইমেজ বেছে নিন।',
  },
  'No readable text was found. Try a clearer, full-size screenshot.':
      <String, String>{
    'ms':
        'Tiada teks yang boleh dibaca ditemui. Cuba tangkapan skrin bersaiz penuh yang lebih jelas.',
    'bn':
        'কোন পাঠযোগ্য পাঠ্য পাওয়া যায়নি. একটি পরিষ্কার, পূর্ণ আকারের স্ক্রিনশট চেষ্টা করুন।',
  },
  'No scans yet!': <String, String>{
    'ms': 'Tiada imbasan lagi!',
    'bn': 'এখনও কোন স্ক্যান!',
  },
  'No scans yet. Start a scan to create your history.': <String, String>{
    'ms': 'Tiada imbasan lagi. Mulakan imbasan untuk mencipta sejarah anda.',
    'bn': 'এখনও কোন স্ক্যান. আপনার ইতিহাস তৈরি করতে একটি স্ক্যান শুরু করুন।',
  },
  'No strong threat indicators were detected. This is not a guarantee that the website is safe.':
      <String, String>{
    'ms':
        'Tiada petunjuk ancaman yang kuat dikesan. Ini bukan jaminan bahawa laman web itu selamat.',
    'bn':
        'কোন শক্তিশালী হুমকি সূচক সনাক্ত করা যায়নি. এটি একটি গ্যারান্টি নয় যে ওয়েবসাইটটি নিরাপদ।',
  },
  'There is not enough meaningful information to assess this content.':
      <String, String>{
    'ms': 'Maklumat bermakna tidak mencukupi untuk menilai kandungan ini.',
    'bn': 'এই বিষয়বস্তু মূল্যায়নের জন্য পর্যাপ্ত অর্থপূর্ণ তথ্য নেই।',
  },
  'The available observations were insufficient to assess the room.':
      <String, String>{
    'ms': 'Pemerhatian yang tersedia tidak mencukupi untuk menilai bilik.',
    'bn': 'কক্ষটি মূল্যায়নের জন্য উপলভ্য পর্যবেক্ষণ যথেষ্ট ছিল না।',
  },
  'No threats recorded': <String, String>{
    'ms': 'Tiada ancaman direkodkan',
    'bn': 'কোন হুমকি রেকর্ড করা',
  },
  'Not supported by this phone': <String, String>{
    'ms': 'Tidak disokong oleh telefon ini',
    'bn': 'এই ফোন দ্বারা সমর্থিত নয়',
  },
  'Notifications': <String, String>{
    'ms': 'Pemberitahuan',
    'bn': 'বিজ্ঞপ্তি',
  },
  'Nov': <String, String>{
    'ms': 'Nov',
    'bn': 'নভেম্বর',
  },
  'Now': <String, String>{
    'ms': 'Sekarang',
    'bn': 'এখন',
  },
  'OK': <String, String>{
    'ms': 'OK',
    'bn': 'ঠিক আছে',
  },
  'OTP and Banking Scams': <String, String>{
    'ms': 'OTP dan Penipuan Perbankan',
    'bn': 'ওটিপি এবং ব্যাঙ্কিং কেলেঙ্কারি',
  },
  'Oct': <String, String>{
    'ms': 'Okt',
    'bn': 'অক্টো',
  },
  'Off': <String, String>{
    'ms': 'Mati',
    'bn': 'বন্ধ',
  },
  'One possible hidden-camera indicator was reported. Verify it without touching the object.':
      <String, String>{
    'ms':
        'Satu kemungkinan penunjuk kamera tersembunyi telah dilaporkan. Sahkan tanpa menyentuh objek.',
    'bn':
        'একটি সম্ভাব্য লুকানো-ক্যামেরা সূচক রিপোর্ট করা হয়েছে। বস্তু স্পর্শ না করে এটি যাচাই করুন।',
  },
  'Online AI': <String, String>{
    'ms': 'AI dalam talian',
    'bn': 'অনলাইন এআই',
  },
  'Only scan a Wi-Fi network you are authorized to inspect. Nirapod AI checks nearby IP services and Bluetooth names; it cannot identify a device owner or point to its physical location.':
      <String, String>{
    'ms':
        'Hanya imbas rangkaian Wi-Fi yang anda dibenarkan untuk memeriksa. Nirapod AI menyemak perkhidmatan IP berdekatan dan nama Bluetooth; ia tidak boleh mengenal pasti pemilik peranti atau menunjuk ke lokasi fizikalnya.',
    'bn':
        'শুধুমাত্র একটি Wi-Fi নেটওয়ার্ক স্ক্যান করুন যা আপনি পরিদর্শনের জন্য অনুমোদিত। Nirapod AI কাছাকাছি আইপি পরিষেবা এবং ব্লুটুথ নাম পরীক্ষা করে; এটি কোনও ডিভাইসের মালিককে শনাক্ত করতে পারে না বা এর প্রকৃত অবস্থান নির্দেশ করতে পারে না।',
  },
  'Oops! It looks like you’re offline.': <String, String>{
    'ms': 'Aduh! Nampaknya anda berada di luar talian.',
    'bn': 'উফ! মনে হচ্ছে আপনি অফলাইনে আছেন।',
  },
  'Open this project on an Android phone or emulator from Android Studio.':
      <String, String>{
    'ms':
        'Buka projek ini pada telefon Android atau emulator daripada Android Studio.',
    'bn':
        'Android স্টুডিও থেকে একটি Android ফোন বা এমুলেটরে এই প্রকল্পটি খুলুন।',
  },
  'Open-source contributors': <String, String>{
    'ms': 'Penyumbang sumber terbuka',
    'bn': 'ওপেন সোর্স অবদানকারী',
  },
  'Or choose from': <String, String>{
    'ms': 'Atau pilih daripada',
    'bn': 'অথবা থেকে চয়ন করুন',
  },
  'Other': <String, String>{
    'ms': 'Lain-lain',
    'bn': 'অন্যান্য',
  },
  'PIN': <String, String>{
    'ms': 'PIN',
    'bn': 'পিন',
  },
  'Password': <String, String>{
    'ms': 'Kata laluan',
    'bn': 'পাসওয়ার্ড',
  },
  'Paste SMS here...': <String, String>{
    'ms': 'Tampal SMS di sini...',
    'bn': 'এখানে এসএমএস পেস্ট করুন...',
  },
  'Paste Text': <String, String>{
    'ms': 'Tampal Teks',
    'bn': 'টেক্সট পেস্ট করুন',
  },
  'Paste a website address and let Nirapod inspect its structure and warning signs.':
      <String, String>{
    'ms':
        'Tampal alamat tapak web dan biarkan Nirapod memeriksa struktur dan tanda amarannya.',
    'bn':
        'একটি ওয়েবসাইটের ঠিকানা পেস্ট করুন এবং Nirapod এর গঠন এবং সতর্কতা চিহ্ন পরিদর্শন করতে দিন।',
  },
  'Paste any message or text content below to scan for threats.':
      <String, String>{
    'ms':
        'Tampal sebarang mesej atau kandungan teks di bawah untuk mengimbas ancaman.',
    'bn':
        'হুমকির জন্য স্ক্যান করতে নিচে যেকোন বার্তা বা টেক্সট কন্টেন্ট পেস্ট করুন।',
  },
  'Paste any website address and receive a clear safety rating before opening it or sharing personal information.':
      <String, String>{
    'ms':
        'Tampal sebarang alamat tapak web dan terima penilaian keselamatan yang jelas sebelum membukanya atau berkongsi maklumat peribadi.',
    'bn':
        'যেকোনো ওয়েবসাইটের ঠিকানা পেস্ট করুন এবং এটি খোলার আগে বা ব্যক্তিগত তথ্য শেয়ার করার আগে একটি পরিষ্কার নিরাপত্তা রেটিং পান।',
  },
  'Paste text here...': <String, String>{
    'ms': 'Tampal teks di sini...',
    'bn': 'এখানে পাঠ্য পেস্ট করুন...',
  },
  'Paste the complete SMS message below to scan for threats.': <String, String>{
    'ms': 'Tampalkan mesej SMS lengkap di bawah untuk mengimbas ancaman.',
    'bn': 'হুমকির জন্য স্ক্যান করতে নীচে সম্পূর্ণ এসএমএস বার্তা আটকান।',
  },
  'Paste the decoded link, payment payload, or text': <String, String>{
    'ms': 'Tampalkan pautan yang dinyahkod, muatan pembayaran atau teks',
    'bn': 'ডিকোড করা লিঙ্ক, পেমেন্ট পেলোড বা টেক্সট পেস্ট করুন',
  },
  'Paste the email sender, subject, and message body below.': <String, String>{
    'ms': 'Tampalkan penghantar e-mel, subjek dan kandungan mesej di bawah.',
    'bn': 'নীচে ইমেল প্রেরক, বিষয়, এবং বার্তা প্রধান অংশ আটকান.',
  },
  'Payment Methods': <String, String>{
    'ms': 'Kaedah Pembayaran',
    'bn': 'পেমেন্ট পদ্ধতি',
  },
  'Phishing': <String, String>{
    'ms': 'Pancingan data',
    'bn': 'ফিশিং',
  },
  'Phishing Website': <String, String>{
    'ms': 'Laman Web Pancingan data',
    'bn': 'ফিশিং ওয়েবসাইট',
  },
  'Phone supported • compatible participating peer required': <String, String>{
    'ms': 'Telefon disokong • rakan sebaya penyertaan yang serasi diperlukan',
    'bn': 'ফোন সমর্থিত • সামঞ্জস্যপূর্ণ অংশগ্রহণকারী সহকর্মী প্রয়োজন',
  },
  'Please check your internet connection and try again.': <String, String>{
    'ms': 'Sila semak sambungan internet anda dan cuba lagi.',
    'bn': 'আপনার ইন্টারনেট সংযোগ পরীক্ষা করুন এবং আবার চেষ্টা করুন.',
  },
  'Please select an image smaller than 10 MB.': <String, String>{
    'ms': 'Sila pilih imej yang lebih kecil daripada 10 MB.',
    'bn': 'অনুগ্রহ করে 10 MB এর চেয়ে ছোট একটি ছবি নির্বাচন করুন৷',
  },
  'Please wait while we scan': <String, String>{
    'ms': 'Sila tunggu sementara kami mengimbas',
    'bn': 'আমরা স্ক্যান করার সময় অনুগ্রহ করে অপেক্ষা করুন',
  },
  'Point the camera at a QR code.': <String, String>{
    'ms': 'Halakan kamera pada kod QR.',
    'bn': 'ক্যামেরাটিকে একটি QR কোডে নির্দেশ করুন।',
  },
  'Popular Articles': <String, String>{
    'ms': 'Artikel Popular',
    'bn': 'জনপ্রিয় প্রবন্ধ',
  },
  'Popular Topics': <String, String>{
    'ms': 'Topik Popular',
    'bn': 'জনপ্রিয় বিষয়',
  },
  'Possible lens reflection': <String, String>{
    'ms': 'Kemungkinan pantulan lensa',
    'bn': 'সম্ভাব্য লেন্স প্রতিফলন',
  },
  'Privacy First': <String, String>{
    'ms': 'Privasi Diutamakan',
    'bn': 'গোপনীয়তা প্রথম',
  },
  'Privacy Settings': <String, String>{
    'ms': 'Tetapan Privasi',
    'bn': 'গোপনীয়তা সেটিংস',
  },
  'Privacy first': <String, String>{
    'ms': 'Privasi dahulu',
    'bn': 'গোপনীয়তা প্রথম',
  },
  'Profile': <String, String>{
    'ms': 'Profil',
    'bn': 'প্রোফাইল',
  },
  'Profile saved to the database.': <String, String>{
    'ms': 'Profil disimpan ke pangkalan data.',
    'bn': 'প্রোফাইল ডাটাবেসে সংরক্ষিত.',
  },
  'Protect Your': <String, String>{
    'ms': 'Lindungi Anda',
    'bn': 'আপনার রক্ষা করুন',
  },
  'Protect yourself from OTP and banking fraud.': <String, String>{
    'ms': 'Lindungi diri anda daripada OTP dan penipuan perbankan.',
    'bn': 'OTP এবং ব্যাঙ্কিং জালিয়াতি থেকে নিজেকে রক্ষা করুন।',
  },
  'Pull text from images or documents.': <String, String>{
    'ms': 'Tarik teks daripada imej atau dokumen.',
    'bn': 'ছবি বা নথি থেকে পাঠ্য টানুন।',
  },
  'Purple': <String, String>{
    'ms': 'Ungu',
    'bn': 'বেগুনি',
  },
  'QR Code': <String, String>{
    'ms': 'Kod QR',
    'bn': 'QR কোড',
  },
  'QR Code Safety': <String, String>{
    'ms': 'Keselamatan Kod QR',
    'bn': 'QR কোড নিরাপত্তা',
  },
  'QR Code Scams': <String, String>{
    'ms': 'Penipuan Kod QR',
    'bn': 'QR কোড স্ক্যাম',
  },
  'QR Code Scan': <String, String>{
    'ms': 'Imbasan Kod QR',
    'bn': 'QR কোড স্ক্যান',
  },
  'QR Code Scanner': <String, String>{
    'ms': 'Pengimbas Kod QR',
    'bn': 'QR কোড স্ক্যানার',
  },
  'QR Codes': <String, String>{
    'ms': 'Kod QR',
    'bn': 'QR কোড',
  },
  'QR Destinations': <String, String>{
    'ms': 'Destinasi QR',
    'bn': 'QR গন্তব্য',
  },
  'QR code scans': <String, String>{
    'ms': 'Imbasan kod QR',
    'bn': 'QR কোড স্ক্যান',
  },
  'Quick Scan': <String, String>{
    'ms': 'Imbasan Pantas',
    'bn': 'দ্রুত স্ক্যান',
  },
  'Rate Us': <String, String>{
    'ms': 'Nilaikan Kami',
    'bn': 'আমাদের রেট',
  },
  'Read copied text': <String, String>{
    'ms': 'Baca teks yang disalin',
    'bn': 'অনুলিপি করা পাঠ্য পড়ুন',
  },
  'Reading Image...': <String, String>{
    'ms': 'Membaca Imej...',
    'bn': 'ছবি পড়া হচ্ছে...',
  },
  'Reading clipboard…': <String, String>{
    'ms': 'Membaca papan keratan…',
    'bn': 'ক্লিপবোর্ড পড়া হচ্ছে...',
  },
  'Reads the clipboard only after you tap this option': <String, String>{
    'ms': 'Membaca papan keratan hanya selepas anda mengetik pilihan ini',
    'bn': 'আপনি এই বিকল্পটি আলতো চাপার পরেই ক্লিপবোর্ডটি পড়ে',
  },
  'Real ML analysis|Risk score from 0 to 100|Database scan history':
      <String, String>{
    'ms':
        'Analisis ML sebenar|Skor risiko dari 0 hingga 100|Sejarah imbasan pangkalan data',
    'bn':
        'বাস্তব ML বিশ্লেষণ|0 থেকে 100 পর্যন্ত ঝুঁকির স্কোর|ডাটাবেস স্ক্যান ইতিহাস',
  },
  'Reason \${entry.key + 1}': <String, String>{
    'ms': 'Sebab \${entry.key + 1}',
    'bn': 'কারণ \${entry.key + 1}',
  },
  'Recent Scans': <String, String>{
    'ms': 'Imbasan Terbaharu',
    'bn': 'সাম্প্রতিক স্ক্যান',
  },
  'Recent Scans (\$total)': <String, String>{
    'ms': 'Imbasan Terbaharu (\$total)',
    'bn': 'সাম্প্রতিক স্ক্যান (\$total)',
  },
  'Recent Scans (0)': <String, String>{
    'ms': 'Imbasan Terbaharu (0)',
    'bn': 'সাম্প্রতিক স্ক্যান (0)',
  },
  'Recent Threats': <String, String>{
    'ms': 'Ancaman Baru-baru ini',
    'bn': 'সাম্প্রতিক হুমকি',
  },
  'Recently Reported': <String, String>{
    'ms': 'Dilaporkan Baru-baru ini',
    'bn': 'সম্প্রতি রিপোর্ট',
  },
  'Refresh Sensor Hardware': <String, String>{
    'ms': 'Muat semula Perkakasan Sensor',
    'bn': 'রিফ্রেশ সেন্সর হার্ডওয়্যার',
  },
  'Repeat Bluetooth Inspection (\${_bluetoothFindings.length})':
      <String, String>{
    'ms': 'Ulangi Pemeriksaan Bluetooth (\${_bluetoothFindings.length})',
    'bn': 'ব্লুটুথ পরিদর্শন পুনরাবৃত্তি করুন (\${_bluetoothFindings.length})',
  },
  'Repeat Camera Inspection': <String, String>{
    'ms': 'Ulangi Pemeriksaan Kamera',
    'bn': 'ক্যামেরা পরিদর্শন পুনরাবৃত্তি করুন',
  },
  'Repeat Wi-Fi Inspection (\${_networkFindings.length})': <String, String>{
    'ms': 'Ulangi Pemeriksaan Wi-Fi (\${_networkFindings.length})',
    'bn': 'ওয়াই-ফাই পরিদর্শন পুনরাবৃত্তি করুন (\${_networkFindings.length})',
  },
  'Report Submitted': <String, String>{
    'ms': 'Laporan Dihantar',
    'bn': 'প্রতিবেদন দাখিল করা হয়েছে',
  },
  'Report a Scam': <String, String>{
    'ms': 'Laporkan Penipuan',
    'bn': 'একটি স্ক্যাম রিপোর্ট করুন',
  },
  'Reports': <String, String>{
    'ms': 'Laporan',
    'bn': 'রিপোর্ট',
  },
  'Reports could not be loaded. Check the secure backend connection.':
      <String, String>{
    'ms':
        'Laporan tidak dapat dimuatkan. Semak sambungan hujung belakang selamat.',
    'bn': 'রিপোর্ট লোড করা যায়নি. নিরাপদ ব্যাকএন্ড সংযোগ পরীক্ষা করুন।',
  },
  'Retry': <String, String>{
    'ms': 'Cuba semula',
    'bn': 'আবার চেষ্টা করুন',
  },
  'Reveal Hidden': <String, String>{
    'ms': 'Dedah Tersembunyi',
    'bn': 'লুকানো প্রকাশ',
  },
  'Reveal QR links and\ncheck their safety': <String, String>{
    'ms': 'Dedahkan pautan QR dan\nsemak keselamatannya',
    'bn': 'QR লিঙ্কগুলি প্রকাশ করুন এবং\nতাদের নিরাপত্তা পরীক্ষা করুন',
  },
  'Reveal the destination inside a QR code and check it for phishing indicators before visiting the website.':
      <String, String>{
    'ms':
        'Dedahkan destinasi di dalam kod QR dan semaknya untuk penunjuk pancingan data sebelum melawati tapak web.',
    'bn':
        'একটি QR কোডের মধ্যে গন্তব্যটি প্রকাশ করুন এবং ওয়েবসাইটটি দেখার আগে এটি ফিশিং সূচকগুলির জন্য পরীক্ষা করুন৷',
  },
  'Review confidence and risk scores.': <String, String>{
    'ms': 'Semak keyakinan dan skor risiko.',
    'bn': 'আত্মবিশ্বাস এবং ঝুঁকির স্কোর পর্যালোচনা করুন।',
  },
  'Risk Score': <String, String>{
    'ms': 'Skor Risiko',
    'bn': 'ঝুঁকি স্কোর',
  },
  'Room Check': <String, String>{
    'ms': 'Semakan Bilik',
    'bn': 'রুম চেক',
  },
  'Room Checks': <String, String>{
    'ms': 'Pemeriksaan Bilik',
    'bn': 'রুম চেক',
  },
  'Room Privacy': <String, String>{
    'ms': 'Privasi Bilik',
    'bn': 'রুম গোপনীয়তা',
  },
  'Running AI Model': <String, String>{
    'ms': 'Menjalankan Model AI',
    'bn': 'এআই মডেল চলছে',
  },
  'SMS': <String, String>{
    'ms': 'SMS',
    'bn': 'এসএমএস',
  },
  'SMS / Text Messages': <String, String>{
    'ms': 'SMS / Mesej Teks',
    'bn': 'এসএমএস/টেক্সট মেসেজ',
  },
  'SMS Scan': <String, String>{
    'ms': 'Imbasan SMS',
    'bn': 'এসএমএস স্ক্যান',
  },
  'Safe': <String, String>{
    'ms': 'selamat',
    'bn': 'নিরাপদ',
  },
  'Safe Items': <String, String>{
    'ms': 'Barang Selamat',
    'bn': 'নিরাপদ আইটেম',
  },
  'Safe to continue': <String, String>{
    'ms': 'Selamat untuk diteruskan',
    'bn': 'চালিয়ে যাওয়া নিরাপদ',
  },
  'Safer links in seconds.': <String, String>{
    'ms': 'Pautan lebih selamat dalam beberapa saat.',
    'bn': 'সেকেন্ডের মধ্যে নিরাপদ লিঙ্ক।',
  },
  'Safety Tip': <String, String>{
    'ms': 'Petua Keselamatan',
    'bn': 'নিরাপত্তা টিপ',
  },
  'Save': <String, String>{
    'ms': 'Jimat',
    'bn': 'সংরক্ষণ করুন',
  },
  'Save Scan History': <String, String>{
    'ms': 'Simpan Sejarah Imbasan',
    'bn': 'স্ক্যান ইতিহাস সংরক্ষণ করুন',
  },
  'Saved to your account': <String, String>{
    'ms': 'Disimpan ke akaun anda',
    'bn': 'আপনার অ্যাকাউন্টে সংরক্ষিত',
  },
  'Saving Check...': <String, String>{
    'ms': 'Menyimpan Cek...',
    'bn': 'চেক সংরক্ষণ করা হচ্ছে...',
  },
  'Scam SMS': <String, String>{
    'ms': 'SMS penipuan',
    'bn': 'স্ক্যাম এসএমএস',
  },
  'Scam language detection|Actionable safety advice|Community reporting':
      <String, String>{
    'ms':
        'Pengesanan bahasa penipuan|Nasihat keselamatan yang boleh diambil tindakan|Pelaporan komuniti',
    'bn':
        'স্ক্যাম ভাষা সনাক্তকরণ|অ্যাকশনেবল নিরাপত্তা পরামর্শ|কমিউনিটি রিপোর্টিং',
  },
  'Scan': <String, String>{
    'ms': 'Imbas',
    'bn': 'স্ক্যান করুন',
  },
  'Scan Again': <String, String>{
    'ms': 'Imbas Lagi',
    'bn': 'আবার স্ক্যান করুন',
  },
  'Scan Email': <String, String>{
    'ms': 'Imbas E-mel',
    'bn': 'ইমেল স্ক্যান করুন',
  },
  'Scan Hidden QR Links': <String, String>{
    'ms': 'Imbas Pautan QR Tersembunyi',
    'bn': 'লুকানো QR লিঙ্ক স্ক্যান করুন',
  },
  'Scan Image': <String, String>{
    'ms': 'Imbas Imej',
    'bn': 'ছবি স্ক্যান করুন',
  },
  'Scan Message': <String, String>{
    'ms': 'Imbas Mesej',
    'bn': 'বার্তা স্ক্যান করুন',
  },
  'Scan Notifications': <String, String>{
    'ms': 'Imbasan Pemberitahuan',
    'bn': 'স্ক্যান বিজ্ঞপ্তি',
  },
  'Scan QR Code': <String, String>{
    'ms': 'Imbas Kod QR',
    'bn': 'QR কোড স্ক্যান করুন',
  },
  'Scan QR codes': <String, String>{
    'ms': 'Imbas kod QR',
    'bn': 'QR কোড স্ক্যান করুন',
  },
  'Scan QR codes safely and verify\nwhere they lead.': <String, String>{
    'ms': 'Imbas kod QR dengan selamat dan sahkan\nke mana ia menuju.',
    'bn':
        'QR কোডগুলি নিরাপদে স্ক্যান করুন এবং\nযাচাই করুন যেখানে তারা নেতৃত্ব দেয়৷',
  },
  'Scan QR codes to reveal links\nand check for threats.': <String, String>{
    'ms': 'Imbas kod QR untuk mendedahkan pautan\ndan semak ancaman.',
    'bn':
        'লিঙ্কগুলি প্রকাশ করতে QR কোডগুলি স্ক্যান করুন এবং হুমকির জন্য পরীক্ষা করুন৷',
  },
  'Scan Result': <String, String>{
    'ms': 'Hasil Imbasan',
    'bn': 'স্ক্যান ফলাফল',
  },
  'Scan SMS': <String, String>{
    'ms': 'Imbas SMS',
    'bn': 'এসএমএস স্ক্যান করুন',
  },
  'Scan Text': <String, String>{
    'ms': 'Teks Imbas',
    'bn': 'পাঠ্য স্ক্যান করুন',
  },
  'Scan URL': <String, String>{
    'ms': 'Imbas URL',
    'bn': 'ইউআরএল স্ক্যান করুন',
  },
  'Scan WhatsApp or Telegram messages': <String, String>{
    'ms': 'Imbas mesej WhatsApp atau Telegram',
    'bn': 'হোয়াটসঅ্যাপ বা টেলিগ্রাম বার্তা স্ক্যান করুন',
  },
  'Scan images with OCR': <String, String>{
    'ms': 'Imbas imej dengan OCR',
    'bn': 'OCR দিয়ে ছবি স্ক্যান করুন',
  },
  'Scan text, SMS & email': <String, String>{
    'ms': 'Imbas teks, SMS & e-mel',
    'bn': 'পাঠ্য, এসএমএস এবং ইমেল স্ক্যান করুন',
  },
  'Scan website links': <String, String>{
    'ms': 'Imbas pautan tapak web',
    'bn': 'ওয়েবসাইট লিঙ্ক স্ক্যান করুন',
  },
  'Scanned Item': <String, String>{
    'ms': 'Item Diimbas',
    'bn': 'স্ক্যান করা আইটেম',
  },
  'Scanned just now': <String, String>{
    'ms': 'Diimbas sebentar tadi',
    'bn': 'এইমাত্র স্ক্যান করা হয়েছে',
  },
  'Scanning': <String, String>{
    'ms': 'Mengimbas',
    'bn': 'স্ক্যানিং',
  },
  'Scanning Database': <String, String>{
    'ms': 'Mengimbas Pangkalan Data',
    'bn': 'ডাটাবেস স্ক্যান করা হচ্ছে',
  },
  'Scans Over Time · \${data[': <String, String>{
    'ms': 'Imbasan Sepanjang Masa · \${data[',
    'bn': 'সময়ের সাথে স্ক্যান করা হয় · \${data[',
  },
  'Screenshot': <String, String>{
    'ms': 'Tangkapan skrin',
    'bn': 'স্ক্রিনশট',
  },
  'Screenshot / OCR': <String, String>{
    'ms': 'Tangkapan skrin / OCR',
    'bn': 'স্ক্রিনশট/ওসিআর',
  },
  'Screenshot / OCR Scan': <String, String>{
    'ms': 'Tangkapan skrin / Imbasan OCR',
    'bn': 'স্ক্রিনশট/ওসিআর স্ক্যান',
  },
  'Screenshots': <String, String>{
    'ms': 'Tangkapan skrin',
    'bn': 'স্ক্রিনশট',
  },
  'Search for help articles...': <String, String>{
    'ms': 'Cari artikel bantuan...',
    'bn': 'সাহায্য নিবন্ধের জন্য অনুসন্ধান করুন...',
  },
  'Search scans...': <String, String>{
    'ms': 'Imbasan carian...',
    'bn': 'স্ক্যান অনুসন্ধান করুন...',
  },
  'Secure analysis': <String, String>{
    'ms': 'Analisis selamat',
    'bn': 'নিরাপদ বিশ্লেষণ',
  },
  'Security': <String, String>{
    'ms': 'Keselamatan',
    'bn': 'নিরাপত্তা',
  },
  'See Safe, Suspicious, or Dangerous results.': <String, String>{
    'ms': 'Lihat keputusan Selamat, Meragukan atau Berbahaya.',
    'bn': 'নিরাপদ, সন্দেহজনক বা বিপজ্জনক ফলাফল দেখুন।',
  },
  'See if content is safe or dangerous.': <String, String>{
    'ms': 'Lihat sama ada kandungan selamat atau berbahaya.',
    'bn': 'বিষয়বস্তু নিরাপদ বা বিপজ্জনক কিনা দেখুন।',
  },
  'See the latest scams reported by our community.': <String, String>{
    'ms': 'Lihat penipuan terkini yang dilaporkan oleh komuniti kami.',
    'bn': 'আমাদের সম্প্রদায়ের দ্বারা রিপোর্ট করা সর্বশেষ স্ক্যামগুলি দেখুন৷',
  },
  'See where every code leads.': <String, String>{
    'ms': 'Lihat ke mana arah setiap kod.',
    'bn': 'প্রতিটি কোড কোথায় নিয়ে যায় তা দেখুন।',
  },
  'Select Scan Type': <String, String>{
    'ms': 'Pilih Jenis Imbasan',
    'bn': 'স্ক্যান টাইপ নির্বাচন করুন',
  },
  'Select from Gallery': <String, String>{
    'ms': 'Pilih daripada Galeri',
    'bn': 'গ্যালারি থেকে নির্বাচন করুন',
  },
  'Send Reset Link': <String, String>{
    'ms': 'Hantar Pautan Tetapan Semula',
    'bn': 'রিসেট লিঙ্ক পাঠান',
  },
  'Send test security alert': <String, String>{
    'ms': 'Hantar amaran keselamatan ujian',
    'bn': 'পরীক্ষা নিরাপত্তা সতর্কতা পাঠান',
  },
  'Sender:\nSubject:\n\nPaste the email body here...': <String, String>{
    'ms': 'Pengirim:\nSubjek:\n\n Tampal badan e-mel di sini...',
    'bn': 'প্রেরক:\nবিষয়:\n\n এখানে ইমেলের বডি পেস্ট করুন...',
  },
  'Sending alert…': <String, String>{
    'ms': 'Menghantar makluman…',
    'bn': 'সতর্কতা পাঠানো হচ্ছে...',
  },
  'Sep': <String, String>{
    'ms': 'Sep',
    'bn': 'সেপ্টেম্বর',
  },
  'Setting could not be saved. Check the backend.': <String, String>{
    'ms': 'Tetapan tidak dapat disimpan. Semak bahagian belakang.',
    'bn': 'সেটিং সংরক্ষণ করা যায়নি. ব্যাকএন্ড চেক করুন।',
  },
  'Settings': <String, String>{
    'ms': 'tetapan',
    'bn': 'সেটিংস',
  },
  'Share your experience': <String, String>{
    'ms': 'Kongsi pengalaman anda',
    'bn': 'আপনার অভিজ্ঞতা শেয়ার করুন',
  },
  'Showing \${items.length} of \$total scans': <String, String>{
    'ms': 'Menunjukkan imbasan\${items.length}daripada \$total',
    'bn': '\$total স্ক্যানের\${items.length}দেখানো হচ্ছে',
  },
  'Shows BLE devices broadcasting nearby for manual review': <String, String>{
    'ms':
        'Menunjukkan peranti BLE yang disiarkan berdekatan untuk semakan manual',
    'bn':
        'ম্যানুয়াল পর্যালোচনার জন্য কাছাকাছি সম্প্রচার করা BLE ডিভাইসগুলি দেখায়৷',
  },
  'Sign Up': <String, String>{
    'ms': 'Daftar',
    'bn': 'সাইন আপ করুন',
  },
  'Sign in and check the backend connection.': <String, String>{
    'ms': 'Log masuk dan semak sambungan bahagian belakang.',
    'bn': 'সাইন ইন করুন এবং ব্যাকএন্ড সংযোগ পরীক্ষা করুন।',
  },
  'Signing In...': <String, String>{
    'ms': 'Log Masuk...',
    'bn': 'সাইন ইন হচ্ছে...',
  },
  'Skip': <String, String>{
    'ms': 'Langkau',
    'bn': 'এড়িয়ে যান',
  },
  'Small': <String, String>{
    'ms': 'Kecil',
    'bn': 'ছোট',
  },
  'Smart Protection': <String, String>{
    'ms': 'Perlindungan Pintar',
    'bn': 'স্মার্ট সুরক্ষা',
  },
  'Social Media / Chat': <String, String>{
    'ms': 'Media Sosial / Sembang',
    'bn': 'সোশ্যাল মিডিয়া / চ্যাট',
  },
  'Start Camera Inspection': <String, String>{
    'ms': 'Mulakan Pemeriksaan Kamera',
    'bn': 'ক্যামেরা পরিদর্শন শুরু করুন',
  },
  'Start Scanning': <String, String>{
    'ms': 'Mula Mengimbas',
    'bn': 'স্ক্যান করা শুরু করুন',
  },
  'Start foreground protection': <String, String>{
    'ms': 'Mulakan perlindungan latar depan',
    'bn': 'ফোরগ্রাউন্ড সুরক্ষা শুরু করুন',
  },
  'Start scanning': <String, String>{
    'ms': 'Mula mengimbas',
    'bn': 'স্ক্যান করা শুরু করুন',
  },
  'Start scanning to see your history here.': <String, String>{
    'ms': 'Mula mengimbas untuk melihat sejarah anda di sini.',
    'bn': 'এখানে আপনার ইতিহাস দেখতে স্ক্যান করা শুরু করুন।',
  },
  'Starting protection…': <String, String>{
    'ms': 'Memulakan perlindungan…',
    'bn': 'সুরক্ষা শুরু হচ্ছে...',
  },
  'Status': <String, String>{
    'ms': 'Status',
    'bn': 'স্ট্যাটাস',
  },
  'Stay Safe Online': <String, String>{
    'ms': 'Kekal Selamat Dalam Talian',
    'bn': 'অনলাইনে নিরাপদে থাকুন',
  },
  'Stay safe online. We’ve got your back.': <String, String>{
    'ms': 'Kekal selamat dalam talian. Kami menyokong anda.',
    'bn': 'অনলাইনে নিরাপদে থাকুন। আমরা আপনার ফিরে পেয়েছি.',
  },
  'Subject': <String, String>{
    'ms': 'Subjek',
    'bn': 'বিষয়',
  },
  'Submit': <String, String>{
    'ms': 'Hantar',
    'bn': 'জমা দিন',
  },
  'Submit Report': <String, String>{
    'ms': 'Hantar Laporan',
    'bn': 'রিপোর্ট জমা দিন',
  },
  'Submitting...': <String, String>{
    'ms': 'Menyerahkan...',
    'bn': 'জমা দেওয়া হচ্ছে...',
  },
  'Supervisor': <String, String>{
    'ms': 'Penyelia',
    'bn': 'সুপারভাইজার',
  },
  'YUDI BUDI SUSILO': <String, String>{
    'ms': 'YUDI BUDI SUSILO',
    'bn': 'সুপারভাইজার নাম',
  },
  'Support & More': <String, String>{
    'ms': 'Sokongan & Lagi',
    'bn': 'সমর্থন এবং আরো',
  },
  'Support ticket #\$id was saved successfully.': <String, String>{
    'ms': 'Tiket sokongan #\$idtelah berjaya disimpan.',
    'bn': 'সমর্থন টিকিট #\$idসফলভাবে সংরক্ষিত হয়েছে৷',
  },
  'Supported directional RF accessory required': <String, String>{
    'ms': 'Aksesori RF arah yang disokong diperlukan',
    'bn': 'সমর্থিত নির্দেশমূলক RF আনুষঙ্গিক প্রয়োজন',
  },
  'Supported thermal accessory required': <String, String>{
    'ms': 'Aksesori terma yang disokong diperlukan',
    'bn': 'সমর্থিত তাপ আনুষঙ্গিক প্রয়োজন',
  },
  'Suspicious': <String, String>{
    'ms': 'mencurigakan',
    'bn': 'সন্দেহজনক',
  },
  'Suspicious and dangerous results will appear here after a scan.':
      <String, String>{
    'ms':
        'Keputusan yang mencurigakan dan berbahaya akan muncul di sini selepas imbasan.',
    'bn':
        'একটি স্ক্যান করার পরে সন্দেহজনক এবং বিপজ্জনক ফলাফল এখানে প্রদর্শিত হবে।',
  },
  'Suspicious object or placement': <String, String>{
    'ms': 'Objek atau penempatan yang mencurigakan',
    'bn': 'সন্দেহজনক বস্তু বা স্থাপন',
  },
  'Switch camera': <String, String>{
    'ms': 'Tukar kamera',
    'bn': 'ক্যামেরা পাল্টান',
  },
  'Switch to dark mode': <String, String>{
    'ms': 'Tukar kepada mod gelap',
    'bn': 'ডার্ক মোডে স্যুইচ করুন',
  },
  'Switch to light mode': <String, String>{
    'ms': 'Tukar kepada mod cahaya',
    'bn': 'হালকা মোডে স্যুইচ করুন',
  },
  'System': <String, String>{
    'ms': 'Sistem',
    'bn': 'সিস্টেম',
  },
  'System browser': <String, String>{
    'ms': 'Pelayar sistem',
    'bn': 'সিস্টেম ব্রাউজার',
  },
  'Take a Photo': <String, String>{
    'ms': 'Ambil Foto',
    'bn': 'একটি ছবি তুলুন',
  },
  'Take photo': <String, String>{
    'ms': 'Ambil gambar',
    'bn': 'ছবি তুলুন',
  },
  'Tell us more about this scam...': <String, String>{
    'ms': 'Beritahu kami lebih lanjut tentang penipuan ini...',
    'bn': 'এই কেলেঙ্কারী সম্পর্কে আমাদের আরও বলুন...',
  },
  'Terms of Service': <String, String>{
    'ms': 'Syarat Perkhidmatan',
    'bn': 'পরিষেবার শর্তাবলী',
  },
  'Test biometric unlock': <String, String>{
    'ms': 'Uji buka kunci biometrik',
    'bn': 'বায়োমেট্রিক আনলক পরীক্ষা করুন',
  },
  'Test notification sent.': <String, String>{
    'ms': 'Pemberitahuan ujian dihantar.',
    'bn': 'পরীক্ষার বিজ্ঞপ্তি পাঠানো হয়েছে।',
  },
  'Text Scan': <String, String>{
    'ms': 'Imbasan Teks',
    'bn': 'টেক্সট স্ক্যান',
  },
  'Text Size': <String, String>{
    'ms': 'Saiz Teks',
    'bn': 'পাঠ্যের আকার',
  },
  'Text extracted. Starting safety analysis...': <String, String>{
    'ms': 'Teks diekstrak. Memulakan analisis keselamatan...',
    'bn': 'পাঠ্য বের করা হয়েছে। নিরাপত্তা বিশ্লেষণ শুরু হচ্ছে...',
  },
  'Text size': <String, String>{
    'ms': 'Saiz teks',
    'bn': 'পাঠ্যের আকার',
  },
  'Thank you': <String, String>{
    'ms': 'terima kasih',
    'bn': 'ধন্যবাদ',
  },
  'Thank you for supporting your online safety.': <String, String>{
    'ms': 'Terima kasih kerana menyokong keselamatan dalam talian anda.',
    'bn': 'আপনার অনলাইন নিরাপত্তা সমর্থন করার জন্য আপনাকে ধন্যবাদ.',
  },
  'Thank you!': <String, String>{
    'ms': 'terima kasih!',
    'bn': 'ধন্যবাদ!',
  },
  'The camera could not be started.': <String, String>{
    'ms': 'Kamera tidak dapat dimulakan.',
    'bn': 'ক্যামেরা চালু করা যায়নি।',
  },
  'The camera could not be started: \$error': <String, String>{
    'ms': 'Kamera tidak dapat dimulakan: \$error',
    'bn': 'ক্যামেরা চালু করা যায়নি: \$error',
  },
  'The guided checks found no reported indicators. This does not certify that the room is camera-free.':
      <String, String>{
    'ms':
        'Semakan berpandu mendapati tiada penunjuk yang dilaporkan. Ini tidak memperakui bahawa bilik itu bebas kamera.',
    'bn':
        'নির্দেশিত চেক কোন রিপোর্ট সূচক পাওয়া যায়নি. এটি প্রমাণ করে না যে রুমটি ক্যামেরা-মুক্ত।',
  },
  'Thermal imaging': <String, String>{
    'ms': 'Pengimejan terma',
    'bn': 'থার্মাল ইমেজিং',
  },
  'Thinking…': <String, String>{
    'ms': 'Berfikir…',
    'bn': 'ভাবছেন…',
  },
  'This is an approximate server or hosting-provider location derived from public IP data. It does not reveal the website owner’s, visitor’s, or attacker’s precise physical location.':
      <String, String>{
    'ms':
        'Ini ialah anggaran pelayan atau lokasi penyedia pengehosan yang diperoleh daripada data IP awam. Ia tidak mendedahkan lokasi fizikal tepat pemilik tapak web, pelawat atau penyerang.',
    'bn':
        'এটি সর্বজনীন আইপি ডেটা থেকে প্রাপ্ত একটি আনুমানিক সার্ভার বা হোস্টিং-প্রদানকারী অবস্থান। এটি ওয়েবসাইটের মালিক, দর্শক বা আক্রমণকারীর সঠিক শারীরিক অবস্থান প্রকাশ করে না।',
  },
  'This link is unsafe and may be a phishing attempt.': <String, String>{
    'ms': 'Pautan ini tidak selamat dan mungkin percubaan pancingan data.',
    'bn': 'এই লিঙ্কটি অনিরাপদ এবং এটি একটি ফিশিং প্রচেষ্টা হতে পারে৷',
  },
  'This may take a few seconds. Please do not close the app.': <String, String>{
    'ms':
        'Ini mungkin mengambil masa beberapa saat. Tolong jangan tutup aplikasinya.',
    'bn': 'এতে কয়েক সেকেন্ড সময় লাগতে পারে। দয়া করে অ্যাপটি বন্ধ করবেন না।',
  },
  'This website shows several warning signs.': <String, String>{
    'ms': 'Laman web ini menunjukkan beberapa tanda amaran.',
    'bn': 'এই ওয়েবসাইটটি বেশ কয়েকটি সতর্কতা চিহ্ন দেখায়।',
  },
  'Threat Intelligence Updates': <String, String>{
    'ms': 'Kemas Kini Perisikan Ancaman',
    'bn': 'থ্রেট ইন্টেলিজেন্স আপডেট',
  },
  'Threat intelligence updates': <String, String>{
    'ms': 'Kemas kini perisikan ancaman',
    'bn': 'হুমকি গোয়েন্দা আপডেট',
  },
  'Threats': <String, String>{
    'ms': 'ugutan',
    'bn': 'হুমকি',
  },
  'Time Saved': <String, String>{
    'ms': 'Masa Dijimatkan',
    'bn': 'সময় সংরক্ষিত',
  },
  'Tip': <String, String>{
    'ms': 'Petua',
    'bn': 'টিপ',
  },
  'Tips': <String, String>{
    'ms': 'Petua',
    'bn': 'টিপস',
  },
  'Tips to spot fake websites and protect your information.': <String, String>{
    'ms': 'Petua untuk mengesan tapak web palsu dan melindungi maklumat anda.',
    'bn': 'জাল ওয়েবসাইট খুঁজে বের করতে এবং আপনার তথ্য রক্ষা করার টিপস।',
  },
  'Together We Stay Safe': <String, String>{
    'ms': 'Bersama Kita Kekal Selamat',
    'bn': 'একসাথে আমরা নিরাপদ থাকি',
  },
  'Toggle flashlight': <String, String>{
    'ms': 'Togol lampu suluh',
    'bn': 'টগল ফ্ল্যাশলাইট',
  },
  'Torch control is unavailable in this browser or on this camera.':
      <String, String>{
    'ms':
        'Kawalan obor tidak tersedia dalam penyemak imbas ini atau pada kamera ini.',
    'bn': 'এই ব্রাউজারে বা এই ক্যামেরায় টর্চ নিয়ন্ত্রণ অনুপলব্ধ৷',
  },
  'Total Scans': <String, String>{
    'ms': 'Jumlah Imbasan',
    'bn': 'মোট স্ক্যান',
  },
  'Trending Now': <String, String>{
    'ms': 'Trend Sekarang',
    'bn': 'এখন প্রবণতা',
  },
  'Try Again': <String, String>{
    'ms': 'Cuba Lagi',
    'bn': 'আবার চেষ্টা করুন',
  },
  'Try another search phrase or clear the search box.': <String, String>{
    'ms': 'Cuba frasa carian lain atau kosongkan kotak carian.',
    'bn':
        'অন্য একটি অনুসন্ধান বাক্যাংশ ব্যবহার করে দেখুন বা অনুসন্ধান বাক্সটি সাফ করুন৷',
  },
  'Turn flashlight off': <String, String>{
    'ms': 'Matikan lampu suluh',
    'bn': 'টর্চলাইট বন্ধ করুন',
  },
  'Turn flashlight on': <String, String>{
    'ms': 'Hidupkan lampu suluh',
    'bn': 'টর্চলাইট চালু করুন',
  },
  'URL / Link': <String, String>{
    'ms': 'URL / Pautan',
    'bn': 'URL/লিঙ্ক',
  },
  'URL / Link Scanner': <String, String>{
    'ms': 'Pengimbas URL / Pautan',
    'bn': 'URL / লিঙ্ক স্ক্যানার',
  },
  'URL or Website': <String, String>{
    'ms': 'URL atau Laman Web',
    'bn': 'URL বা ওয়েবসাইট',
  },
  'UWB can estimate distance and direction only when this phone communicates with a compatible participating UWB device. It cannot locate an ordinary hidden camera that does not participate in ranging.':
      <String, String>{
    'ms':
        'UWB boleh menganggarkan jarak dan arah hanya apabila telefon ini berkomunikasi dengan peranti UWB yang mengambil bahagian yang serasi. Ia tidak dapat mengesan kamera tersembunyi biasa yang tidak mengambil bahagian dalam julat.',
    'bn':
        'এই ফোনটি একটি সামঞ্জস্যপূর্ণ অংশগ্রহণকারী UWB ডিভাইসের সাথে যোগাযোগ করলেই UWB দূরত্ব এবং দিকনির্দেশ অনুমান করতে পারে। এটি একটি সাধারণ লুকানো ক্যামেরা সনাক্ত করতে পারে না যা পরিসরে অংশ নেয় না।',
  },
  'UWB directional ranging': <String, String>{
    'ms': 'Julat arah UWB',
    'bn': 'UWB দিকনির্দেশক সীমা',
  },
  'Unavailable': <String, String>{
    'ms': 'Tidak tersedia',
    'bn': 'অনুপলব্ধ',
  },
  'Understand Scam Messages': <String, String>{
    'ms': 'Fahami Mesej Penipuan',
    'bn': 'স্ক্যাম বার্তা বুঝুন',
  },
  'Understand why content was flagged.': <String, String>{
    'ms': 'Fahami sebab kandungan dibenderakan.',
    'bn': 'কেন বিষয়বস্তু পতাকাঙ্কিত করা হয়েছে তা বুঝুন।',
  },
  'UNIVERSITY OF CYBERJAYA': <String, String>{
    'ms': 'UNIVERSITY OF CYBERJAYA',
    'bn': 'UNIVERSITY OF CYBERJAYA',
  },
  'University': <String, String>{
    'ms': 'Universiti',
    'bn': 'বিশ্ববিদ্যালয়',
  },
  'Update your personal information': <String, String>{
    'ms': 'Kemas kini maklumat peribadi anda',
    'bn': 'আপনার ব্যক্তিগত তথ্য আপডেট করুন',
  },
  'Upload Screenshot or Image': <String, String>{
    'ms': 'Muat Naik Tangkapan Skrin atau Imej',
    'bn': 'স্ক্রিনশট বা ছবি আপলোড করুন',
  },
  'Use Camera': <String, String>{
    'ms': 'Gunakan Kamera',
    'bn': 'ক্যামেরা ব্যবহার করুন',
  },
  'Use dark theme throughout the app': <String, String>{
    'ms': 'Gunakan tema gelap di seluruh apl',
    'bn': 'অ্যাপ জুড়ে অন্ধকার থিম ব্যবহার করুন',
  },
  'Use enrolled fingerprint, face, or device credential': <String, String>{
    'ms':
        'Gunakan bukti kelayakan cap jari, muka atau peranti yang didaftarkan',
    'bn': 'নথিভুক্ত আঙ্গুলের ছাপ, মুখ, বা ডিভাইস শংসাপত্র ব্যবহার করুন',
  },
  'Use this scan type and its result will appear here.': <String, String>{
    'ms': 'Gunakan jenis imbasan ini dan hasilnya akan dipaparkan di sini.',
    'bn': 'এই স্ক্যান টাইপ ব্যবহার করুন এবং এর ফলাফল এখানে প্রদর্শিত হবে।',
  },
  'Use your camera to read QR codes and verify their destination before opening them.':
      <String, String>{
    'ms':
        'Gunakan kamera anda untuk membaca kod QR dan mengesahkan destinasinya sebelum membukanya.',
    'bn':
        'QR কোডগুলি পড়তে এবং সেগুলি খোলার আগে তাদের গন্তব্য যাচাই করতে আপনার ক্যামেরা ব্যবহার করুন৷',
  },
  'Verifies Android notification delivery': <String, String>{
    'ms': 'Mengesahkan penghantaran pemberitahuan Android',
    'bn': 'অ্যান্ড্রয়েড বিজ্ঞপ্তি বিতরণ যাচাই করে',
  },
  'Version 1.0.0': <String, String>{
    'ms': 'Versi 1.0.0',
    'bn': 'সংস্করণ 1.0.0',
  },
  'View All': <String, String>{
    'ms': 'Lihat Semua',
    'bn': 'সব দেখুন',
  },
  'View and manage your scan history': <String, String>{
    'ms': 'Lihat dan urus sejarah imbasan anda',
    'bn': 'আপনার স্ক্যান ইতিহাস দেখুন এবং পরিচালনা করুন',
  },
  'Visual inspection recorded. Mark any reflection or suspicious object you observed.':
      <String, String>{
    'ms':
        'Pemeriksaan visual direkodkan. Tandai sebarang pantulan atau objek mencurigakan yang anda perhatikan.',
    'bn':
        'ভিজ্যুয়াল পরিদর্শন রেকর্ড করা হয়েছে। আপনার পর্যবেক্ষণ করা কোনো প্রতিফলন বা সন্দেহজনক বস্তু চিহ্নিত করুন।',
  },
  'Waiting for authentication…': <String, String>{
    'ms': 'Menunggu pengesahan…',
    'bn': 'প্রমাণীকরণের জন্য অপেক্ষা করা হচ্ছে...',
  },
  'Warn about unsecured Wi-Fi': <String, String>{
    'ms': 'Beri amaran tentang Wi-Fi tidak selamat',
    'bn': 'অনিরাপদ ওয়াই-ফাই সম্পর্কে সতর্ক করুন',
  },
  'Warnings you can understand.': <String, String>{
    'ms': 'Amaran yang anda boleh fahami.',
    'bn': 'সতর্কতা আপনি বুঝতে পারেন.',
  },
  'We could not process your request. Please try again.': <String, String>{
    'ms': 'Kami tidak dapat memproses permintaan anda. Sila cuba lagi.',
    'bn': 'আমরা আপনার অনুরোধ প্রক্রিয়া করতে পারিনি. আবার চেষ্টা করুন.',
  },
  'We don’t store or share your scans. Your safety is our priority.':
      <String, String>{
    'ms':
        'Kami tidak menyimpan atau berkongsi imbasan anda. Keselamatan anda keutamaan kami.',
    'bn':
        'আমরা আপনার স্ক্যানগুলি সঞ্চয় বা ভাগ করি না। আপনার নিরাপত্তা আমাদের অগ্রাধিকার.',
  },
  'Website': <String, String>{
    'ms': 'laman web',
    'bn': 'ওয়েবসাইট',
  },
  'Website Link': <String, String>{
    'ms': 'Pautan Laman Web',
    'bn': 'ওয়েবসাইট লিংক',
  },
  'Website hosting endpoint': <String, String>{
    'ms': 'Titik akhir pengehosan tapak web',
    'bn': 'ওয়েবসাইট হোস্টিং এন্ডপয়েন্ট',
  },
  'Welcome Back!': <String, String>{
    'ms': 'Selamat Kembali!',
    'bn': 'আবার স্বাগতম!',
  },
  'We’re having trouble': <String, String>{
    'ms': 'Kami menghadapi masalah',
    'bn': 'আমাদের সমস্যা হচ্ছে',
  },
  'What are you reporting?': <String, String>{
    'ms': 'Apa yang anda laporkan?',
    'bn': 'আপনি কি রিপোর্ট করছেন?',
  },
  'What is Phishing?': <String, String>{
    'ms': 'Apa itu Phishing?',
    'bn': 'ফিশিং কি?',
  },
  'What should you do?': <String, String>{
    'ms': 'Apa yang patut anda lakukan?',
    'bn': 'আপনার কি করা উচিত?',
  },
  'What we can do': <String, String>{
    'ms': 'Apa yang kita boleh buat',
    'bn': 'আমরা কি করতে পারি',
  },
  'When in doubt, don’t click! Scan first and stay safe online.':
      <String, String>{
    'ms':
        'Apabila ragu-ragu, jangan klik! Imbas dahulu dan kekal selamat dalam talian.',
    'bn':
        'সন্দেহ হলে, ক্লিক করবেন না! প্রথমে স্ক্যান করুন এবং অনলাইনে নিরাপদ থাকুন।',
  },
  'When in doubt, scan it out. Nirapod AI helps you identify threats before it’s too late.':
      <String, String>{
    'ms':
        'Apabila ragu-ragu, imbas keluar. Nirapod AI membantu anda mengenal pasti ancaman sebelum terlambat.',
    'bn':
        'সন্দেহ হলে, এটি স্ক্যান করুন। নিরাপড এআই আপনাকে অনেক দেরি হওয়ার আগেই হুমকি শনাক্ত করতে সাহায্য করে।',
  },
  'Why is my scanned URL suspicious?': <String, String>{
    'ms': 'Mengapa URL imbasan saya mencurigakan?',
    'bn': 'কেন আমার স্ক্যান করা URL সন্দেহজনক?',
  },
  'Why it’s safe': <String, String>{
    'ms': 'Mengapa ia selamat',
    'bn': 'কেন এটি নিরাপদ',
  },
  'Wi-Fi Scan Warning': <String, String>{
    'ms': 'Amaran Imbasan Wi-Fi',
    'bn': 'ওয়াই-ফাই স্ক্যান সতর্কতা',
  },
  'Win iPhone 15 Now! 🎉': <String, String>{
    'ms': 'Menangi iPhone 15 Sekarang! 🎉',
    'bn': 'এখনই জিতে নিন iPhone 15! 🎉',
  },
  'Your activity chart will appear here': <String, String>{
    'ms': 'Carta aktiviti anda akan dipaparkan di sini',
    'bn': 'আপনার কার্যকলাপ চার্ট এখানে প্রদর্শিত হবে',
  },
  'Your feedback helps improve Nirapod AI.': <String, String>{
    'ms': 'Maklum balas anda membantu meningkatkan Nirapod AI.',
    'bn': 'আপনার প্রতিক্রিয়া Nirapod AI উন্নত করতে সাহায্য করে।',
  },
  'Your profile, scan history, and community reports were exported as JSON and copied to the clipboard.':
      <String, String>{
    'ms':
        'Profil, sejarah imbasan dan laporan komuniti anda telah dieksport sebagai JSON dan disalin ke papan keratan.',
    'bn':
        'আপনার প্রোফাইল, স্ক্যান ইতিহাস এবং সম্প্রদায়ের প্রতিবেদনগুলি JSON হিসাবে রপ্তানি করা হয়েছে এবং ক্লিপবোর্ডে অনুলিপি করা হয়েছে৷',
  },
  'Your report helps keep our community safe.': <String, String>{
    'ms': 'Laporan anda membantu memastikan komuniti kami selamat.',
    'bn': 'আপনার প্রতিবেদন আমাদের সম্প্রদায়কে নিরাপদ রাখতে সাহায্য করে।',
  },
  'You’re using Premium': <String, String>{
    'ms': 'Anda menggunakan Premium',
    'bn': 'আপনি প্রিমিয়াম ব্যবহার করছেন',
  },
  'before accepting payments. No card data is stored locally.':
      <String, String>{
    'ms': 'sebelum menerima bayaran. Tiada data kad disimpan secara setempat.',
    'bn':
        'পেমেন্ট গ্রহণ করার আগে। কোনও কার্ডের ডেটা স্থানীয়ভাবে সংরক্ষণ করা হয় না।',
  },
  'dart:async': <String, String>{
    'ms': 'dart:async',
    'bn': 'ডার্ট: অ্যাসিঙ্ক',
  },
  'dart:math': <String, String>{
    'ms': 'dart:matematik',
    'bn': 'ডার্ট: গণিত',
  },
  'fake-bank-login.com': <String, String>{
    'ms': 'fake-bank-login.com',
    'bn': 'fake-bank-login.com',
  },
  'link scans': <String, String>{
    'ms': 'imbasan pautan',
    'bn': 'লিঙ্ক স্ক্যান',
  },
  'message, SMS, or email scans': <String, String>{
    'ms': 'imbasan mesej, SMS atau e-mel',
    'bn': 'বার্তা, এসএমএস বা ইমেল স্ক্যান',
  },
  'noCamera': <String, String>{
    'ms': 'tiadaKamera',
    'bn': 'কোন ক্যামেরা',
  },
  'or login with': <String, String>{
    'ms': 'atau log masuk dengan',
    'bn': 'অথবা লগইন করুন',
  },
  'permissionDenied': <String, String>{
    'ms': 'kebenaran dinafikan',
    'bn': 'অনুমতি অস্বীকৃত',
  },
  'room checks': <String, String>{
    'ms': 'pemeriksaan bilik',
    'bn': 'রুম চেক',
  },
  'scan history': <String, String>{
    'ms': 'imbas sejarah',
    'bn': 'ইতিহাস স্ক্যান করুন',
  },
  'screenshot/OCR scans': <String, String>{
    'ms': 'tangkapan skrin/imbasan OCR',
    'bn': 'স্ক্রিনশট/ওসিআর স্ক্যান',
  },
  'secure-pay-update.net': <String, String>{
    'ms': 'secure-pay-update.net',
    'bn': 'safe-pay-update.net',
  },
  'nirapod-ai-guide': <String, String>{
    'ms': 'nirapod-ai-guide',
    'bn': 'safelens-ai-গাইড',
  },
  'such as Stripe using your own test and production keys ': <String, String>{
    'ms': 'seperti Stripe menggunakan ujian dan kunci pengeluaran anda sendiri',
    'bn': 'যেমন স্ট্রাইপ আপনার নিজের পরীক্ষা এবং উত্পাদন কী ব্যবহার করে',
  },
  'uwbReady': <String, String>{
    'ms': 'uwbSedia',
    'bn': 'uwbReady',
  },
  'uwbSupported': <String, String>{
    'ms': 'uwbDisokong',
    'bn': 'uwb সমর্থিত',
  },
  'youremail@example.com': <String, String>{
    'ms': 'youremail@example.com',
    'bn': 'youremail@example.com',
  },
  '} \${accessories.length} USB device(s) detected.': <String, String>{
    'ms': '}\${accessories.length}Peranti USB dikesan.',
    'bn': '}\${accessories.length}USB ডিভাইস(গুলি) সনাক্ত করা হয়েছে৷',
  },
  '© 2026 Nirapod AI. All rights reserved.': <String, String>{
    'ms': '© 2026 Nirapod AI. Semua hak terpelihara.',
    'bn': '© 2026 Nirapod AI. সর্বস্বত্ব সংরক্ষিত',
  },
  '♛ Premium Member': <String, String>{
    'ms': '♛ Ahli Premium',
    'bn': '♛ প্রিমিয়াম সদস্য',
  },
};
