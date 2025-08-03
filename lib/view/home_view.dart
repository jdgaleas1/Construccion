import 'package:flutter/material.dart';
import 'package:lata_emprende/controller/home_controller.dart';
import 'package:lata_emprende/models/emprendimiento_model.dart';
import 'package:lata_emprende/models/producto_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with AutomaticKeepAliveClientMixin {
  final HomeController _homeController = HomeController();
  List<Map<String, dynamic>> _productos = [];
  bool _cargando = true;
  String? _errorMessage;

  // Mantener el estado cuando cambia de pestañas
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _cargarProductosSafely();
  }

  Future<void> _cargarProductosSafely() async {
    if (!mounted) return;

    setState(() {
      _cargando = true;
      _errorMessage = null;
    });

    try {
      final productos = await _homeController.obtenerTodosLosProductos();

      if (mounted) {
        setState(() {
          _productos = productos;
          _cargando = false;
        });
      }
    } catch (e) {
      print('Error al cargar productos en HomeView: $e');

      if (mounted) {
        setState(() {
          _productos = [];
          _cargando = false;
          _errorMessage = 'Error al cargar productos. Toca para reintentar.';
        });
      }
    }
  }

  void _mostrarDetalleProducto(
    ProductoModel producto,
    EmprendimientoModel emprendimiento,
  ) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen del producto
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image, size: 60, color: Colors.grey),
              ),

              const SizedBox(height: 16),

              // Precio destacado
              Center(
                child: Text(
                  '\$${producto.precio.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Título descripción
              const Text(
                'Descripción',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              // Descripción del producto
              Text(
                producto.descripcion.isNotEmpty
                    ? producto.descripcion
                    : 'Sin descripción disponible',
                style: const TextStyle(fontSize: 14),
              ),

              const SizedBox(height: 16),

              // Info del emprendimiento
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Emprendimiento:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      emprendimiento.nombre,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ubicación: ${emprendimiento.ubicacion}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Funcionalidad de contactar (próximamente)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Contactar a ${emprendimiento.nombre}'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Contactar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.red),
          const SizedBox(height: 20),
          Text(
            _errorMessage ?? 'Error desconocido',
            style: const TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _cargarProductosSafely,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text(
              'Reintentar',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'No hay productos disponibles',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          const Text(
            'Los emprendedores pueden agregar productos desde la pestaña "Productos"',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _cargarProductosSafely,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text(
              'Actualizar',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necesario para AutomaticKeepAliveClientMixin

    return RefreshIndicator(
      onRefresh: _cargarProductosSafely,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Row(
              children: [
                Icon(Icons.storefront, size: 28, color: Colors.redAccent),
                SizedBox(width: 10),
                Text(
                  'Productos Disponibles',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Contenido principal
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? _buildErrorWidget()
                  : _productos.isEmpty
                  ? _buildEmptyWidget()
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: _productos.length,
                      itemBuilder: (context, index) {
                        try {
                          final item = _productos[index];
                          final producto = item['producto'] as ProductoModel;
                          final emprendimiento =
                              item['emprendimiento'] as EmprendimientoModel;

                          return GestureDetector(
                            onTap: () => _mostrarDetalleProducto(
                              producto,
                              emprendimiento,
                            ),
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Imagen del producto
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(12),
                                            ),
                                      ),
                                      child: const Icon(
                                        Icons.image,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),

                                  // Info del producto
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Nombre del producto
                                          Text(
                                            producto.nombre.isNotEmpty
                                                ? producto.nombre
                                                : 'Sin nombre',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),

                                          const SizedBox(height: 4),

                                          // Precio
                                          Text(
                                            '\$${producto.precio.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: Colors.redAccent,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),

                                          const Spacer(),

                                          // Nombre del emprendimiento
                                          Text(
                                            emprendimiento.nombre.isNotEmpty
                                                ? emprendimiento.nombre
                                                : 'Sin nombre',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } catch (e) {
                          print(
                            'Error al renderizar producto en índice $index: $e',
                          );
                          return const Card(
                            child: Center(
                              child: Text(
                                'Error al cargar producto',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          );
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
