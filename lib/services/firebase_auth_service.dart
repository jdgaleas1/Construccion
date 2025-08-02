import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Registrar usuario con email y contraseña
  Future<User?> registerUser({
    required String nombre,
    required String apellido,
    required String correo,
    required String contrasena,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: correo,
        password: contrasena,
      );

      // Guardar datos en Firestore
      await _db.collection('usuarios').doc(credential.user!.uid).set({
        'nombre': nombre,
        'apellido': apellido,
        'correo': correo,
        'tipo_usuario': 'consumidor', // o 'emprendedor'
        'telefono': '',
        'fecha_registro': DateTime.now().toIso8601String(),
      });

      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error al registrar usuario: $e');
    }
  }
}
