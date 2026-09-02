import 'package:flutter/material.dart';
import '../widgets/localized_text.dart';
import '../services/api_service.dart';
import '../services/native_android_service.dart';
import '../services/theme_controller.dart';
import '../services/language_controller.dart';

const _ink = Color(0xFF080B28);
const _muted = Color(0xFF595C7A);
const _purple = Color(0xFF5420E6);
const _border = Color(0xFFE7E6F1);
const _gradient = LinearGradient(
  colors: [Color(0xFF6E24F4), Color(0xFF4C20DA)],
);

void _open(BuildContext context, Widget page) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _accepted = false;
  bool _hidden = true;
  bool _submitting = false;
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_name.text.trim().length < 2 ||
        !_email.text.contains('@') ||
        _password.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: LocalizedText(
              'Enter your name, a valid email, and at least 8 password characters.'),
        ),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await ApiService.register(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: LocalizedText('Account created. You can now sign in.')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 14, 26, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: _purple, size: 30),
              ),
              const SizedBox(height: 22),
              const Center(
                child: Column(
                  children: [
                    _BrandIcon(size: 84),
                    SizedBox(height: 18),
                    LocalizedText(
                      'Create Account',
                      style: TextStyle(
                          color: _ink,
                          fontSize: 31,
                          fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 8),
                    LocalizedText(
                      'Join Nirapod AI and stay protected online.',
                      style: TextStyle(color: _muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 35),
              _LabeledField(
                label: 'Full Name',
                hint: 'Enter your full name',
                icon: Icons.person_outline,
                controller: _name,
              ),
              const SizedBox(height: 18),
              _LabeledField(
                label: 'Email Address',
                hint: 'Enter your email',
                icon: Icons.mail_outline,
                controller: _email,
              ),
              const SizedBox(height: 18),
              _LabeledField(
                label: 'Password',
                hint: 'Create a strong password',
                icon: Icons.lock_outline,
                obscure: _hidden,
                controller: _password,
                suffix: IconButton(
                  onPressed: () => setState(() => _hidden = !_hidden),
                  icon: Icon(_hidden
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                ),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _accepted,
                onChanged: (value) =>
                    setState(() => _accepted = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                title: Text.rich(
                  TextSpan(
                    style: const TextStyle(color: _muted, fontSize: 13),
                    children: [
                      TextSpan(
                        text:
                            AppLanguageController.translate('I agree to the '),
                      ),
                      TextSpan(
                          text: AppLanguageController.translate(
                              'Terms of Service'),
                          style: const TextStyle(color: _purple)),
                      TextSpan(
                        text: AppLanguageController.translate(
                          ' and Privacy Policy.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _GradientButton(
                label: _submitting ? 'Creating Account...' : 'Create Account',
                onTap: _accepted && !_submitting ? _register : null,
              ),
              const SizedBox(height: 25),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const LocalizedText('Already have an account? Log in'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  final _token = TextEditingController();
  final _password = TextEditingController();
  bool _requestSent = false;
  bool _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    _token.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _requestReset() async {
    if (!_email.text.contains('@')) {
      _message('Enter a valid email address.');
      return;
    }
    setState(() => _submitting = true);
    try {
      final message = await ApiService.requestPasswordReset(_email.text);
      if (!mounted) return;
      setState(() => _requestSent = true);
      _message(message);
    } catch (error) {
      if (mounted) {
        _message(error.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _confirmReset() async {
    if (_token.text.trim().length < 20 || _password.text.length < 8) {
      _message('Enter the reset token and at least 8 password characters.');
      return;
    }
    setState(() => _submitting = true);
    try {
      final message = await ApiService.confirmPasswordReset(
        token: _token.text,
        newPassword: _password.text,
      );
      if (!mounted) return;
      _message(message);
      Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        _message(error.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: LocalizedText(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 14, 26, 30),
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
                      'Forgot Password',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: _ink,
                          fontSize: 23,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  const _BrandIcon(size: 40),
                ],
              ),
              const SizedBox(height: 75),
              Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                    color: Color(0xFFF0E9FF), shape: BoxShape.circle),
                child: const Icon(Icons.lock_reset_rounded,
                    color: _purple, size: 85),
              ),
              const SizedBox(height: 30),
              const LocalizedText(
                'Enter your email address and we’ll send you a link to reset your password.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted, height: 1.5),
              ),
              const SizedBox(height: 30),
              _LabeledField(
                label: 'Email Address',
                hint: 'youremail@example.com',
                icon: Icons.mail_outline,
                controller: _email,
              ),
              const SizedBox(height: 24),
              _GradientButton(
                label: _submitting ? 'Please wait...' : 'Send Reset Link',
                onTap: _submitting ? null : _requestReset,
              ),
              if (_requestSent) ...[
                const SizedBox(height: 24),
                _LabeledField(
                  label: 'Reset Token',
                  hint: 'Paste the token from your email',
                  icon: Icons.password_rounded,
                  controller: _token,
                ),
                const SizedBox(height: 18),
                _LabeledField(
                  label: 'New Password',
                  hint: 'At least 8 characters',
                  icon: Icons.lock_outline,
                  obscure: true,
                  controller: _password,
                ),
                const SizedBox(height: 24),
                _GradientButton(
                  label: _submitting ? 'Please wait...' : 'Reset Password',
                  onTap: _submitting ? null : _confirmReset,
                ),
              ],
              const SizedBox(height: 16),
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const LocalizedText('Back to Login')),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _loading = true;
  bool _saving = false;
  late final Map<String, bool> _values = {
    'Auto Scan Links': false,
    'Scan Notifications': true,
    'Wi-Fi Scan Warning': true,
    'Save Scan History': true,
    'Cloud Protection': true,
    'Dark Mode': AppThemeController.isDark,
  };
  String _defaultBrowser = 'in_app';
  String _appLockMode = 'off';
  String _threatUpdates = 'automatic';
  String _textSize = 'medium';
  String _accentColor = 'purple';
  String _language = AppLanguageController.language.value;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final settings = await ApiService.settings();
      if (!mounted) return;
      setState(() {
        _values['Auto Scan Links'] = settings['auto_scan_links'] as bool;
        _values['Scan Notifications'] = settings['scan_notifications'] as bool;
        _values['Wi-Fi Scan Warning'] = settings['wifi_scan_warning'] as bool;
        _values['Save Scan History'] = settings['save_scan_history'] as bool;
        _values['Cloud Protection'] = settings['cloud_protection'] as bool;
        _values['Dark Mode'] = settings['dark_mode'] as bool;
        _defaultBrowser = settings['default_browser'] as String;
        _appLockMode = settings['app_lock_mode'] as String;
        _threatUpdates = settings['threat_updates'] as String;
        _textSize = settings['text_size'] as String;
        _accentColor = settings['accent_color'] as String;
        _language = (settings['language'] as String?) ?? 'en';
      });
      await AppThemeController.setDarkMode(_values['Dark Mode']!);
      await AppThemeController.setTextSize(_textSize);
      await AppThemeController.setAccentColor(_accentColor);
      await AppLanguageController.setLanguage(_language);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  LocalizedText('Could not load settings from the server.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Map<String, dynamic> get _payload => {
        'auto_scan_links': _values['Auto Scan Links'],
        'scan_notifications': _values['Scan Notifications'],
        'wifi_scan_warning': _values['Wi-Fi Scan Warning'],
        'default_browser': _defaultBrowser,
        'save_scan_history': _values['Save Scan History'],
        'app_lock_mode': _appLockMode,
        'threat_updates': _threatUpdates,
        'cloud_protection': _values['Cloud Protection'],
        'dark_mode': _values['Dark Mode'],
        'text_size': _textSize,
        'accent_color': _accentColor,
        'language': _language,
      };

  String _t(String key) => AppLanguageController.text(key);

  Future<void> _chooseLanguage() async {
    await _choose(
      title: _t('choose_language'),
      options: const [
        ('en', 'English'),
        ('ms', 'Bahasa Melayu'),
        ('bn', 'বাংলা'),
      ],
      selected: _language,
      onSelected: (value) {
        _language = value;
        AppLanguageController.setLanguage(value);
      },
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: LocalizedText(_t('language_saved'))),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ApiService.updateSettings(_payload);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: LocalizedText(
                  'Setting could not be saved. Check the backend.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _choose({
    required String title,
    required List<(String, String)> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) async {
    final value = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: LocalizedText(title),
        children: [
          RadioGroup<String>(
            groupValue: selected,
            onChanged: (value) => Navigator.pop(context, value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options
                  .map(
                    (option) => RadioListTile<String>(
                      value: option.$1,
                      title: LocalizedText(option.$2),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
    if (value == null) return;
    setState(() => onSelected(value));
    await _save();
  }

  Future<void> _chooseAppLock() async {
    final previous = _appLockMode;
    await _choose(
      title: 'App lock',
      options: const [
        ('off', 'Off'),
        ('pin', 'Device PIN'),
        ('biometric', 'Face or fingerprint'),
      ],
      selected: _appLockMode,
      onSelected: (value) => _appLockMode = value,
    );
    if (_appLockMode == 'off' || _appLockMode == previous) return;
    if (!NativeAndroidService.isSupported) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: LocalizedText(
                'App lock is tested on an Android phone or emulator.'),
          ),
        );
      }
      return;
    }
    try {
      final verified = await NativeAndroidService.authenticate();
      if (!verified && mounted) setState(() => _appLockMode = previous);
    } catch (error) {
      if (!mounted) return;
      setState(() => _appLockMode = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: LocalizedText('Authentication was not completed: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Page(
      title: _t('settings'),
      subtitle: _t('settings_subtitle'),
      child: _loading
          ? const Center(
              child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator()))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Section(
                  title: _t('scan_preferences'),
                  children: [
                    _toggle('Auto Scan Links', Icons.shield_outlined,
                        'Automatically scan links shared to Nirapod'),
                    _toggle('Scan Notifications', Icons.notifications_none,
                        'Get notified about scan results'),
                    _toggle('Wi-Fi Scan Warning', Icons.wifi,
                        'Warn about unsecured Wi-Fi'),
                    _MenuRow(
                      icon: Icons.public,
                      title: 'Default Browser',
                      subtitle: 'Choose where verified links open',
                      trailing:
                          _defaultBrowser == 'in_app' ? 'In App' : 'System',
                      onTap: () => _choose(
                        title: 'Default browser',
                        options: const [
                          ('in_app', 'In-app browser'),
                          ('system', 'System browser')
                        ],
                        selected: _defaultBrowser,
                        onSelected: (value) => _defaultBrowser = value,
                      ),
                    ),
                    _toggle('Save Scan History', Icons.history,
                        'Keep a record on this device'),
                  ],
                ),
                const SizedBox(height: 18),
                _Section(
                  title: _t('security'),
                  children: [
                    _MenuRow(
                      icon: Icons.lock_outline,
                      title: 'App Lock',
                      subtitle:
                          'Biometrics require a supported Android or iOS device',
                      trailing: _appLockMode == 'off'
                          ? 'Off'
                          : _appLockMode == 'pin'
                              ? 'PIN'
                              : 'Biometric',
                      onTap: _chooseAppLock,
                    ),
                    _MenuRow(
                      icon: Icons.security,
                      title: 'Threat Intelligence Updates',
                      subtitle: 'Choose how threat information is refreshed',
                      trailing: _threatUpdates == 'automatic'
                          ? 'Automatic'
                          : 'Manual',
                      onTap: () => _choose(
                        title: 'Threat intelligence updates',
                        options: const [
                          ('automatic', 'Automatic'),
                          ('manual', 'Manual')
                        ],
                        selected: _threatUpdates,
                        onSelected: (value) => _threatUpdates = value,
                      ),
                    ),
                    _toggle('Cloud Protection', Icons.cloud_outlined,
                        'Enable real-time cloud scanning'),
                    _MenuRow(
                      icon: Icons.android,
                      title: 'Android Protection Tools',
                      subtitle:
                          'Biometrics, notifications, nearby devices and protection service',
                      trailing: NativeAndroidService.isSupported
                          ? 'Available'
                          : 'Android only',
                      onTap: () =>
                          _open(context, const NativeProtectionScreen()),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _Section(
                  title: _t('appearance'),
                  children: [
                    _MenuRow(
                      icon: Icons.language_rounded,
                      title: _t('language'),
                      subtitle: _t('language_subtitle'),
                      trailing: AppLanguageController.nativeName,
                      onTap: _chooseLanguage,
                    ),
                    _toggle('Dark Mode', Icons.dark_mode_outlined,
                        'Use dark theme throughout the app'),
                    _MenuRow(
                      icon: Icons.text_fields,
                      title: 'Text Size',
                      subtitle: 'Saved to your account',
                      trailing:
                          _textSize[0].toUpperCase() + _textSize.substring(1),
                      onTap: () => _choose(
                        title: 'Text size',
                        options: const [
                          ('small', 'Small'),
                          ('medium', 'Medium'),
                          ('large', 'Large')
                        ],
                        selected: _textSize,
                        onSelected: (value) {
                          _textSize = value;
                          AppThemeController.setTextSize(value);
                        },
                      ),
                    ),
                    _MenuRow(
                      icon: Icons.palette_outlined,
                      title: 'Accent Color',
                      subtitle: 'Saved to your account',
                      trailing: _accentColor[0].toUpperCase() +
                          _accentColor.substring(1),
                      onTap: () => _choose(
                        title: 'Accent color',
                        options: const [
                          ('purple', 'Purple'),
                          ('blue', 'Blue'),
                          ('green', 'Green')
                        ],
                        selected: _accentColor,
                        onSelected: (value) {
                          _accentColor = value;
                          AppThemeController.setAccentColor(value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (_saving) const LinearProgressIndicator(),
                _Notice(
                  icon: Icons.verified_user_outlined,
                  title: _t('safety_matters'),
                  text: _t('safety_text'),
                ),
              ],
            ),
    );
  }

  Widget _toggle(String title, IconData icon, String subtitle) {
    return _MenuRow(
      icon: icon,
      title: title,
      subtitle: subtitle,
      switchValue: _values[title],
      onSwitch: _saving
          ? null
          : (value) async {
              setState(() => _values[title] = value);
              if (title == 'Dark Mode') {
                await AppThemeController.setDarkMode(value);
              }
              if (title == 'Auto Scan Links' &&
                  NativeAndroidService.isSupported) {
                if (value) {
                  await NativeAndroidService.startProtection();
                } else {
                  await NativeAndroidService.stopProtection();
                }
              }
              await _save();
            },
    );
  }
}

class NativeProtectionScreen extends StatefulWidget {
  const NativeProtectionScreen({super.key});

  @override
  State<NativeProtectionScreen> createState() => _NativeProtectionScreenState();
}

class _NativeProtectionScreenState extends State<NativeProtectionScreen> {
  bool _busy = false;
  String _status = 'Choose a tool below. Scans only run when you request them.';
  List<Map<String, dynamic>> _results = [];

  Future<void> _run(
    String working,
    Future<void> Function() action,
  ) async {
    if (!NativeAndroidService.isSupported) {
      setState(() => _status =
          'Open this project on an Android phone or emulator from Android Studio.');
      return;
    }
    setState(() {
      _busy = true;
      _status = working;
      _results = [];
    });
    try {
      await action();
    } catch (error) {
      setState(() => _status = 'Could not complete the action: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Page(
      title: 'Android Protection Tools',
      subtitle: 'Native security features for your Android device',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Notice(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy first',
            text:
                'Nearby scans are user-initiated and should only be used on networks and places where you have permission.',
          ),
          const SizedBox(height: 18),
          _Section(
            title: 'Device Protection',
            children: [
              _MenuRow(
                icon: Icons.fingerprint,
                title: 'Test biometric unlock',
                subtitle:
                    'Use enrolled fingerprint, face, or device credential',
                onTap: () => _run('Waiting for authentication…', () async {
                  final ok = await NativeAndroidService.authenticate();
                  setState(() => _status = ok
                      ? 'Identity verified successfully.'
                      : 'Identity was not verified.');
                }),
              ),
              _MenuRow(
                icon: Icons.shield_outlined,
                title: 'Start foreground protection',
                subtitle:
                    'Keeps a visible Android protection notification active',
                onTap: () => _run('Starting protection…', () async {
                  await NativeAndroidService.startProtection();
                  setState(() => _status = 'Foreground protection is active.');
                }),
              ),
              _MenuRow(
                icon: Icons.notifications_active_outlined,
                title: 'Send test security alert',
                subtitle: 'Verifies Android notification delivery',
                onTap: () => _run('Sending alert…', () async {
                  await NativeAndroidService.showNotification(
                    title: 'Nirapod AI security test',
                    body: 'Android notifications are working correctly.',
                  );
                  setState(() => _status = 'Test notification sent.');
                }),
              ),
              _MenuRow(
                icon: Icons.content_paste_go_outlined,
                title: 'Read copied text',
                subtitle: 'Reads the clipboard only after you tap this option',
                onTap: () => _run('Reading clipboard…', () async {
                  final text = await NativeAndroidService.getClipboardText();
                  setState(() => _status = text?.isNotEmpty == true
                      ? 'Copied text: $text'
                      : 'No plain text is currently copied.');
                }),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _Section(
            title: 'Authorized Nearby Checks',
            children: [
              _MenuRow(
                icon: Icons.wifi_find,
                title: 'Discover devices on this Wi-Fi',
                subtitle:
                    'Checks common web and camera-service ports on your local network',
                onTap: () => _run('Checking the local network…', () async {
                  final wifi = await NativeAndroidService.currentWifiInfo();
                  final findings =
                      await NativeAndroidService.scanLocalNetwork();
                  final assessment = await ApiService.wifiSafetyCheck(
                    wifi: wifi,
                    networkFindings: findings,
                  );
                  setState(() {
                    _results = [
                      {
                        'name': wifi['ssid'] ?? 'Unknown Wi-Fi',
                        'security': wifi['security'] ?? 'Unknown',
                        'safety': assessment.classification.toUpperCase(),
                        'risk score': '${assessment.riskScore}/100',
                        'signal': '${wifi['rssi'] ?? 'Unknown'} dBm',
                      },
                      ...findings,
                    ];
                    _status = assessment.classification == 'safe'
                        ? 'This Wi-Fi uses recognized encryption. Continue using HTTPS and only trust networks you know.'
                        : assessment.classification == 'dangerous'
                            ? 'This Wi-Fi is not safely encrypted. Avoid passwords, banking, and sensitive activity.'
                            : 'Wi-Fi protection could not be confirmed. Review the network before sensitive activity.';
                  });
                }),
              ),
              _MenuRow(
                icon: Icons.bluetooth_searching,
                title: 'Discover nearby Bluetooth devices',
                subtitle:
                    'Shows BLE devices broadcasting nearby for manual review',
                onTap: () =>
                    _run('Listening for nearby Bluetooth devices…', () async {
                  final findings =
                      await NativeAndroidService.scanNearbyBluetooth();
                  setState(() {
                    _results = findings;
                    _status = findings.isEmpty
                        ? 'No Bluetooth Low Energy broadcasts were detected.'
                        : '${findings.length} nearby Bluetooth device(s) found.';
                  });
                }),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (_busy) const LinearProgressIndicator(),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LocalizedText('Status',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  LocalizedText(_status),
                  if (_results.isNotEmpty) ...[
                    const Divider(height: 28),
                    ..._results.map((item) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading:
                              const Icon(Icons.devices_other, color: _purple),
                          title: LocalizedText(
                            (item['name'] ?? item['ip'] ?? 'Nearby device')
                                .toString(),
                          ),
                          subtitle: LocalizedText(item.entries
                              .where((entry) => entry.key != 'name')
                              .map((entry) => '${entry.key}: ${entry.value}')
                              .join(' • ')),
                        )),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const LocalizedText(
            'Important: ordinary phone cameras cannot reliably detect thermal or infrared cameras. Network and Bluetooth discovery are supporting checks, not proof that a location is camera-free.',
            style: TextStyle(color: _muted, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _entries = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final entries = await ApiService.notifications();
      if (mounted) setState(() => _entries = entries);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: LocalizedText('Could not load notifications.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAllRead() async {
    await ApiService.markAllNotificationsRead();
    await _load();
  }

  Future<void> _openNotification(Map<String, dynamic> item) async {
    if ((item['is_read'] as int) == 0) {
      await ApiService.markNotificationRead(item['id'] as int);
      await _load();
    }
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: LocalizedText(item['title'] as String),
        content: LocalizedText(item['message'] as String),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const LocalizedText('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _Page(
      title: 'Notifications',
      trailing: TextButton(
        onPressed: _entries.any((item) => (item['is_read'] as int) == 0)
            ? _markAllRead
            : null,
        child: const LocalizedText('Mark all as read'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(35),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_entries.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(35),
                child: LocalizedText(
                    'No notifications yet. New scan results will appear here.'),
              ),
            )
          else
            ..._entries.map((item) => _notificationCard(item)),
        ],
      ),
    );
  }

  Widget _notificationCard(Map<String, dynamic> item) {
    final type = item['notification_type'] as String;
    final (icon, color) = switch (type) {
      'dangerous' => (Icons.gpp_bad_rounded, const Color(0xFFE31D2B)),
      'suspicious' => (Icons.warning_rounded, const Color(0xFFF07A00)),
      'safe' => (Icons.verified_user, const Color(0xFF14944C)),
      _ => (Icons.notifications_active, _purple),
    };
    final unread = (item['is_read'] as int) == 0;
    return InkWell(
      onTap: () => _openNotification(item),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: unread ? const Color(0xFFFCFAFF) : Colors.white,
          border: Border.all(color: _border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: .1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LocalizedText(
                    item['title'] as String,
                    style: TextStyle(
                      color: _ink,
                      fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LocalizedText(
                    item['message'] as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                LocalizedText(
                  item['created_at'] as String,
                  style: const TextStyle(color: _muted, fontSize: 10),
                ),
                if (unread)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: CircleAvatar(radius: 4, backgroundColor: _purple),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CommunityReportsScreen extends StatelessWidget {
  const CommunityReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _Page(
      title: 'Community Reports',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
                gradient: _gradient, borderRadius: BorderRadius.circular(17)),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LocalizedText('Together We Stay Safe',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                SizedBox(height: 7),
                LocalizedText('See the latest scams reported by our community.',
                    style: TextStyle(color: Color(0xFFE3DCFF))),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const LocalizedText('Trending Now',
              style: TextStyle(
                  color: _ink, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          const _CommunityTile(
              rank: '1',
              title: 'fake-bank-login.com',
              type: 'Phishing Website',
              reports: '152 reports',
              color: Color(0xFFE31D2B)),
          const _CommunityTile(
              rank: '2',
              title: 'Win iPhone 15 Now! 🎉',
              type: 'Scam SMS',
              reports: '98 reports',
              color: Color(0xFFF07A00)),
          const _CommunityTile(
              rank: '3',
              title: 'Fake QR – Parking Scam',
              type: 'QR Code',
              reports: '74 reports',
              color: _purple),
          const SizedBox(height: 18),
          _GradientButton(
              label: 'Report a Scam',
              onTap: () => _open(context, const ReportScamScreen())),
          const SizedBox(height: 24),
          const LocalizedText('Recently Reported',
              style: TextStyle(
                  color: _ink, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          const _CommunityTile(
              rank: '•',
              title: 'secure-pay-update.net',
              type: 'Phishing Website',
              reports: '34m ago',
              color: Color(0xFFE31D2B)),
        ],
      ),
    );
  }
}

class ReportScamScreen extends StatefulWidget {
  const ReportScamScreen({super.key});

  @override
  State<ReportScamScreen> createState() => _ReportScamScreenState();
}

class _ReportScamScreenState extends State<ReportScamScreen> {
  int _type = 0;
  bool _submitted = false;
  bool _submitting = false;
  final _content = TextEditingController();
  final _details = TextEditingController();

  @override
  void dispose() {
    _content.dispose();
    _details.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_content.text.trim().length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: LocalizedText('Enter the scam URL or content first.')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      const labels = ['website', 'message', 'qr_code', 'other'];
      await ApiService.submitReport(
        type: labels[_type],
        content: _content.text.trim(),
        details: _details.text.trim(),
      );
      if (mounted) setState(() => _submitted = true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: LocalizedText(
                  'Could not submit. Check the backend connection.')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const types = [
      (Icons.language, 'Website'),
      (Icons.message, 'Message'),
      (Icons.qr_code_2, 'QR Code'),
      (Icons.add_circle_outline, 'Other'),
    ];
    return _Page(
      title: 'Report a Scam',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LocalizedText('What are you reporting?',
              style: TextStyle(color: _ink, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              types.length,
              (index) => Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.only(right: index == types.length - 1 ? 0 : 8),
                  child: InkWell(
                    onTap: () => setState(() => _type = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: index == _type
                            ? const Color(0xFFEEE8FF)
                            : Colors.white,
                        border: Border.all(
                            color: index == _type ? _purple : _border),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Column(
                        children: [
                          Icon(types[index].$1,
                              color: index == _type ? _purple : _muted),
                          const SizedBox(height: 6),
                          FittedBox(
                              child: LocalizedText(types[index].$2,
                                  style: const TextStyle(fontSize: 11))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _LabeledField(
            label: 'URL or Website',
            hint: 'https://example-scam.com',
            icon: Icons.link,
            controller: _content,
          ),
          const SizedBox(height: 18),
          const LocalizedText('Additional Information',
              style: TextStyle(color: _ink, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(
            controller: _details,
            maxLines: 6,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: AppLanguageController.translate(
                  'Tell us more about this scam...'),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 18),
          _GradientButton(
            label: _submitted
                ? 'Report Submitted'
                : _submitting
                    ? 'Submitting...'
                    : 'Submit Report',
            onTap: _submitted || _submitting ? null : _submit,
          ),
          const SizedBox(height: 16),
          const _Notice(
            icon: Icons.verified_user,
            title: 'Thank you',
            text: 'Your report helps keep our community safe.',
          ),
        ],
      ),
    );
  }
}

class LearningCentreScreen extends StatefulWidget {
  const LearningCentreScreen({super.key});

  @override
  State<LearningCentreScreen> createState() => _LearningCentreScreenState();
}

class _LearningCentreScreenState extends State<LearningCentreScreen> {
  int _category = 0;

  Future<void> _openArticle(String title) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final matches = await ApiService.helpArticles(query: title);
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      final article = matches.cast<Map<String, dynamic>?>().firstWhere(
            (item) => item?['title'] == title,
            orElse: () => matches.isEmpty ? null : matches.first,
          );
      if (article == null) throw Exception('Article not found');
      _open(
        context,
        LearningArticleScreen(
          title: article['title'] as String,
          summary: article['summary'] as String,
          content: article['content'] as String,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: LocalizedText(
            'The article could not be loaded. Check the backend connection.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const categories = [
      'All',
      'Phishing',
      'Messages',
      'QR Codes',
      'Room Privacy',
    ];
    const articles = [
      (
        Icons.shield_outlined,
        'What is Phishing?',
        'Learn how phishing attacks work and how to stay safe.',
        'Phishing',
      ),
      (
        Icons.web_asset,
        'How to Identify Fake Websites',
        'Tips to spot fake websites and protect your information.',
        'Phishing',
      ),
      (
        Icons.qr_code_2,
        'QR Code Scams',
        'How scammers use QR codes and how to avoid them.',
        'QR Codes',
      ),
      (
        Icons.phone_android,
        'OTP and Banking Scams',
        'Protect yourself from OTP and banking fraud.',
        'Messages',
      ),
      (
        Icons.videocam_outlined,
        'Hidden Camera Safety',
        'Learn realistic phone-assisted checks and their limitations.',
        'Room Privacy',
      ),
    ];
    return _Page(
      title: 'Learning Centre',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LocalizedText('Categories',
              style: TextStyle(color: _ink, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                categories.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    selected: _category == index,
                    label: LocalizedText(categories[index]),
                    onSelected: (_) => setState(() => _category = index),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const LocalizedText('Popular Articles',
              style: TextStyle(
                  color: _ink, fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          ...articles
              .where(
                (article) =>
                    _category == 0 || article.$4 == categories[_category],
              )
              .map(
                (article) => InkWell(
                  onTap: () => _openArticle(article.$2),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      border: Border.all(color: _border),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFFEEE8FF),
                          child: Icon(article.$1, color: _purple),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LocalizedText(
                                article.$2,
                                style: const TextStyle(
                                  color: _ink,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              LocalizedText(
                                article.$3,
                                style: const TextStyle(
                                  color: _muted,
                                  fontSize: 12,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: _muted),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class LearningArticleScreen extends StatelessWidget {
  const LearningArticleScreen({
    required this.title,
    required this.summary,
    required this.content,
    super.key,
  });

  final String title;
  final String summary;
  final String content;

  @override
  Widget build(BuildContext context) {
    return _Page(
      title: title,
      subtitle: summary,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F3FF),
          border: Border.all(color: _border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.menu_book_rounded, color: _purple, size: 38),
            const SizedBox(height: 16),
            LocalizedText(
              content,
              style: const TextStyle(color: _ink, height: 1.65, fontSize: 15),
            ),
            const SizedBox(height: 20),
            const _Notice(
              icon: Icons.verified_user_outlined,
              title: 'Remember',
              text:
                  'When unsure, stop and verify through an official website, application, or phone number.',
            ),
          ],
        ),
      ),
    );
  }
}

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final _search = TextEditingController();
  String _category = 'all';
  bool _loading = true;
  List<Map<String, dynamic>> _articles = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await ApiService.helpArticles(
        query: _search.text.trim(),
        category: _category,
      );
      if (mounted) setState(() => _articles = items);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: LocalizedText(
                  'Could not load help articles. Check the backend.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showArticle(Map<String, dynamic> article) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: LocalizedText(article['title'] as String),
        content: SingleChildScrollView(
          child: LocalizedText(
            article['content'] as String,
            style: const TextStyle(height: 1.55),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const LocalizedText('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _contactSupport() async {
    final subject = TextEditingController();
    final message = TextEditingController();
    final submit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const LocalizedText('Contact Support'),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subject,
                decoration: InputDecoration(
                    labelText: AppLanguageController.translate('Subject')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: message,
                minLines: 4,
                maxLines: 7,
                decoration: InputDecoration(
                  labelText:
                      AppLanguageController.translate('Describe the problem'),
                  alignLabelWithHint: true,
                ),
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
            child: const LocalizedText('Submit'),
          ),
        ],
      ),
    );
    if (submit != true) return;
    if (subject.text.trim().length < 3 || message.text.trim().length < 10) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: LocalizedText('Add a subject and a detailed message.')),
        );
      }
      return;
    }
    try {
      final id = await ApiService.submitSupportTicket(
        subject: subject.text.trim(),
        message: message.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                LocalizedText('Support ticket #$id was saved successfully.')),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  LocalizedText('Sign in and check the backend connection.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Page(
      title: 'Help Center',
      subtitle: 'Find answers and get the help you need',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _search,
            onSubmitted: (_) => _load(),
            decoration: InputDecoration(
              hintText: AppLanguageController.translate(
                  'Search for help articles...'),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                onPressed: _load,
                icon: const Icon(Icons.arrow_forward),
              ),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 22),
          const LocalizedText('Popular Topics',
              style: TextStyle(
                  color: _ink, fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _categoryChip('all', 'All', Icons.menu_book),
              _categoryChip('getting_started', 'Getting Started', Icons.shield),
              _categoryChip('security', 'Security', Icons.lock),
              _categoryChip('scanning', 'Scanning', Icons.qr_code_scanner),
            ],
          ),
          const SizedBox(height: 24),
          const LocalizedText('Help Articles',
              style: TextStyle(
                  color: _ink, fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          if (_loading)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(30),
                    child: CircularProgressIndicator()))
          else if (_articles.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                  child:
                      LocalizedText('No matching help articles were found.')),
            )
          else
            ..._articles.map(
              (article) => ListTile(
                onTap: () => _showArticle(article),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.menu_book_outlined, color: _purple),
                title: LocalizedText(
                  article['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: LocalizedText(article['summary'] as String),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _contactSupport,
              icon: const Icon(Icons.support_agent),
              label: const LocalizedText('Contact Support'),
            ),
          ),
          const SizedBox(height: 18),
          const _Notice(
            icon: Icons.fingerprint,
            title: 'About the fingerprint symbol',
            text:
                'It represents identifying a threat’s digital fingerprint. Nirapod AI does not collect your biometric fingerprint.',
          ),
          const SizedBox(height: 18),
          const _Notice(
            icon: Icons.lightbulb_outline,
            title: 'Safety Tip',
            text:
                'When in doubt, don’t click! Scan first and stay safe online.',
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(String value, String label, IconData icon) {
    return ChoiceChip(
      avatar: Icon(icon, size: 18),
      label: LocalizedText(label),
      selected: _category == value,
      onSelected: (_) {
        setState(() => _category = value);
        _load();
      },
    );
  }
}

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _Page(
      title: 'About Nirapod AI',
      child: Column(
        children: [
          const SizedBox(height: 30),
          const _BrandIcon(size: 125),
          const SizedBox(height: 22),
          const LocalizedText('Nirapod AI',
              style: TextStyle(
                  color: _ink, fontSize: 27, fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          const LocalizedText('AI-Powered Cybersecurity',
              style: TextStyle(color: _muted)),
          const LocalizedText('Version 1.0.0', style: TextStyle(color: _muted)),
          const SizedBox(height: 35),
          const _Section(
            children: [
              _MenuRow(
                  icon: Icons.code,
                  title: 'Developed By',
                  subtitle: 'ZAKARYA JAHIN'),
              _MenuRow(
                  icon: Icons.school_outlined,
                  title: 'University',
                  subtitle: 'UNIVERSITY OF CYBERJAYA'),
              _MenuRow(
                  icon: Icons.person_outline,
                  title: 'Supervisor',
                  subtitle: 'YUDI BUDI SUSILO'),
              _MenuRow(
                  icon: Icons.favorite_outline,
                  title: 'Acknowledgements',
                  subtitle: 'Open-source contributors'),
            ],
          ),
          const SizedBox(height: 35),
          const LocalizedText('© 2026 Nirapod AI. All rights reserved.',
              style: TextStyle(color: _muted, fontSize: 12)),
        ],
      ),
    );
  }
}

class EmptyHistoryScreen extends StatelessWidget {
  const EmptyHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) => const _StateScreen(
        icon: Icons.inventory_2_outlined,
        title: 'No scans yet!',
        text: 'Start scanning to see your history here.',
        button: 'Start Scanning',
      );
}

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});
  @override
  Widget build(BuildContext context) => const _StateScreen(
        icon: Icons.wifi_off_rounded,
        title: 'Oops! It looks like you’re offline.',
        text: 'Please check your internet connection and try again.',
        button: 'Retry',
      );
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});
  @override
  Widget build(BuildContext context) => const _StateScreen(
        icon: Icons.error_outline_rounded,
        title: 'We’re having trouble',
        text: 'We could not process your request. Please try again.',
        button: 'Try Again',
      );
}

class _Page extends StatelessWidget {
  const _Page({
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
  });
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
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
                        const Icon(Icons.arrow_back, color: _purple, size: 29),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        LocalizedText(title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: _ink,
                                fontSize: 25,
                                fontWeight: FontWeight.w800)),
                        if (subtitle != null) ...[
                          const SizedBox(height: 5),
                          LocalizedText(subtitle!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: _muted)),
                        ],
                      ],
                    ),
                  ),
                  trailing ?? const SizedBox(width: 42),
                ],
              ),
              const SizedBox(height: 25),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.controller,
  });
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextEditingController? controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LocalizedText(label,
            style: const TextStyle(color: _ink, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: _purple),
            suffixIcon: suffix,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _border),
            ),
          ),
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: onTap == null ? null : _gradient,
        color: onTap == null ? const Color(0xFFCFCDDA) : null,
        borderRadius: BorderRadius.circular(13),
      ),
      child: TextButton(
        onPressed: onTap,
        child: LocalizedText(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.children, this.title});
  final String? title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          LocalizedText(title!,
              style: const TextStyle(
                  color: _ink, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 9),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
              border: Border.all(color: _border),
              borderRadius: BorderRadius.circular(15)),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.switchValue,
    this.onSwitch,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailing;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitch;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: switchValue == null ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: _border))),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                  color: const Color(0xFFF0EAFF),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: _purple),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LocalizedText(title,
                      style: const TextStyle(
                          color: _ink, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  LocalizedText(subtitle,
                      style: const TextStyle(color: _muted, fontSize: 11)),
                ],
              ),
            ),
            if (switchValue != null)
              Switch(value: switchValue!, onChanged: onSwitch)
            else ...[
              if (trailing != null)
                LocalizedText(trailing!,
                    style: const TextStyle(color: _purple, fontSize: 11)),
              const Icon(Icons.chevron_right, color: _muted),
            ],
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.title, required this.text});
  final IconData icon;
  final String title;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFFF5F1FF),
          borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          CircleAvatar(
              backgroundColor: const Color(0xFFE6DCFF),
              child: Icon(icon, color: _purple)),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LocalizedText(title,
                    style: const TextStyle(
                        color: _purple, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                LocalizedText(text,
                    style: const TextStyle(color: _muted, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandIcon extends StatelessWidget {
  const _BrandIcon({required this.size});
  final double size;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          gradient: _gradient, borderRadius: BorderRadius.circular(size * .3)),
      child: Icon(Icons.fingerprint_rounded,
          color: Colors.white, size: size * .58),
    );
  }
}

class _CommunityTile extends StatelessWidget {
  const _CommunityTile({
    required this.rank,
    required this.title,
    required this.type,
    required this.reports,
    required this.color,
  });
  final String rank;
  final String title;
  final String type;
  final String reports;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: _border))),
      child: Row(
        children: [
          SizedBox(
              width: 25,
              child: LocalizedText(rank,
                  style: const TextStyle(
                      color: _ink, fontWeight: FontWeight.w800))),
          CircleAvatar(
              backgroundColor: color.withValues(alpha: .1),
              child: Icon(Icons.warning_rounded, color: color)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LocalizedText(title,
                    style: const TextStyle(
                        color: _ink, fontWeight: FontWeight.w700)),
                LocalizedText(type,
                    style: const TextStyle(color: _muted, fontSize: 11)),
              ],
            ),
          ),
          LocalizedText(reports,
              style: const TextStyle(color: _muted, fontSize: 10)),
        ],
      ),
    );
  }
}

class _StateScreen extends StatelessWidget {
  const _StateScreen({
    required this.icon,
    required this.title,
    required this.text,
    required this.button,
  });
  final IconData icon;
  final String title;
  final String text;
  final String button;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 155,
                height: 155,
                decoration: const BoxDecoration(
                    color: Color(0xFFF0EAFF), shape: BoxShape.circle),
                child: Icon(icon, color: _purple, size: 85),
              ),
              const SizedBox(height: 30),
              LocalizedText(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: _ink, fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              LocalizedText(text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _muted, height: 1.5)),
              const SizedBox(height: 30),
              _GradientButton(
                  label: button, onTap: () => Navigator.maybePop(context)),
              const SizedBox(height: 10),
              TextButton(
                  onPressed: () => Navigator.maybePop(context),
                  child: const LocalizedText('Go Home')),
            ],
          ),
        ),
      ),
    );
  }
}
