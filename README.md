# Grevo - Renewable Energy Management System

<div align="center">
  <img src="assets/icon/app_icon.png" alt="Grevo Logo" width="120" height="120">
  <h3>Monitor and manage renewable energy sources in real-time</h3>
</div>

## 🌟 Features

### 📊 **Real-time Energy Monitoring**
- Live energy generation from solar and wind sources
- Battery state of charge and power flow monitoring
- Grid import/export tracking
- Load consumption analysis
- Weather data integration

### 📱 **Modern Mobile Experience**
- Native performance on iOS and Android
- Responsive design for tablets and phones
- Dark/Light theme switching
- Offline capability with local storage
- Pull-to-refresh for latest data

### 📈 **Advanced Analytics**
- Interactive charts and graphs
- Historical data visualization
- Energy efficiency calculations
- Power balance monitoring
- Customizable time ranges (1H, 6H, 24H, 7D)

### 🔄 **Real-time Updates**
- WebSocket connection for live data
- Automatic reconnection handling
- Connection status indicators
- Real-time notifications

### 🏢 **Multi-Campus Support**
- Switch between different energy facilities
- Campus-specific configurations
- Location-based energy optimization
- Detailed campus information display

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.10.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code with Flutter extensions
- Node.js 16.0+ (for the integrated mock backend)
- NPM or Yarn package manager

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Thejaggeddevil/Grevo_.git
   cd grevo_app
   ```

2. **Quick Setup (Windows)**
   ```bash
   # Run the automated setup script
   setup.bat
   ```

3. **Manual Setup**
   ```bash
   # Install Flutter dependencies
   flutter pub get
      
   # Install backend dependencies
   cd mock-backend
   npm install
   cd ..
   
   # Copy environment configuration
   copy .env.example .env
   
   # Edit .env with your settings
   notepad .env
   ```

4. **Run the complete system**
   
   **Option A: Automated (Windows)**
   ```bash
   # Start both backend and frontend together
   start-grevo.bat
   ```
   
   **Option B: Manual**
   ```bash
   # Terminal 1: Start the backend
   cd mock-backend
   npm start
   
   # Terminal 2: Start the Flutter app
   flutter run -d chrome
   ```

### Integrated Backend

This project includes a complete mock backend server for development and testing:

- **Location**: `mock-backend/` directory
- **Technology**: Node.js + Express + Socket.IO
- **Port**: `http://localhost:8000`
- **Features**:
  - REST API endpoints for energy data
  - WebSocket support for real-time updates
  - Mock campuses and energy data
  - Simulated real-time energy generation
  - CORS enabled for frontend communication

**Backend Features:**
- Multiple campus configurations
- Real-time solar, wind, battery, and grid data simulation
- Weather data integration
- Automatic data updates every 30 seconds
- RESTful API with proper error handling

## 📱 Supported Platforms

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12.0+)
- ✅ **Windows** (Windows 10+)
- ✅ **Web** (Modern browsers)
- ✅ **macOS** (macOS 10.14+)
- ✅ **Linux** (Ubuntu 18.04+)

## 🏗️ Architecture

### State Management
- **Provider** pattern for state management
- Reactive UI updates with `Consumer` widgets
- Centralized data providers for energy data and themes

### Networking
- **HTTP** client for REST API communication
- **Socket.IO** client for real-time WebSocket connections
- Automatic retry logic and error handling
- Connection state management

### Data Models
```dart
// Campus model with location and energy sources
class Campus {
  final String id, name;
  final Location location;
  final EnergySources energySources;
}

// Real-time energy data
class EnergyData {
  final SolarData solar;
  final WindData wind;
  final BatteryData battery;
  final GridData grid;
  final LoadData load;
  final WeatherData weather;
}
```

### Services
- `ApiService` - REST API communication
- `SocketService` - WebSocket real-time updates
- `LoggingService` - Comprehensive logging system

### UI Components
- `EnergyOverviewCards` - Key metrics display
- `EnergyChartWidget` - Interactive data visualization
- `CampusSelector` - Campus switching interface
- `ConnectionStatusWidget` - Real-time connection status

## 🔧 Configuration

### Environment Variables
Configure your backend URL in `lib/constants/app_constants.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:8000';
  static const String productionUrl = 'https://api.grevo.energy';
}
```

