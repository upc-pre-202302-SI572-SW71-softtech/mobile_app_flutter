import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/route.dart';


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