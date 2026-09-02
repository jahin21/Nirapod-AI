import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'widgets/localized_text.dart';
import 'screens/core_screens.dart';
import 'services/native_android_service.dart';
import 'services/theme_controller.dart';
import 'services/language_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppThemeController.initialize();
  await AppLanguageController.initialize();
  await NativeAndroidService.initialize();
  runApp(const NirapodApp());
}

class NirapodApp extends StatelessWidget {
  const NirapodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        AppThemeController.mode,
        AppThemeController.appearanceRevision,
        AppLanguageController.language,
      ]),
      builder: (context, _) {
        final mode = AppThemeController.mode.value;
        final baseTheme = ThemeData(
          useMaterial3: true,
          fontFamily: 'Arial',
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppThemeController.accent,
          ),
        );
        return MaterialApp(
          title: 'Nirapod AI',
          debugShowCheckedModeBanner: false,
          locale: AppLanguageController.locale,
          supportedLocales: AppLanguageController.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          theme: baseTheme,
          darkTheme: baseTheme,
          themeMode: mode,
          builder: (context, child) {
            if (child == null) return const SizedBox.shrink();
            Widget themedChild = MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(AppThemeController.textScale),
              ),
              child: child,
            );
            if (mode != ThemeMode.dark) return themedChild;
            return ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                0.574,
                -1.430,
                -0.144,
                0,
                255,
                -0.426,
                -0.430,
                -0.144,
                0,
                255,
                -0.426,
                -1.430,
                0.856,
                0,
                255,
                0,
                0,
                0,
                1,
                0,
              ]),
              child: themedChild,
            );
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final PageController _pages;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _fade = const AlwaysStoppedAnimation<double>(1);
    _pages = PageController();
  }

  @override
  void dispose() {
    _pages.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _continue() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: const LoginScreen(),
        ),
      ),
    );
  }

  void _openLogin() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
    );
  }

  void _next() {
    if (_page == 3) {
      _continue();
      return;
    }
    _pages.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    const slides = [
      _WelcomeSlideData(
        icon: Icons.security_rounded,
        title: 'Nirapod AI',
        tagline: 'Detect. Analyze. Protect.',
        description:
            'AI-powered protection against phishing attacks, malicious links, and scam attempts.',
      ),
      _WelcomeSlideData(
        icon: Icons.link_rounded,
        title: 'Check Before You Click',
        tagline: 'Safer links in seconds.',
        description:
            'Paste any website address and receive a clear safety rating before opening it or sharing personal information.',
      ),
      _WelcomeSlideData(
        icon: Icons.qr_code_scanner_rounded,
        title: 'Scan Hidden QR Links',
        tagline: 'See where every code leads.',
        description:
            'Reveal the destination inside a QR code and check it for phishing indicators before visiting the website.',
      ),
      _WelcomeSlideData(
        icon: Icons.message_rounded,
        title: 'Understand Scam Messages',
        tagline: 'Warnings you can understand.',
        description:
            'Analyze suspicious SMS, email, and chat messages. Nirapod AI explains the warning signs and recommends what to do next.',
      ),
    ];
    return Scaffold(
      backgroundColor: const Color(0xFF020319),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.28),
                radius: 0.8,
                colors: [Color(0xFF121143), Color(0xFF020319)],
              ),
            ),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) => CustomPaint(
                painter: CircuitWavePainter(progress: _controller.value),
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxHeight < 700;
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          compact ? 20 : 32,
                          8,
                          compact ? 20 : 32,
                          16,
                        ),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _openLogin,
                                child: const LocalizedText(
                                  'Skip',
                                  style: TextStyle(
                                    color: Color(0xFFB9ADFF),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: PageView.builder(
                                controller: _pages,
                                itemCount: slides.length,
                                onPageChanged: (value) =>
                                    setState(() => _page = value),
                                itemBuilder: (_, index) => _WelcomeSlide(
                                  data: slides[index],
                                  compact: compact,
                                ),
                              ),
                            ),
                            PageDots(active: _page, dark: true),
                            SizedBox(height: compact ? 12 : 22),
                            GradientButton(
                              label: _page == slides.length - 1
                                  ? 'Get Started'
                                  : 'Next',
                              onPressed: _next,
                            ),
                            SizedBox(height: compact ? 10 : 18),
                            LoginPrompt(onTap: _openLogin, dark: true),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeSlideData {
  const _WelcomeSlideData({
    required this.icon,
    required this.title,
    required this.tagline,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String tagline;
  final String description;
}

class _WelcomeSlide extends StatelessWidget {
  const _WelcomeSlide({
    required this.data,
    required this.compact,
  });

  final _WelcomeSlideData data;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.only(top: compact ? 0 : 20, bottom: 18),
        child: Column(
          children: [
            if (data.icon == Icons.security_rounded)
              NirapodLogo(size: compact ? 135 : 190, glow: true)
            else
              Container(
                width: compact ? 135 : 190,
                height: compact ? 135 : 190,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x554D29D7), Color(0x111D155B)],
                  ),
                ),
                child: Icon(
                  data.icon,
                  size: compact ? 75 : 105,
                  color: const Color(0xFF7A4DFF),
                ),
              ),
            SizedBox(height: compact ? 12 : 28),
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: _titleShader,
              child: LocalizedText(
                data.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 32 : 42,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
            ),
            const SizedBox(height: 10),
            LocalizedText(
              data.tagline,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFFC8C7E0),
                fontSize: compact ? 17 : 20,
              ),
            ),
            SizedBox(height: compact ? 14 : 23),
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C2AE8), Color(0xFF10B981)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: compact ? 14 : 23),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: LocalizedText(
                data.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFFAAAAC8),
                  fontSize: compact ? 14 : 16,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pages = PageController();
  int _page = 0;

  static const _slides = [
    (
      'Smart Protection',
      'Against Phishing',
      'Detect suspicious links, QR codes, and scam messages before it is too late.',
      Icons.security_rounded,
      'AI-powered detection|Clear risk results|Simple explanations',
    ),
    (
      'Check Every',
      'Website Link',
      'Paste a website address and let Nirapod inspect its structure and warning signs.',
      Icons.link_rounded,
      'Real ML analysis|Risk score from 0 to 100|Database scan history',
    ),
    (
      'Reveal Hidden',
      'QR Destinations',
      'Use your camera to read QR codes and verify their destination before opening them.',
      Icons.qr_code_scanner_rounded,
      'Live camera scanning|Automatic URL checking|Warnings before opening',
    ),
    (
      'Protect Your',
      'Messages & Inbox',
      'Analyze SMS, email, and chat content for social-engineering and credential theft.',
      Icons.mark_chat_unread_rounded,
      'Scam language detection|Actionable safety advice|Community reporting',
    ),
  ];

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _login() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
    );
  }

  void _next() {
    if (_page == _slides.length - 1) {
      _login();
    } else {
      _pages.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 760;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(26, 8, 26, 18),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                            onPressed: _login,
                            child: const LocalizedText('Skip')),
                      ),
                      Expanded(
                        child: PageView.builder(
                          controller: _pages,
                          itemCount: _slides.length,
                          onPageChanged: (value) =>
                              setState(() => _page = value),
                          itemBuilder: (_, index) {
                            final slide = _slides[index];
                            final features = slide.$5.split('|');
                            return SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LocalizedText(
                                    slide.$1,
                                    style: TextStyle(
                                      color: const Color(0xFF080B28),
                                      fontSize: compact ? 28 : 34,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  ShaderMask(
                                    blendMode: BlendMode.srcIn,
                                    shaderCallback: _titleShader,
                                    child: LocalizedText(
                                      slide.$2,
                                      style: TextStyle(
                                        fontSize: compact ? 28 : 34,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  LocalizedText(
                                    slide.$3,
                                    style: const TextStyle(
                                      color: Color(0xFF4B4D6D),
                                      fontSize: 16,
                                      height: 1.45,
                                    ),
                                  ),
                                  SizedBox(height: compact ? 12 : 20),
                                  Center(
                                    child: Container(
                                      width: compact ? 145 : 205,
                                      height: compact ? 145 : 205,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            Color(0xFFE1D8FF),
                                            Color(0x22FFFFFF)
                                          ],
                                        ),
                                      ),
                                      child: Icon(
                                        slide.$4,
                                        color: const Color(0xFF6327E9),
                                        size: compact ? 76 : 105,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ...features.asMap().entries.map(
                                        (entry) => FeatureRow(
                                          icon: const [
                                            Icons.verified_user_rounded,
                                            Icons.insights_rounded,
                                            Icons.tips_and_updates_rounded,
                                          ][entry.key],
                                          title: entry.value,
                                          description: switch (index) {
                                            0 => const [
                                                'Machine learning evaluates links and messages.',
                                                'See Safe, Suspicious, or Dangerous results.',
                                                'Understand why content was flagged.',
                                              ][entry.key],
                                            1 => const [
                                                'A trained URL model calculates phishing risk.',
                                                'Review confidence and risk scores.',
                                                'Completed scans are saved automatically.',
                                              ][entry.key],
                                            2 => const [
                                                'Point the camera at a QR code.',
                                                'Decoded links go directly to ML analysis.',
                                                'Decide safely before visiting a website.',
                                              ][entry.key],
                                            _ => const [
                                                'Detect common social-engineering patterns.',
                                                'Learn what not to click or share.',
                                                'Help others by reporting new scams.',
                                              ][entry.key],
                                          },
                                          divider:
                                              entry.key != features.length - 1,
                                        ),
                                      ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      PageDots(active: _page),
                      const SizedBox(height: 16),
                      GradientButton(
                        label: _page == _slides.length - 1
                            ? 'Continue to Login'
                            : 'Next',
                        onPressed: _next,
                      ),
                      const SizedBox(height: 12),
                      LoginPrompt(onTap: _login),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class LegacyOnboardingScreen extends StatelessWidget {
  const LegacyOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void openLogin() {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 760;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(30, 12, 30, 24),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: constraints.maxHeight - 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: openLogin,
                        child: const LocalizedText(
                          'Skip',
                          style: TextStyle(
                            color: Color(0xFF5923EF),
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: compact ? 4 : 16),
                    const LocalizedText(
                      'Smart Protection',
                      style: TextStyle(
                        color: Color(0xFF080B28),
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: _titleShader,
                      child: LocalizedText(
                        'Against Phishing',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const LocalizedText(
                      'Nirapod AI helps you detect malicious\nlinks, QR codes, and scam messages\nbefore it’s too late.',
                      style: TextStyle(
                        color: Color(0xFF4B4D6D),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: compact ? 12 : 24),
                    Center(
                      child: SizedBox(
                        height: compact ? 220 : 265,
                        width: 340,
                        child: const ProtectionHero(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const FeatureRow(
                      icon: Icons.verified_user_rounded,
                      title: 'AI-Powered Detection',
                      description:
                          'Advanced AI identifies phishing links,\nfake websites, and risky messages.',
                    ),
                    const FeatureRow(
                      icon: Icons.qr_code_2_rounded,
                      title: 'QR Code Safety',
                      description:
                          'Scan QR codes safely and verify\nwhere they lead.',
                    ),
                    const FeatureRow(
                      icon: Icons.message_rounded,
                      title: 'Message Scanner',
                      description:
                          'Analyze SMS, email, and chat messages\nfor suspicious content.',
                    ),
                    const FeatureRow(
                      icon: Icons.pie_chart_rounded,
                      title: 'Detailed Reports',
                      description:
                          'Get risk scores and clear explanations\nfor every scan.',
                      divider: false,
                    ),
                    const SizedBox(height: 16),
                    const Center(child: PageDots(active: 0)),
                    const SizedBox(height: 24),
                    GradientButton(label: 'Next', onPressed: openLogin),
                    const SizedBox(height: 18),
                    Center(child: LoginPrompt(onTap: openLogin)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

Shader _titleShader(Rect bounds) => const LinearGradient(
      colors: [Color(0xFF7527F0), Color(0xFF10B981)],
    ).createShader(bounds);

class GradientButton extends StatelessWidget {
  const GradientButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7D1FFF), Color(0xFF10B981)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33712BFF),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: SizedBox(
        height: 64,
        width: double.infinity,
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              LocalizedText(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 22),
                  child: Icon(Icons.arrow_forward_rounded, size: 30),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginPrompt extends StatelessWidget {
  const LoginPrompt({
    required this.onTap,
    this.dark = false,
    super.key,
  });

  final VoidCallback onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: AppLanguageController.translate(
                'Already have an account? ',
              ),
            ),
            TextSpan(
              text: AppLanguageController.translate('Log in'),
              style: const TextStyle(
                color: Color(0xFF6A25F4),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        style: TextStyle(
          color: dark ? const Color(0xFFB8B7CB) : const Color(0xFF888BA3),
          fontSize: 16,
        ),
      ),
    );
  }
}

class PageDots extends StatelessWidget {
  const PageDots({
    required this.active,
    this.dark = false,
    super.key,
  });

  final int active;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        4,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          width: index == active ? 26 : 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: index == active
                ? const Color(0xFF6B25F3)
                : dark
                    ? const Color(0xFF343657)
                    : const Color(0xFFE1E1EA),
          ),
        ),
      ),
    );
  }
}

class FeatureRow extends StatelessWidget {
  const FeatureRow({
    required this.icon,
    required this.title,
    required this.description,
    this.divider = true,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: divider
            ? const Border(bottom: BorderSide(color: Color(0xFFE8E8F0)))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EAFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF6425EA), size: 27),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LocalizedText(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF090B27),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                LocalizedText(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF555874),
                    fontSize: 13.5,
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

class ProtectionHero extends StatelessWidget {
  const ProtectionHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 270,
          height: 210,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [Color(0xFFE4DAFF), Color(0x22EDE8FF)],
            ),
          ),
        ),
        Container(
          width: 128,
          height: 220,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF312170), Color(0xFF17123D)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF0B0C20), width: 6),
            boxShadow: const [
              BoxShadow(color: Color(0x44290B72), blurRadius: 25),
            ],
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NirapodLogo(size: 72),
              SizedBox(height: 15),
              LocalizedText(
                'Nirapod AI',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const Positioned(
          left: 10,
          top: 26,
          child:
              _FloatingCard(icon: Icons.link_rounded, color: Color(0xFF6330F3)),
        ),
        const Positioned(
          right: 6,
          top: 40,
          child:
              _FloatingCard(icon: Icons.mail_rounded, color: Color(0xFF7134F4)),
        ),
        const Positioned(
          left: 6,
          bottom: 22,
          child: _FloatingCard(icon: Icons.qr_code_2_rounded, light: true),
        ),
        const Positioned(
          right: 0,
          bottom: 8,
          child: _FloatingCard(
            icon: Icons.warning_rounded,
            color: Color(0xFFFF513F),
          ),
        ),
      ],
    );
  }
}

class _FloatingCard extends StatelessWidget {
  const _FloatingCard({
    required this.icon,
    this.color = const Color(0xFF6731EF),
    this.light = false,
  });

  final IconData icon;
  final Color color;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: light ? -.08 : .08,
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          color: light ? Colors.white : color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
                color: Color(0x33271866), blurRadius: 16, offset: Offset(0, 7)),
          ],
        ),
        child: Icon(
          icon,
          size: 36,
          color: light ? const Color(0xFF6327E9) : Colors.white,
        ),
      ),
    );
  }
}

class NirapodLogo extends StatelessWidget {
  const NirapodLogo({
    required this.size,
    this.glow = false,
    super.key,
  });

  final double size;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: LogoPainter(glow: glow),
    );
  }
}

