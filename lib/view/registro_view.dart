import 'package:flutter/material.dart';
import 'package:lata_emprende/controller/auth_controller.dart';

class RegistroView extends StatefulWidget {
  const RegistroView({super.key});

  @override
  State<RegistroView> createState() => _RegistroViewState();
}

class _RegistroViewState extends State<RegistroView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _confirmarContrasenaController =
      TextEditingController();

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 40),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Image.asset('assets/images/logo.png', height: 100),
              const SizedBox(height: 20),
              const Text('Registrarse', style: TextStyle(fontSize: 24)),

              const SizedBox(height: 20),
              TextFormField(
                controller: _nombresController,
                decoration: const InputDecoration(labelText: 'Nombres'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Ingresa tus nombres'
                    : null,
              ),

              TextFormField(
                controller: _apellidosController,
                decoration: const InputDecoration(labelText: 'Apellidos'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Ingresa tus apellidos'
                    : null,
              ),

              TextFormField(
                controller: _correoController,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Ingresa un correo válido';
                  if (!value.contains('@')) return 'Correo inválido';
                  return null;
                },
              ),

              TextFormField(
                controller: _contrasenaController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final authController = AuthController();
                        authController.registrarUsuario(
                          context: context,
                          nombres: _nombresController.text.trim(),
                          apellidos: _apellidosController.text.trim(),
                          correo: _correoController.text.trim(),
                          contrasena: _contrasenaController.text.trim(),
                        );
                      }
                    },
                  ),
                ),
                validator: (value) => value != null && value.length < 6
                    ? 'Mínimo 6 caracteres'
                    : null,
              ),

              TextFormField(
                controller: _confirmarContrasenaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar Contraseña',
                ),
                validator: (value) => value != _contrasenaController.text
                    ? 'No coincide la contraseña'
                    : null,
              ),

              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Aquí se llama al controlador
                    // TODO: llamar a AuthController.register(...)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Procesando registro...')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 14,
                  ),
                ),
                child: const Text('Registrar Cuenta'),
              ),

              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
                child: const Text('Ya tienes una cuenta? Inicia Sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
