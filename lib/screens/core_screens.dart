import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../widgets/localized_text.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'extra_screens.dart';
import 'chatbot_screen.dart';
import '../services/api_service.dart';
import '../services/ocr_service.dart';
import '../services/theme_controller.dart';
import '../services/language_controller.dart';
import '../services/native_android_service.dart';
import '../services/room_visual_heuristic.dart';

const _ink = Color(0xFF080B28);
const _muted = Color(0xFF595C7A);
const _purple = Color(0xFF5420E6);
const _blue = Color(0xFF10B981);
const _successGreen = Color(0xFF159947);
const _border = Color(0xFFE7E6F1);

const _primaryGradient = LinearGradient(
  colors: [Color(0xFF6E24F4), Color(0xFF4C20DA)],
);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _lastEmailKey = 'last_successful_login_email';
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _obscure = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadPreviousEmail();
  }

  Future<void> _loadPreviousEmail() async {
    final preferences = await SharedPreferences.getInstance();
    final previousEmail = preferences.getString(_lastEmailKey);
    if (!mounted || previousEmail == null || previousEmail.isEmpty) return;
    _email.value = TextEditingValue(
      text: previousEmail,
      selection: TextSelection.collapsed(offset: previousEmail.length),
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_email.text.contains('@') || _password.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: LocalizedText('Enter a valid email and password.')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await ApiService.login(
        email: _email.text.trim(),
        password: _password.text,
      );
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_lastEmailKey, _email.text.trim());
      _password.clear();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const MainShell()),
        (_) => false,
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: LocalizedText(
                  error.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _socialProvider(String provider) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: LocalizedText('$provider sign-in is coming soon'),
        content: LocalizedText(
          'This release supports secure email and password sign-in. '
          '$provider OAuth has not been enabled yet.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const LocalizedText('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 28),
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.arrow_back, color: _purple, size: 32),
                ),
                const SizedBox(height: 36),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LocalizedText(
                      'Welcome Back!',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 12),
                    LocalizedText(
                      'Login to continue protecting yourself\nfrom phishing attacks.',
                      style:
                          TextStyle(color: _muted, fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
                const SizedBox(height: 56),
                const _FieldLabel('Email Address'),
                const SizedBox(height: 9),
                _InputBox(
                  controller: _email,
                  hint: 'Enter your email',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _passwordFocus.requestFocus(),
                ),
                const SizedBox(height: 22),
                const _FieldLabel('Password'),
                const SizedBox(height: 9),
                _InputBox(
                  controller: _password,
                  hint: 'Enter your password',
                  icon: Icons.lock_outline_rounded,
                  obscureText: _obscure,
                  focusNode: _passwordFocus,
                  textInputAction: TextInputAction.done,
                  submitOnPhysicalEnter: true,
                  onSubmitted: (_) {
                    if (!_submitting) _login();
                  },
                  suffix: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: const Color(0xFF777A99),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        _open(context, const ForgotPasswordScreen()),
                    child: const LocalizedText('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: _submitting ? 'Signing In...' : 'Login',
                  onPressed: _submitting ? () {} : _login,
                ),
                const SizedBox(height: 34),
                const _DividerLabel('or login with'),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialButton(
                      label: 'G',
                      color: const Color(0xFF4285F4),
                      onTap: () => _socialProvider('Google'),
                    ),
                    const SizedBox(width: 28),
                    SocialButton(
                      label: 'f',
                      color: const Color(0xFF1877F2),
                      onTap: () => _socialProvider('Facebook'),
                    ),
                    const SizedBox(width: 28),
                    SocialButton(
                      label: 'M',
                      color: const Color(0xFF0078D4),
                      onTap: () => _socialProvider('Microsoft / Outlook'),
                    ),
                  ],
                ),
                const SizedBox(height: 42),
                InkWell(
                  onTap: () => _open(context, const SignUpScreen()),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: _border),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const _IconTile(icon: Icons.verified_user_rounded),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: TextStyle(color: _ink, fontSize: 16),
                              children: [
                                TextSpan(
                                  text: AppLanguageController.translate(
                                    'Don?t have an account?\n',
                                  ),
                                ),
                                TextSpan(
                                  text: AppLanguageController.translate(
                                      'Sign Up'),
                                  style: const TextStyle(
                                    color: _purple,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            color: _purple, size: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialIndex;
  int _homeVersion = 0;
  int _historyVersion = 0;

  @override
  void initState() {
    super.initState();
    NativeAndroidService.sharedText.addListener(_handleSharedLink);
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleSharedLink());
  }

  @override
  void dispose() {
    NativeAndroidService.sharedText.removeListener(_handleSharedLink);
    super.dispose();
  }

  Future<void> _handleSharedLink() async {
    final value = NativeAndroidService.sharedText.value?.trim();
    if (value == null || value.isEmpty) return;
    final uri = Uri.tryParse(value);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) return;
    try {
      final settings = await ApiService.settings();
      if (settings['auto_scan_links'] != true || !mounted) return;
      NativeAndroidService.sharedText.value = null;
      _open(context, AnalysisScreen(content: value, scanType: 'url'));
    } catch (_) {
      // Keep the shared link available so the user can retry after reconnecting.
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(key: ValueKey(_homeVersion)),
      HistoryScreen(key: ValueKey(_historyVersion)),
      const ScanSelectionScreen(),
      const ReportsScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'nirapod-ai-guide',
        onPressed: () => _open(context, const ChatbotScreen()),
        icon: const Icon(Icons.smart_toy_rounded),
        label: const LocalizedText(
          'Ask AI',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: AppBottomBar(
        index: _index,
        onChanged: (value) => setState(() {
          _index = value;
          if (value == 0) _homeVersion++;
          if (value == 1) _historyVersion++;
        }),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>> _history;
  late Future<Map<String, dynamic>> _analytics;
  String _firstName = 'there';

  @override
  void initState() {
    super.initState();
    _refresh();
    _loadUserName();
  }

  void _refresh() {
    _history = ApiService.history(limit: 3);
    _analytics = ApiService.analytics(days: 30);
  }

  Future<void> _loadUserName() async {
    try {
      final profile = await ApiService.profile();
      final fullName = (profile['name'] as String? ?? '').trim();
      if (!mounted || fullName.isEmpty) return;
      setState(() {
        _firstName = fullName.split(RegExp(r'\s+')).first;
      });
    } catch (_) {
      // Keep a friendly fallback if the profile cannot be loaded.
    }
  }

  Future<void> _toggleTheme() async {
    final darkMode = !AppThemeController.isDark;
    await AppThemeController.setDarkMode(darkMode);
    try {
      final settings = await ApiService.settings();
      settings['dark_mode'] = darkMode;
      await ApiService.updateSettings(settings);
    } catch (_) {
      // The local preference still works when the backend is unavailable.
    }
  }

  String _timeLabel(String value) {
    final parsed =
        DateTime.tryParse('${value.replaceFirst(' ', 'T')}Z')?.toLocal();
    if (parsed == null) return value;
    final difference = DateTime.now().difference(parsed);
    if (difference.inMinutes < 1) return 'Now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${parsed.day}/${parsed.month}/${parsed.year}';
  }

  Color _resultColor(String classification) => switch (classification) {
        'safe' => const Color(0xFF14944C),
        'suspicious' => const Color(0xFFF07A00),
        'inconclusive' => const Color(0xFF667085),
        _ => const Color(0xFFE31D2B),
      };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _HomeMenuButton(),
                const Spacer(),
                IconButton(
                  tooltip: AppLanguageController.translate('Ask Nirapod Guide'),
                  onPressed: () => _open(context, const ChatbotScreen()),
                  icon: const Icon(Icons.smart_toy_outlined,
                      color: _purple, size: 29),
                ),
                const _NotificationButton(),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: AppLanguageController.translate('Hello, '),
                            ),
                            TextSpan(
                              text: '$_firstName! ',
                              style: const TextStyle(color: _purple),
                            ),
                            const TextSpan(text: '👋'),
                          ],
                        ),
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 29,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const LocalizedText(
                        'Stay safe online. We’ve got your back.',
                        style: TextStyle(color: _muted, fontSize: 15),
                      ),
                    ],
                  ),
                ),
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: AppThemeController.mode,
                  builder: (context, mode, _) => _ThemeToggleButton(
                    darkMode: mode == ThemeMode.dark,
                    onPressed: _toggleTheme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            FutureBuilder<Map<String, dynamic>>(
              future: _analytics,
              builder: (context, snapshot) =>
                  _HomeAnalytics(data: snapshot.data),
            ),
            const SizedBox(height: 26),
            const SectionTitle(
                title: 'Quick Scan',
                subtitle: 'Choose a scan type to get started'),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth < 700 ? 2 : 5;
                const gap = 10.0;
                final width =
                    (constraints.maxWidth - gap * (columns - 1)) / columns;
                final cards = [
                  (
                    Icons.link_rounded,
                    'URL / Link',
                    'Scan website links',
                    const UrlScannerScreen()
                  ),
                  (
                    Icons.qr_code_2_rounded,
                    'QR Code',
                    'Scan QR codes',
                    const QrScannerScreen()
                  ),
                  (
                    Icons.message_outlined,
                    'Message',
                    'Scan text, SMS & email',
                    const MessageScannerScreen()
                  ),
                  (
                    Icons.image_outlined,
                    'Screenshot',
                    'Scan images with OCR',
                    const OcrScannerScreen()
                  ),
                  (
                    Icons.videocam_outlined,
                    'Room Check',
                    'Check camera indicators',
                    const HiddenCameraSafetyScreen()
                  ),
                ];
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: cards
                      .map((card) => SizedBox(
                            width: width,
                            child: QuickScanCard(
                              icon: card.$1,
                              title: card.$2,
                              subtitle: card.$3,
                              onTap: () => _open(context, card.$4),
                            ),
                          ))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const LocalizedText('Recent Scans',
                    style: TextStyle(
                        color: _ink,
                        fontSize: 19,
                        fontWeight: FontWeight.w800)),
                TextButton(
                  onPressed: () =>
                      _open(context, const MainShell(initialIndex: 1)),
                  child: const LocalizedText('View All'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FutureBuilder<Map<String, dynamic>>(
              future: _history,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return _HomeHistoryMessage(
                    message: 'Could not load recent scans. Check the backend.',
                    button: 'Retry',
                    onPressed: () => setState(_refresh),
                  );
                }
                final items = List<Map<String, dynamic>>.from(
                  snapshot.data?['items'] as List? ?? const [],
                );
                if (items.isEmpty) {
                  return _HomeHistoryMessage(
                    message:
                        'No scans yet. Start a scan to create your history.',
                    button: 'Start scanning',
                    onPressed: () =>
                        _open(context, const ScanSelectionScreen()),
                  );
                }
                return Column(
                  children: items.map((item) {
                    final classification = item['classification'] as String;
                    return RecentScanTile(
                      title: item['content'] as String,
                      result: classification == 'dangerous'
                          ? 'Dangerous'
                          : classification[0].toUpperCase() +
                              classification.substring(1),
                      time: _timeLabel(item['created_at'] as String),
                      color: _resultColor(classification),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeAnalytics extends StatelessWidget {
  const _HomeAnalytics({required this.data});
  final Map<String, dynamic>? data;

  @override
  Widget build(BuildContext context) {
    final summary = (data?['summary'] as Map<String, dynamic>?) ?? const {};
    final daily = (data?['daily'] as List? ?? const [])
        .map((item) =>
            ((item as Map<String, dynamic>)['count'] as num).toDouble())
        .toList();
    final total = (summary['total'] as num?)?.toInt() ?? 0;
    final safe = (summary['safe'] as num?)?.toInt() ?? 0;
    final suspicious = (summary['suspicious'] as num?)?.toInt() ?? 0;
    final dangerous = (summary['dangerous'] as num?)?.toInt() ?? 0;
    return Column(
      children: [
        Container(
          height: 150,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: _primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LocalizedText(
                    'Total Scans',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  LocalizedText(
                    '$total',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 46,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  const LocalizedText('Last 30 days',
                      style: TextStyle(color: Color(0xFFCBC1FF))),
                ],
              ),
              const SizedBox(width: 25),
              Expanded(
                child: total == 0
                    ? const Center(
                        child: LocalizedText(
                            'Your activity chart will appear here',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFFCBC1FF))))
                    : MiniTrendChart(values: daily),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
                child: StatCard(
                    label: 'Safe',
                    value: '$safe',
                    color: const Color(0xFF14944C))),
            const SizedBox(width: 10),
            Expanded(
                child: StatCard(
                    label: 'Suspicious',
                    value: '$suspicious',
                    color: const Color(0xFFF07A00))),
            const SizedBox(width: 10),
            Expanded(
                child: StatCard(
                    label: 'Phishing',
                    value: '$dangerous',
                    color: const Color(0xFFE31D2B))),
          ],
        ),
      ],
    );
  }
}

class _HomeHistoryMessage extends StatelessWidget {
  const _HomeHistoryMessage({
    required this.message,
    required this.button,
    required this.onPressed,
  });
  final String message;
  final String button;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          LocalizedText(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted)),
          const SizedBox(height: 8),
          TextButton(onPressed: onPressed, child: LocalizedText(button)),
        ],
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton();
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _open(context, const NotificationsScreen()),
      icon: const Badge(
        smallSize: 8,
        child: Icon(Icons.notifications_none_rounded, color: _purple, size: 30),
      ),
    );
  }
}

