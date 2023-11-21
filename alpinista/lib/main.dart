import 'package:flutter/material.dart';
import 'package:flutter_animator/animation/animation_preferences.dart';
import 'package:flutter_animator/animation/animator_play_states.dart';
import 'package:flutter_animator/widgets/attention_seekers/rubber_band.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:fl_chart/fl_chart.dart';
import 'magament_account/login.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'magament_account/register_user.dart';
import '../models/Persona.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'dart:async';
import 'dart:math';



import 'models/route.dart';


void main() async {
  await Hive.initFlutter();
  await Hive.openBox('usuarios');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Login(),
    );
  }
}



class MyHomePage extends StatefulWidget {
  @override
  final String userName;

  MyHomePage({required this.userName});
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 2;

  final List<Widget> _screens = [
    SaludScreen(),
    RutasScreen(),
    ClimaScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido ${widget.userName}'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Salud",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "Rutas",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: "Clima",
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

class SaludScreen extends StatefulWidget {
  @override
  _SaludScreenState createState() => _SaludScreenState();
}

class _SaludScreenState extends State<SaludScreen> {
  late double pulsoCardiaco = 70; // Inicializar pulsoCardiaco

  double presionArterial = 120;

  @override
  void initState() {
    super.initState();

    // Iniciar la medición del pulso cada 5 segundos
    Timer.periodic(Duration(seconds: 5), (timer) {
      // Generar valores aleatorios para simular la medición del pulso
      setState(() {
        pulsoCardiaco = Random().nextInt(60) + 70; // Rango entre 70 y 130
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),

          // Barra de pulso cardíaco
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Pulso Cardiaco:'),
                SizedBox(width: 10),
                PulseBar(pulsoCardiaco),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Datos cardiacos
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Datos Cardiacos'),
                  SizedBox(height: 10),
                  Text('Pulso: ${pulsoCardiaco.round()} bpm'),
                  Text('Presión Arterial: ${presionArterial.round()} mmHg'),
                ],
              ),
            ),
          ),

          // Animación de corazón latiendo
          SizedBox(height: 20),
          HeartBeatAnimation(),

          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class PulseBar extends StatelessWidget {
  final double pulso;

  PulseBar(this.pulso);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, // Establecer un ancho explícito
      child: LinearProgressIndicator(
        value: pulso / 100,
        color: Colors.red,
        backgroundColor: Colors.grey,
      ),
    );
  }
}

class HeartBeatAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RubberBand(
      child: Icon(
        Icons.favorite,
        color: Colors.red,
        size: 50,
      ),
    );
  }
}



class RouteCard extends StatefulWidget {
  final RouteData route;

  RouteCard({required this.route});

  @override
  _RouteCardState createState() => _RouteCardState();
}

class _RouteCardState extends State<RouteCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Manejar el evento onTap aquí
        print('Card Tapped!');
        _showRouteDetails(context);
      },
      onHover: (hovering) {
        setState(() {
          isHovered = hovering;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
          color: isHovered ? Colors.blue : Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: Text(
                widget.route.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                widget.route.description,
                style: TextStyle(fontSize: 14),
              ),
              leading: widget.route.photoUrl != null
                  ? Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(widget.route.photoUrl!),
                  ),
                ),
              )
                  : SizedBox.shrink(),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.yellow),
                  Text(widget.route.score),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Manejar el evento del botón "Ver Ruta"
                _showRouteDetails(context);
              },
              child: Text('Ver Ruta'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRouteDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Nombre: ${widget.route.name}'),
              Text('Descripción: ${widget.route.description}'),
              Text('Estrellas: ${widget.route.score}'),
              SizedBox(height: 16),
              // Aquí puedes agregar la foto panorámica
              widget.route.photoUrl != null
                  ? Image.network(
                widget.route.photoUrl!,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              )
                  : SizedBox.shrink(),
              SizedBox(height: 16),

    Container(
    height: 200,
    child: GoogleMap(
    initialCameraPosition: CameraPosition(
    target: LatLng(0, 0),
    zoom: 15,
    ),
    markers: {
    Marker(
    markerId: MarkerId('ruta'),
    position: LatLng(0, 0),
    infoWindow: InfoWindow(
    title: 'Ruta',
    snippet: 'Ubicación de la ruta',
    ),
    ),
    },
    ),
    ),
            ],
          ),
        );
      },
    );
  }
}