class LogoPainter extends CustomPainter {
  const LogoPainter({required this.glow});

  final bool glow;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final gradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFE142FF), Color(0xFF7335FF), Color(0xFF168CFF)],
    ).createShader(rect);
    final shield = Path()
      ..moveTo(size.width * .5, size.height * .05)
      ..quadraticBezierTo(size.width * .7, size.height * .22, size.width * .9,
          size.height * .25)
      ..lineTo(size.width * .87, size.height * .58)
      ..quadraticBezierTo(size.width * .78, size.height * .81, size.width * .5,
          size.height * .94)
      ..quadraticBezierTo(size.width * .22, size.height * .81, size.width * .13,
          size.height * .58)
      ..lineTo(size.width * .1, size.height * .25)
      ..quadraticBezierTo(size.width * .3, size.height * .22, size.width * .5,
          size.height * .05);
    if (glow) {
      canvas.drawPath(
        shield,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * .08
          ..color = const Color(0x556127FF)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * .08),
      );
    }
    canvas.drawPath(
      shield,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * .07
        ..strokeJoin = StrokeJoin.round
        ..shader = gradient,
    );
    final center = Offset(size.width * .5, size.height * .48);
    for (var i = 0; i < 4; i++) {
      final r = size.width * (.09 + i * .055);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        3.55,
        4.25,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * .025
          ..strokeCap = StrokeCap.round
          ..shader = gradient,
      );
    }
    final lensCenter = Offset(size.width * .62, size.height * .6);
    canvas.drawCircle(
      lensCenter,
      size.width * .145,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * .065
        ..shader = gradient,
    );
    canvas.drawLine(
      Offset(size.width * .72, size.height * .71),
      Offset(size.width * .84, size.height * .84),
      Paint()
        ..strokeWidth = size.width * .08
        ..strokeCap = StrokeCap.round
        ..shader = gradient,
    );
  }

  @override
  bool shouldRepaint(covariant LogoPainter oldDelegate) =>
      oldDelegate.glow != glow;
}

