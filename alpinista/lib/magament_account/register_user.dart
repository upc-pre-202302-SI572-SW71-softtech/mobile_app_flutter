import 'package:flutter/material.dart';
import '../main.dart';
import '../models/Persona.dart';

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

  void _registrar() {
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
      print(persona);

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => MyHomePage(),
        ),
            (Route<dynamic> route) => false,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Usuario'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
              TextFormField(
                controller: _telefonoController,
                decoration: InputDecoration(labelText: 'Telefono'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
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
              ElevatedButton(
                onPressed: _registrar,
                child: Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
