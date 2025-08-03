import 'package:lata_emprende/models/emprendimiento_model.dart';
import 'package:lata_emprende/models/producto_model.dart';
import 'package:lata_emprende/services/firebase_auth_service.dart';

class HomeController {
  final FirestoreService _firestoreService = FirestoreService();

  /// Obtener todos los productos con sus emprendimientos
  Future<List<Map<String, dynamic>>> obtenerTodosLosProductos() async {
    try {
      final productos = await _firestoreService.obtenerTodosLosProductos();

      // Filtrar productos válidos
      final productosValidos = productos.where((item) {
        final producto = item['producto'] as ProductoModel?;
        final emprendimiento = item['emprendimiento'] as EmprendimientoModel?;

        return producto != null &&
            emprendimiento != null &&
            producto.nombre.isNotEmpty &&
            emprendimiento.nombre.isNotEmpty;
      }).toList();

      return productosValidos;
    } catch (e) {
      print('Error en HomeController.obtenerTodosLosProductos: $e');
      rethrow; // Re-lanza el error para que HomeView lo maneje
    }
  }
}
