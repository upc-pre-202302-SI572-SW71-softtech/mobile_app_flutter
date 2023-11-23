import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/route.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
          color: isHovered ? Colors.orangeAccent : Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: Text(
                widget.route.name,
                style: TextStyle(
                  fontSize: 33,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              subtitle: Text(
                widget.route.description,
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              leading: _buildLeadingWidget(),
              trailing: _buildTrailingWidget(),
            ),
            ElevatedButton(
              onPressed: () {
                _showRouteDetails(context);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.orangeAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Ver Ruta',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingWidget() {
    return widget.route.photoUrl != null
        ? Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Image.network(
        widget.route.photoUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {
            return child;
          } else {
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
              ),
            );
          }
        },
        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
          print("Error loading image: $error");
          return Icon(Icons.error);
        },
      ),
    )
        : SizedBox.shrink();
  }

  // Helper method to build the trailing widget (stars and score)
  Widget _buildTrailingWidget() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, color: Colors.yellow),
        Text(
          widget.route.score,
          style: TextStyle(fontSize: 20, color: Colors.grey),
        ),
      ],
    );
  }

  void _showRouteDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          content: Container(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                Text(
                  'Nombre: ${widget.route.name}',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 8),
                if (widget.route.photoUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.route.photoUrl!,
                      height: 150, // Adjust the height as needed
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class RutasScreen extends StatelessWidget {
  Future<List<RouteData>> fetchRoutes() async {
    try {
      final response = await http.get(Uri.parse('https://backendiot.azurewebsites.net/api/routes'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('API Response: $data');

        return data.map((route) {
          return RouteData(
            name: route['name'],
            photoUrl: route['photoUrl'],
            description: route['description'],
            score: route['score'],
          );
        }).toList();
      } else {
        print('Error al cargar las rutas - Código: ${response.statusCode}');
        return [];
      }
    } catch (error) {
      print('Error al cargar las rutas: $error');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/montanas.gif'),
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder<List<RouteData>>(
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
                padding: EdgeInsets.all(16),
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
        ),
      ),
    );
  }
}