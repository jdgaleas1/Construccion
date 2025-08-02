import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lata_emprende/models/usuario_model.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Encriptar contraseña usando SHA-256
  String _encryptPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Registrar usuario SOLO en Firestore (sin Firebase Auth)
  Future<String> registrarUsuario({
    required String nombre,
    required String apellido,
    required String correo,
    required String telefono,
    required String contrasena,
    required String tipoUsuario,
  }) async {
    try {
      print('Iniciando registro de usuario en Firestore...');
      print('Correo: $correo');
      print('Teléfono: $telefono');
      print('Tipo de usuario: $tipoUsuario');

      // Verificar si el correo ya existe
      final existeUsuario = await _db
          .collection('usuarios')
          .where('correo', isEqualTo: correo)
          .get();

      if (existeUsuario.docs.isNotEmpty) {
        throw Exception('Este correo ya está registrado');
      }

      // Verificar si el teléfono ya existe
      if (telefono.isNotEmpty) {
        final existeTelefono = await _db
            .collection('usuarios')
            .where('telefono', isEqualTo: telefono)
            .get();

        if (existeTelefono.docs.isNotEmpty) {
          throw Exception('Este número de teléfono ya está registrado');
        }
      }

      // Encriptar la contraseña
      String contrasenaEncriptada = _encryptPassword(contrasena);

      // Crear datos del usuario
      final userData = {
        'nombre': nombre,
        'apellido': apellido,
        'correo': correo,
        'telefono': telefono,
        'contrasena': contrasenaEncriptada,
        'tipo_usuario': tipoUsuario,
        'fecha_registro': DateTime.now().toIso8601String(),
      };

      print('Guardando datos en Firestore...');
      print('Datos: $userData');

      // Guardar en Firestore con ID automático
      final docRef = await _db.collection('usuarios').add(userData);

      print('Usuario registrado exitosamente con ID: ${docRef.id}');
      return docRef.id;
    } on FirebaseException catch (e) {
      print('FirebaseException: ${e.code} - ${e.message}');
      throw Exception('Error en Firebase: ${e.message}');
    } catch (e) {
      print('Error general al registrar usuario: $e');
      throw Exception('Error al registrar usuario: $e');
    }
  }

  /// Obtener usuario por ID
  Future<UsuarioModel?> obtenerUsuarioPorId(String id) async {
    try {
      final doc = await _db.collection('usuarios').doc(id).get();
      if (doc.exists && doc.data() != null) {
        return UsuarioModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error al obtener usuario: $e');
      throw Exception('Error al obtener datos del usuario: $e');
    }
  }

  /// Obtener usuario por correo
  Future<UsuarioModel?> obtenerUsuarioPorCorreo(String correo) async {
    try {
      final query = await _db
          .collection('usuarios')
          .where('correo', isEqualTo: correo)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        return UsuarioModel.fromJson(doc.data(), doc.id);
      }
      return null;
    } catch (e) {
      print('Error al obtener usuario por correo: $e');
      throw Exception('Error al obtener usuario: $e');
    }
  }

  /// Validar login (correo y contraseña)
  Future<UsuarioModel?> validarLogin(String correo, String contrasena) async {
    try {
      final usuario = await obtenerUsuarioPorCorreo(correo);

      if (usuario == null) {
        throw Exception('Usuario no encontrado');
      }

      // Verificar contraseña
      String contrasenaEncriptada = _encryptPassword(contrasena);
      if (usuario.contrasena != contrasenaEncriptada) {
        throw Exception('Contraseña incorrecta');
      }

      return usuario;
    } catch (e) {
      print('Error en validación de login: $e');
      rethrow;
    }
  }

  /// Actualizar usuario
  Future<void> actualizarUsuario({
    required String id,
    required String nombre,
    required String apellido,
    required String telefono,
  }) async {
    try {
      await _db.collection('usuarios').doc(id).update({
        'nombre': nombre,
        'apellido': apellido,
        'telefono': telefono,
      });
    } catch (e) {
      print('Error al actualizar usuario: $e');
      throw Exception('Error al actualizar usuario: $e');
    }
  }
}