class _HomeMenuButton extends StatelessWidget {
  const _HomeMenuButton();
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu_rounded, color: _purple, size: 32),
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.groups_outlined, color: _purple),
                  title: const LocalizedText('Community Reports'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _open(context, const CommunityReportsScreen());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.school_outlined, color: _purple),
                  title: const LocalizedText('Learning Centre'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _open(context, const LearningCentreScreen());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined, color: _purple),
                  title: const LocalizedText('Settings'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _open(context, const SettingsScreen());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _open(BuildContext context, Widget screen) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
}

class ScanSelectionScreen extends StatelessWidget {
  const ScanSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        Icons.link_rounded,
        'URL / Link Scanner',
        'Check if a website link\nis safe or phishing',
        'Scan URL',
        const UrlScannerScreen(),
        _purple
      ),
      (
        Icons.qr_code_2_rounded,
        'QR Code Scanner',
        'Reveal QR links and\ncheck their safety',
        'Scan QR Code',
        const QrScannerScreen(),
        _blue
      ),
      (
        Icons.message_rounded,
        'Message Scanner',
        'Analyze SMS, emails or\nmessages for threats',
        'Scan Message',
        const MessageScannerScreen(),
        const Color(0xFF16A05A)
      ),
      (
        Icons.image_rounded,
        'Screenshot / OCR',
        'Extract text from images\nand analyze risks',
        'Scan Image',
        const OcrScannerScreen(),
        _purple
      ),
      (
        Icons.videocam_outlined,
        'Hidden Camera Check',
        'Inspect a room for possible\nhidden-camera indicators',
        'Check Room',
        const HiddenCameraSafetyScreen(),
        const Color(0xFFE45876)
      ),
    ];
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 130),
        child: Column(
          children: [
            const PageHeader(
                title: 'Select Scan Type',
                subtitle: 'Choose what you want to scan'),
            const SizedBox(height: 30),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final columns = width < 620 ? 1 : 2;
                    // Mobile cards need additional vertical room for the
                    // description and action button. A larger aspect ratio
                    // made the cards too short and caused a bottom overflow.
                    final ratio = width < 620 ? 1.12 : 1.35;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: ratio,
                      ),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ScanTypeCard(
                          icon: item.$1,
                          title: item.$2,
                          description: item.$3,
                          button: item.$4,
                          color: item.$6,
                          onTap: () => _open(context, item.$5),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 22),
            const InfoBanner(
              icon: Icons.lock_rounded,
              title: 'Stay Safe Online',
              text:
                  'When in doubt, scan it out. Nirapod AI helps you identify threats before it’s too late.',
            ),
          ],
        ),
      ),
    );
  }
}

class HiddenCameraSafetyScreen extends StatefulWidget {
  const HiddenCameraSafetyScreen({super.key});

  @override
  State<HiddenCameraSafetyScreen> createState() =>
      _HiddenCameraSafetyScreenState();
}

class _HiddenCameraSafetyScreenState extends State<HiddenCameraSafetyScreen> {
  bool _reflectionDetected = false;
  bool _suspiciousObject = false;
  bool _visualCheckCompleted = false;
  bool _networkScanning = false;
  bool _bluetoothScanning = false;
  bool _networkCheckCompleted = false;
  bool _bluetoothCheckCompleted = false;
  List<Map<String, dynamic>> _networkFindings = [];
  List<Map<String, dynamic>> _bluetoothFindings = [];
  Map<String, dynamic> _advancedCapabilities = {};
  List<Map<String, dynamic>> _usbAccessories = [];
  bool _checkingAdvancedHardware = false;
  bool _submitting = false;
  Map<String, dynamic> _stageAResult = {};
  Map<String, dynamic> _stageBResult = {};

  @override
  void initState() {
    super.initState();
    _refreshAdvancedHardware();
  }

  Future<void> _refreshAdvancedHardware({bool announce = false}) async {
    if (!NativeAndroidService.isSupported) {
      if (announce) {
        _showRoomMessage(
          'Advanced sensor checks require a supported Android phone and compatible accessory.',
        );
      }
      return;
    }
    setState(() => _checkingAdvancedHardware = true);
    try {
      final capabilities =
          await NativeAndroidService.advancedRoomCapabilities();
      final accessories = await NativeAndroidService.connectedUsbAccessories();
      if (mounted) {
        setState(() {
          _advancedCapabilities = capabilities;
          _usbAccessories = accessories;
        });
        if (announce) {
          final uwb = capabilities['uwbSupported'] == true;
          _showRoomMessage(
            uwb || accessories.isNotEmpty
                ? 'Hardware refreshed. ${uwb ? 'UWB is supported, but a compatible participating peer is still required.' : ''} ${accessories.length} USB device(s) detected.'
                : 'No compatible UWB peer, thermal camera, or directional RF accessory was detected.',
          );
        }
      }
    } catch (error) {
      _showRoomMessage('Advanced hardware check could not finish: $error');
    } finally {
      if (mounted) setState(() => _checkingAdvancedHardware = false);
    }
  }

