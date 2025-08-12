import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lata_emprende/controller/emprendimiento_controller.dart';

class CrearEmprendimientoView extends StatefulWidget {
  const CrearEmprendimientoView({super.key});

  @override
  State<CrearEmprendimientoView> createState() =>
      _CrearEmprendimientoViewState();
}

class _CrearEmprendimientoViewState extends State<CrearEmprendimientoView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _ubicacionController = TextEditingController();
  String _categoriaSeleccionada = 'comida';

  File? _logo;
  String? _logoBase64;

  final List<String> _categorias = [
    'comida',
    'ropa',
    'artesania',
    'tecnologia',
    'servicios',
    'otros',
  ];

  Future<void> _seleccionarLogo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final bytes = await file.readAsBytes();
      setState(() {
        _logo = file;
        _logoBase64 = base64Encode(bytes);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Emprendimiento'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _seleccionarLogo,
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                    image: _logo != null
                        ? DecorationImage(
                            image: FileImage(_logo!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _logo == null
                      ? const Icon(Icons.business, size: 50, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Agregar Logo del Emprendimiento',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),

              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Negocio',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Ingresa el nombre del negocio'
                    : null,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción del Negocio',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) => value == null || value.isEmpty
                    ? 'Ingresa una descripción'
                    : null,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _ubicacionController,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Ingresa la dirección'
                    : null,
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: _categoriaSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
                items: _categorias.map((categoria) {
                  return DropdownMenuItem(
                    value: categoria,
                    child: Text(categoria.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _categoriaSeleccionada = value!),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_logoBase64 == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Selecciona un logo primero'),
                          ),
                        );
                        return;
                      }

                      final controller = EmprendimientoController();
                      controller.crearEmprendimiento(
                        context: context,
                        nombre: _nombreController.text.trim(),
                        descripcion: _descripcionController.text.trim(),
                        ubicacion: _ubicacionController.text.trim(),
                        categoria: _categoriaSeleccionada,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    'Guardar Perfil',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
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
    _ubicacionController.dispose();
    super.dispose();
  }
}
