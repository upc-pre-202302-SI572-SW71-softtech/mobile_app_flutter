import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

import '../models/weather.dart';

class ClimaScreen extends StatefulWidget {
  @override
  _ClimaScreenState createState() => _ClimaScreenState();
}

class _ClimaScreenState extends State<ClimaScreen> {
  List<DeviceData> deviceDataList = [];
  final apiUrl = 'https://backendiot.azurewebsites.net/api/devices/param';

  @override
  void initState() {
    super.initState();
    fetchDeviceData();
  }

  Future<void> fetchDeviceData() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        deviceDataList = data.map((item) => DeviceData.fromJson(item)).toList();
      });
    } else {
      print('Error al obtener datos de la API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return deviceDataList.isEmpty
        ? Center(child: Text('No se encontraron datos de dispositivos.'))
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
            itemCount: deviceDataList.length,
            itemBuilder: (context, index) {
              final deviceData = deviceDataList[index];
              return DeviceCard(deviceData: deviceData);
            },
          ),
        ],
      ),
    );
  }
}


class DeviceCard extends StatelessWidget {
  final DeviceData deviceData;

  DeviceCard({required this.deviceData});

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
                'Position - ${deviceData.id}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 20,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Temperatura: ${deviceData.temperature.toStringAsFixed(1)}°C',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Humedad: ${deviceData.humidity}%',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
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
                            FlSpot(0, deviceData.temperature),
                            // Ajusta estos puntos según tus necesidades
                            FlSpot(1, deviceData.temperature + 5),
                            FlSpot(2, deviceData.temperature - 3),
                            FlSpot(3, deviceData.temperature + 2),
                            FlSpot(4, deviceData.temperature - 1),
                            FlSpot(5, deviceData.temperature + 4),
                            FlSpot(6, deviceData.temperature - 2),
                            FlSpot(7, deviceData.temperature),
                          ],
                          isCurved: true,
                          colors: [Colors.blue],
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      minX: 0,
                      maxX: 7,
                      minY: deviceData.temperature - 5,
                      maxY: deviceData.temperature + 5,
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