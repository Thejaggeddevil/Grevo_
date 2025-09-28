const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

// Middleware
app.use(cors());
app.use(express.json());

// Mock data
const mockCampuses = [
  {
    id: "campus-1",
    name: "Green Valley Campus",
    location: {
      address: "123 Renewable Street",
      city: "EcoCity",
      state: "CA",
      country: "USA",
      zipCode: "90210",
      coordinates: {
        latitude: 34.0522,
        longitude: -118.2437
      }
    },
    energySources: {
      solar: {
        enabled: true,
        capacity: 500,
        panels: 200,
        efficiency: 0.22
      },
      wind: {
        enabled: true,
        capacity: 300,
        turbines: 5,
        cutInSpeed: 3.5
      },
      battery: {
        enabled: true,
        capacity: 1000,
        type: "lithium-ion",
        cycleLife: 5000
      }
    }
  },
  {
    id: "campus-2", 
    name: "Solar Ridge Campus",
    location: {
      address: "456 Solar Avenue",
      city: "SunCity",
      state: "AZ",
      country: "USA",
      zipCode: "85001",
      coordinates: {
        latitude: 33.4484,
        longitude: -112.0740
      }
    },
    energySources: {
      solar: {
        enabled: true,
        capacity: 750,
        panels: 300,
        efficiency: 0.24
      },
      wind: {
        enabled: false,
        capacity: 0,
        turbines: 0,
        cutInSpeed: 0
      },
      battery: {
        enabled: true,
        capacity: 1500,
        type: "lithium-ion",
        cycleLife: 6000
      }
    }
  }
];

function generateMockEnergyData(campusId) {
  return {
    campusId: campusId,
    timestamp: new Date().toISOString(),
    solar: {
      generation: Math.random() * 400 + 100, // 100-500 kW
      irradiance: Math.random() * 800 + 200,  // 200-1000 W/m²
      efficiency: Math.random() * 5 + 20,      // 20-25%
      temperature: Math.random() * 10 + 35     // 35-45°C
    },
    wind: {
      generation: Math.random() * 250 + 50,    // 50-300 kW
      speed: Math.random() * 10 + 5,           // 5-15 m/s
      direction: Math.floor(Math.random() * 360), // 0-360 degrees
      temperature: Math.random() * 15 + 20     // 20-35°C
    },
    battery: {
      soc: Math.random() * 40 + 60,           // 60-100%
      power: (Math.random() - 0.5) * 200,     // -100 to +100 kW
      voltage: Math.random() * 50 + 400,      // 400-450V
      temperature: Math.random() * 10 + 25,   // 25-35°C
      capacity: 1000,
      cycles: Math.floor(Math.random() * 1000 + 500)
    },
    grid: {
      import: Math.random() * 100,            // 0-100 kW
      export: Math.random() * 150,            // 0-150 kW
      frequency: 50 + (Math.random() - 0.5),  // 49.5-50.5 Hz
      voltage: 230 + (Math.random() - 0.5) * 10, // 225-235V
      powerFactor: Math.random() * 0.1 + 0.9  // 0.9-1.0
    },
    load: {
      total: Math.random() * 400 + 200,       // 200-600 kW
      critical: Math.random() * 100 + 50,     // 50-150 kW
      nonCritical: Math.random() * 300 + 150  // 150-450 kW
    },
    weather: {
      temperature: Math.random() * 15 + 20,   // 20-35°C
      humidity: Math.random() * 30 + 40,      // 40-70%
      pressure: Math.random() * 50 + 1000,    // 1000-1050 hPa
      windSpeed: Math.random() * 10 + 2,      // 2-12 m/s
      cloudCover: Math.floor(Math.random() * 100) // 0-100%
    },
    source: "mock-iot"
  };
}

// API Routes
app.get('/api/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

app.get('/api/status', (req, res) => {
  res.json({ 
    server: 'Grevo Mock Backend',
    version: '1.0.0',
    status: 'running',
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

app.get('/api/campuses', (req, res) => {
  res.json(mockCampuses);
});

app.get('/api/campuses/:id', (req, res) => {
  const campus = mockCampuses.find(c => c.id === req.params.id);
  if (!campus) {
    return res.status(404).json({ error: 'Campus not found' });
  }
  res.json(campus);
});

app.get('/api/energy-data', (req, res) => {
  const { campusId, limit = 10 } = req.query;
  const data = [];
  
  for (let i = 0; i < parseInt(limit); i++) {
    data.push(generateMockEnergyData(campusId || 'campus-1'));
  }
  
  res.json(data);
});

app.get('/api/energy-data/latest/:campusId', (req, res) => {
  const energyData = generateMockEnergyData(req.params.campusId);
  res.json(energyData);
});

// Socket.IO for real-time updates
io.on('connection', (socket) => {
  console.log('Client connected:', socket.id);

  socket.on('join-campus', (data) => {
    const { campusId } = data;
    socket.join(campusId);
    console.log(`Client ${socket.id} joined campus: ${campusId}`);
    
    // Send initial data
    const energyData = generateMockEnergyData(campusId);
    socket.emit('energy-data', energyData);
  });

  socket.on('leave-campus', (data) => {
    const { campusId } = data;
    socket.leave(campusId);
    console.log(`Client ${socket.id} left campus: ${campusId}`);
  });

  socket.on('get-latest-data', (data) => {
    const { campusId } = data;
    const energyData = generateMockEnergyData(campusId);
    socket.emit('energy-data', energyData);
  });

  socket.on('disconnect', () => {
    console.log('Client disconnected:', socket.id);
  });
});

// Send real-time data every 5 seconds
setInterval(() => {
  mockCampuses.forEach(campus => {
    const energyData = generateMockEnergyData(campus.id);
    io.to(campus.id).emit('energy-data', energyData);
  });
}, 5000);

const PORT = process.env.PORT || 8000;
server.listen(PORT, () => {
  console.log(`🚀 Grevo Mock Backend Server running on port ${PORT}`);
  console.log(`📊 Dashboard: http://localhost:${PORT}/api/health`);
  console.log(`🏢 Campuses: http://localhost:${PORT}/api/campuses`);
  console.log(`⚡ Real-time updates enabled via WebSocket`);
});