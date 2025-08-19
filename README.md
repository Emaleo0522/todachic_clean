# TODAChic - Sistema de Gestión Boutique 🦋

Una aplicación Flutter web moderna para gestión de inventario y ventas de ropa, con diseño Material 3 y branding elegante.

## ✨ Características

- **Gestión de Stock**: Productos con categorías, talles y niveles de inventario
- **Ventas**: Registro manual con cálculo automático
- **Balance**: Dashboard con métricas y gráficos interactivos
- **Import/Export**: Respaldos completos en JSON
- **Responsive**: Optimizado para web con PWA
- **Dark/Light Mode**: Temas adaptativos

## 🎨 Sistema de Diseño

### Tema Material 3

La aplicación usa un sistema de colores custom basado en Material 3 ubicado en `lib/theme/app_theme.dart`:

#### Paleta de Colores
- **Primary**: `#C46486` (Rosa viejo)
- **Secondary**: `#E5B8A1` (Durazno)
- **Tertiary**: `#D7C6A3` (Dorado suave)
- **Surface Light**: `#FFF8FA`
- **Surface Dark**: `#121014`

#### Tipografía
- **Fuente**: Poppins (con fallback a Inter/Roboto)
- **Escalas**: Siguiendo especificaciones Material 3

### Componentes Personalizados

#### Widgets UI (`lib/ui/widgets/`)
- **AppSection**: Secciones con títulos y descripción
- **KPIChip/KPICard**: Métricas e indicadores
- **StockLevelPill**: Indicadores de nivel de stock
- **AnimatedVisibility**: Transiciones suaves
- **GradientAppBar**: AppBar con gradientes

#### Design Tokens (`lib/theme/app_theme.dart`)
```dart
AppSpacing.xs = 4px
AppSpacing.sm = 8px  
AppSpacing.md = 12px
AppSpacing.lg = 16px
AppSpacing.xl = 24px

AppDurations.fast = 180ms
AppDurations.medium = 240ms
AppDurations.slow = 300ms
```

### Personalización

Para cambiar colores principales, edita las constantes en `AppTheme`:

```dart
// lib/theme/app_theme.dart
static const Color _primary = Color(0xFFC46486);
static const Color _secondary = Color(0xFFE5B8A1); 
static const Color _tertiary = Color(0xFFD7C6A3);
```

### Animaciones

- **Micro-transiciones**: 180-240ms con curvas suaves
- **Staggered lists**: Aparición secuencial de elementos
- **Hover/Focus states**: Con ripple contenido
- **Stock level pulse**: Para alertas críticas

## 🚀 Desarrollo

### Construcción
```bash
flutter build web --web-renderer html
```

### Análisis
```bash  
flutter analyze
```

### Testing
```bash
flutter test
```

## 📱 Estructura

```
lib/
├── theme/           # Sistema de diseño Material 3
├── ui/widgets/      # Componentes reutilizables
├── features/        # Pantallas principales
│   ├── stock/       # Gestión de inventario
│   ├── sales/       # Registro de ventas
│   ├── balance/     # Dashboard y métricas
│   └── settings/    # Configuración
├── data/            # Repositorios y adaptadores Hive
├── models/          # Modelos de datos
└── widgets/         # Widgets compartidos legacy
```

## 🛠️ Tecnologías

- **Flutter** 3.24+ con Material 3
- **Riverpod** para estado reactivo  
- **Hive** para almacenamiento local
- **Go Router** para navegación
- **FL Chart** para gráficos

## 🎯 Características de UI/UX

- **Tema por defecto**: Claro (con soporte oscuro)
- **Design System**: Material 3 con tokens customizados
- **Animaciones**: Micro-transiciones suaves (180-240ms)
- **Colores boutique**: Rosa viejo, durazno y dorado suave
- **Chips pastel**: Estados seleccionados claros
- **Cards redondeadas**: Radius 24px sin líneas duras
- **FAB extendido**: Con iconos outline modernos
- **Gradientes sutiles**: En AppBars y fondos

---

*Desarrollado con 🦋 para TODAChic*