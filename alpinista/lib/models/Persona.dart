import 'package:hive/hive.dart';

class User {
  final String name;
  final String lastName;
  final String phoneNumber;
  final String dni;
  final int age;
  final String email;
  final String gender;
  final String password;

  User({
    required this.name,
    required this.lastName,
    required this.phoneNumber,
    required this.dni,
    required this.age,
    required this.email,
    required this.gender,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'dni': dni,
      'age': age,
      'email': email,
      'gender': gender,
      'password': password,
    };
  }

  static User? authenticate(String email, String password) {
    final box = Hive.box('usuarios');

    final user = box.values.firstWhere(
          (user) => user['email'] == email,
      orElse: () => null,
    );

    if (user != null && user['password'] == password) {
      return User(
        name: user['name'],
        lastName: user['lastName'],
        phoneNumber: user['phoneNumber'],
        dni: user['dni'],
        age: user['age'],
        email: user['email'],
        gender: user['gender'],
        password: user['password'],
      );
    } else {
      return null;
    }
  }
  String getFullName() {
    return '$name $lastName';
  }

}
