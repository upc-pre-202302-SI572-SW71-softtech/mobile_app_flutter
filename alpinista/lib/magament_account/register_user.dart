import 'package:flutter/material.dart';
import '../main.dart';
import '../models/Persona.dart';
import 'package:hive_flutter/hive_flutter.dart';

class RegisterUser extends StatefulWidget {
  @override
  _RegisterUserState createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dniController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isMale = false;
  bool _isFemale = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final person = User(
        name: _nameController.text,
        lastName: _lastNameController.text,
        phoneNumber: _phoneController.text,
        dni: _dniController.text,
        age: int.parse(_ageController.text),
        email: _emailController.text,
        gender: _isMale ? 'Male' : 'Female',
        password: _passwordController.text,
      );

      final box = await Hive.openBox('users');
      box.add(person.toMap());

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => MyHomePage(userName: person.getFullName()),
        ),
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('User Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                },
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(height: 12.0),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                },
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(height: 12.0),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                },
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(height: 12.0),
              TextFormField(
                controller: _dniController,
                decoration: InputDecoration(labelText: 'DNI'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                },
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(height: 12.0),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Age'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                },
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(height: 12.0),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                },
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(height: 12.0),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                },
                obscureText: true,
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(height: 12.0),
              Row(
                children: [
                  Checkbox(
                    value: _isMale,
                    onChanged: (value) {
                      setState(() {
                        _isMale = value!;
                        _isFemale = !value;
                      });
                    },
                  ),
                  Text('Male', style: TextStyle(color: Colors.black)),
                  SizedBox(width: 16.0),
                  Checkbox(
                    value: _isFemale,
                    onChanged: (value) {
                      setState(() {
                        _isFemale = value!;
                        _isMale = !value;
                      });
                    },
                  ),
                  Text('Female', style: TextStyle(color: Colors.black)),
                ],
              ),
              Container(
                height: 80.0,
                margin: EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black54,
                    padding: EdgeInsets.all(20.0),
                  ),
                  child: Text(
                    'Register',
                    style: TextStyle(fontSize: 18.0),
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