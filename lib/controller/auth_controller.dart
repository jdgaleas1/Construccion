import 'package:flutter/material.dart';
import '../services/firebase_auth_service.dart';

class AuthController {
  final FirebaseAuthService _authService = FirebaseAuthService();

  Future<void> registrarUsuario({
    required BuildContext context,
    required String nombres,
    required String apellidos,
    required String correo,
    required String contrasena,
  }) async {
    try {
      final user = await _authService.registerUser(
        nombre: nombres,
        apellido: apellidos,
        correo: correo,
        contrasena: contrasena,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('¡Registro exitoso!')));
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }
}
