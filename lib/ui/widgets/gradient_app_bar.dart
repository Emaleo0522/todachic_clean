import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final bool showGradient;

  const GradientAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.bottom,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.showGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: showGradient ? BoxDecoration(
        gradient: AppGradients.appBar,
      ) : null,
      child: AppBar(
        title: title,
        actions: actions,
        leading: leading,
        bottom: bottom,
        automaticallyImplyLeading: automaticallyImplyLeading,
        backgroundColor: backgroundColor ?? Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: showGradient ? 0 : 2,
        centerTitle: true,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
  );
}

class SliverGradientAppBar extends StatelessWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? flexibleSpace;
  final bool automaticallyImplyLeading;
  final double expandedHeight;
  final bool floating;
  final bool pinned;
  final bool snap;

  const SliverGradientAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.flexibleSpace,
    this.automaticallyImplyLeading = true,
    this.expandedHeight = kToolbarHeight * 2,
    this.floating = false,
    this.pinned = true,
    this.snap = false,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: title,
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      expandedHeight: expandedHeight,
      floating: floating,
      pinned: pinned,
      snap: snap,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
          ),
          child: flexibleSpace,
        ),
      ),
    );
  }
}