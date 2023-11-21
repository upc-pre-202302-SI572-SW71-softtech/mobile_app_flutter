import 'package:flutter/material.dart';
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

class SaludScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Vista de Salud"),
    );
  }
}

class RutasScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Vista de Rutas"),
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