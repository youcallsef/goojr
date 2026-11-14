import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Package Name: com.goojr.app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  final prefs = await SharedPreferences.getInstance();
  final bool onboardingDone = prefs.getBool('onboarding_done') ?? false;
  runApp(GooJRApp(onboardingDone: onboardingDone));
}

class AppColors {
  static const Color pitchBlack = Color(0xFF070709);
  static const Color darkSlate = Color(0xFF141519);
  static const Color cardGray = Color(0xFF1E2028);
  static const Color silverGlow = Color(0xFFE2E6F0);
  static const Color silverMuted = Color(0xFF8E95A5);
  static const Color accentSilver = Color(0xFFB8C2D6);
}

class GooJRApp extends StatelessWidget {
  final bool onboardingDone;
  const GooJRApp({super.key, required this.onboardingDone});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GooJR Browser',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.pitchBlack,
        primaryColor: AppColors.silverGlow,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.silverGlow,
          secondary: AppColors.accentSilver,
          surface: AppColors.darkSlate,
        ),
      ),
      home: onboardingDone ? const BrowserMainScreen() : const OnboardingScreen(),
    );
  }
}

// ============================================================================
// 1. شاشة الترحيب (3 صفحات بالأسود والرصاصي المتدرج)
// ============================================================================
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<dynamic> _pages = [
    {
      'title': 'نواة GooJR المفتوحة',
      'subtitle':
          'متصفح هندسي صُمم ليكسر القيود. تحكم كامل في محرك العرض مع واجهة فضية فائقة السرعة.',
      'icon': Icons.terminal_rounded,
    },
    {
      'title': 'حقن السكريبتات والشبكة',
      'subtitle':
          'حقن فوري لأكواد JavaScript و CSS، اعتراض طلبات الشبكة، جلسات معزولة، وتحكم مباشر في الملفات.',
      'icon': Icons.code_rounded,
    },
    {
      'title': 'ذكاء اصطناعي مدمج',
      'subtitle':
          'مدعوم بنموذج gemini-3.5-flash-lite السحابي لتوليد الأكواد وتحليل الصفحات واستخراج البيانات لحظياً.',
      'icon': Icons.auto_awesome_rounded,
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const BrowserMainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.pitchBlack,
              AppColors.darkSlate,
              Color(0xFF232631),
              AppColors.pitchBlack,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              // شعار JR المتوهج
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.cardGray,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.silverGlow.withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.silverGlow.withOpacity(0.15),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Text(
                  'JR',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    color: AppColors.silverGlow,
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    final item = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2C303E), Color(0xFF121318)],
                              ),
                              border: Border.all(
                                color: AppColors.silverGlow.withOpacity(0.5),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.silverGlow.withOpacity(0.2),
                                  blurRadius: 25,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              item['icon'],
                              size: 48,
                              color: AppColors.silverGlow,
                            ),
                          ),
                          const SizedBox(height: 40),
                          Text(
                            item['title'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.silverGlow,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            item['subtitle'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: AppColors.silverMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // مؤشرات الصفحات وزر التالي / ابدأ
              Padding(
                padding: const EdgeInsets.all(28.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(
                        _pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.only(right: 8),
                          height: 8,
                          width: _currentPage == index ? 26 : 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? AppColors.silverGlow
                                : AppColors.silverMuted.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _completeOnboarding();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE2E6F0), Color(0xFF9AA3B5)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.silverGlow.withOpacity(0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1 ? 'ابدأ' : 'التالي',
                          style: const TextStyle(
                            color: AppColors.pitchBlack,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 2. نماذج البيانات وإدارة الحالة للمميزات الـ 21
// ============================================================================
class UserScript {
  String id;
  String name;
  String domainPattern;
  String jsCode;
  String cssCode;
  bool enabled;
  bool runAtStart;

  UserScript({
    required this.id,
    required this.name,
    required this.domainPattern,
    required this.jsCode,
    this.cssCode = '',
    this.enabled = true,
    this.runAtStart = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'domainPattern': domainPattern,
        'jsCode': jsCode,
        'cssCode': cssCode,
        'enabled': enabled,
        'runAtStart': runAtStart,
      };

  factory UserScript.fromJson(Map<String, dynamic> json) => UserScript(
        id: json['id'],
        name: json['name'],
        domainPattern: json['domainPattern'],
        jsCode: json['jsCode'],
        cssCode: json['cssCode'] ?? '',
        enabled: json['enabled'] ?? true,
        runAtStart: json['runAtStart'] ?? false,
      );
}

class BrowserTabModel {
  final String id;
  String title;
  String url;
  bool isIncognitoIsolated;
  InAppWebViewController? controller;

  BrowserTabModel({
    required this.id,
    this.title = 'GooJR Home',
    this.url = '',
    this.isIncognitoIsolated = false,
  });
}

// ============================================================================
// 3. الشاشة الرئيسية للمتصفح (GooJR Browser Core)
// ============================================================================
class BrowserMainScreen extends StatefulWidget {
  const BrowserMainScreen({super.key});

  @override
  State<BrowserMainScreen> createState() => _BrowserMainScreenState();
}

class _BrowserMainScreenState extends State<BrowserMainScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<BrowserTabModel> _tabs = [
    BrowserTabModel(id: 'tab_1', title: 'الرئيسية - JR'),
  ];
  int _activeTabIndex = 0;
  double _loadingProgress = 0.0;
  bool _isHomeView = true;

  // قائمة السكريبتات المحقونة
  List<UserScript> _scripts = [];

  // سجلات الشبكة (HAR / Request Logger)
  final List<String> _networkLogs = [];

  // مفاتيح التفعيل السريعة في قائمة الـ 3 نقاط والإعدادات الـ 21
  bool _scriptEngineEnabled = true;
  bool _networkInterceptorEnabled = true;
  bool _fingerprintSpoofing = false;
  bool _blockWebRTC = true;
  bool _autoClearCacheOnExit = false;
  bool _hardwareAcceleration = true;
  bool _bypassCors = false;
  bool _proxyVpnEnabled = false;
  bool _verticalTabsMode = false;
  bool _macroRecording = false;
  String _proxyAddress = '127.0.0.1:8080';
  String _customUserAgent = '';
  String _geminiApiKey = '';
  final String _geminiModel = 'gemini-3.5-flash-lite';

  @override
  void initState() {
    super.initState();
    _loadSettingsAndScripts();
  }

  Future<void> _loadSettingsAndScripts() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _geminiApiKey = prefs.getString('gemini_api_key') ?? '';
      _scriptEngineEnabled = prefs.getBool('script_engine') ?? true;
      _networkInterceptorEnabled = prefs.getBool('net_interceptor') ?? true;
      _fingerprintSpoofing = prefs.getBool('fp_spoof') ?? false;
      _proxyVpnEnabled = prefs.getBool('proxy_enabled') ?? false;
      _proxyAddress = prefs.getString('proxy_addr') ?? '127.0.0.1:8080';
      _customUserAgent = prefs.getString('custom_ua') ?? '';

      final savedScripts = prefs.getStringList('user_scripts') ?? [];
      if (savedScripts.isEmpty) {
        _scripts = [
          UserScript(
            id: '1',
            name: 'Dark Force & Clean DOM',
            domainPattern: '*',
            jsCode:
                "console.log('[GooJR] Script Engine Active on ' + window.location.hostname);",
            cssCode: '',
            enabled: true,
          ),
        ];
      } else {
        _scripts = savedScripts
            .map((e) => UserScript.fromJson(jsonDecode(e)))
            .toList();
      }
    });
  }

  Future<void> _saveScripts() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _scripts.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('user_scripts', encoded);
  }

  Future<void> _savePref(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) await prefs.setBool(key, value);
    if (value is String) await prefs.setString(key, value);
  }

  // تنفيذ البحث الفوري عبر جوجل أو فتح الرابط مباشرة
  void _navigateTo(String input) {
    String query = input.trim();
    if (query.isEmpty) return;

    String finalUrl;
    if (query.startsWith('http://') || query.startsWith('https://')) {
      finalUrl = query;
    } else if (query.contains('.') && !query.contains(' ')) {
      finalUrl = 'https://$query';
    } else {
      finalUrl =
          'https://www.google.com/search?q=${Uri.encodeComponent(query)}';
    }

    setState(() {
      _isHomeView = false;
      _tabs[_activeTabIndex].url = finalUrl;
      _searchController.text = finalUrl;
    });

    _tabs[_activeTabIndex].controller?.loadUrl(
          urlRequest: URLRequest(url: WebUri(finalUrl)),
        );
  }

  // حقن السكريبتات والـ CSS في الصفحة المفتوحة
  Future<void> _injectActiveScripts(
      InAppWebViewController controller, String currentUrl) async {
    if (!_scriptEngineEnabled) return;

    // 1. حقن طبقة تزييف البصمة الرقمية إذا كانت مفعلة
    if (_fingerprintSpoofing) {
      await controller.evaluateJavascript(source: """
        Object.defineProperty(navigator, 'hardwareConcurrency', {get: () => 4});
        Object.defineProperty(navigator, 'deviceMemory', {get: () => 8});
        console.log('[GooJR] Fingerprint Spoofing Applied');
      """);
    }

    // 2. حقن السكريبتات المخصصة للمستخدم
    for (final script in _scripts) {
      if (!script.enabled) continue;
      if (script.domainPattern == '*' ||
          currentUrl.contains(script.domainPattern)) {
        if (script.cssCode.trim().isNotEmpty) {
          final safeCss = script.cssCode.replaceAll("'", "\\'").replaceAll('\n', ' ');
          await controller.evaluateJavascript(source: """
            (function(){
              var style = document.createElement('style');
              style.innerHTML = '$safeCss';
              document.head.appendChild(style);
            })();
          """);
        }
        if (script.jsCode.trim().isNotEmpty) {
          await controller.evaluateJavascript(source: script.jsCode);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeTab = _tabs[_activeTabIndex];

    return Scaffold(
      backgroundColor: AppColors.pitchBlack,
      body: SafeArea(
        child: Column(
          children: [
            // ================================================================
            // الشريط العلوي: كبسولة Gemini + كبسولة السكريبتات والصور + 3 نقاط
            // ================================================================
            _buildTopActionBar(),

            // شريط التقدم العلوي عند التحميل (Progress Bar)
            if (_loadingProgress > 0 && _loadingProgress < 1.0)
              LinearProgressIndicator(
                value: _loadingProgress,
                minHeight: 2.5,
                backgroundColor: AppColors.pitchBlack,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.silverGlow),
              )
            else
              const SizedBox(height: 2.5),

            // ================================================================
            // منطقة العرض: الصفحة الرئيسية بشعار JR أو محرك التصفح الفوري
            // ================================================================
            Expanded(
              child: _isHomeView
                  ? _buildSilverHomeView()
                  : _buildWebViewEngine(activeTab),
            ),

            // ================================================================
            // شريط التنقل السفلي وإدارة التبويبات
            // ================================================================
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  // الشريط العلوي المدمج بالكبسولات وقائمة الثلاث نقاط
  Widget _buildTopActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.pitchBlack,
        border: Border(
          bottom: BorderSide(color: AppColors.silverGlow.withOpacity(0.12)),
        ),
      ),
      child: Row(
        children: [
          // 1. كبسولة التحدث مع نموذج gemini-3.5-flash-lite
          Expanded(
            flex: 4,
            child: GestureDetector(
              onTap: _openGeminiChatSheet,
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF232631), Color(0xFF141519)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: AppColors.silverGlow.withOpacity(0.45)),
                  boxShadow: [
     