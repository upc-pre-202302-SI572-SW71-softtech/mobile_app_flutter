import 'package:flutter/material.dart';
import '../main.dart';
import '../models/Persona.dart';
import 'package:hive_flutter/hive_flutter.dart';


class RegistrarUsuario extends StatefulWidget {
  @override
  _RegistrarUsuarioState createState() => _RegistrarUsuarioState();
}

class _RegistrarUsuarioState extends State<RegistrarUsuario> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _dniController = TextEditingController();
  final _edadController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isMasculino = false;
  bool _isFemenino = false;

  void _registrar() async {
    if (_formKey.currentState!.validate()) {
      final persona = User(
        name: _nombreController.text,
        lastName: _apellidoController.text,
        phoneNumber: _telefonoController.text,
        dni: _dniController.text,
        age: int.parse(_edadController.text),
        email: _correoController.text,
        gender: _isMasculino ? 'Masculino' : 'Femenino',
        password: _passwordController.text,
      );


      final box = await Hive.openBox('usuarios');
      box.add(persona.toMap());

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => MyHomePage(userName: persona.getFullName()),
        ),
            (Route<dynamic> route) => false,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Usuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.0),
              TextFormField(
                controller: _apellidoController,
                decoration: InputDecoration(labelText: 'Apellido'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.0),
              TextFormField(
                controller: _telefonoController,
                decoration: InputDecoration(labelText: 'Teléfono'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.0),
              TextFormField(
                controller: _dniController,
                decoration: InputDecoration(labelText: 'DNI'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.0),
              TextFormField(
                controller: _edadController,
                decoration: InputDecoration(labelText: 'Edad'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.0),
              TextFormField(
                controller: _correoController,
                decoration: InputDecoration(labelText: 'Correo'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.0),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Contraseña'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
                obscureText: true,
              ),
              SizedBox(height: 12.0),
              Row(
                children: [
                  Checkbox(
                    value: _isMasculino,
                    onChanged: (value) {
                      setState(() {
                        _isMasculino = value!;
                        _isFemenino = !value;
                      });
                    },
                  ),
                  Text('Masculino'),
                  SizedBox(width: 16.0),
                  Checkbox(
                    value: _isFemenino,
                    onChanged: (value) {
                      setState(() {
                        _isFemenino = value!;
                        _isMasculino = !value;
                      });
                    },
                  ),
                  Text('Femenino'),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 80.0,
                  margin: EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    onPressed: _registrar,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(20.0),
                    ),
                    child: Text(
                      'Registrar',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