class RutasScreen extends StatelessWidget {
  Future<List<RouteData>> fetchRoutes() async {
    final response = await http.get(Uri.parse('https://backendiot.azurewebsites.net/api/routes'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      return data.map((route) {
        return RouteData(
          name: route['name'],
          photoUrl: route['photourl'],
          description: route['description'],
          score: route['score'],
        );
      }).toList();
    } else {
      throw Exception('Error al cargar las rutas');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RouteData>>(
      future: fetchRoutes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No se encontraron rutas.'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (context, index) {
              final route = snapshot.data?[index];
              if (route != null) {
                return RouteCard(route: route);
              } else {
                return SizedBox.shrink();
              }
            },
          );
        }
      },
    );
  }
}

class ClimaScreen extends StatefulWidget {
  @override
  _ClimaScreenState createState() => _ClimaScreenState();
}

class _ClimaScreenState extends State<ClimaScreen> {
  List<CityWeatherData> cityWeatherData = [];
  final apiKey = 'c5df7aa6bc367505265274d82813805c';
  final coordinates = [
    {'lat': -13.5170887, 'lon': -71.9785356},
    {'lat': -12.068098, 'lon': -75.2100953},
    {'lat': -14.0764407, 'lon': -72.7210075},
    {'lat': -13.1604269, 'lon': -74.2256973},
    {'lat': -16.3988667, 'lon': -71.5369607},
    {'lat': -11.5985493, 'lon': -76.1931885},
    {'lat': -11.4199882, 'lon': -75.6877142},
  ];

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    for (var coord in coordinates) {
      final lat = coord['lat'];
      final lon = coord['lon'];

      final weatherResponse = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey'),
      );

      if (weatherResponse.statusCode == 200) {
        final Map<String, dynamic> weatherData =
        json.decode(weatherResponse.body);

        final String cityName = weatherData['name'];
        final String description = weatherData['weather'][0]['description'];
        final double temperature = (weatherData['main']['temp'] - 273.15);

        setState(() {
          cityWeatherData.add(CityWeatherData(cityName, description, temperature,
              weatherData, lat!, lon!));
        });
      } else {
        print('Error al obtener datos climáticos para lat=$lat, lon=$lon');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return cityWeatherData.isEmpty
        ? Center(child: Text('No se encontraron datos climáticos.'))
        : ListView.builder(
      itemCount: cityWeatherData.length,
      itemBuilder: (context, index) {
        final weatherData = cityWeatherData[index];
        return WeatherCard(
          weatherData: weatherData,
          onPressed: () {
            _showDetailsModal(context, weatherData);
          },
        );
      },
    );
  }

  void _showDetailsModal(BuildContext context, CityWeatherData weatherData) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Temperatura Mínima: ${weatherData.minTemperature.toStringAsFixed(1)}°C'),
              Text('Temperatura Máxima: ${weatherData.maxTemperature.toStringAsFixed(1)}°C'),
              Text('Humedad: ${weatherData.humidity}%'),
              Text('Ubicación: Lat ${weatherData.lat}, Lon ${weatherData.lon}'),

              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class CityWeatherData {
  final String name;
  final String description;
  final double temperature;
  final double minTemperature;
  final double maxTemperature;
  final int humidity;
  final double lat;
  final double lon;

  CityWeatherData(this.name, this.description, this.temperature,
      Map<String, dynamic> weatherData, this.lat, this.lon)
      : minTemperature = weatherData['main']['temp_min'] - 273.15,
        maxTemperature = weatherData['main']['temp_max'] - 273.15,
        humidity = weatherData['main']['humidity'];
}

class WeatherCard extends StatelessWidget {
  final CityWeatherData weatherData;
  final VoidCallback onPressed;

  WeatherCard({required this.weatherData, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                weatherData.name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Clima: ${weatherData.description}'),
                  Text('Temperatura: ${weatherData.temperature.toStringAsFixed(1)}°C'),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PopupMenuButton(
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                        child: Text('Ver Detalles'),
                        value: 'details',
                      ),
                    ];
                  },
                  onSelected: (value) {
                    if (value == 'details') {
                      onPressed();
                    }
                  },
                  icon: Icon(Icons.more_vert),
                ),
              ],
            ),
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  Image.asset(
                    'assets/cloudy.gif',
                    fit: BoxFit.cover,
                    width: 45,
                    height: 45,
                  ),
                  LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            FlSpot(0, weatherData.maxTemperature),
                            FlSpot(1, weatherData.minTemperature+7),
                            FlSpot(2, weatherData.minTemperature+5),
                            FlSpot(3, weatherData.minTemperature),
                          ],
                          isCurved: true,
                          colors: [Colors.black38],
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                          color: const Color(0xff37434d),
                          width: 1,
                        ),
                      ),
                      minX: 0,
                      maxX: 3,
                      minY: 0,
                      maxY: 30,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}