  void _showCapabilityInfo(String title, String explanation) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: LocalizedText(title),
        content: LocalizedText(explanation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const LocalizedText('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _scanNetwork() async {
    if (!NativeAndroidService.isSupported) {
      _showRoomMessage(
          'Nearby network inspection is available in the Android app, not the web preview.');
      return;
    }
    setState(() => _networkScanning = true);
    try {
      final findings = await NativeAndroidService.scanLocalNetwork();
      if (mounted) {
        setState(() {
          _networkFindings = findings;
          _networkCheckCompleted = true;
        });
      }
      _showRoomMessage(
          'Network inspection completed: ${findings.length} reachable device(s) reviewed. Ordinary web services are not treated as cameras.');
    } catch (error) {
      _showRoomMessage('Network inspection could not finish: $error');
    } finally {
      if (mounted) setState(() => _networkScanning = false);
    }
  }

  Future<void> _scanBluetooth() async {
    if (!NativeAndroidService.isSupported) {
      _showRoomMessage(
          'Nearby Bluetooth inspection is available in the Android app, not the web preview.');
      return;
    }
    setState(() => _bluetoothScanning = true);
    try {
      final findings = await NativeAndroidService.scanNearbyBluetooth();
      if (mounted) {
        setState(() {
          _bluetoothFindings = findings;
          _bluetoothCheckCompleted = true;
        });
      }
      _showRoomMessage(
          'Bluetooth inspection completed: ${findings.length} nearby device(s) observed. Presence alone is not evidence of a hidden camera.');
    } catch (error) {
      _showRoomMessage('Bluetooth inspection could not finish: $error');
    } finally {
      if (mounted) setState(() => _bluetoothScanning = false);
    }
  }

  void _showRoomMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: LocalizedText(message)),
    );
  }

  Future<void> _startVisualInspection() async {
    final photo = await Navigator.of(context).push<XFile>(
      MaterialPageRoute(builder: (_) => const LiveCameraScreen()),
    );
    if (photo != null && mounted) {
      try {
        final stageA = await NativeAndroidService.classifyRoomImage(photo.path);
        Map<String, dynamic> stageB = {};
        if (stageA['confidentKnownSafe'] != true) {
          stageB =
              RoomVisualHeuristic.analyze(await photo.readAsBytes()).toJson();
        }
        if (!mounted) return;
        setState(() {
          _visualCheckCompleted = true;
          _stageAResult = stageA;
          _stageBResult = stageB;
        });
        final confidence =
            ((stageA['confidence'] as num?)?.toDouble() ?? 0) * 100;
        final confident = stageA['confidentKnownSafe'] == true;
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const LocalizedText('Visual analysis'),
            content: LocalizedText(confident
                ? 'Stage A recognized an ordinary ${stageA['label']} (${confidence.toStringAsFixed(1)}%). This resemblance is not proof that the device or room is safe.'
                : 'Stage A was below the safety gate (${confidence.toStringAsFixed(1)}%), so the image was treated as unclassified and Stage B visual heuristics were run. Reflection and pinhole patterns can come from ordinary objects and are not conclusive.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const LocalizedText('OK'))
            ],
          ),
        );
      } catch (error) {
        if (!mounted) return;
        setState(() => _visualCheckCompleted = true);
        _showRoomMessage(
            'Automatic visual analysis was inconclusive. You can still record your observations. $error');
      }
    }
  }

  Future<void> _completeCheck() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final prediction = await ApiService.roomSafetyCheck(
        reflectionDetected: _reflectionDetected,
        suspiciousObject: _suspiciousObject,
        visualCheckCompleted: _visualCheckCompleted,
        networkCheckCompleted: _networkCheckCompleted,
        bluetoothCheckCompleted: _bluetoothCheckCompleted,
        networkFindings: _networkFindings,
        bluetoothFindings: _bluetoothFindings,
        // Measurements are submitted only by a verified accessory adapter.
        // Generic USB devices and UWB capability are not evidence by themselves.
        advancedReadings: const [],
        stageAResult: _stageAResult,
        stageBResult: _stageBResult,
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ScanResultScreen(prediction: prediction),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: LocalizedText(
            'Could not save the room check. Confirm the backend is running. $error',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScannerScaffold(
      title: 'Hidden Camera Safety Check',
      subtitle:
          'Guided checks for possible camera indicators\nin hotel rooms and private spaces.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const InfoBanner(
            icon: Icons.info_outline_rounded,
            title: 'Important limitation',
            text:
                'A phone cannot certify that a room is camera-free. Thermal or RF detection requires compatible specialist hardware.',
          ),
          const SizedBox(height: 20),
          const LocalizedText(
            '1. Visual lens-reflection inspection',
            style: TextStyle(
              color: _ink,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const LocalizedText(
            'Dim the room and slowly inspect smoke detectors, clocks, chargers, vents, mirrors, and objects facing beds or bathrooms. Look for a small sharp reflection.',
            style: TextStyle(color: _muted, height: 1.5),
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: _visualCheckCompleted
                ? 'Repeat Camera Inspection'
                : 'Start Camera Inspection',
            icon: Icons.camera_alt_outlined,
            onPressed: _startVisualInspection,
          ),
          const SizedBox(height: 22),
          const LocalizedText(
            '2. Inspect nearby devices (Android)',
            style: TextStyle(
              color: _ink,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const LocalizedText(
            'Only scan a Wi-Fi network you are authorized to inspect. Nirapod AI checks nearby IP services and Bluetooth names; it cannot identify a device owner or point to its physical location.',
            style: TextStyle(color: _muted, height: 1.5),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: _networkScanning
                ? 'Inspecting Network...'
                : _networkFindings.isEmpty
                    ? 'Inspect Authorized Wi-Fi'
                    : 'Repeat Wi-Fi Inspection (${_networkFindings.length})',
            icon: Icons.wifi_find_rounded,
            onPressed: _networkScanning ? () {} : _scanNetwork,
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: _bluetoothScanning
                ? 'Inspecting Bluetooth...'
                : _bluetoothFindings.isEmpty
                    ? 'Inspect Nearby Bluetooth'
                    : 'Repeat Bluetooth Inspection (${_bluetoothFindings.length})',
            icon: Icons.bluetooth_searching_rounded,
            onPressed: _bluetoothScanning ? () {} : _scanBluetooth,
          ),
          const SizedBox(height: 22),
          const LocalizedText(
            '3. Advanced sensor hardware',
            style: TextStyle(
              color: _ink,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const LocalizedText(
            'Nirapod AI uses measurements only from a supported accessory. It never invents an arrow, distance, temperature, or RF signal.',
            style: TextStyle(color: _muted, height: 1.5),
          ),
          const SizedBox(height: 10),
          _SensorCapabilityTile(
            icon: Icons.radar_rounded,
            title: 'UWB directional ranging',
            status: _advancedCapabilities['uwbSupported'] == true
                ? 'Phone supported • compatible participating peer required'
                : 'Not supported by this phone',
            ready: _advancedCapabilities['uwbReady'] == true,
            onTap: () => _showCapabilityInfo(
              'UWB directional ranging',
              'UWB can estimate distance and direction only when this phone communicates with a compatible participating UWB device. It cannot locate an ordinary hidden camera that does not participate in ranging.',
            ),
          ),
          _SensorCapabilityTile(
            icon: Icons.thermostat_rounded,
            title: 'Thermal imaging',
            status: 'Supported thermal accessory required',
            ready: false,
            onTap: () => _showCapabilityInfo(
              'Thermal imaging',
              'A normal phone camera cannot measure heat. Connect a supported thermal camera accessory with its approved Android SDK to enable real temperature measurements.',
            ),
          ),
          _SensorCapabilityTile(
            icon: Icons.cell_tower_rounded,
            title: 'Directional RF measurement',
            status: 'Supported directional RF accessory required',
            ready: false,
            onTap: () => _showCapabilityInfo(
              'Directional RF measurement',
              'Directional radio locating requires a compatible RF receiver and directional antenna. Bluetooth or Wi-Fi presence alone cannot provide a reliable arrow to a device.',
            ),
          ),
          if (_usbAccessories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: LocalizedText(
                '${_usbAccessories.length} USB device(s) connected; none are treated as sensors until a verified adapter identifies them.',
                style: const TextStyle(color: _muted, height: 1.4),
              ),
            ),
          PrimaryButton(
            label: _checkingAdvancedHardware
                ? 'Checking Hardware...'
                : 'Refresh Sensor Hardware',
            icon: Icons.usb_rounded,
            onPressed: _checkingAdvancedHardware
                ? () {}
                : () => _refreshAdvancedHardware(announce: true),
          ),
          const SizedBox(height: 22),
          const LocalizedText(
            '4. Record visual observations',
            style: TextStyle(
              color: _ink,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          _RoomCheckToggle(
            title: 'Possible lens reflection',
            subtitle: 'A small, sharp reflection appeared from an object.',
            value: _reflectionDetected,
            onChanged: (value) => setState(() => _reflectionDetected = value),
          ),
          _RoomCheckToggle(
            title: 'Suspicious object or placement',
            subtitle:
                'An altered object, unexpected wire, pinhole, or device points toward a private area.',
            value: _suspiciousObject,
            onChanged: (value) => setState(() => _suspiciousObject = value),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: _submitting ? 'Saving Check...' : 'Complete Safety Check',
            icon: Icons.fact_check_outlined,
            onPressed: _submitting ? () {} : _completeCheck,
          ),
          const SizedBox(height: 18),
          const InfoBanner(
            icon: Icons.report_problem_outlined,
            title: 'If you find something',
            text:
                'Do not touch or dismantle it. Leave the room, preserve photos, contact hotel management, and report it to local authorities.',
            green: true,
          ),
        ],
      ),
    );
  }
}

class _SensorCapabilityTile extends StatelessWidget {
  const _SensorCapabilityTile({
    required this.icon,
    required this.title,
    required this.status,
    required this.ready,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String status;
  final bool ready;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: _border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: ready ? _successGreen : _muted),
        title: LocalizedText(title,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: LocalizedText(status),
        trailing: Icon(
          ready ? Icons.check_circle_rounded : Icons.info_outline_rounded,
          color: ready ? _successGreen : _muted,
        ),
      ),
    );
  }
}

class _RoomCheckToggle extends StatelessWidget {
  const _RoomCheckToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: _border),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeThumbColor: _purple,
        title: LocalizedText(
          title,
          style: const TextStyle(color: _ink, fontWeight: FontWeight.w700),
        ),
        subtitle:
            LocalizedText(subtitle, style: const TextStyle(color: _muted)),
      ),
    );
  }
}

class UrlScannerScreen extends StatefulWidget {
  const UrlScannerScreen({super.key});

  @override
  State<UrlScannerScreen> createState() => _UrlScannerScreenState();
}

class _UrlScannerScreenState extends State<UrlScannerScreen> {
  final _controller = TextEditingController();

