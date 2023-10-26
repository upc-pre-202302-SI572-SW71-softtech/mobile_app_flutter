class User {
  String name;
  String lastName;
  String phoneNumber;
  String dni;
  int age;
  String email;
  String gender;

  User({
    required this.name,
    required this.lastName,
    required this.phoneNumber,
    required this.dni,
    required this.age,
    required this.email,
    required this.gender,
  });

  @override
  String toString() {
    return 'Name: $name\nLastName: $lastName\nPhoneNumber: $phoneNumber\nDNI: $dni\nAge: $age\nEmail: $email\nGender: $gender';
  }
}
