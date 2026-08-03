import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/glass_theme.dart';
import '../../../data/services/user_service.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  final _userService = UserService();
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await _userService.getUsers();

      setState(() {
        users = response;
        isLoading = false;
      });

      print('Usuarios cargados: ${users.length}');
    } catch (e) {
      print('Error cargando usuarios: $e');
      setState(() {
        error = 'Error al cargar usuarios: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _createUsersTable() async {
    try {
      // La tabla de usuarios ya existe en el backend; solo recargamos.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usuarios recargados',
              style: GoogleFonts.outfit()),
          backgroundColor: Colors.green,
        ),
      );
      _loadUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creando tabla: $e', style: GoogleFonts.outfit()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _changeUserRole(String userId, String newRole) async {
    try {
      print('🔄 Intentando cambiar rol de usuario $userId a $newRole');

      await _userService.updateRole(userId, newRole);

      print('✅ Rol actualizado');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rol actualizado correctamente',
              style: GoogleFonts.outfit()),
          backgroundColor: Colors.green,
        ),
      );
      _loadUsers();
    } catch (e) {
      print('❌ Error cambiando rol: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Error actualizando rol: $e', style: GoogleFonts.outfit()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEditUserDialog(String userId, String currentName,
      String currentEmail, String currentRole) {
    final nameController = TextEditingController(text: currentName);
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('Editar Usuario',
            style: GoogleFonts.outfit(color: Colors.white)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: GoogleFonts.outfit(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: GoogleFonts.outfit(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: GlassTheme.primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                style: GoogleFonts.outfit(color: Colors.black),
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Nueva contraseña (opcional)',
                  labelStyle: GoogleFonts.outfit(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: GlassTheme.primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _showRoleDialog(
                        userId,
                        currentRole,
                        nameController.text.isNotEmpty
                            ? nameController.text
                            : currentName);
                  },
                  child: Text('Cambiar Rol', style: GoogleFonts.outfit()),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _showDeleteConfirmDialog(userId, currentName);
                  },
                  child: Text('Eliminar Usuario', style: GoogleFonts.outfit()),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar',
                style: GoogleFonts.outfit(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: GlassTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _updateUser(
                userId, nameController.text, passwordController.text),
            child: Text('Guardar', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUser(String userId, String name, String password) async {
    try {
      await _userService.updateUser(userId, name: name, password: password);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usuario actualizado correctamente',
              style: GoogleFonts.outfit()),
          backgroundColor: Colors.green,
        ),
      );
      _loadUsers();
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error actualizando usuario: $e',
              style: GoogleFonts.outfit()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmDialog(String userId, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('Eliminar Usuario',
            style: GoogleFonts.outfit(color: Colors.white)),
        content: Text(
          '¿Estás seguro de que quieres eliminar a $userName?\n\nEsta acción no se puede deshacer.',
          style: GoogleFonts.outfit(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar',
                style: GoogleFonts.outfit(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _deleteUser(userId),
            child: Text('Eliminar', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    );
  }

  void _showRoleDialog(String userId, String currentRole, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('Cambiar Rol - $userName',
            style: GoogleFonts.outfit(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['lector', 'profesor', 'bibliotecario', 'admin']
              .map((role) => ListTile(
                    title: Text(role.toUpperCase(),
                        style: GoogleFonts.outfit(color: Colors.white)),
                    leading: Radio<String>(
                      value: role,
                      groupValue: currentRole,
                      onChanged: (value) {
                        Navigator.pop(context);
                        if (value != null) {
                          _changeUserRole(userId, value);
                        }
                      },
                      activeColor: GlassTheme.primaryColor,
                    ),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar',
                style: GoogleFonts.outfit(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(String userId) async {
    try {
      await _userService.deleteUser(userId);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usuario eliminado correctamente',
              style: GoogleFonts.outfit()),
          backgroundColor: Colors.green,
        ),
      );
      _loadUsers();
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Error eliminando usuario: $e', style: GoogleFonts.outfit()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'bibliotecario':
        return Colors.blue;
      case 'profesor':
        return Colors.green;
      case 'lector':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Gestión de Usuarios',
            style: GoogleFonts.outfit(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: GlassTheme.glassDecoration.gradient,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: Container(
        decoration: GlassTheme.decorationBackground,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
          child: Column(
            children: [
              if (error != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Error al cargar usuarios',
                        style: GoogleFonts.outfit(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error!,
                        style: GoogleFonts.outfit(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _createUsersTable,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Crear Tabla Users',
                            style: GoogleFonts.outfit()),
                      ),
                    ],
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${users.length} usuarios',
                    style:
                        GoogleFonts.outfit(fontSize: 18, color: Colors.white70),
                  ),
                  Text(
                    'Usuarios Registrados',
                    style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white))
                    : users.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.people_outline,
                                    size: 64, color: Colors.white54),
                                const SizedBox(height: 16),
                                Text(
                                  'No hay usuarios registrados',
                                  style: GoogleFonts.outfit(
                                      fontSize: 18, color: Colors.white70),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Los usuarios aparecerán aquí cuando se registren',
                                  style:
                                      GoogleFonts.outfit(color: Colors.white54),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];
                              final role = user['role']?.toString() ?? 'lector';

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GlassmorphicContainer(
                                  width: double.infinity,
                                  height: 90,
                                  borderRadius: 16,
                                  blur: 10,
                                  alignment: Alignment.center,
                                  border: 0,
                                  linearGradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.1),
                                      Colors.white.withOpacity(0.05),
                                    ],
                                  ),
                                  borderGradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.2),
                                      Colors.white.withOpacity(0.1),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 8),
                                    leading: CircleAvatar(
                                      backgroundColor: _getRoleColor(role),
                                      radius: 25,
                                      child: const Icon(Icons.person,
                                          color: Colors.white, size: 28),
                                    ),
                                    title: Text(
                                      user['name']?.toString() ?? 'Sin nombre',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user['email']?.toString() ??
                                              'Sin email',
                                          style: GoogleFonts.outfit(
                                              color: Colors.white70,
                                              fontSize: 14),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _getRoleColor(role)
                                                .withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            role.toUpperCase(),
                                            style: GoogleFonts.outfit(
                                              color: _getRoleColor(role),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.white70),
                                      onPressed: () => _showEditUserDialog(
                                        user['id'].toString(),
                                        user['name']?.toString() ?? 'Usuario',
                                        user['email']?.toString() ?? '',
                                        role,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
