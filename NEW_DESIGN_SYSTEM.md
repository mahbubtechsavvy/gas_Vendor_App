# Gas Lagbe Vendor App - New UI Design System

## Phase 1 Complete ✅

This document describes the new design system implemented for the Gas Lagbe Vendor App redesign.

## Files Created

### 1. Theme Configuration

**File:** `lib/config/new_theme_config.dart`

Complete theme configuration including:

- Color palette (Gas Lagbe blue, orange, pink, teal, lime)
- Typography system (Poppins font)
- Spacing scale (4px base unit)
- Border radius values
- Shadow definitions
- Helper methods for status colors and decorations

### 2. Component Library

**File:** `lib/widgets/new_ui_components.dart`

Reusable UI components:

- **CustomAppBar** - Gas Lagbe logo with premium badge
- **MetricCard** - Colorful stat cards for dashboard
- **StatusBadge** - Order status indicators
- **ShopToggleCard** - Shop open/close toggle
- **QuickActionButton** - Icon buttons for quick actions
- **SubscriptionBanner** - Subscription promotion card
- **OrderListItem** - Order card with avatar and details
- **ProductCard** - Product list item with stock indicators
- **SocialIconButton** - Social media icons

### 3. SVG Assets Helper

**File:** `lib/utils/svg_assets.dart`

Constants for SVG asset paths.

### 4. Component Demo

**File:** `lib/screens/demo/components_demo.dart`

Interactive demo showcasing all components. Use this for:

- Testing components
- Visual reference
- Development guide

### 5. Assets Updated

**File:** `pubspec.yaml`

Added:

- `assets/images/Logo.svg` - New Gas Lagbe logo
- `assets/images/new-vendorapp-ui-design/` - UI design references

## Color Palette

```dart
// Primary Colors
primaryBlue: #5B6EF5    // Gas Lagbe brand
darkBlue: #001B44       // Buttons
orange: #FF9245         // CTAs
pink: #E961FF           // Pending
teal: #4FDDC5           // Success
lime: #D4FF4D           // Shop status
purple: #8B7BF7         // Metrics

// Status Colors
statusPending: #FF9245
statusAccepted: #5B6EF5
statusProcessing: #E961FF
statusDelivered: #10B981
statusDeclined: #EF4444
```

## Typography

All text uses **Poppins** font family via Google Fonts.

```dart
heading1: 28px, Bold
heading2: 22px, Bold
heading3: 18px, SemiBold
bodyLarge: 16px, Regular
bodyMedium: 14px, Regular
bodySmall: 12px, Regular
buttonText: 16px, SemiBold
metricValue: 32px, Bold (for dashboard stats)
```

## Spacing Scale

Based on 4px increments:

- XS: 4px
- SM: 8px
- MD: 12px
- LG: 16px
- XL: 24px
- 2XL: 32px
- 3XL: 48px

## Border Radius

- Small: 8px
- Medium: 12px
- Large: 16px
- XLarge: 20px
- Pill: 100px (for badges)

## Component Usage Examples

### CustomAppBar

```dart
CustomAppBar(
  showPremiumBadge: true,
  onNotificationTap: () {
    // Handle notification tap
  },
)
```

### MetricCard

```dart
MetricCard(
  label: 'Total Orders',
  value: '1,245',
  color: NewThemeConfig.purple,
  onTap: () {
    // Navigate to orders
  },
)
```

### StatusBadge

```dart
StatusBadge(status: 'Pending')
StatusBadge(status: 'Delivered')
```

### ShopToggleCard

```dart
ShopToggleCard(
  isOpen: isShopOpen,
  onChanged: (value) {
    setState(() => isShopOpen = value);
    // Update shop status via API
  },
)
```

### OrderListItem

```dart
OrderListItem(
  customerName: 'Bab Koli',
  address: 'Miajan Haji Bari, Talua Chandpur',
  orderNumber: '#VGD001',
  date: '2024-07-28',
  items: 'Total Gas 12 kg x1',
  amount: '৳ 1,250',
  status: 'Pending',
  timeAgo: '08:43',
  onTap: () {
    // Navigate to order details
  },
)
```

### ProductCard

```dart
ProductCard(
  imageUrl: 'https://...',
  name: 'Total Gas 12 kg',
  description: '12 kg',
  price: '৳ 1,350',
  stockCount: 18,
  isInStock: true,
  onEdit: () {
    // Edit product
  },
  onDelete: () {
    // Delete product
  },
)
```

## Testing the Components

To see all components in action:

1. Import the demo screen in your main.dart or any route
2. Navigate to ComponentsDemo screen
3. Interact with all components

```dart
import 'package:vendorapp/screens/demo/components_demo.dart';

// In your route or button:
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const ComponentsDemo()),
);
```

## Next Steps (Phase 2)

- Redesign Dashboard screen using new components
- Redesign Orders screen
- Redesign Products screen
- Redesign Profile screen

## Notes

- All components are fully responsive
- Components follow Material Design 3 principles
- SVG logo requires `flutter_svg` package (already added)
- All colors are accessible (WCAG AA compliant)
- Components support both light mode (dark mode not in current design)

## Migration Guide

When updating existing screens:

1. Import new theme: `import '../config/new_theme_config.dart';`
2. Import components: `import '../widgets/new_ui_components.dart';`
3. Replace old theme colors with `NewThemeConfig.*`
4. Replace custom widgets with new components
5. Update text styles to use `NewThemeConfig.heading1`, etc.
6. Test on multiple screen sizes

## Support

For questions or issues with the new design system, refer to:

- Component demo: `lib/screens/demo/components_demo.dart`
- Theme config: `lib/config/new_theme_config.dart`
- Implementation plan: See project documentation
