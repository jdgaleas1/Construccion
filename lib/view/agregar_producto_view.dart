import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lata_emprende/controller/emprendimiento_controller.dart';

class AgregarProductoView extends StatefulWidget {
  final String idEmprendimiento;

  const AgregarProductoView({super.key, required this.idEmprendimiento});

  @override
  State<AgregarProductoView> createState() => _AgregarProductoViewState();
}

class _AgregarProductoViewState extends State<AgregarProductoView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();

  File? _imagenProducto;
  String? _imagenBase64; // <- aquí guardaremos el Base64

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final bytes = await file.readAsBytes();
      setState(() {
        _imagenProducto = file;
        _imagenBase64 = base64Encode(bytes); // <- convertimos a Base64
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Producto'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Imagen del producto
              GestureDetector(
                onTap: _seleccionarImagen,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                    image: _imagenProducto != null
                        ? DecorationImage(
                            image: FileImage(_imagenProducto!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _imagenProducto == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Subir Imagen del Producto',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ),

              const SizedBox(height: 30),

              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Producto',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa el nombre del producto';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción del Producto',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa una descripción';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _precioController,
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa el precio';
                  }
                  final precio = double.tryParse(value);
                  if (precio == null || precio <= 0) {
                    return 'Ingresa un precio válido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_imagenBase64 == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Selecciona una imagen primero'),
                          ),
                        );
                        return;
                      }

                      final precio = double.parse(_precioController.text);
                      final controller = EmprendimientoController();
                      controller.crearProducto(
                        context: context,
                        nombre: _nombreController.text.trim(),
                        descripcion: _descripcionController.text.trim(),
                        precio: precio,
                        idEmprendimiento: widget.idEmprendimiento,
                        imagenBase64: _imagenBase64!, // <- enviamos base64
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    'Guardar Producto',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(fontSize: 16, color: Colors.redAccent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    super.dispose();
  }
}
