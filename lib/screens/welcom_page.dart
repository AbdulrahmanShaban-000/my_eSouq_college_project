// lib/auth/screens/welcome_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:zad/controllers/theme_controller.dart';
import 'package:zad/home/screens/home_page.dart';
import 'package:zad/auth/screens/login_screen.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<double>> _staggeredAnimations;
  late final Animation<double> _logoPulseAnimation;
  late final Animation<double> _logoRotateAnimation;
  

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

  
    _logoPulseAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _logoRotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    
  
   
    _staggeredAnimations = List.generate(
      7,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            0.05 + (index * 0.07),
            0.5 + (index * 0.07),
            curve: Curves.easeOut,
          ),
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.isDark.value;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _buildBackground(
          context: context,
          theme: theme,
          isDark: isDark,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  _buildHeaderButtons(theme, themeController, isDark),
                  const Spacer(flex: 1),
                  _buildLogoSection(theme),
                  const SizedBox(height: 32),
                  _buildTitleSection(theme),
                  const SizedBox(height: 8),
                  _buildSubtitleSection(theme),
                  const SizedBox(height: 40),
                  _buildActionButtons(theme, isDark),
                  const Spacer(flex: 2),
                  _buildFooterSection(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  
  Widget _buildBackground({
    required BuildContext context,
    required ThemeData theme,
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(gradient: _buildBackgroundGradient(isDark)),
      child: Stack(
        children: [
        
          ..._buildBackgroundParticles(isDark),
         
          _buildGlassOverlay(isDark),
          child,
        ],
      ),
    );
  }

  
  LinearGradient _buildBackgroundGradient(bool isDark) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              const Color(0xFF0F2027),
              const Color(0xFF203A43),
              const Color(0xFF2C5364),
            ]
          : [
              const Color(0xFF667eea),
              const Color(0xFF764ba2),
              const Color(0xFFf093fb),
            ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  
  List<Widget> _buildBackgroundParticles(bool isDark) {
    final colors = isDark
        ? [
            Colors.white.withOpacity(0.03),
            Colors.white.withOpacity(0.02),
            Colors.white.withOpacity(0.015),
            Colors.white.withOpacity(0.01),
          ]
        : [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.05),
          ];

    return [
     
      Positioned(
        top: -80,
        right: -80,
        child: _buildParticle(
          size: 300,
          color: colors[0],
          duration: const Duration(seconds: 12),
          beginScale: 0.8,
          endScale: 1.2,
        ),
      ),
   
      Positioned(
        bottom: -60,
        left: -100,
        child: _buildParticle(
          size: 250,
          color: colors[1],
          duration: const Duration(seconds: 15),
          beginScale: 0.7,
          endScale: 1.3,
        ),
      ),
     
      Positioned(
        top: MediaQuery.of(context).size.height * 0.3,
        left: -50,
        child: _buildParticle(
          size: 180,
          color: colors[2],
          duration: const Duration(seconds: 18),
          beginScale: 0.9,
          endScale: 1.4,
        ),
      ),
     
      Positioned(
        bottom: MediaQuery.of(context).size.height * 0.2,
        right: -30,
        child: _buildParticle(
          size: 120,
          color: colors[3],
          duration: const Duration(seconds: 20),
          beginScale: 0.6,
          endScale: 1.5,
        ),
      ),
    ];
  }

  Widget _buildParticle({
    required double size,
    required Color color,
    required Duration duration,
    required double beginScale,
    required double endScale,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: beginScale, end: endScale),
      duration: duration,
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        );
      },
    );
  }

 
  Widget _buildGlassOverlay(bool isDark) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                isDark
                    ? const Color(0xFF0F2027).withOpacity(0.2)
                    : Colors.white.withOpacity(0.1),
                isDark
                    ? const Color(0xFF0F2027).withOpacity(0.4)
                    : Colors.white.withOpacity(0.2),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderButtons(
    ThemeData theme,
    ThemeController themeController,
    bool isDark,
  ) {
    return FadeTransition(
      opacity: _staggeredAnimations[0],
      child: Align(
        alignment: Alignment.topRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildGlassButton(
              icon: Icons.language_outlined,
              onPressed: () {
                final newLang = Get.locale?.languageCode == 'en' ? 'ar' : 'en';
                Get.updateLocale(Locale(newLang));
                HapticFeedback.lightImpact();
              },
              tooltip: 'change_language'.tr,
              theme: theme,
              isDark: isDark,
            ),
            const SizedBox(width: 12),
            Obx(
              () => _buildGlassButton(
                icon: themeController.isDark.value
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
                onPressed: () {
                  themeController.switchTheme();
                  HapticFeedback.mediumImpact();
                },
                tooltip: themeController.isDark.value
                    ? 'Dark Mode'
                    : 'Light Mode',
                theme: theme,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ]
                  : [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.1),
                    ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: isDark ? Colors.white : Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }


  Widget _buildLogoSection(ThemeData theme) {
    return FadeTransition(
      opacity: _staggeredAnimations[1],
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(_staggeredAnimations[1]),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _logoPulseAnimation.value,
              child: Transform.rotate(
                angle: _logoRotateAnimation.value,
                child: child,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 60,
                  spreadRadius: 10,
                  offset: const Offset(0, 0),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildTitleSection(ThemeData theme) {
    return FadeTransition(
      opacity: _staggeredAnimations[2],
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_staggeredAnimations[2]),
        child: Column(
          children: [
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.white.withOpacity(0.7)],
                ).createShader(bounds);
              },
              child: Text(
                'welcome_back'.tr,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.6),
                    Colors.white.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitleSection(ThemeData theme) {
    return FadeTransition(
      opacity: _staggeredAnimations[3],
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_staggeredAnimations[3]),
        child: Text(
          'app_description'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withOpacity(0.7),
            height: 1.6,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }


  Widget _buildActionButtons(ThemeData theme, bool isDark) {
    return Column(
      children: [
        _buildAnimatedButton(
          index: 4,
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () =>
                  _navigateWithHaptic(() => Get.offAll(() => const HomePage())),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                shadowColor: Colors.white.withOpacity(0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 22,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'browse_products'.tr,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildAnimatedButton(
          index: 5,
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () =>
                  _navigateWithHaptic(() => Get.to(() => const LoginScreen())),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: Colors.white.withOpacity(0.5),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: Colors.white.withOpacity(0.05),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    size: 22,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'sign_in'.tr,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildAnimatedButton({required int index, required Widget child}) {
    return FadeTransition(
      opacity: _staggeredAnimations[index],
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.5),
          end: Offset.zero,
        ).animate(_staggeredAnimations[index]),
        child: child,
      ),
    );
  }
  void _navigateWithHaptic(VoidCallback navigate) {
    HapticFeedback.selectionClick();
    Future.delayed(const Duration(milliseconds: 150), navigate);
  }

  Widget _buildFooterSection(ThemeData theme) {
    return FadeTransition(
      opacity: _staggeredAnimations[6],
      child: Column(
        children: [
          Divider(
            height: 1,
            color: Colors.white.withOpacity(0.1),
            thickness: 0.5,
          ),
          const SizedBox(height: 16),
          Text(
            "© 2026 All Rights Reserved",
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 0.5,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 6),
          _buildAnimatedFooterText(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAnimatedFooterText() {
    const text = "Made with ❤️";
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 2),
      builder: (context, double value, child) {
        final int charCount = (text.length * value).round();
        return Text(
          text.substring(0, charCount),
          style: const TextStyle(
            fontSize: 12,
            letterSpacing: 0.5,
            color: Colors.white38,
          ),
        );
      },
    );
  }
}
