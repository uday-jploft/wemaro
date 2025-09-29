import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _featuresController;
  late AnimationController _fadeController;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _featuresSlide;
  late Animation<double> _featuresFade;

  int _currentFeatureIndex = 0;
  final List<FeatureData> _features = [
    FeatureData(
      icon: Icons.hd,
      title: 'HD Quality',
      description: 'Crystal clear video calls',
      color: Color(0xFFE91E63),
    ),
    FeatureData(
      icon: Icons.security,
      title: 'Secure',
      description: 'End-to-end encrypted',
      color: Color(0xFF4CAF50),
    ),
    FeatureData(
      icon: Icons.speed,
      title: 'Fast Connect',
      description: 'Quick peer connection',
      color: Color(0xFFFF9800),
    ),
    FeatureData(
      icon: Icons.devices,
      title: 'Cross Platform',
      description: 'Works on all devices',
      color: Color(0xFF2196F3),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Features animations
    _featuresController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _featuresSlide = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _featuresController, curve: Curves.easeOutCubic),
    );

    _featuresFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _featuresController, curve: Curves.easeIn),
    );

    // Fade out controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  void _startAnimationSequence() async {
    // Start logo animation
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    // Wait for logo animation to complete
    await Future.delayed(const Duration(milliseconds: 1500));

    // Start cycling through features
    _cycleFeatures();
  }

  void _cycleFeatures() {
    Timer.periodic(const Duration(milliseconds: 2000), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _currentFeatureIndex = (_currentFeatureIndex + 1) % _features.length;
      });

      _featuresController.reset();
      _featuresController.forward();

      // After showing all features, navigate
      if (_currentFeatureIndex == 0 && timer.tick > 1) {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 1500), () {
          _navigateToNextScreen();
        });
      }
    });

    _featuresController.forward();
  }

  void _navigateToNextScreen() async {
    await _fadeController.forward();
    if (mounted) {
      // This callback will be passed from main.dart
      Navigator.of(context).pushReplacementNamed('/auth_check');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _featuresController.dispose();
    _fadeController.dispose();
    super.dispose();
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
              Color(0xFF1976D2),
              Color(0xFF2196F3),
              Color(0xFF42A5F5),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_fadeController),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Logo Section
                _buildLogoSection(),

                const SizedBox(height: 60),

                // Features Section
                _buildFeaturesSection(),

                const Spacer(flex: 2),

                // Loading Indicator
                _buildLoadingIndicator(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScale.value,
          child: Opacity(
            opacity: _logoFade.value,
            child: Column(
              children: [
                // App Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.video_call,
                    size: 60,
                    color: Color(0xFF2196F3),
                  ),
                ),

                const SizedBox(height: 24),

                // App Name
                const Text(
                  'Flutter WebRTC',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 8),

                // Tagline
                Text(
                  'Connect Anywhere, Anytime',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturesSection() {
    return AnimatedBuilder(
      animation: _featuresController,
      builder: (context, child) {
        final feature = _features[_currentFeatureIndex];
        return Transform.translate(
          offset: Offset(0, _featuresSlide.value),
          child: Opacity(
            opacity: _featuresFade.value,
            child: Container(
              height: 180,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Feature Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      feature.icon,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Feature Title
                  Text(
                    feature.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Feature Description
                  Text(
                    feature.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _features.length,
                (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentFeatureIndex == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentFeatureIndex == index
                    ? Colors.white
                    : Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),

        const SizedBox(height: 30),

        // Loading spinner
        const SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ],
    );
  }
}

class FeatureData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  FeatureData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}