  void _scan() {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: LocalizedText('Enter a URL before scanning.')),
      );
      return;
    }
    _open(context, AnalysisScreen(content: value, scanType: 'url'));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScannerScaffold(
      title: 'URL / Link Scanner',
      subtitle: 'Check if a website link is safe\nbefore you open it.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: ScannerHero(icon: Icons.language_rounded)),
          const SizedBox(height: 24),
          const _FieldLabel('Enter URL to Scan'),
          const SizedBox(height: 10),
          _InputBox(
            controller: _controller,
            hint: 'https://example.com',
            icon: Icons.link_rounded,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
            submitOnPhysicalEnter: true,
            onSubmitted: (_) => _scan(),
            suffix: IconButton(
              onPressed: _controller.clear,
              icon: const Icon(Icons.cancel, color: Color(0xFFAAACC0)),
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Scan URL',
            icon: Icons.search_rounded,
            onPressed: _scan,
          ),
          const SizedBox(height: 28),
          const _DividerLabel('How it works'),
          const SizedBox(height: 20),
          const Row(
            children: [
              Expanded(
                  child: StepCard(
                      number: '1', icon: Icons.link, title: 'Enter Link')),
              SizedBox(width: 10),
              Expanded(
                  child: StepCard(
                      number: '2',
                      icon: Icons.shield_outlined,
                      title: 'AI Analysis')),
              SizedBox(width: 10),
              Expanded(
                  child: StepCard(
                      number: '3',
                      icon: Icons.fact_check_outlined,
                      title: 'Get Result')),
            ],
          ),
          const SizedBox(height: 22),
          const InfoBanner(
            icon: Icons.lightbulb_rounded,
            title: 'Tip',
            text:
                'Always double-check links from unknown sources to stay safe online.',
          ),
        ],
      ),
    );
  }
}

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final _picker = ImagePicker();
  final _scanner = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  bool _handling = false;

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  Future<void> _analyzeQrValue(String rawValue) async {
    final value = rawValue.trim();
    if (value.isEmpty || _handling) return;
    _handling = true;
    try {
      await _scanner.stop();
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AnalysisScreen(content: value, scanType: 'qr'),
        ),
      );
    } finally {
      _handling = false;
      if (mounted) {
        try {
          await _scanner.start();
        } catch (_) {
          // The camera can be unavailable while the route is closing.
        }
      }
    }
  }

  Future<void> _detected(BarcodeCapture capture) async {
    if (_handling) return;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue?.trim();
      if (value != null && value.isNotEmpty) {
        await _analyzeQrValue(value);
        return;
      }
    }
  }

  Future<void> _pickQrFromGallery() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final capture = await _scanner.analyzeImage(image.path);
      String? value;
      for (final barcode in capture?.barcodes ?? const <Barcode>[]) {
        final candidate = barcode.rawValue?.trim();
        if (candidate != null && candidate.isNotEmpty) {
          value = candidate;
          break;
        }
      }
      if (!mounted) return;
      if (value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: LocalizedText(
              'No readable QR code was found. Choose a clear, uncropped QR image.',
            ),
          ),
        );
        return;
      }
      await _analyzeQrValue(value);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: LocalizedText('Could not read that QR image: $error')),
      );
    }
  }

  Future<void> _enterCodeManually() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const LocalizedText('Enter QR content'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: AppLanguageController.translate(
              'Paste the decoded link, payment payload, or text',
            ),
          ),
          onSubmitted: (value) => Navigator.pop(dialogContext, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const LocalizedText('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const LocalizedText('Analyze'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null || result.isEmpty || !mounted) return;
    await _analyzeQrValue(result);
  }

  @override
  Widget build(BuildContext context) {
    return ScannerScaffold(
      title: 'QR Code Scanner',
      subtitle: 'Scan QR codes to reveal links\nand check for threats.',
      child: Column(
        children: [
          Container(
            height: 390,
            decoration: BoxDecoration(
              color: const Color(0xFF171927),
              borderRadius: BorderRadius.circular(20),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              alignment: Alignment.center,
              children: [
                MobileScanner(
                  controller: _scanner,
                  onDetect: _detected,
                  errorBuilder: (context, error) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: LocalizedText(
                        'Camera unavailable: ${error.errorDetails?.message ?? error.errorCode.name}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                    child: IgnorePointer(
                        child: CustomPaint(painter: ScanFramePainter()))),
                Positioned(
                  bottom: 22,
                  child: InkWell(
                    onTap: _scanner.toggleTorch,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.flashlight_on_rounded,
                              color: Colors.white),
                          SizedBox(width: 10),
                          LocalizedText('Toggle flashlight',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const _DividerLabel('Or choose from'),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                  child: ChoiceCard(
                      icon: Icons.image_outlined,
                      title: 'Select from Gallery',
                      onTap: _pickQrFromGallery)),
              const SizedBox(width: 14),
              Expanded(
                  child: ChoiceCard(
                      icon: Icons.keyboard_alt_outlined,
                      title: 'Enter Code Manually',
                      onTap: _enterCodeManually)),
            ],
          ),
          const SizedBox(height: 22),
          const InfoBanner(
            icon: Icons.verified_user_rounded,
            title: 'Privacy First',
            text:
                'We don’t store or share your scans. Your safety is our priority.',
          ),
        ],
      ),
    );
  }
}

class MessageScannerScreen extends StatefulWidget {
  const MessageScannerScreen({super.key});

  @override
  State<MessageScannerScreen> createState() => _MessageScannerScreenState();
}

class _MessageScannerScreenState extends State<MessageScannerScreen> {
  final _controller = TextEditingController();
  int _tab = 0;

  String get _scanType => const ['text', 'sms', 'email'][_tab];
  String get _actionLabel => switch (_tab) {
        1 => 'Scan SMS',
        2 => 'Scan Email',
        _ => 'Scan Text',
      };

  void _scan() {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: LocalizedText(
            'Enter content before ${_actionLabel.toLowerCase()}.',
          ),
        ),
      );
      return;
    }
    _open(context, AnalysisScreen(content: value, scanType: _scanType));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScannerScaffold(
      title: 'Message / Text Scanner',
      subtitle:
          'Analyze SMS, emails or messages\nto detect suspicious content.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedTabs(
            labels: const ['Paste Text', 'SMS', 'Email'],
            icons: const [
              Icons.description_outlined,
              Icons.sms_outlined,
              Icons.mail_outline
            ],
            index: _tab,
            onChanged: (value) => setState(() => _tab = value),
          ),
          const SizedBox(height: 18),
          LocalizedText(
            switch (_tab) {
              1 => 'Paste the complete SMS message below to scan for threats.',
              2 => 'Paste the email sender, subject, and message body below.',
              _ =>
                'Paste any message or text content below to scan for threats.',
            },
            style: const TextStyle(color: _muted, fontSize: 15),
          ),
          const SizedBox(height: 12),
          Focus(
            onKeyEvent: (_, event) {
              final isEnter = event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.numpadEnter;
              if (event is KeyDownEvent &&
                  isEnter &&
                  !HardwareKeyboard.instance.isShiftPressed) {
                _scan();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: TextField(
              controller: _controller,
              maxLines: 9,
              maxLength: 5000,
              decoration: InputDecoration(
                hintText: switch (_tab) {
                  1 => 'Paste SMS here...',
                  2 => 'Sender:\nSubject:\n\nPaste the email body here...',
                  _ => 'Paste text here...',
                },
                hintStyle: const TextStyle(color: Color(0xFF8B8EA8)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: _border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: _border),
                ),
                contentPadding: const EdgeInsets.all(18),
              ),
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: _actionLabel,
            icon: Icons.search,
            onPressed: _scan,
          ),
          const SizedBox(height: 24),
          const ExamplePanel(),
          const SizedBox(height: 20),
          const InfoBanner(
            icon: Icons.verified_user_rounded,
            title: 'Tips',
            text:
                'Do not share personal information. Be cautious of urgent requests or unknown links.',
            green: true,
          ),
        ],
      ),
    );
  }
}

class OcrScannerScreen extends StatefulWidget {
  const OcrScannerScreen({super.key});

  @override
  State<OcrScannerScreen> createState() => _OcrScannerScreenState();
}

class _OcrScannerScreenState extends State<OcrScannerScreen> {
  final _picker = ImagePicker();
  bool _processing = false;
  String _status = '';

  Future<void> _processImage(XFile file) async {
    if (_processing) return;
    try {
      final size = await file.length();
      if (size > 10 * 1024 * 1024) {
        throw Exception('Please select an image smaller than 10 MB.');
      }

      setState(() {
        _processing = true;
        _status = 'Extracting text from ${file.name}...';
      });
      final text = await extractTextFromImage(file);
      if (text.trim().isEmpty) {
        throw Exception(
          'No readable text was found. Try a clearer, full-size screenshot.',
        );
      }
      if (!mounted) return;
      setState(() => _status = 'Text extracted. Starting safety analysis...');
      _open(
        context,
        AnalysisScreen(content: text, scanType: 'ocr'),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: LocalizedText(
                error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _processing = false;
          _status = '';
        });
      }
    }
  }

  Future<void> _selectAndScan() async {
    if (_processing) return;
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 92,
      );
      if (file != null && mounted) await _processImage(file);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: LocalizedText(
                error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _openCamera() async {
    if (_processing) return;
    final file = await Navigator.of(context).push<XFile>(
      MaterialPageRoute(builder: (_) => const LiveCameraScreen()),
    );
    if (file != null && mounted) await _processImage(file);
  }

  @override
  Widget build(BuildContext context) {
    return ScannerScaffold(
      title: 'Screenshot / OCR',
      subtitle: 'Extract text from images and analyze\nfor potential risks.',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFCFAFF),
              border: Border.all(color: _border),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 38, 24, 30),
              decoration: BoxDecoration(
                border: Border.all(
                    color: const Color(0xFFA68AFF), style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.add_photo_alternate_outlined,
                      color: _purple, size: 80),
                  const SizedBox(height: 20),
                  const LocalizedText(
                    'Upload Screenshot or Image',
                    style: TextStyle(
                        color: _ink, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 7),
                  const LocalizedText('JPG, PNG, WEBP up to 10MB',
                      style: TextStyle(color: _muted)),
                  const SizedBox(height: 22),
                  PrimaryButton(
                    label: _processing ? 'Reading Image...' : 'Choose Image',
                    icon: _processing
                        ? Icons.hourglass_top_rounded
                        : Icons.upload_rounded,
                    onPressed: _processing ? () {} : _selectAndScan,
                  ),
                  const SizedBox(height: 14),
                  const LocalizedText('or', style: TextStyle(color: _muted)),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: _processing ? null : _openCamera,
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const LocalizedText('Use Camera'),
                  ),
                  if (_status.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    const LinearProgressIndicator(color: _purple),
                    const SizedBox(height: 10),
                    LocalizedText(
                      _status,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: _muted),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const ExamplePanel(
            title: 'What we can do',
            items: [
              (
                Icons.text_fields_rounded,
                'Extract Text (OCR)',
                'Pull text from images or documents.'
              ),
              (
                Icons.warning_amber_rounded,
                'Analyze for Risks',
                'Detect phishing attempts and scams.'
              ),
              (
                Icons.verified_user_rounded,
                'Get Safety Result',
                'See if content is safe or dangerous.'
              ),
            ],
          ),
          const SizedBox(height: 20),
          const InfoBanner(
            icon: Icons.lightbulb_rounded,
            title: 'Tip',
            text:
                'Capture the full message, email, or alert for better accuracy.',
            green: true,
          ),
        ],
      ),
    );
  }
}

class LiveCameraScreen extends StatefulWidget {
  const LiveCameraScreen({super.key});

  @override
  State<LiveCameraScreen> createState() => _LiveCameraScreenState();
}