### Themes
The app supports both light and dark themes with energy-focused color schemes:
- **Light Theme**: Green primary with clean whites
- **Dark Theme**: Eco-friendly greens with dark backgrounds

## 📦 Building for Production

### Android
```bash
# APK for sideloading
flutter build apk --release

# App Bundle for Play Store
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

### Windows
```bash
flutter build windows --release
```

### Automated Build
Use the provided build script:
```bash
# Windows
scripts/build_release.bat

# macOS/Linux
scripts/build_release.sh
```

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run tests with coverage
flutter test --coverage
```

## 📊 Performance

### Optimization Features
- **Code splitting** for faster initial loading
- **Image optimization** with proper formats
- **Lazy loading** for charts and heavy widgets
- **Memory management** with proper disposal
- **Caching** for API responses and static assets

### Monitoring
- Built-in performance monitoring
- Error tracking and reporting
- User analytics (anonymized)
- Real-time connection monitoring

## 🔒 Security

### Data Protection
- Secure HTTP connections (HTTPS in production)
- Input validation and sanitization
- No sensitive data stored locally
- Proper authentication handling

### Privacy
- No personal data collection
- Optional analytics
- Transparent data usage
- GDPR compliant design

## 🛠️ Development

### Project Structure
```
grevo_app/
├── lib/                    # Flutter application code
│   ├── constants/          # App constants and configuration
│   ├── models/            # Data models and schemas
│   ├── providers/         # State management providers
│   ├── screens/          # UI screens and pages
│   ├── services/         # API, Socket, and utility services
│   ├── utils/            # Helper functions and formatters
│   ├── widgets/          # Reusable UI components
│   └── main.dart         # Application entry point
├── mock-backend/           # Integrated Node.js backend
│   ├── server.js          # Express server with Socket.IO
│   ├── package.json       # Backend dependencies
│   └── node_modules/      # Backend packages
├── assets/                 # App assets and resources
├── scripts/               # Build and utility scripts
├── start-grevo.bat        # Windows startup script
└── README.md              # This documentation
```

### Code Style
- Follow official Dart/Flutter style guide
- Use meaningful variable and function names
- Document public APIs with dartdoc comments
- Maintain consistent indentation and formatting

### Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes with tests
4. Submit a pull request

## 📝 API Integration

### Required Endpoints
```
GET  /api/campuses              # List all campuses
GET  /api/campuses/:id          # Get specific campus
GET  /api/energy-data           # Get energy data with filters
GET  /api/energy-data/latest/:campusId  # Get latest data
GET  /api/health                # Server health check
```

### WebSocket Events
```
// Client -> Server
join-campus         # Subscribe to campus updates
leave-campus        # Unsubscribe from campus
get-latest-data     # Request latest data

// Server -> Client
energy-data         # Real-time energy data
system-alert        # System notifications
```

## 🔍 Troubleshooting

### Common Issues

1. **Connection Failed**
   - Check if backend server is running on `http://localhost:8000`
   - Verify network connectivity
   - Check firewall settings

2. **No Data Displayed**
   - Ensure backend has campus data configured
   - Check API endpoints are responding
   - Verify data format matches models

3. **Build Errors**
   - Run `flutter clean && flutter pub get`
   - Check Flutter/Dart SDK versions
   - Verify all dependencies are compatible

### Debug Mode
Enable debug logging in `lib/services/logging_service.dart` to see detailed logs.

## 📈 Roadmap

### Upcoming Features
- [ ] Push notifications for alerts
- [ ] Offline mode with local database
- [ ] Advanced analytics and reporting
- [ ] Multi-language support
- [ ] Voice commands integration
- [ ] AR visualization features

### Version History
- **v1.0.0** - Initial release with core functionality
- **v1.1.0** - Enhanced charts and analytics (planned)
- **v1.2.0** - Offline mode support (planned)

## 📞 Support

### Documentation
- [Flutter Documentation](https://docs.flutter.dev/)
- [API Reference](https://api.grevo.energy/docs)
- [User Guide](https://grevo.energy/guide)

### Contact
- **Email**: support@grevo.energy
- **Website**: https://grevo.energy
- **Issues**: GitHub Issues tab

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Chart libraries: fl_chart, syncfusion_flutter_charts
- Socket.IO team for real-time communication
- Open source community for inspiration

---

<div align="center">
  <strong>Built with ❤️ for a sustainable future</strong>
  <br>
  <sub>Making renewable energy management accessible and intuitive</sub>
</div>