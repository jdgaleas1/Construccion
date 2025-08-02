class UsuarioModel {
  final String idUsuario;
  final String nombre;
  final String correo;
  final String contrasena;
  final String tipoUsuario; // 'emprendedor' o 'consumidor'
  final String telefono;
  final DateTime fechaRegistro;

  UsuarioModel({
    required this.idUsuario,
    required this.nombre,
    required this.correo,
    required this.contrasena,
    required this.tipoUsuario,
    required this.telefono,
    required this.fechaRegistro,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json, String id) {
    return UsuarioModel(
      idUsuario: id,
      nombre: json['nombre'],
      correo: json['correo'],
      contrasena: json['contrasena'],
      tipoUsuario: json['tipo_usuario'],
      telefono: json['telefono'],
      fechaRegistro: DateTime.parse(json['fecha_registro']),
    );
  }

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'correo': correo,
    'contrasena': contrasena,
    'tipo_usuario': tipoUsuario,
    'telefono': telefono,
    'fecha_registro': fechaRegistro.toIso8601String(),
  };
}