class _LiveCameraScreenState extends State<LiveCameraScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  int _cameraIndex = 0;
  bool _capturing = false;
  bool _torchOn = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize([int cameraIndex = 0]) async {
    try {
      final cameras = _cameras.isEmpty ? await availableCameras() : _cameras;
      if (cameras.isEmpty) {
        throw CameraException(
            'noCamera', 'No camera was found on this device.');
      }
      final index = cameraIndex.clamp(0, cameras.length - 1);
      final previous = _controller;
      final controller = CameraController(
        cameras[index],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await previous?.dispose();
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _cameras = cameras;
        _cameraIndex = index;
        _controller = controller;
        _error = null;
        _torchOn = false;
      });
    } on CameraException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.code == 'CameraAccessDenied' ||
                error.code == 'permissionDenied'
            ? 'Camera permission was denied. Allow camera access in the browser address bar, then try again.'
            : (error.description ?? 'The camera could not be started.');
      });
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'The camera could not be started: $error');
      }
    }
  }

  Future<void> _takePhoto() async {
    final controller = _controller;
    if (_capturing || controller == null || !controller.value.isInitialized) {
      return;
    }
    setState(() => _capturing = true);
    try {
      final photo = await controller.takePicture();
      if (mounted) Navigator.of(context).pop(photo);
    } on CameraException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: LocalizedText(
                error.description ?? 'Could not take the photo.')),
      );
      setState(() => _capturing = false);
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _capturing) return;
    await _initialize((_cameraIndex + 1) % _cameras.length);
  }

  Future<void> _toggleTorch() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    try {
      final next = !_torchOn;
      await controller.setFlashMode(next ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() => _torchOn = next);
    } on CameraException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: LocalizedText(
            'Torch control is unavailable in this browser or on this camera.',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        title: const LocalizedText('Take a Photo'),
        actions: [
          IconButton(
            tooltip: _torchOn ? 'Turn flashlight off' : 'Turn flashlight on',
            onPressed: _toggleTorch,
            icon: Icon(_torchOn ? Icons.flash_on : Icons.flash_off),
          ),
          if (_cameras.length > 1)
            IconButton(
              tooltip: AppLanguageController.translate('Switch camera'),
              onPressed: _switchCamera,
              icon: const Icon(Icons.cameraswitch_rounded),
            ),
        ],
      ),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.no_photography_rounded,
                        color: Colors.white, size: 64),
                    const SizedBox(height: 18),
                    LocalizedText(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 17),
                    ),
                    const SizedBox(height: 22),
                    FilledButton.icon(
                      onPressed: _initialize,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const LocalizedText('Try Again'),
                    ),
                  ],
                ),
              ),
            )
          : controller == null || !controller.value.isInitialized
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    Center(child: CameraPreview(controller)),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                        color: Colors.black54,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const LocalizedText(
                              'Keep the complete message clearly inside the frame.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            Semantics(
                              button: true,
                              label: 'Take photo',
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: _takePhoto,
                                child: Container(
                                  width: 76,
                                  height: 76,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(
                                      color: _capturing ? Colors.grey : _purple,
                                      width: 6,
                                    ),
                                  ),
                                  child: _capturing
                                      ? const Padding(
                                          padding: EdgeInsets.all(20),
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class ScannerScaffold extends StatelessWidget {
  const ScannerScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 32),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon:
                        const Icon(Icons.arrow_back, color: _purple, size: 30),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        LocalizedText(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 7),
                        LocalizedText(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: _muted, fontSize: 15, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const ShieldMark(size: 48),
                ],
              ),
              const SizedBox(height: 30),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class ShieldMark extends StatelessWidget {
  const ShieldMark({required this.size, super.key});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8E4BFF), Color(0xFF3A12A6)],
        ),
        borderRadius: BorderRadius.circular(size * .3),
      ),
      child: Icon(Icons.fingerprint_rounded,
          color: Colors.white, size: size * .57),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton({
    required this.darkMode,
    required this.onPressed,
  });

  final bool darkMode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label = darkMode ? 'Switch to light mode' : 'Switch to dark mode';
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(22),
            child: Ink(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                gradient: darkMode
                    ? const LinearGradient(
                        colors: [Color(0xFF16213E), Color(0xFF0B102A)],
                      )
                    : _primaryGradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: _purple.withValues(alpha: .2),
                    blurRadius: 16,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Icon(
                darkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: darkMode ? const Color(0xFFFFD65A) : Colors.white,
                size: 42,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: _primaryGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: icon == null
            ? const SizedBox.shrink()
            : Icon(icon, color: Colors.white),
        label: LocalizedText(
          label,
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  const _InputBox({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.autofillHints,
    this.submitOnPhysicalEnter = false,
  });
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;
  final bool submitOnPhysicalEnter;

  @override
  Widget build(BuildContext context) {
    final field = TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        obscureText: obscureText,
        textInputAction: textInputAction,
        onSubmitted: submitOnPhysicalEnter ? null : onSubmitted,
        autofillHints: autofillHints,
        autocorrect: false,
        enableSuggestions: !obscureText,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9496AF)),
          prefixIcon: Icon(icon, color: _purple),
          suffixIcon: suffix,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _purple, width: 1.5),
          ),
        ));
    if (!submitOnPhysicalEnter) return field;
    return Focus(
      onKeyEvent: (_, event) {
        final isEnter = event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.numpadEnter;
        if (event is KeyDownEvent && isEnter) {
          onSubmitted?.call(controller.text);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: field,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => LocalizedText(
        label,
        style: const TextStyle(
            color: _ink, fontSize: 17, fontWeight: FontWeight.w700),
      );
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel(this.label);
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: _border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: LocalizedText(label,
              style: const TextStyle(color: _muted, fontSize: 15)),
        ),
        const Expanded(child: Divider(color: _border)),
      ],
    );
  }
}

class SocialButton extends StatelessWidget {
  const SocialButton({
    required this.label,
    required this.color,
    this.onTap,
    super.key,
  });
  final String label;
  final Color color;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Color(0x18000000), blurRadius: 18)],
        ),
        alignment: Alignment.center,
        child: LocalizedText(
          label,
          style: TextStyle(
              color: color, fontSize: 36, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon});
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFF0EAFF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: _purple),
    );
  }
}

class PageHeader extends StatelessWidget {
  const PageHeader({required this.title, required this.subtitle, super.key});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 42),
        Expanded(
          child: Column(
            children: [
              LocalizedText(title,
                  style: const TextStyle(
                      color: _ink, fontSize: 27, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              LocalizedText(subtitle,
                  style: const TextStyle(color: _muted, fontSize: 15)),
            ],
          ),
        ),
        const SizedBox(width: 42),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard(
      {required this.label,
      required this.value,
      required this.color,
      super.key});
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.shield_rounded, color: color),
          const SizedBox(height: 5),
          FittedBox(
              child: LocalizedText(label,
                  style: TextStyle(color: color, fontWeight: FontWeight.w700))),
          const SizedBox(height: 8),
          LocalizedText(value,
              style: TextStyle(
                  color: color, fontSize: 30, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({required this.title, required this.subtitle, super.key});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LocalizedText(title,
              style: const TextStyle(
                  color: _ink, fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          LocalizedText(subtitle, style: const TextStyle(color: _muted)),
        ],
      );
}

class QuickScanCard extends StatelessWidget {
  const QuickScanCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 130,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _border),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0D4219A8), blurRadius: 14, offset: Offset(0, 5))
          ],
        ),
        child: Column(
          children: [
            _IconTile(icon: icon),
            const SizedBox(height: 8),
            FittedBox(
                child: LocalizedText(title,
                    style: const TextStyle(
                        color: _ink, fontWeight: FontWeight.w700))),
            const SizedBox(height: 4),
            LocalizedText(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _muted, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class RecentScanTile extends StatelessWidget {
  const RecentScanTile({
    required this.title,
    required this.result,
    required this.time,
    required this.color,
    super.key,
  });
  final String title;
  final String result;
  final String time;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x0C000000), blurRadius: 12)],
      ),
      child: Row(
        children: [
          Icon(Icons.shield_rounded, color: color, size: 35),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LocalizedText(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: _ink, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                LocalizedText(result,
                    style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          LocalizedText(time,
              style: const TextStyle(color: _muted, fontSize: 12)),
          const Icon(Icons.chevron_right, color: Color(0xFF8B8EA4)),
        ],
      ),
    );
  }
}

