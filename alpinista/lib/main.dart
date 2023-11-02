import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ClimaScreen extends StatefulWidget {
  @override
  _ClimaScreenState createState() => _ClimaScreenState();
}

class _ClimaScreenState extends State<ClimaScreen> {
  List<CityWeatherData> cityWeatherData = [];
  final apiKey = 'c5df7aa6bc367505265274d82813805c';
  final apiKeyc = '6ea050e80616dec93583899563cd6f1c';
  final cityNames = ['Cuzco', 'Cerro de Pasco', 'Huancayo', 'Ayacucho'];

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    for (var cityName in cityNames) {
      final geoResponse = await http.get(
        Uri.parse('http://api.openweathermap.org/geo/1.0/direct?q=$cityName&limit=1&appid=$apiKey'),
      );

      if (geoResponse.statusCode == 200) {
        final List<dynamic> geoData = json.decode(geoResponse.body);
        if (geoData.isNotEmpty) {
          final Map<String, dynamic> cityData = geoData[0];
          final lat = cityData['lat'];
          final lon = cityData['lon'];
          final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000; // Tiempo actual en formato UNIX

          final historyResponse = await http.get(
            Uri.parse('https://api.openweathermap.org/data/3.0/onecall/timemachine?lat=$lat&lon=$lon&dt=$currentTime&appid=$apiKeyc'),
          );

          if (historyResponse.statusCode == 200) {
            final Map<String, dynamic> data = json.decode(historyResponse.body);
            final String description = data['current']['weather'][0]['description'];
            final double temperature = data['current']['temp'] - 273.15; // Temperatura en grados Celsius

            setState(() {
              cityWeatherData.add(CityWeatherData(cityName, description, temperature));
            });
          } else {
            // Manejar errores
            print('Error al cargar datos históricos para $cityName');
          }
        } else {
          // Manejar errores
          print('No se encontraron coordenadas para $cityName');
        }
      } else {
        // Manejar errores
        print('Error al obtener coordenadas para $cityName');
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
        return ListTile(
          title: Text(weatherData.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Clima: ${weatherData.description}'),
              Text('Temperatura: ${weatherData.temperature.toStringAsFixed(1)}°C'),
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

  CityWeatherData(this.name, this.description, this.temperature);
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    SaludScreen(),
    RutasScreen(),
    ClimaScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Alpinista"),
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
