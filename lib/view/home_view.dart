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
  final TextEditingController _busquedaController = TextEditingController();

  List<Map<String, dynamic>> _todosLosProductos = [];
  List<Map<String, dynamic>> _productosFiltrados = [];
  bool _cargando = true;
  String? _errorMessage;
  String _categoriaSeleccionada = 'todas';

  // Categorías disponibles
  final List<String> _categorias = [
    'todas',
    'comida',
    'ropa',
    'artesania',
    'tecnologia',
    'servicios',
    'otros',
  ];

  // Mantener el estado cuando cambia de pestañas
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _cargarProductosSafely();
    _busquedaController.addListener(_aplicarFiltros);
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
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
          _todosLosProductos = productos;
          _productosFiltrados = productos;
          _cargando = false;
        });
      }
    } catch (e) {
      print('Error al cargar productos en HomeView: $e');

      if (mounted) {
        setState(() {
          _todosLosProductos = [];
          _productosFiltrados = [];
          _cargando = false;
          _errorMessage = 'Error al cargar productos. Toca para reintentar.';
        });
      }
    }
  }

  void _aplicarFiltros() {
    if (!mounted) return;

    setState(() {
      _productosFiltrados = _homeController.aplicarFiltros(
        _todosLosProductos,
        _busquedaController.text,
        _categoriaSeleccionada,
      );
    });
  }

  void _cambiarCategoria(String categoria) {
    setState(() {
      _categoriaSeleccionada = categoria;
    });
    _aplicarFiltros();
  }

  void _limpiarBusqueda() {
    _busquedaController.clear();
    setState(() {
      _categoriaSeleccionada = 'todas';
    });
    _aplicarFiltros();
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
                      'Categoría: ${emprendimiento.categoria.toUpperCase()}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
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
    final bool hayBusqueda =
        _busquedaController.text.isNotEmpty ||
        _categoriaSeleccionada != 'todas';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hayBusqueda ? Icons.search_off : Icons.inventory,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          Text(
            hayBusqueda
                ? 'No se encontraron productos'
                : 'No hay productos disponibles',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Text(
            hayBusqueda
                ? 'Intenta con otros términos de búsqueda'
                : 'Los emprendedores pueden agregar productos desde la pestaña "Productos"',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (hayBusqueda)
            ElevatedButton.icon(
              onPressed: _limpiarBusqueda,
              icon: const Icon(Icons.clear, color: Colors.white),
              label: const Text(
                'Limpiar filtros',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: _cargarProductosSafely,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Actualizar',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Column(
      children: [
        // Barra de búsqueda
        TextField(
          controller: _busquedaController,
          decoration: InputDecoration(
            hintText: 'Buscar productos o emprendimientos...',
            prefixIcon: const Icon(Icons.search, color: Colors.redAccent),
            suffixIcon: _busquedaController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _busquedaController.clear(),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.redAccent, width: 2),
            ),
          ),
        ),

        const SizedBox(height: 15),

        // Filtros de categoría
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categorias.length,
            itemBuilder: (context, index) {
              final categoria = _categorias[index];
              final isSelected = categoria == _categoriaSeleccionada;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(
                    categoria == 'todas' ? 'Todas' : categoria.toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.redAccent,
                      fontSize: 12,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) => _cambiarCategoria(categoria),
                  selectedColor: Colors.redAccent,
                  checkmarkColor: Colors.white,
                  side: const BorderSide(color: Colors.redAccent),
                ),
              );
            },
          ),
        ),
      ],
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

            // Filtros de búsqueda
            _buildFiltros(),

            const SizedBox(height: 20),

            // Contador de resultados
            if (!_cargando && _errorMessage == null)
              Text(
                '${_productosFiltrados.length} producto(s) encontrado(s)',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),

            const SizedBox(height: 10),

            // Contenido principal
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? _buildErrorWidget()
                  : _productosFiltrados.isEmpty
                  ? _buildEmptyWidget()
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: _productosFiltrados.length,
                      itemBuilder: (context, index) {
                        try {
                          final item = _productosFiltrados[index];
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

                                          // Nombre del emprendimiento y categoría
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
                                          Text(
                                            emprendimiento.categoria
                                                .toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 9,
                                              color: Colors.redAccent,
                                              fontWeight: FontWeight.w500,
                                            ),
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