class CircuitWavePainter extends CustomPainter {
  const CircuitWavePainter({this.progress = 0});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final circuitPaint = Paint()
      ..color = const Color(0x55381AA8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (var i = 0; i < 12; i++) {
      final x = size.width * i / 11;
      final pulse = 9 * ((progress + i * .08) % 1);
      final startY = size.height * (.55 + (i % 3) * .035) - pulse;
      final path = Path()
        ..moveTo(x, size.height * .82)
        ..lineTo(x, startY + 55)
        ..lineTo(x + (i.isEven ? 18 : -18), startY + 37)
        ..lineTo(x + (i.isEven ? 18 : -18), startY);
      canvas.drawPath(path, circuitPaint);
      canvas.drawCircle(
        Offset(x + (i.isEven ? 18 : -18), startY),
        3.5,
        Paint()..color = const Color(0x993D18BD),
      );
    }
    final dotPaint = Paint()..color = const Color(0xAA5325F5);
    for (var row = 0; row < 28; row++) {
      final y = size.height * .67 + row * 7.0;
      for (var col = 0; col < 40; col++) {
        final x = col * size.width / 39;
        final wave = 18 *
            (1 + .35 * row / 28) *
            (col % 12 < 6 ? col % 6 / 6 : (6 - col % 6) / 6);
        final drift = 8 * ((progress + col / 40) % 1);
        canvas.drawCircle(Offset(x, y + wave - drift), 1.1, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CircuitWavePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
