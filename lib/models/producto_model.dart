class ProductoModel {
  final String idProducto;
  final String nombre;
  final String descripcion;
  final double precio;
  final String imagen;
  final String idEmprendimiento;

  ProductoModel({
    required this.idProducto,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagen,
    required this.idEmprendimiento,
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json, String id) {
    return ProductoModel(
      idProducto: id,
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      precio: (json['precio'] as num).toDouble(),
      imagen: json['imagen'],
      idEmprendimiento: json['id_emprendimiento'],
    );
  }

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'descripcion': descripcion,
    'precio': precio,
    'imagen': imagen,
    'id_emprendimiento': idEmprendimiento,
  };
}
