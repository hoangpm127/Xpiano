# HTML/Tailwind to Flutter Conversion Guide

## Complete Mapping Reference

### 1. Background Image with Brightness Filter

**HTML/Tailwind:**
```html
<img class="brightness-75" src="..." />
<div class="bg-gradient-to-t from-black/80 via-black/30 to-transparent"></div>
```

**Flutter:**
```dart
Image.network(
  src,
  color: Colors.black.withOpacity(0.25),
  colorBlendMode: BlendMode.darken,
)

Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        Colors.black.withOpacity(0.3),
        Colors.black.withOpacity(0.8),
      ],
    ),
  ),
)
```

---

### 2. Glassmorphism Panel

**HTML/Tailwind:**
```html
<div class="glass-panel bg-white/20 backdrop-blur-md border border-white/10">
```

**CSS:**
```css
.glass-panel {
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
}
```

**Flutter:**
```dart
ClipRRect(
  borderRadius: BorderRadius.circular(30),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
    ),
  ),
)
```

---

### 3. Gold Gradient Button

**HTML/Tailwind:**
```html
<button class="gold-gradient">Học Ngay</button>
```

**CSS:**
```css
.gold-gradient {
    background: linear-gradient(135deg, #E6C86E 0%, #BF953F 50%, #E6C86E 100%);
}
```

**Flutter:**
```dart
Container(
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFE6C86E),
        Color(0xFFBF953F),
        Color(0xFFE6C86E),
      ],
    ),
    borderRadius: BorderRadius.circular(22),
    boxShadow: [
      BoxShadow(
        color: Color(0xFFD4AF37).withOpacity(0.3),
        blurRadius: 15,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {},
      child: // Button content
    ),
  ),
)
```

---

### 4. Text Shadow

**HTML/Tailwind:**
```html
<span class="text-shadow">LinhPiano</span>
```

**CSS:**
```css
.text-shadow {
    text-shadow: 0 1px 3px rgba(0,0,0,0.6);
}
```

**Flutter:**
```dart
Text(
  'LinhPiano',
  style: GoogleFonts.inter(
    shadows: [
      Shadow(
        color: Colors.black.withOpacity(0.6),
        offset: Offset(0, 1),
        blurRadius: 3,
      ),
    ],
  ),
)
```

---

### 5. Rounded Top Corners

**HTML/Tailwind:**
```html
<div class="rounded-t-3xl">Bottom Navigation</div>
```

**Flutter:**
```dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(24),
      topRight: Radius.circular(24),
    ),
  ),
)
```

---

### 6. Avatar with Border

**HTML/Tailwind:**
```html
<div class="w-10 h-10 rounded-full border border-white/30">
  <img class="w-full h-full object-cover" src="..." />
</div>
```

**Flutter:**
```dart
Container(
  width: 40,
  height: 40,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(
      color: Colors.white.withOpacity(0.3),
      width: 1,
    ),
  ),
  child: ClipOval(
    child: Image.network(
      src,
      fit: BoxFit.cover,
    ),
  ),
)
```

---

### 7. Inter Font Family

**HTML:**
```html
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet"/>
```

**CSS:**
```css
font-family: 'Inter', sans-serif;
```

**Flutter:**
```dart
// pubspec.yaml
dependencies:
  google_fonts: ^6.1.0

// Dart code
Text(
  'Text',
  style: GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  ),
)
```

---

### 8. Absolute Positioning

**HTML/Tailwind:**
```html
<div class="absolute top-14 left-4">Content</div>
```

**Flutter:**
```dart
Stack(
  children: [
    Positioned(
      top: 56,  // 14 * 4 = 56 (Tailwind uses 4px base)
      left: 16, // 4 * 4 = 16
      child: // Content
    ),
  ],
)
```

---

### 9. Flexbox Row with Gap

**HTML/Tailwind:**
```html
<div class="flex items-center gap-2">
  <img />
  <span>Text</span>
</div>
```

**Flutter:**
```dart
Row(
  children: [
    Image.network(src),
    SizedBox(width: 8), // gap-2 = 8px
    Text('Text'),
  ],
)
```

---

### 10. Box Shadow with Glow

**HTML/Tailwind:**
```css
box-shadow: 0 0 15px rgba(212, 175, 55, 0.3);
```

**Flutter:**
```dart
Container(
  decoration: BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: Color(0xFFD4AF37).withOpacity(0.3),
        blurRadius: 15,
        spreadRadius: 0,
        offset: Offset(0, 0),
      ),
    ],
  ),
)
```

---

### 11. Material Icons

