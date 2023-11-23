import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';


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
        : Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/clima.gif',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          ListView.builder(
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
          ),
        ],
      ),
    );
  }

  void _showDetailsModal(BuildContext context, CityWeatherData weatherData) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 500),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detalles del Clima',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Temperatura Mínima: ${weatherData.minTemperature.toStringAsFixed(1)}°C',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              Text(
                'Temperatura Máxima: ${weatherData.maxTemperature.toStringAsFixed(1)}°C',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              Text(
                'Humedad: ${weatherData.humidity}%',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              Text(
                'Ubicación: Lat ${weatherData.lat}, Lon ${weatherData.lon}',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cerrar'),
              ),
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
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.4),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                weatherData.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 26,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Clima: ${weatherData.description}',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Temperatura: ${weatherData.temperature.toStringAsFixed(1)}°C',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
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
                        child: Text(
                          'Ver Detalles',
                          style: TextStyle(color: Colors.blue),
                        ),
                        value: 'details',
                      ),
                    ];
                  },
                  onSelected: (value) {
                    if (value == 'details') {
                      onPressed();
                    }
                  },
                  icon: Icon(Icons.more_vert, color: Colors.blue),
                ),
              ],
            ),
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            FlSpot(0, weatherData.maxTemperature),
                            FlSpot(1, weatherData.minTemperature + 7),
                            FlSpot(2, weatherData.minTemperature + 5),
                            FlSpot(3, weatherData.minTemperature + 4),
                            FlSpot(4, weatherData.minTemperature + 3),
                            FlSpot(5, weatherData.minTemperature + 2),
                            FlSpot(6, weatherData.minTemperature + 1),
                            FlSpot(7, weatherData.minTemperature),
                          ],
                          isCurved: true,
                          colors: [Colors.red],
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(show: false),

                        ),
                      ],
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                          color: Colors.blue,
                          width: 1,
                        ),
                      ),
                      minX: 0,
                      maxX: 7,
                      minY: 0,
                      maxY: 32,
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