# App Icons and Assets

## 📱 App Icon Requirements

To complete the app setup, you need to add the following app icon files:

### **Main App Icon**
- **File**: `app_icon.png`
- **Size**: 1024x1024 pixels
- **Format**: PNG with transparency
- **Design**: Energy-themed icon with green/sustainable colors

### **Suggested Icon Design Elements**
- 🌱 Leaf or plant symbol representing sustainability
- ⚡ Lightning bolt for energy
- 🏢 Building outline for campus management
- 📊 Graph/chart elements for data monitoring
- 🌞 Sun symbol for solar energy
- 💨 Wind turbine for wind energy

### **Icon Generation**
Once you have your `app_icon.png` file (1024x1024), you can generate all platform-specific icons automatically:

1. **Add flutter_launcher_icons to pubspec.yaml**:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/icon/app_icon.png"
  min_sdk_android: 21
  web:
    generate: true
    image_path: "assets/icon/app_icon.png"
  windows:
    generate: true
    image_path: "assets/icon/app_icon.png"
  macos:
    generate: true
    image_path: "assets/icon/app_icon.png"
```

2. **Generate icons**:
```bash
flutter pub get
flutter pub run flutter_launcher_icons:main
```

## 🎨 Splash Screen Assets

### **Splash Screen Image**
- **File**: `splash_icon.png`
- **Size**: 512x512 pixels
- **Format**: PNG with transparency
- **Usage**: Displayed during app initialization

### **Background Colors**
- **Light Theme**: `#FFFFFF` (white)
- **Dark Theme**: `#121212` (dark gray)

### **Native Splash Screen Setup**
1. **Add flutter_native_splash to pubspec.yaml**:
```yaml
dev_dependencies:
  flutter_native_splash: ^2.3.7

flutter_native_splash:
  color: "#FFFFFF"
  image: assets/icon/splash_icon.png
  color_dark: "#121212"
  image_dark: assets/icon/splash_icon.png
  android_12:
    image: assets/icon/splash_icon.png
    color: "#FFFFFF"
```

2. **Generate splash screens**:
```bash
flutter pub run flutter_native_splash:create
```

## 📁 Directory Structure
```
assets/
├── icon/
│   ├── app_icon.png         (1024x1024 - Main app icon)
│   ├── splash_icon.png      (512x512 - Splash screen icon)
│   └── README.md           (This file)
└── images/
    └── (Additional app images)
```

## 🎯 Brand Guidelines

### **Color Palette**
- **Primary Green**: `#2E7D32`
- **Secondary Green**: `#4CAF50`
- **Accent Orange**: `#FFB74D`
- **Text Dark**: `#212121`
- **Background**: `#FFFFFF`

### **Typography**
- **Primary Font**: Roboto
- **Weights**: Regular (400), Medium (500), Bold (700)

### **Design Principles**
- Clean and modern design
- Eco-friendly and sustainable theme
- Professional appearance
- High contrast for accessibility
- Scalable vector elements

## 🚀 Quick Setup

If you don't have custom icons ready, you can use a placeholder:

1. **Create a simple icon** with online tools like:
   - Canva
   - GIMP
   - Adobe Illustrator
   - Online icon generators

2. **Use the Grevo brand colors** mentioned above

3. **Include elements** like:
   - Energy/lightning symbol
   - Leaf for sustainability
   - Clean, minimalist design

4. **Save as PNG** with transparent background

5. **Name the file** `app_icon.png` and place in this directory

6. **Run the generation commands** mentioned above

## ✅ Completion Checklist

- [ ] Create or obtain app icon (1024x1024)
- [ ] Create or obtain splash screen icon (512x512)
- [ ] Add flutter_launcher_icons dependency
- [ ] Configure icon generation in pubspec.yaml
- [ ] Run icon generation command
- [ ] Add flutter_native_splash dependency
- [ ] Configure splash screen in pubspec.yaml
- [ ] Run splash screen generation command
- [ ] Test on different platforms
- [ ] Verify icon appears correctly in all contexts

Once completed, your Grevo app will have professional icons across all platforms! 🎉