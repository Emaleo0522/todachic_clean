import 'package:flutter/material.dart';
import '../../models/settings.dart';
import '../../theme/app_theme.dart';

class StockLevelPill extends StatelessWidget {
  final StockLevel level;
  final int quantity;
  final bool showQuantity;
  final double? size;

  const StockLevelPill({
    super.key,
    required this.level,
    required this.quantity,
    this.showQuantity = true,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStockLevelConfig(level, context);
    final effectiveSize = size ?? 1.0;
    
    return AnimatedContainer(
      duration: AppDurations.fast,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md * effectiveSize,
        vertical: AppSpacing.sm * effectiveSize,
      ),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16 * effectiveSize),
        border: Border.all(
          color: config.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icon,
            size: 16 * effectiveSize,
            color: config.color,
          ),
          if (showQuantity) ...[
            SizedBox(width: AppSpacing.xs * effectiveSize),
            Text(
              quantity.toString(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: config.color,
                fontWeight: FontWeight.w600,
                fontSize: (Theme.of(context).textTheme.labelMedium?.fontSize ?? 12) * effectiveSize,
              ),
            ),
          ],
        ],
      ),
    );
  }

  StockLevelConfig _getStockLevelConfig(StockLevel level, BuildContext context) {
    switch (level) {
      case StockLevel.high:
        return StockLevelConfig(
          color: Theme.of(context).colorScheme.tertiary,
          icon: Icons.trending_up,
          label: 'Alto',
        );
      case StockLevel.medium:
        return StockLevelConfig(
          color: Theme.of(context).colorScheme.secondary,
          icon: Icons.trending_flat,
          label: 'Medio',
        );
      case StockLevel.low:
        return StockLevelConfig(
          color: Theme.of(context).colorScheme.error,
          icon: Icons.trending_down,
          label: 'Bajo',
        );
      case StockLevel.outOfStock:
        return StockLevelConfig(
          color: Colors.red.shade700,
          icon: Icons.remove_circle,
          label: 'Sin Stock',
        );
    }
  }
}

class StockLevelConfig {
  final Color color;
  final IconData icon;
  final String label;

  StockLevelConfig({
    required this.color,
    required this.icon,
    required this.label,
  });
}

class StockLevelIndicator extends StatelessWidget {
  final StockLevel level;
  final double size;
  final bool showPulse;

  const StockLevelIndicator({
    super.key,
    required this.level,
    this.size = 12,
    this.showPulse = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStockLevelConfig(level, context);
    
    return AnimatedContainer(
      duration: AppDurations.fast,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: config.color,
        shape: BoxShape.circle,
        boxShadow: showPulse ? [
          BoxShadow(
            color: config.color.withOpacity(0.4),
            blurRadius: size * 0.5,
            spreadRadius: 2,
          ),
        ] : null,
      ),
    );
  }

  StockLevelConfig _getStockLevelConfig(StockLevel level, BuildContext context) {
    switch (level) {
      case StockLevel.high:
        return StockLevelConfig(
          color: Theme.of(context).colorScheme.tertiary,
          icon: Icons.trending_up,
          label: 'Alto',
        );
      case StockLevel.medium:
        return StockLevelConfig(
          color: Theme.of(context).colorScheme.secondary,
          icon: Icons.trending_flat,
          label: 'Medio',
        );
      case StockLevel.low:
        return StockLevelConfig(
          color: Theme.of(context).colorScheme.error,
          icon: Icons.trending_down,
          label: 'Bajo',
        );
      case StockLevel.outOfStock:
        return StockLevelConfig(
          color: Colors.red.shade700,
          icon: Icons.remove_circle,
          label: 'Sin Stock',
        );
    }
  }
}