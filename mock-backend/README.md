# Grevo Mock Backend Server

This is a Node.js mock backend server for the Grevo Renewable Energy Management System Flutter app.

## 🚀 Purpose

This backend server provides:
- **REST API endpoints** for energy data, campuses, and health checks
- **WebSocket connections** for real-time energy data updates
- **Mock data simulation** for development and testing
- **CORS support** for frontend communication

## 📋 Features

- **Multiple Campus Support**: Pre-configured campuses with different energy profiles
- **Real-time Data**: Simulates live solar, wind, battery, and grid data
- **WebSocket Updates**: Pushes data updates every 30 seconds
- **RESTful API**: Standard HTTP endpoints for data retrieval
- **Health Monitoring**: Server health check endpoint

## 🔧 Setup

```bash
# Install dependencies
npm install

# Start the server
npm start

# Server will run on http://localhost:8000
```

## 📡 API Endpoints

### REST API
- `GET /api/health` - Server health check
- `GET /api/campuses` - List all available campuses
- `GET /api/campuses/:id` - Get specific campus details
- `GET /api/energy-data` - Get energy data with optional filters
- `GET /api/energy-data/latest/:campusId` - Get latest data for specific campus

### WebSocket Events

**Client → Server:**
- `join-campus` - Subscribe to campus updates
- `leave-campus` - Unsubscribe from campus
- `get-latest-data` - Request immediate data update

**Server → Client:**
- `energy-data` - Real-time energy data updates
- `system-alert` - System notifications

## 📊 Mock Data

The server generates realistic mock data for:

### Solar Energy
- Power generation: 0-500 kW (varies by time of day)
- Efficiency: 85-95%
- Temperature: 20-40°C

### Wind Energy  
- Power generation: 0-300 kW (random variations)
- Wind speed: 0-25 m/s
- Direction: 0-360°

### Battery System
- State of charge: 20-100%
- Charge/discharge power: -200 to +200 kW
- Capacity: 1000 kWh
- Temperature: 15-35°C

### Grid Connection
- Import/export: -400 to +400 kW
- Frequency: 49.8-50.2 Hz
- Voltage: 230-240V

### Load Data
- Consumption: 200-800 kW (varies throughout day)
- Power factor: 0.85-0.95

### Weather Data
- Temperature: -10 to 40°C
- Humidity: 30-90%
- Weather conditions: sunny, cloudy, rainy, windy

## 🏢 Available Campuses

1. **Renewable Energy Research Campus**
   - Location: Austin, Texas
   - Solar: 500 kW capacity
   - Wind: 300 kW capacity
   - Battery: 1000 kWh

2. **Green Technology Center**
   - Location: Portland, Oregon  
   - Solar: 750 kW capacity
   - Wind: 200 kW capacity
   - Battery: 1500 kWh

3. **Sustainable Innovation Hub**
   - Location: Denver, Colorado
   - Solar: 400 kW capacity
   - Wind: 400 kW capacity
   - Battery: 800 kWh

## 🔄 Data Update Cycle

- Energy data updates every **30 seconds**
- Solar data follows **daylight patterns**
- Wind data uses **random variations**
- Battery follows **charge/discharge cycles**
- Load data simulates **daily usage patterns**

## 🌐 CORS Configuration

The server is configured to accept requests from:
- `http://localhost:*` (all local ports)
- `http://127.0.0.1:*` (all local ports)
- Web browsers during development

## 🐛 Troubleshooting

### Server won't start
```bash
# Check if port 8000 is available
netstat -ano | findstr :8000

# Install dependencies
npm install

# Check Node.js version (requires 16.0+)
node --version
```

### No data updates
- Check WebSocket connection in browser console
- Verify client is sending `join-campus` event
- Check server logs for errors

### CORS errors
- Server automatically handles CORS for local development
- Check console for specific CORS error messages

## 📝 Usage with Frontend

This backend is designed to work seamlessly with the Grevo Flutter app:

1. **Automatic startup**: Use `start-grevo.bat` in the main project
2. **Manual startup**: Run `npm start` in this directory
3. **Frontend connection**: App connects to `http://localhost:8000`

## 🛠️ Development

The server uses:
- **Express.js** for HTTP server and REST API
- **Socket.IO** for WebSocket communication
- **CORS** for cross-origin requests
- **Node.js** for runtime

To modify data or add features:
1. Edit `server.js` 
2. Restart server with `npm start`
3. Test with frontend or API tools

---

**Part of the Grevo Renewable Energy Management System**