class ScanTypeCard extends StatelessWidget {
  const ScanTypeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.button,
    required this.color,
    required this.onTap,
    super.key,
  });
  final IconData icon;
  final String title;
  final String description;
  final String button;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10451BB0),
                blurRadius: 18,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: const BoxDecoration(
                    color: Color(0xFFF4F0FF), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 44),
              ),
              const SizedBox(height: 16),
              FittedBox(
                  child: LocalizedText(title,
                      style: const TextStyle(
                          color: _ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w800))),
              const SizedBox(height: 10),
              LocalizedText(description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _muted, height: 1.4)),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onTap,
                  style: FilledButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(vertical: 13)),
                  child: LocalizedText(button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoBanner extends StatelessWidget {
  const InfoBanner({
    required this.icon,
    required this.title,
    required this.text,
    this.green = false,
    super.key,
  });
  final IconData icon;
  final String title;
  final String text;
  final bool green;
  @override
  Widget build(BuildContext context) {
    final color = green ? const Color(0xFF14944C) : _purple;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .06),
        border: Border.all(color: color.withValues(alpha: .12)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _IconTile(icon: icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LocalizedText(title,
                    style: TextStyle(
                        color: color,
                        fontSize: 17,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 5),
                LocalizedText(text,
                    style: const TextStyle(color: _muted, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerHero extends StatelessWidget {
  const ScannerHero({required this.icon, super.key});
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 180,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient:
            RadialGradient(colors: [Color(0xFFDCD1FF), Color(0x11FFFFFF)]),
      ),
      child: Icon(icon, color: _purple, size: 115),
    );
  }
}

class StepCard extends StatelessWidget {
  const StepCard(
      {required this.number,
      required this.icon,
      required this.title,
      super.key});
  final String number;
  final IconData icon;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CircleAvatar(
              radius: 13,
              backgroundColor: _purple,
              child: LocalizedText(number,
                  style: const TextStyle(color: Colors.white))),
          const SizedBox(height: 14),
          Icon(icon, color: _purple, size: 42),
          const Spacer(),
          FittedBox(
              child: LocalizedText(title,
                  style: const TextStyle(
                      color: _ink, fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({
    required this.icon,
    required this.title,
    required this.onTap,
    super.key,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 145,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: _purple, size: 48),
              const SizedBox(height: 16),
              LocalizedText(
                title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: _ink, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    required this.labels,
    required this.icons,
    required this.index,
    required this.onChanged,
    super.key,
  });
  final List<String> labels;
  final List<IconData> icons;
  final int index;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) {
    Widget tab(int i) {
      final active = i == index;
      return InkWell(
        onTap: () => onChanged(i),
        borderRadius: BorderRadius.circular(11),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            gradient: active ? _primaryGradient : null,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icons[i], color: active ? Colors.white : _muted, size: 20),
              const SizedBox(width: 7),
              Flexible(
                child: LocalizedText(
                  labels[i],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: active ? Colors.white : _ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final needsScrolling = constraints.maxWidth < labels.length * 125;
        final tabs = List.generate(labels.length, (i) {
          final child = tab(i);
          return needsScrolling
              ? SizedBox(width: 132, child: child)
              : Expanded(child: child);
        });

        final row = Row(children: tabs);
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(13),
          ),
          child: needsScrolling
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: row,
                )
              : row,
        );
      },
    );
  }
}

class ExamplePanel extends StatelessWidget {
  const ExamplePanel({
    this.title = 'Examples of what you can scan',
    this.items = const [
      (
        Icons.sms_rounded,
        'SMS / Text Messages',
        'Check suspicious SMS or text messages'
      ),
      (
        Icons.mail_outline_rounded,
        'Email Content',
        'Analyze email body or suspicious content'
      ),
      (
        Icons.link_rounded,
        'Social Media / Chat',
        'Scan WhatsApp or Telegram messages'
      ),
    ],
    super.key,
  });
  final String title;
  final List<(IconData, String, String)> items;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LocalizedText(title,
              style:
                  const TextStyle(color: _purple, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 9),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Icon(item.$1, color: _purple, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LocalizedText(item.$2,
                            style: const TextStyle(
                                color: _ink, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 3),
                        LocalizedText(item.$3,
                            style:
                                const TextStyle(color: _muted, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppBottomBar extends StatelessWidget {
  const AppBottomBar({required this.index, required this.onChanged, super.key});
  final int index;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) {
    const icons = [
      Icons.home_rounded,
      Icons.history_rounded,
      Icons.center_focus_strong_rounded,
      Icons.flag_outlined,
      Icons.person_outline_rounded
    ];
    const labels = ['Home', 'History', 'Scan', 'Reports', 'Profile'];
    return SafeArea(
      top: false,
      child: Container(
        height: 76,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: _border)),
        ),
        child: Row(
          children: List.generate(5, (i) {
            final active = index == i;
            final scan = i == 2;
            return Expanded(
              child: InkWell(
                onTap: () => onChanged(i),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: scan ? 56 : 36,
                      height: scan ? 56 : 36,
                      decoration: scan
                          ? const BoxDecoration(
                              gradient: _primaryGradient,
                              shape: BoxShape.circle)
                          : null,
                      child: Icon(icons[i],
                          color: scan
                              ? Colors.white
                              : active
                                  ? _purple
                                  : _muted,
                          size: scan ? 29 : 26),
                    ),
                    if (!scan)
                      LocalizedText(labels[i],
                          style: TextStyle(
                              color: active ? _purple : _muted,
                              fontSize: 11,
                              fontWeight:
                                  active ? FontWeight.w700 : FontWeight.w500)),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

enum ScanLevel { safe, suspicious, dangerous, inconclusive }

extension ScanLevelStyle on ScanLevel {
  String get label => switch (this) {
        ScanLevel.safe => 'Safe',
        ScanLevel.suspicious => 'Suspicious',
        ScanLevel.dangerous => 'Dangerous',
        ScanLevel.inconclusive => 'Inconclusive',
      };

  Color get color => switch (this) {
        ScanLevel.safe => const Color(0xFF14944C),
        ScanLevel.suspicious => const Color(0xFFF07A00),
        ScanLevel.dangerous => const Color(0xFFE31D2B),
        ScanLevel.inconclusive => const Color(0xFF667085),
      };

  IconData get icon => switch (this) {
        ScanLevel.safe => Icons.verified_user_rounded,
        ScanLevel.suspicious => Icons.warning_rounded,
        ScanLevel.dangerous => Icons.gpp_bad_rounded,
        ScanLevel.inconclusive => Icons.help_outline_rounded,
      };
}

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({
    required this.content,
    required this.scanType,
    super.key,
  });

  final String content;
  final String scanType;

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _advance();
  }

  Future<void> _advance() async {
    final predictionFuture = switch (widget.scanType) {
      'url' => ApiService.scanUrl(widget.content),
      'qr' => ApiService.scanQr(widget.content),
      'sms' => ApiService.scanSms(widget.content),
      'email' => ApiService.scanEmail(widget.content),
      'ocr' => ApiService.scanOcr(widget.content),
      'text' => ApiService.scanText(widget.content),
      _ => ApiService.scanMessage(widget.content),
    };
    for (var i = 1; i <= 4; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 450));
      if (!mounted) return;
      setState(() => _step = i);
    }
    try {
      final prediction = await predictionFuture;
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ScanResultScreen(prediction: prediction),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const ErrorScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const labels = [
      'Checking URL',
      'Scanning Database',
      'Running AI Model',
      'Comparing Threat Intelligence',
      'Almost Done...',
    ];
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 30),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 48,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: _purple),
                        ),
                        const Expanded(
                          child: LocalizedText(
                            'Analyzing...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _ink,
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const ShieldMark(size: 42),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 190,
                      height: 190,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const SizedBox(
                            width: 190,
                            height: 190,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              color: _purple,
                              backgroundColor: Color(0xFFEAE5FA),
                            ),
                          ),
                          Container(
                            width: 120,
                            height: 120,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1ECFF),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(child: ShieldMark(size: 72)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 34),
                    const LocalizedText(
                      'Please wait while we scan',
                      style: TextStyle(
                          color: _ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 28),
                    ...List.generate(
                      labels.length,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        child: Row(
                          children: [
                            Icon(
                              index < _step
                                  ? Icons.check_circle
                                  : index == _step
                                      ? Icons.autorenew_rounded
                                      : Icons.circle_outlined,
                              color: index <= _step
                                  ? _purple
                                  : const Color(0xFF9295AD),
                              size: 22,
                            ),
                            const SizedBox(width: 14),
                            LocalizedText(labels[index],
                                style:
                                    const TextStyle(color: _ink, fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    const InfoBanner(
                      icon: Icons.shield_rounded,
                      title: 'Secure analysis',
                      text:
                          'This may take a few seconds. Please do not close the app.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ScanResultScreen extends StatelessWidget {
  const ScanResultScreen({required this.prediction, super.key});

  final ScanPrediction prediction;

  @override
  Widget build(BuildContext context) {
    final level = switch (prediction.classification) {
      'safe' => ScanLevel.safe,
      'suspicious' => ScanLevel.suspicious,
      'dangerous' => ScanLevel.dangerous,
      _ => ScanLevel.inconclusive,
    };
    final score = prediction.riskScore;
    final isRoomCheck = prediction.scanType == 'hidden_camera';
    final resultLabel = isRoomCheck
        ? switch (level) {
            ScanLevel.safe => 'No Indicators Found',
            ScanLevel.suspicious => 'Caution',
            _ => level.label,
          }
        : level.label;
    final description = isRoomCheck
        ? switch (level) {
            ScanLevel.safe =>
              'The guided checks found no reported indicators. This does not certify that the room is camera-free.',
            ScanLevel.suspicious =>
              'One supporting signal was reported. It is not conclusive by itself; verify it without touching the object.',
            ScanLevel.dangerous =>
              'Multiple possible hidden-camera indicators were reported. Leave the room and seek assistance.',
            ScanLevel.inconclusive =>
              'The available observations were insufficient to assess the room.',
          }
        : switch (level) {
            ScanLevel.safe =>
              'No strong threat indicators were detected. This is not a guarantee that the website is safe.',
            ScanLevel.suspicious => 'This website shows several warning signs.',
            ScanLevel.dangerous =>
              'This link is unsafe and may be a phishing attempt.',
            ScanLevel.inconclusive =>
              'There is not enough meaningful information to assess this content.',
          };
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 30),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon:
                        const Icon(Icons.arrow_back, color: _purple, size: 30),
                  ),
                  const Expanded(
                    child: Column(
                      children: [
                        LocalizedText(
                          'Scan Result',
                          style: TextStyle(
                              color: _ink,
                              fontSize: 25,
                              fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 4),
                        LocalizedText('Scanned just now',
                            style: TextStyle(color: _muted)),
                      ],
                    ),
                  ),
                  const ShieldMark(size: 44),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: level.color.withValues(alpha: .07),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: level.color.withValues(alpha: .12)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 95,
                      height: 95,
                      decoration: BoxDecoration(
                        color: level.color.withValues(alpha: .13),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(level.icon, color: level.color, size: 61),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LocalizedText(
                            resultLabel,
                            style: TextStyle(
                              color: level.color,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          LocalizedText(description,
                              style: const TextStyle(color: _ink, height: 1.4)),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        LocalizedText(
                          '$score',
                          style: TextStyle(
                              color: level.color,
                              fontSize: 38,
                              fontWeight: FontWeight.w800),
                        ),
                        const LocalizedText('/100',
                            style: TextStyle(color: _muted)),
                        const LocalizedText('Risk Score',
                            style: TextStyle(color: _muted, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _ResultCard(
                title: 'Scanned Item',
                child: Row(
                  children: [
                    const Icon(Icons.link_rounded, color: _purple),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LocalizedText(
                        prediction.content,
                        style: const TextStyle(
                            color: _ink, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              _ResultCard(
                title: level == ScanLevel.safe
                    ? 'Why it’s safe'
                    : 'Detection Details',
                child: Column(
                  children: [
                    if (prediction.urlIntelligence != null) ...[
                      _DetailRow(
                        icon: Icons.language,
                        label: 'Domain',
                        value:
                            '${prediction.urlIntelligence!['domain'] ?? 'Unavailable'}',
                        color: level.color,
                      ),
                      _DetailRow(
                        icon: Icons.dns_outlined,
                        label: 'IP Address',
                        value:
                            '${prediction.urlIntelligence!['ip_address'] ?? 'Unavailable'}',
                        color: level.color,
                      ),
                      _DetailRow(
                        icon: Icons.location_on_outlined,
                        label: 'Infrastructure IP Location',
                        value:
                            '${prediction.urlIntelligence!['location'] ?? 'Unavailable'}',
                        color: level.color,
                      ),
                      _DetailRow(
                        icon: Icons.business_outlined,
                        label: 'Hosting Network',
                        value:
                            '${prediction.urlIntelligence!['network_provider'] ?? 'Unavailable'}',
                        color: level.color,
                      ),
                      _DetailRow(
                        icon: Icons.info_outline,
                        label: 'Infrastructure Meaning',
                        value:
                            '${prediction.urlIntelligence!['infrastructure_role'] ?? 'Website hosting endpoint'}',
                        color: level.color,
                      ),
                      _DetailRow(
                        icon: Icons.place_outlined,
                        label: 'Location Interpretation',
                        value:
                            '${prediction.urlIntelligence!['destination_note'] ?? 'Infrastructure location does not establish the content or organisation location.'}',
                        color: level.color,
                      ),
                      _DetailRow(
                        icon: Icons.hub_outlined,
                        label: 'ASN',
                        value:
                            '${prediction.urlIntelligence!['asn'] ?? 'Unavailable'}',
                        color: level.color,
                      ),
                    ],
                    if (isRoomCheck && prediction.signalDetails.isNotEmpty) ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(top: 4, bottom: 4),
                          child: LocalizedText(
                            'Signal evidence and limitations',
                            style: TextStyle(
                              color: _ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      ...prediction.signalDetails.map(
                        (signal) => _SignalDetailRow(
                          signal: signal,
                          color: level.color,
                        ),
                      ),
                    ],
                    _DetailRow(
                      icon: Icons.public,
                      label: 'Threat Type',
                      value: resultLabel,
                      color: level.color,
                    ),
                    _DetailRow(
                      icon: Icons.psychology_outlined,
                      label: 'Detected By',
                      value: prediction.scanType == 'url' ||
                              prediction.scanType == 'qr'
                          ? 'URL Random Forest'
                          : isRoomCheck
                              ? 'Guided Safety Checklist'
                              : 'TF-IDF Logistic Regression',
                      color: level.color,
                    ),
                    _DetailRow(
                      icon: Icons.security,
                      label: 'Confidence',
                      value: '${(prediction.confidence * 100).round()}%',
                      color: level.color,
                    ),
                    ...prediction.reasons.asMap().entries.map(
                          (entry) => _DetailRow(
                            icon: Icons.info_outline,
                            label: 'Reason ${entry.key + 1}',
                            value: entry.value,
                            color: level.color,
                            divider: entry.key != prediction.reasons.length - 1,
                          ),
                        ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (prediction.urlIntelligence != null) ...[
                const InfoBanner(
                  icon: Icons.info_outline,
                  title: 'Location privacy notice',
                  text:
                      'This is an approximate server or hosting-provider location derived from public IP data. It does not reveal the website owner’s, visitor’s, or attacker’s precise physical location.',
                ),
                const SizedBox(height: 16),
              ],
              InfoBanner(
                icon: level == ScanLevel.safe
                    ? Icons.check_circle
                    : Icons.lightbulb_rounded,
                title: level == ScanLevel.safe
                    ? 'Safe to continue'
                    : 'What should you do?',
                text: prediction.recommendation,
                green: level == ScanLevel.safe,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.refresh),
                      label: const LocalizedText('Scan Again'),
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 17)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Go Home',
                      icon: Icons.home_outlined,
                      onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute<void>(
                            builder: (_) => const MainShell()),
                        (_) => false,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LocalizedText(title,
              style: const TextStyle(color: _ink, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.divider = true,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool divider;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border:
            divider ? const Border(bottom: BorderSide(color: _border)) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          SizedBox(
              width: 90,
              child:
                  LocalizedText(label, style: const TextStyle(color: _muted))),
          Expanded(
            child: LocalizedText(
              value,
              textAlign: TextAlign.right,
              softWrap: true,
              style: const TextStyle(
                color: _ink,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalDetailRow extends StatelessWidget {
  const _SignalDetailRow({required this.signal, required this.color});

  final Map<String, dynamic> signal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final detected = signal['detected'] == true;
    final confidence = ((signal['confidence'] as num?) ?? 0).toDouble();
    final evidence = '${signal['evidence'] ?? 'No hit reported'}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              detected ? Icons.sensors_rounded : Icons.sensors_off_rounded,
              color: detected ? color : _muted,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: LocalizedText(
                        '${signal['label'] ?? 'Signal'}',
                        style: const TextStyle(
                          color: _ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (detected)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LocalizedText(
                            'Detected',
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            ' (${(confidence * 100).round()}%)',
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      )
                    else
                      const LocalizedText(
                        'No hit reported',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
                if (detected && evidence != 'No hit reported') ...[
                  const SizedBox(height: 5),
                  Text(
                    evidence,
                    style: const TextStyle(color: _ink, height: 1.35),
                  ),
                ],
                const SizedBox(height: 5),
                LocalizedText(
                  '${signal['limitation'] ?? 'This signal is not conclusive by itself.'}',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _filter = 0;
  int _limit = 6;
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  late Future<Map<String, dynamic>> _history;

  @override
  void initState() {
    super.initState();
    _history = ApiService.history(limit: 1000);
  }

  void _refresh() {
    setState(() => _history = ApiService.history(limit: 1000));
  }

  bool _matchesSelectedCategory(Map<String, dynamic> item) {
    final type = (item['scan_type'] as String? ?? '').toLowerCase();
    return switch (_filter) {
      1 => type == 'url',
      2 => type == 'qr',
      3 => const {'message', 'text', 'sms', 'email'}.contains(type),
      4 => type == 'ocr',
      5 => const {'hidden_camera', 'room'}.contains(type),
      _ => true,
    };
  }

  bool _matchesSearch(Map<String, dynamic> item) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return true;
    return [
      item['content'],
      item['scan_type'],
      item['classification'],
      item['created_at'],
    ].any((value) => value.toString().toLowerCase().contains(query));
  }

  void _searchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _limit = 6);
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
                title: 'History',
                subtitle: 'View and manage your scan history'),
            const SizedBox(height: 22),
            TextField(
              controller: _searchController,
              onChanged: _searchChanged,
              decoration: InputDecoration(
                hintText: AppLanguageController.translate('Search scans...'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: AppLanguageController.translate('Clear search'),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _limit = 6);
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
                filled: true,
                fillColor: const Color(0xFFFBFBFE),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _border),
                ),
              ),
            ),
            const SizedBox(height: 18),
            SegmentedTabs(
              labels: const [
                'All',
                'Links',
                'QR Codes',
                'Messages',
                'Screenshots',
                'Room Checks',
              ],
              icons: const [
                Icons.apps,
                Icons.link,
                Icons.qr_code_2,
                Icons.message,
                Icons.image_search_outlined,
                Icons.videocam_outlined,
              ],
              index: _filter,
              onChanged: (value) {
                setState(() {
                  _filter = value;
                  _limit = 6;
                });
              },
            ),
            const SizedBox(height: 22),
            FutureBuilder<Map<String, dynamic>>(
              future: _history,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(35),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Column(
                    children: [
                      const LocalizedText(
                        'Could not load history. Make sure the backend is running.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: _muted),
                      ),
                      TextButton.icon(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh),
                        label: const LocalizedText('Retry'),
                      ),
                    ],
                  );
                }
                final data = snapshot.data ?? const <String, dynamic>{};
                final allItems =
                    (data['items'] as List<Map<String, dynamic>>?) ?? [];
                final categoryItems =
                    allItems.where(_matchesSelectedCategory).toList();
                final filteredItems =
                    categoryItems.where(_matchesSearch).toList();
                final total = filteredItems.length;
                final items = filteredItems.take(_limit).toList();
                final category = switch (_filter) {
                  1 => 'link scans',
                  2 => 'QR code scans',
                  3 => 'message, SMS, or email scans',
                  4 => 'screenshot/OCR scans',
                  5 => 'room checks',
                  _ => 'scan history',
                };
                if (items.isEmpty) {
                  final categoryHasNoRecords = categoryItems.isEmpty;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LocalizedText(
                        'Recent Scans (0)',
                        style: TextStyle(
                          color: _ink,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 42),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(
                                Icons.manage_search_rounded,
                                color: _purple,
                                size: 58,
                              ),
                              const SizedBox(height: 12),
                              LocalizedText(
                                categoryHasNoRecords
                                    ? 'No $category yet.'
                                    : 'No matching $category found.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: _ink,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              LocalizedText(
                                categoryHasNoRecords
                                    ? _filter == 0
                                        ? 'Complete your first scan and its result will appear here.'
                                        : 'Use this scan type and its result will appear here.'
                                    : 'Try another search phrase or clear the search box.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: _muted),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LocalizedText(
                      'Recent Scans ($total)',
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...items.map((item) {
                      final classification = item['classification'] as String;
                      final level = switch (classification) {
                        'safe' => ScanLevel.safe,
                        'suspicious' => ScanLevel.suspicious,
                        'dangerous' => ScanLevel.dangerous,
                        _ => ScanLevel.inconclusive,
                      };
                      return HistoryTile(
                        entry: (
                          item['content'] as String,
                          switch (item['scan_type'] as String) {
                            'url' => 'Link Scan',
                            'qr' => 'QR Code Scan',
                            'sms' => 'SMS Scan',
                            'email' => 'Email Scan',
                            'ocr' => 'Screenshot / OCR Scan',
                            'text' => 'Text Scan',
                            'hidden_camera' => 'Hidden Camera Safety Check',
                            _ => 'Message Scan',
                          },
                          item['created_at'] as String,
                          level,
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    LocalizedText(
                      'Showing ${items.length} of $total scans',
                      style: const TextStyle(color: _muted),
                    ),
                    if (items.length < total)
                      TextButton.icon(
                        onPressed: () {
                          _limit += 6;
                          _refresh();
                        },
                        label: const LocalizedText('Load More'),
                        icon: const Icon(Icons.keyboard_arrow_down),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryTile extends StatelessWidget {
  const HistoryTile({required this.entry, super.key});
  final (String, String, String, ScanLevel) entry;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: entry.$4.color.withValues(alpha: .1),
              shape: BoxShape.circle,
            ),
            child: Icon(entry.$4.icon, color: entry.$4.color, size: 32),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LocalizedText(
                  entry.$1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(color: _ink, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                LocalizedText(entry.$2,
                    style: const TextStyle(color: _muted, fontSize: 12)),
                const SizedBox(height: 5),
                _RiskPill(level: entry.$4),
              ],
            ),
          ),
          LocalizedText(entry.$3,
              style: const TextStyle(color: _muted, fontSize: 11)),
          const Icon(Icons.chevron_right, color: _muted),
        ],
      ),
    );
  }
}

class _RiskPill extends StatelessWidget {
  const _RiskPill({required this.level});
  final ScanLevel level;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: level.color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: LocalizedText(
          level.label,
          style: TextStyle(
              color: level.color, fontSize: 10, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late Future<Map<String, dynamic>> _analytics;

  @override
  void initState() {
    super.initState();
    _analytics = ApiService.analytics(days: 30);
  }

  void _refresh() {
    setState(() => _analytics = ApiService.analytics(days: 30));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
                title: 'Reports',
                subtitle: 'Insights and statistics about your security'),
            const SizedBox(height: 24),
            FutureBuilder<Map<String, dynamic>>(
              future: _analytics,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return _HomeHistoryMessage(
                    message:
                        'Reports could not be loaded. Check the secure backend connection.',
                    button: 'Retry',
                    onPressed: _refresh,
                  );
                }
                return _ReportsContent(data: snapshot.data ?? const {});
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportsContent extends StatelessWidget {
  const _ReportsContent({required this.data});
  final Map<String, dynamic> data;

  String _dateLabel(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return value;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final summary = (data['summary'] as Map<String, dynamic>?) ?? const {};
    final daily = List<Map<String, dynamic>>.from(data['daily'] as List? ?? []);
    final recent =
        List<Map<String, dynamic>>.from(data['recent_threats'] as List? ?? []);
    final total = (summary['total'] as num?)?.toInt() ?? 0;
    final safe = (summary['safe'] as num?)?.toInt() ?? 0;
    final suspicious = (summary['suspicious'] as num?)?.toInt() ?? 0;
    final dangerous = (summary['dangerous'] as num?)?.toInt() ?? 0;
    final threats = suspicious + dangerous;
    final values =
        daily.map((item) => (item['count'] as num).toDouble()).toList();
    final labels = daily.isEmpty
        ? <String>[]
        : [daily.first, daily[daily.length ~/ 2], daily.last]
            .map((item) => _dateLabel(item['date'] as String))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
                child: ReportMetric(
                    icon: Icons.shield,
                    value: '$total',
                    label: 'Total Scans',
                    color: _purple)),
            const SizedBox(width: 10),
            Expanded(
                child: ReportMetric(
                    icon: Icons.warning,
                    value: '$threats',
                    label: 'Threats',
                    color: const Color(0xFFE31D2B))),
            const SizedBox(width: 10),
            Expanded(
                child: ReportMetric(
                    icon: Icons.verified_user,
                    value: '$safe',
                    label: 'Safe Items',
                    color: const Color(0xFF14944C))),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          height: 245,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: total == 0
              ? const Center(
                  child: LocalizedText(
                    'No activity yet.\nComplete a scan to build your security report.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _muted, height: 1.5),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LocalizedText(
                      'Scans Over Time · ${data['from_date']} to ${data['to_date']}',
                      style: const TextStyle(
                          color: _ink, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 16),
                    Expanded(child: LargeTrendChart(values: values)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: labels
                          .map((label) => LocalizedText(label,
                              style:
                                  const TextStyle(color: _muted, fontSize: 10)))
                          .toList(),
                    ),
                  ],
                ),
        ),
        if (total > 0) ...[
          const SizedBox(height: 18),
          _ResultCard(
            title: 'Detection Results',
            child: Column(
              children: [
                ThreatTypeRow(
                    label: 'Phishing',
                    value: dangerous,
                    total: total,
                    color: const Color(0xFFE31D2B)),
                ThreatTypeRow(
                    label: 'Suspicious',
                    value: suspicious,
                    total: total,
                    color: const Color(0xFFF07A00)),
                ThreatTypeRow(
                    label: 'Safe',
                    value: safe,
                    total: total,
                    color: const Color(0xFF14944C)),
              ],
            ),
          ),
        ],
        const SizedBox(height: 18),
        const LocalizedText('Recent Threats',
            style: TextStyle(
                color: _ink, fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        if (recent.isEmpty)
          const InfoBanner(
            icon: Icons.verified_user_outlined,
            title: 'No threats recorded',
            text:
                'Suspicious and dangerous results will appear here after a scan.',
            green: true,
          )
        else
          ...recent.map((item) {
            final classification = item['classification'] as String;
            return RecentScanTile(
              title: item['content'] as String,
              result:
                  classification == 'dangerous' ? 'Dangerous' : 'Suspicious',
              time: item['created_at'] as String,
              color: classification == 'dangerous'
                  ? const Color(0xFFE31D2B)
                  : const Color(0xFFF07A00),
            );
          }),
      ],
    );
  }
}

class ReportMetric extends StatelessWidget {
  const ReportMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    super.key,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 125,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 29),
          const SizedBox(height: 7),
          LocalizedText(value,
              style: TextStyle(
                  color: color, fontSize: 26, fontWeight: FontWeight.w800)),
          FittedBox(
              child: LocalizedText(label,
                  style: const TextStyle(color: _muted, fontSize: 11))),
        ],
      ),
    );
  }
}

class ThreatTypeRow extends StatelessWidget {
  const ThreatTypeRow({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
    super.key,
  });
  final String label;
  final int value;
  final int total;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(
              child: LocalizedText(label, style: const TextStyle(color: _ink))),
          LocalizedText('$value (${(value / total * 100).round()}%)',
              style: const TextStyle(color: _muted)),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'ZAKARYA JAHIN';
  String _email = 'jahin.ahmed@email.com';
  int _totalScans = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ApiService.profile();
      if (!mounted) return;
      setState(() {
        _name = profile['name'] as String;
        _email = profile['email'] as String;
        _totalScans = profile['total_scans'] as int;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  LocalizedText('Could not load profile from the backend.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _editProfile() async {
    final name = TextEditingController(text: _name);
    final email = TextEditingController(text: _email);
    final save = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const LocalizedText('Account Information'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: InputDecoration(
                    labelText: AppLanguageController.translate('Full name')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    labelText:
                        AppLanguageController.translate('Email address')),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const LocalizedText('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const LocalizedText('Save'),
          ),
        ],
      ),
    );
    if (save != true ||
        name.text.trim().length < 2 ||
        !email.text.contains('@')) {
      return;
    }
    try {
      final profile = await ApiService.updateProfile(
        name: name.text.trim(),
        email: email.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _name = profile['name'] as String;
        _email = profile['email'] as String;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: LocalizedText('Profile saved to the database.')),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  LocalizedText('Could not save profile. Check the backend.')),
        );
      }
    }
  }

  Future<void> _exportData() async {
    try {
      final data = await ApiService.exportData();
      await Clipboard.setData(ClipboardData(text: data));
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const LocalizedText('Data Export Ready'),
          content: const LocalizedText(
            'Your profile, scan history, and community reports were exported as JSON and copied to the clipboard.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const LocalizedText('Done'),
            ),
          ],
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  LocalizedText('Could not export data. Check the backend.')),
        );
      }
    }
  }

  void _informationDialog(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: LocalizedText(title),
        content: LocalizedText(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const LocalizedText('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const accountItems = [
      (
        Icons.person_outline,
        'Account Information',
        'Update your personal information'
      ),
      (Icons.lock_outline, 'Security', 'Manage password and 2FA'),
      (
        Icons.notifications_none,
        'Notifications',
        'Customize alerts and updates'
      ),
      (
        Icons.verified_user_outlined,
        'Privacy Settings',
        'Manage your data and privacy'
      ),
      (Icons.credit_card, 'Payment Methods', 'Manage your payment options'),
      (
        Icons.download_outlined,
        'Export My Data',
        'Download scan history and reports'
      ),
    ];
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
                title: 'Profile',
                subtitle: 'Manage your account and preferences'),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                border: Border.all(color: _border),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: _editProfile,
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 45,
                          backgroundColor: Color(0xFFEDE6FF),
                          child: Icon(Icons.person, color: _purple, size: 54),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LocalizedText(_loading ? 'Loading...' : _name,
                                  style: const TextStyle(
                                      color: _ink,
                                      fontSize: 23,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 4),
                              LocalizedText(_email,
                                  style: const TextStyle(color: _muted)),
                              const SizedBox(height: 8),
                              const _PremiumPill(),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: _muted),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: _border),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const _ProfileStat(
                          value: 'May 2025', label: 'Member Since'),
                      _ProfileStat(value: '$_totalScans', label: 'Total Scans'),
                      const _ProfileStat(value: '3h 42m', label: 'Time Saved'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const InfoBanner(
              icon: Icons.workspace_premium_rounded,
              title: 'You’re using Premium',
              text: 'Thank you for supporting your online safety.',
            ),
            const SizedBox(height: 18),
            _SettingsGroup(
              items: accountItems,
              onTap: (index) {
                if (index == 0) _editProfile();
                if (index == 1) _open(context, const SettingsScreen());
                if (index == 2) _open(context, const NotificationsScreen());
                if (index == 3) _open(context, const SettingsScreen());
                if (index == 4) {
                  _informationDialog(
                    'Payment Methods',
                    'Billing is not activated yet. Connect a payment provider '
                        'such as Stripe using your own test and production keys '
                        'before accepting payments. No card data is stored locally.',
                  );
                }
                if (index == 5) _exportData();
              },
            ),
            const SizedBox(height: 20),
            const LocalizedText('Support & More',
                style: TextStyle(
                    color: _ink, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            _SettingsGroup(
              items: [
                (
                  Icons.help_outline,
                  'Help Center',
                  'Get help and find answers'
                ),
                (Icons.star_outline, 'Rate Us', 'Share your experience'),
                (Icons.info_outline, 'About Nirapod AI', 'Version 1.0.0'),
              ],
              onTap: (index) {
                if (index == 0) _open(context, const HelpCenterScreen());
                if (index == 1) {
                  _informationDialog(
                    'Thank you!',
                    'Your feedback helps improve Nirapod AI.',
                  );
                }
                if (index == 2) _open(context, const AboutAppScreen());
              },
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await ApiService.logout();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute<void>(
                        builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                },
                icon: const Icon(Icons.logout, color: Color(0xFFE31D2B)),
                label: const LocalizedText('Log Out',
                    style: TextStyle(color: Color(0xFFE31D2B))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFFB5B9)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumPill extends StatelessWidget {
  const _PremiumPill();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFECE5FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const LocalizedText('♛ Premium Member',
          style: TextStyle(
              color: _purple, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LocalizedText(value,
            style: const TextStyle(color: _ink, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        LocalizedText(label,
            style: const TextStyle(color: _muted, fontSize: 10)),
      ],
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.items, this.onTap});
  final List<(IconData, String, String)> items;
  final ValueChanged<int>? onTap;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return InkWell(
            onTap: () => onTap?.call(index),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: _border)),
              ),
              child: Row(
                children: [
                  _IconTile(icon: item.$1),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LocalizedText(item.$2,
                            style: const TextStyle(
                                color: _ink, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 3),
                        LocalizedText(item.$3,
                            style:
                                const TextStyle(color: _muted, fontSize: 11)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: _muted),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class LargeTrendChart extends StatelessWidget {
  const LargeTrendChart({required this.values, super.key});
  final List<double> values;
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: LargeTrendPainter(values), size: Size.infinite);
}

class LargeTrendPainter extends CustomPainter {
  LargeTrendPainter(this.values);
  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xFFEAE9F2)
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    if (values.isEmpty) return;
    final maximum = values.reduce(max).clamp(1, double.infinity);
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? size.width / 2
          : size.width * i / (values.length - 1);
      final point =
          Offset(x, size.height * (1 - values[i] / maximum) * .85 + 4);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawCircle(point, 4, Paint()..color = _purple);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = _purple
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant LargeTrendPainter oldDelegate) =>
      !listEquals(values, oldDelegate.values);
}

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage(
      {required this.title, required this.subtitle, super.key});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ShieldMark(size: 90),
            const SizedBox(height: 22),
            LocalizedText(title,
                style: const TextStyle(
                    color: _ink, fontSize: 30, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            LocalizedText(subtitle, style: const TextStyle(color: _muted)),
          ],
        ),
      ),
    );
  }
}

class MiniTrendChart extends StatelessWidget {
  const MiniTrendChart({required this.values, super.key});
  final List<double> values;
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: MiniTrendPainter(values), size: Size.infinite);
}

class MiniTrendPainter extends CustomPainter {
  MiniTrendPainter(this.values);
  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maximum = values.reduce(max).clamp(1, double.infinity);
    final points = List.generate(values.length, (index) {
      final x = values.length == 1
          ? size.width / 2
          : size.width * index / (values.length - 1);
      return Offset(x, size.height * (1 - values[index] / maximum) * .75 + 8);
    });
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFD3C9FF)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
    for (final point in points) {
      canvas.drawCircle(point, 3, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant MiniTrendPainter oldDelegate) =>
      !listEquals(values, oldDelegate.values);
}

class ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF9B65FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    const length = 48.0;
    const inset = 70.0;
    final corners = [
      Offset(inset, inset),
      Offset(size.width - inset, inset),
      Offset(inset, size.height - inset),
      Offset(size.width - inset, size.height - inset),
    ];
    for (var i = 0; i < corners.length; i++) {
      final c = corners[i];
      final sx = i.isEven ? 1.0 : -1.0;
      final sy = i < 2 ? 1.0 : -1.0;
      canvas.drawLine(c, Offset(c.dx + length * sx, c.dy), paint);
      canvas.drawLine(c, Offset(c.dx, c.dy + length * sy), paint);
    }
    canvas.drawLine(
      Offset(inset - 25, size.height / 2),
      Offset(size.width - inset + 25, size.height / 2),
      Paint()
        ..color = const Color(0xFF9B65FF)
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
