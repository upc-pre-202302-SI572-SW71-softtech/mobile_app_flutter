import 'package:flutter/material.dart';

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
        title: Text("alpinista"),
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

class ClimaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Aquí puedes usar un ListView para mostrar los datos climáticos.
    return ListView.builder(
      itemCount: mountainWeatherData.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(mountainWeatherData[index].name),
          subtitle: Text(mountainWeatherData[index].weatherInfo),
          // Otros detalles climáticos
        );
      },
    );
  }
}

class MountainWeatherData {
  final String name;
  final String weatherInfo;

  MountainWeatherData(this.name, this.weatherInfo);
}

final List<MountainWeatherData> mountainWeatherData = [
  MountainWeatherData("Montaña 1", "Soleado, 25°C"),
  MountainWeatherData("Montaña 2", "Nublado, 20°C"),
  // Agrega más datos de montaña según sea necesario
];
