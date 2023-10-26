class Persona {
  String nombre;
  String apellido;
  String telefono;
  String dni;
  int edad;
  String correo;
  String genero;

  Persona({
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.dni,
    required this.edad,
    required this.correo,
    required this.genero,
  });

  @override
  String toString() {
    return 'Nombre: $nombre\nApellido: $apellido\nTelefono: $telefono\nDNI: $dni\nEdad: $edad\nCorreo: $correo\nGenero: $genero';
  }
}
