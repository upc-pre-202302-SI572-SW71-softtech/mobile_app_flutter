import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:hive/hive.dart';
import 'package:fl_chart/fl_chart.dart';


class PulseModelAdapter extends TypeAdapter<PulseModel> {
@override
final int typeId = 32;

@override
PulseModel read(BinaryReader reader) {
  return PulseModel(reader.readDouble());
}

@override
void write(BinaryWriter writer, PulseModel obj) {
  writer.writeDouble(obj.pulso);
}
}

class PulseModel {
  late double pulso;

  PulseModel(this.pulso);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        // Espera a que se abra la caja antes de construir la pantalla principal
        future: Hive.openBox<PulseModel>('pulses'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SaludScreen();
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

class SaludScreen extends StatefulWidget {
  @override
  _SaludScreenState createState() => _SaludScreenState();
}

class _SaludScreenState extends State<SaludScreen> with TickerProviderStateMixin {
  late double pulsoCardiaco = 60;
  late double presionArterial = 120;

  late AnimationController _heartBeatController;
  late Timer _heartBeatTimer;
  late List<PulseModel> pulses;

  @override
  void initState() {
    super.initState();

    _heartBeatController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _heartBeatController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    // Inicializa el temporizador del latido con una duración predeterminada
    _heartBeatTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      _heartBeatController.forward(from: 0.0);
    });

    pulses = [];

    Timer.periodic(Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          pulsoCardiaco = Random().nextInt(60) + 70;
          _savePulseToHive(pulsoCardiaco);
        });
      }
    });

    Timer.periodic(Duration(seconds: 60), (timer) {
      if (mounted) {
        setState(() {
          presionArterial = Random().nextInt(141) + 20;
          _restartHeartBeatTimer();
        });
      }
    });

    // Obtén los pulsos almacenados al inicio
    _getStoredPulses();
  }

  void _restartHeartBeatTimer() {
    _heartBeatTimer.cancel();

    final duration = Duration(seconds: 2 + (161 - presionArterial).clamp(0, 159).toInt());

    _heartBeatTimer = Timer.periodic(duration, (timer) {
      _heartBeatController.forward(from: 0.0);
    });
  }

  void _savePulseToHive(double pulsoCardiaco) async {
    final hiveBox = await Hive.openBox<PulseModel>('pulses');

    final pulseModel = PulseModel(pulsoCardiaco);
    hiveBox.add(pulseModel);

    if (hiveBox.length > 20) {
      hiveBox.deleteAt(0);
    }
  }

  void _getStoredPulses() async {
    final hiveBox = Hive.box<PulseModel>('pulses');
    setState(() {
      pulses = hiveBox.values.toList().cast<PulseModel>();
    });

    print("Pulses: $pulses");
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Heartbeat:',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10),
                PulseBar(pulsoCardiaco),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Datos cardiacos
          Card(
            color: Colors.grey[800],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Cardiac Data',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Pulse: ${pulsoCardiaco.round()} bpm',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Blood pressure: ${presionArterial.round()} mmHg',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Animación de corazón latiendo
          SizedBox(height: 20),
          HeartBeatAnimation(controller: _heartBeatController),

          SizedBox(height: 20),

          SizedBox(height: 20),
          Container(
            height: 300,
            child: Card(
              color: Colors.white54,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Heart Rate History',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: LineChart(
                        LineChartData(
                          // Configuración del gráfico de líneas
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: const Color(0xff37434d),
                              width: 1,
                            ),
                          ),
                          minX: 0,
                          maxX: pulses.isNotEmpty ? pulses.length.toDouble() - 1 : 0,
                          minY: 0,
                          maxY: pulses.isNotEmpty ? pulses.map((pulse) => pulse.pulso).reduce((a, b) => a > b ? a : b) + 10 : 100,
                          lineBarsData: [
                            LineChartBarData(
                              spots: List.generate(
                                pulses.length,
                                    (index) => FlSpot(index.toDouble(), pulses[index].pulso),
                              ),
                              isCurved: true,
                              colors: [Colors.red],
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _heartBeatController.dispose();
    _heartBeatTimer.cancel();
    super.dispose();
  }
}

class PulseBar extends StatelessWidget {
  final double pulso;

  PulseBar(this.pulso);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      child: LinearProgressIndicator(
        value: pulso / 100,
        color: Colors.red,
        backgroundColor: Colors.grey,
      ),
    );
  }
}

class HeartBeatAnimation extends StatelessWidget {
  final AnimationController controller;

  HeartBeatAnimation({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Pulse(
          child: Transform.scale(
            scale: Tween<double>(begin: 1.2, end: 1.0).animate(controller).value,
            child: Icon(
              Icons.favorite,
              color: Colors.red,
              size: 300,
            ),
          ),
        );
      },
    );
  }
}