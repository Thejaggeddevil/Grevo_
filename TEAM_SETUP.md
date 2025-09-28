# 🚀 Grevo Flutter App - Team Setup Guide

## 📋 **Quick Start for Team Members**

### **Prerequisites**
- Flutter SDK 3.10.0+ 
- Node.js 16.0+ and NPM
- Git installed

### **1. Clone & Setup**
```bash
# Clone the repository
git clone https://github.com/Thejaggeddevil/Grevo_.git
cd grevo_app

# Quick setup (Windows) - Sets up both frontend and backend
setup.bat

# OR Manual setup
flutter pub get
cd mock-backend && npm install && cd ..
copy .env.example .env
```

### **2. Install Flutter (if not installed)**
```bash
# Via winget (recommended)
winget install --id=Flutter.Flutter

# OR download from https://flutter.dev/docs/get-started/install
```

### **3. Run the Complete System**
```bash
# Option A: Start everything with one command (Windows)
start-grevo.bat

# Option B: Manual startup
# Terminal 1: Start backend
cd mock-backend
npm start

# Terminal 2: Start Flutter app
flutter run -d chrome    # For web browser
flutter run             # For default device
flutter run -d windows  # For Windows desktop
```

## 🧪 **Testing Checklist**

### **Integrated Backend**
The project includes a complete Node.js backend in the `mock-backend/` folder:
- **Technology**: Node.js + Express + Socket.IO
- **Port**: http://localhost:8000
- **Auto-start**: Use `start-grevo.bat` or run `npm start` manually

**Available Endpoints**:
- `GET /api/health` - Server health check
- `GET /api/campuses` - List of energy campuses
- `GET /api/energy-data` - Historical energy data
- `GET /api/energy-data/latest/:campusId` - Latest data for campus
- WebSocket connection for real-time updates

### **App Features to Test**
- [ ] **Splash Screen** - Shows Grevo logo and loading animation
- [ ] **Dashboard** - Displays energy monitoring interface
- [ ] **Campus Selection** - Dropdown with campus list from backend
- [ ] **Energy Cards** - Real-time solar, wind, battery, grid data
- [ ] **Charts** - Interactive charts with time range selection
- [ ] **Connection Status** - Shows "Live" when connected to backend
- [ ] **Theme Toggle** - Switch between light and dark themes
- [ ] **Real-time Updates** - Data updates automatically via WebSocket
- [ ] **Error Handling** - Graceful error messages when backend unavailable

### **Platform Testing**
- [ ] **Android** - APK runs on Android device/emulator
- [ ] **iOS** - App runs on iOS simulator (Mac required)
- [ ] **Web** - Works in Chrome, Firefox, Safari
- [ ] **Windows** - Desktop app runs on Windows 10+

## 🔧 **Configuration**

### **Environment Variables**
Edit `.env` file for your setup:
```env
API_BASE_URL=http://localhost:8000
SOCKET_URL=http://localhost:8000
DEBUG_MODE=true
ENABLE_REAL_TIME_UPDATES=true
```

### **Backend URL Configuration**
If your backend runs on different port, update:
- `.env` file for environment variables
- `lib/constants/app_constants.dart` for hardcoded values

## 🐛 **Troubleshooting**

### **Common Issues**

1. **"Flutter not found"**
   ```bash
   # Add Flutter to PATH or reinstall
   winget install --id=Flutter.Flutter
   ```

2. **"No device found"**
   ```bash
   # Check connected devices
   flutter devices
   
   # For web
   flutter run -d chrome
   ```

3. **"Connection failed"**
   - Start the backend: `cd mock-backend && npm start`
   - Or use the startup script: `start-grevo.bat`
   - Check firewall settings
   - Verify API endpoints are responding

4. **Build errors**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### **Backend Connection Test**
```bash
# First, make sure backend is running
cd mock-backend
npm start

# Then test if backend is responding (in another terminal)
curl http://localhost:8000/api/health
curl http://localhost:8000/api/campuses

# Or open in browser:
# http://localhost:8000/api/health
# http://localhost:8000/api/campuses
```

## 📱 **Building for Production**

### **Android APK**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/
```

### **Windows Executable**
```bash
flutter build windows --release
# Output: build/windows/runner/Release/
```

### **Web Build**
```bash
flutter build web --release
# Output: build/web/
```

## 📊 **Expected Performance**

### **Startup Times**
- App launch: < 3 seconds
- Data loading: < 5 seconds
- Chart rendering: < 2 seconds

### **Features**
- ✅ Real-time energy monitoring
- ✅ Interactive charts and analytics
- ✅ Multi-campus support
- ✅ Dark/Light themes
- ✅ Cross-platform compatibility
- ✅ WebSocket real-time updates
- ✅ Professional UI/UX design

## 🆘 **Need Help?**

### **Check These First**
1. `flutter doctor` - Shows Flutter installation issues
2. `flutter devices` - Lists available devices
3. Backend logs - Check if API is responding
4. App logs - Check console for errors

### **Documentation**
- Main README: `README.md`
- Production checklist: `PRODUCTION_CHECKLIST.md`
- App constants: `lib/constants/app_constants.dart`

### **Contact**
- Repository: https://github.com/Thejaggeddevil/Grevo_
- Issues: Use GitHub Issues tab

---

## 🎉 **Success Indicators**

When everything works correctly, you should see:
- ✅ Grevo splash screen with animated logo
- ✅ Dashboard with energy monitoring cards
- ✅ "Live" connection status (green indicator)
- ✅ Real-time data updating automatically
- ✅ Interactive charts with proper data
- ✅ Smooth theme switching
- ✅ Responsive design on different screen sizes

**Happy testing! 🌱⚡**