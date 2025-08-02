import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lata_emprende/controller/auth_controller.dart';

class RegistroView extends StatefulWidget {
  const RegistroView({super.key});

  @override
  State<RegistroView> createState() => _RegistroViewState();
}

class _RegistroViewState extends State<RegistroView> {
  final _formKey = GlobalKey<FormState>();
  String _tipoUsuario = 'consumidor'; // Valor por defecto

  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _confirmarContrasenaController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Función para validar teléfono ecuatoriano
  String? _validarTelefono(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu número de teléfono';
    }

    // Remover espacios y caracteres especiales
    String telefono = value.replaceAll(RegExp(r'[^\d]'), '');

    // Validar formato ecuatoriano
    if (telefono.length == 10) {
      // Celular: debe empezar con 09
      if (telefono.startsWith('09')) {
        return null; // Válido
      }
      // Convencional: debe empezar con 0 seguido del código de área
      List<String> codigosArea = ['02', '03', '04', '05', '06', '07'];
      for (String codigo in codigosArea) {
        if (telefono.startsWith(codigo)) {
          return null; // Válido
        }
      }
    }

    return 'Ingresa un número ecuatoriano válido (10 dígitos)';
  }

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
                textCapitalization: TextCapitalization.words,
                validator: (value) => value == null || value.isEmpty
                    ? 'Ingresa tus nombres'
                    : null,
              ),

              TextFormField(
                controller: _apellidosController,
                decoration: const InputDecoration(labelText: 'Apellidos'),
                textCapitalization: TextCapitalization.words,
                validator: (value) => value == null || value.isEmpty
                    ? 'Ingresa tus apellidos'
                    : null,
              ),

              DropdownButtonFormField<String>(
                value: _tipoUsuario,
                decoration: const InputDecoration(labelText: 'Tipo de usuario'),
                items: const [
                  DropdownMenuItem(
                    value: 'consumidor',
                    child: Text('Consumidor'),
                  ),
                  DropdownMenuItem(
                    value: 'emprendedor',
                    child: Text('Emprendedor'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _tipoUsuario = value!;
                  });
                },
                validator: (value) =>
                    value == null ? 'Selecciona un tipo' : null,
              ),

              TextFormField(
                controller: _correoController,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa un correo válido';
                  }
                  if (!value.contains('@')) {
                    return 'Correo inválido';
                  }
                  return null;
                },
              ),

              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  hintText: 'Ej: 0987654321',
                  prefixText: '+593 ',
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: _validarTelefono,
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
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa una contraseña';
                  }
                  if (value.length < 6) {
                    return 'Mínimo 6 caracteres';
                  }
                  return null;
                },
              ),

              TextFormField(
                controller: _confirmarContrasenaController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirmar Contraseña',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value != _contrasenaController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final authController = AuthController();
                    authController.registrarUsuario(
                      context: context,
                      nombres: _nombresController.text.trim(),
                      apellidos: _apellidosController.text.trim(),
                      correo: _correoController.text.trim(),
                      telefono: _telefonoController.text.trim(),
                      contrasena: _contrasenaController.text.trim(),
                      tipoUsuario: _tipoUsuario,
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
                child: const Text('¿Ya tienes una cuenta? Inicia Sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _contrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    super.dispose();
  }
}
