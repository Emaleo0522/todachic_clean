import 'package:flutter/material.dart';
import '../widgets/todachic_logo.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _logoOpacity;

  @override
  void initState() {
    super.initState();
    
    // Controlador para fade in/out general
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Controlador para escala del logo
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Animación de fade in/out de la pantalla completa
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    // Animación de escala del logo
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Animación de opacidad del logo
    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    // Fade in de la pantalla
    await _fadeController.forward();
    
    // Pequeña pausa antes del logo
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Animación del logo
    await _scaleController.forward();
    
    // Mantener visible por un momento
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Fade out suave
    await _fadeController.reverse();
    
    // Callback para mostrar el dashboard
    widget.onComplete();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Scaffold(
            backgroundColor: colorScheme.primary,
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary,
                    colorScheme.secondary.withOpacity(0.9),
                    colorScheme.tertiary.withOpacity(0.8),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Efectos de fondo
                  _buildBackgroundEffects(colorScheme),
                  
                  // Contenido principal
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo animado
                        AnimatedBuilder(
                          animation: _scaleController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Opacity(
                                opacity: _logoOpacity.value,
                                child: Column(
                                  children: [
                                    // Logo principal
                                    TODAChicLogo(
                                      fontSize: 48,
                                      color: Colors.white,
                                      showButterflies: true,
                                      isLight: true,
                                    ),
                                    const SizedBox(height: 24),
                                    
                                    // Subtitle con animación
                                    FadeTransition(
                                      opacity: _logoOpacity,
                                      child: Text(
                                        'Gestión de Tienda',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.w300,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 48),
                                    
                                    // Loading indicator sutil
                                    SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white.withOpacity(0.7),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
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

  Widget _buildBackgroundEffects(ColorScheme colorScheme) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _scaleController,
        builder: (context, child) {
          return CustomPaint(
            painter: _BackgroundEffectsPainter(
              animationValue: _scaleController.value,
              primaryColor: colorScheme.primary,
              secondaryColor: colorScheme.secondary,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _BackgroundEffectsPainter extends CustomPainter {
  final double animationValue;
  final Color primaryColor;
  final Color secondaryColor;

  _BackgroundEffectsPainter({
    required this.animationValue,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Círculos flotantes con diferentes opacidades y tamaños
    final circles = [
      {'x': size.width * 0.1, 'y': size.height * 0.2, 'radius': 30.0},
      {'x': size.width * 0.9, 'y': size.height * 0.1, 'radius': 20.0},
      {'x': size.width * 0.8, 'y': size.height * 0.8, 'radius': 25.0},
      {'x': size.width * 0.2, 'y': size.height * 0.9, 'radius': 15.0},
    ];

    for (int i = 0; i < circles.length; i++) {
      final circle = circles[i];
      final opacity = (0.1 + (animationValue * 0.15)) * (1.0 - (i * 0.02));
      
      paint.color = Colors.white.withOpacity(opacity);
      
      final animatedRadius = (circle['radius'] as double) * 
          (0.5 + (animationValue * 0.5));
      
      canvas.drawCircle(
        Offset(circle['x'] as double, circle['y'] as double),
        animatedRadius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}