import "package:flutter/material.dart";
import "package:lostmate/Service/auth_service.dart";

class EditProfileScreen extends StatefulWidget {
  final String id;

  const EditProfileScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _fakultasController = TextEditingController();
  final _jurusanController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final data = await AuthService().getUserData() as Map<String, dynamic>?;
      _phoneController.text = data?["phone"] ?? "";
      _fakultasController.text = data?["fakultas"] ?? "";
      _jurusanController.text = data?["jurusan"] ?? "";
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await AuthService().updateProfile(widget.id, {
        "phone": _phoneController.text.trim(),
        "fakultas": _fakultasController.text.trim(),
        "jurusan": _jurusanController.text.trim(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil diperbarui!")),
      );
      Navigator.pop(context); // Kembali ke ProfileScreen setelah simpan
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _fakultasController.dispose();
    _jurusanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profil"),
        backgroundColor: Colors.yellow[700], // Tema kuning untuk AppBar
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: "Nomor Telepon",
                        filled: true,
                        fillColor: Colors.yellow, // Input field dengan latar kuning
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Nomor telepon harus diisi";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _fakultasController,
                      decoration: const InputDecoration(
                        labelText: "Fakultas",
                        filled: true,
                        fillColor: Colors.yellow, // Input field dengan latar kuning
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Fakultas harus diisi";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _jurusanController,
                      decoration: const InputDecoration(
                        labelText: "Jurusan",
                        filled: true,
                        fillColor: Colors.yellow, // Input field dengan latar kuning
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Jurusan harus diisi";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow[700], // Tombol kuning
                            foregroundColor: Colors.black87,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text("Simpan"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Kembali ke ProfileScreen tanpa simpan
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black87,
                          ),
                          child: const Text("Batal"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}