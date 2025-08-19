import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AnimatedVisibility extends StatefulWidget {
  final Widget child;
  final bool visible;
  final Duration duration;
  final Curve curve;
  final AnimationType animationType;
  final Offset? slideOffset;

  const AnimatedVisibility({
    super.key,
    required this.child,
    required this.visible,
    this.duration = AppDurations.medium,
    this.curve = Curves.easeInOut,
    this.animationType = AnimationType.fade,
    this.slideOffset,
  });

  @override
  State<AnimatedVisibility> createState() => _AnimatedVisibilityState();
}

class _AnimatedVisibilityState extends State<AnimatedVisibility>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _slideAnimation = Tween<Offset>(
      begin: widget.slideOffset ?? const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    if (widget.visible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedVisibility oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) {
      if (widget.visible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.isDismissed) {
          return const SizedBox.shrink();
        }

        Widget animatedChild = widget.child;

        switch (widget.animationType) {
          case AnimationType.fade:
            animatedChild = FadeTransition(
              opacity: _fadeAnimation,
              child: animatedChild,
            );
            break;
          case AnimationType.scale:
            animatedChild = ScaleTransition(
              scale: _scaleAnimation,
              child: animatedChild,
            );
            break;
          case AnimationType.slide:
            animatedChild = SlideTransition(
              position: _slideAnimation,
              child: animatedChild,
            );
            break;
          case AnimationType.fadeScale:
            animatedChild = FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: animatedChild,
              ),
            );
            break;
          case AnimationType.fadeSlide:
            animatedChild = FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: animatedChild,
              ),
            );
            break;
        }

        return animatedChild;
      },
    );
  }
}

enum AnimationType {
  fade,
  scale,
  slide,
  fadeScale,
  fadeSlide,
}

class StaggeredAnimatedList extends StatefulWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Duration itemDuration;
  final AnimationType animationType;
  final Axis direction;

  const StaggeredAnimatedList({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.itemDuration = AppDurations.medium,
    this.animationType = AnimationType.fadeSlide,
    this.direction = Axis.vertical,
  });

  @override
  State<StaggeredAnimatedList> createState() => _StaggeredAnimatedListState();
}

class _StaggeredAnimatedListState extends State<StaggeredAnimatedList> {
  final List<bool> _visibilityStates = [];

  @override
  void initState() {
    super.initState();
    _visibilityStates.addAll(List.filled(widget.children.length, false));
    _startStaggeredAnimation();
  }

  void _startStaggeredAnimation() {
    for (int i = 0; i < widget.children.length; i++) {
      Future.delayed(widget.staggerDelay * i, () {
        if (mounted) {
          setState(() {
            _visibilityStates[i] = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        return AnimatedVisibility(
          visible: _visibilityStates[index],
          duration: widget.itemDuration,
          animationType: widget.animationType,
          slideOffset: widget.direction == Axis.vertical
              ? const Offset(0, 0.3)
              : const Offset(0.3, 0),
          child: widget.children[index],
        );
      },
    );
  }
}