**HTML:**
```html
<link href="https://fonts.googleapis.com/icon?family=Material+Icons+Round" rel="stylesheet"/>
<span class="material-icons-round">verified</span>
```

**Flutter:**
```dart
Icon(
  Icons.verified,
  color: Color(0xFFFFD700),
  size: 14,
)
```

---

### 12. Hover Effects (Touch Feedback in Flutter)

**HTML/Tailwind:**
```html
<button class="hover:scale-110 active:scale-95 transition-transform">
```

**Flutter:**
```dart
Material(
  child: InkWell(
    onTap: () {},
    child: AnimatedScale(
      scale: _isPressed ? 0.95 : 1.0,
      duration: Duration(milliseconds: 100),
      child: // Button content
    ),
  ),
)
```

---

### 13. Opacity Classes

**Tailwind → Flutter Mapping:**
- `bg-white/20` → `Colors.white.withOpacity(0.2)`
- `bg-black/40` → `Colors.black.withOpacity(0.4)`
- `text-white/90` → `Colors.white.withOpacity(0.9)`
- `border-white/10` → `Colors.white.withOpacity(0.1)`

---

### 14. Spacing Utilities

**Tailwind → Flutter Mapping (1 unit = 4px):**
- `gap-1` (4px) → `SizedBox(width: 4)` or `height: 4`
- `gap-2` (8px) → `SizedBox(width: 8)`
- `gap-3` (12px) → `SizedBox(width: 12)`
- `p-3` → `padding: EdgeInsets.all(12)`
- `px-3 py-1.5` → `padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6)`

---

### 15. Border Radius

**Tailwind → Flutter Mapping:**
- `rounded-full` → `BorderRadius.circular(999)` or `shape: BoxShape.circle`
- `rounded-xl` (16px) → `BorderRadius.circular(16)`
- `rounded-2xl` (24px) → `BorderRadius.circular(24)`
- `rounded-3xl` (32px) → `BorderRadius.circular(32)`

---

### 16. Color Opacity with Blend Modes

**HTML/Tailwind:**
```html
<img class="brightness-75" />
```

**Flutter:**
```dart
Image.network(
  src,
  color: Colors.black.withOpacity(0.25),
  colorBlendMode: BlendMode.darken,
)
```

**Brightness Mapping:**
- `brightness-50` → `opacity(0.5)`
- `brightness-75` → `opacity(0.25)` (inverted for darken)
- `brightness-100` → `opacity(0)`

---

### 17. Z-Index (Stacking Order)

**HTML/Tailwind:**
```html
<div class="z-0">Background</div>
<div class="z-10">Middle</div>
<div class="z-20">Top</div>
```

**Flutter:**
```dart
Stack(
  children: [
    // First child (z-0)
    // Second child (z-10) - drawn on top
    // Third child (z-20) - drawn on top of both
  ],
)
```
*Note: In Flutter Stack, order determines z-index (later = higher)*

---

### 18. Full Screen (Edge-to-Edge)

**HTML/Tailwind:**
```html
<body class="h-screen w-screen overflow-hidden">
```

**Flutter:**
```dart
SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
SystemChrome.setSystemUIOverlayStyle(
  SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ),
);

Scaffold(
  backgroundColor: Colors.black,
  body: Stack(...),
)
```

---

## Key Differences to Remember

1. **Tailwind uses 4px base unit**, Flutter uses logical pixels
2. **Tailwind: `opacity/percentage`**, Flutter: `withOpacity(0.0-1.0)`
3. **Tailwind: `class=""`**, Flutter: `decoration: BoxDecoration()`
4. **Tailwind: hover states**, Flutter: `InkWell` + `AnimatedContainer`
5. **Tailwind: `backdrop-filter`**, Flutter: `BackdropFilter` + `ClipRRect`
6. **Tailwind: z-index**, Flutter: Stack order (first = bottom)

---

## Performance Tips

1. **Use `const` wherever possible** for better performance
2. **Avoid excessive `BackdropFilter`** on low-end devices
3. **Use `RepaintBoundary`** for complex animations
4. **Cache network images** using `CachedNetworkImage` package
5. **Profile with DevTools** to identify bottlenecks

---

## Common Patterns

### Pattern: Card with Shadow
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  ),
)
```

### Pattern: Gradient Overlay
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        Colors.black.withOpacity(0.6),
      ],
    ),
  ),
)
```

### Pattern: Icon with Label
```dart
Column(
  children: [
    Icon(Icons.favorite),
    SizedBox(height: 4),
    Text('1.2K'),
  ],
)
```

---

This guide covers all the major HTML/Tailwind patterns used in the Piano Social Feed design and their exact Flutter equivalents. Use it as a quick reference for future conversions!
