import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  int _currentIndex = 2; // Cambiado a 2 para que muestre la pantalla de Clima por defecto

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

class ClimaScreen extends StatefulWidget {
  @override
  _ClimaScreenState createState() => _ClimaScreenState();
}

class _ClimaScreenState extends State<ClimaScreen> {
  List<CityWeatherData> cityWeatherData = [];
  final apiKey = 'c5df7aa6bc367505265274d82813805c';
  final coordinates = [
    {'lat': -13.5170887, 'lon': -71.9785356},
    {'lat': -12.068098 , 'lon': -75.2100953 },
    {'lat': -14.0764407, 'lon': -72.7210075},
    {'lat': -13.1604269 , 'lon':-74.2256973 },
    {'lat': -16.3988667, 'lon':-71.5369607},
    {'lat': -11.5985493, 'lon':-76.1931885},
    {'lat': -11.4199882, 'lon':-75.6877142, },


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
        Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey'),
      );

      if (weatherResponse.statusCode == 200) {
        final Map<String, dynamic> weatherData = json.decode(weatherResponse.body);

        final String cityName = weatherData['name'];
        final String description = weatherData['weather'][0]['description'];
        final double temperature = (weatherData['main']['temp'] - 273.15); // Convert to Celsius

        setState(() {
          cityWeatherData.add(CityWeatherData(cityName, description, temperature));
        });
      } else {
        // Handle errors
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
        return Card(
          child: ListTile(
            title: Text(weatherData.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Clima: ${weatherData.description}'),
                Text('Temperatura: ${weatherData.temperature.toStringAsFixed(1)}°C'),
              ],
            ),
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
