import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:pocketbase/pocketbase.dart';
import 'package:lostmate/presentation/screens/report/Repository.dart'; // Pastikan path import sesuai






class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _contactController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  File? _imageFile;
  bool _isLoading = false;
  late LostItemRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = LostItemRepository(PocketBase('http://127.0.0.1:8090')); // Ganti URL jika perlu
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _updateDateTimeControllers();
  }

  void _updateDateTimeControllers() {
    if (_selectedDate != null) {
      _dateController.text = _formatDate(_selectedDate!);
    }
    if (_selectedTime != null) {
      _timeController.text = _formatTime(_selectedTime!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: Color(0xFFF9A826)),
            ),
            child: child!,
          );
        },
      );
      if (picked != null && picked != _selectedDate) {
        setState(() {
          _selectedDate = picked;
          _dateController.text = _formatDate(picked);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih tanggal: $e')),
      );
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    try {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: _selectedTime ?? TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: Color(0xFFF9A826)),
            ),
            child: child!,
          );
        },
      );
      if (picked != null && picked != _selectedTime) {
        setState(() {
          _selectedTime = picked;
          _timeController.text = _formatTime(picked);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih waktu: $e')),
      );
    }
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  _getImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Kamera'),
                onTap: () {
                  _getImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (!_repository.pb.authStore.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesi autentikasi tidak valid, silakan login kembali')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Persiapkan laporan
        final report = LostItemReport(
          namabarang: _titleController.text,
          deskripsi: _descriptionController.text,
          lokasi: _locationController.text,
          lostDate: _selectedDate!,
          waktuHilang: _timeController.text,
          kontak: _contactController.text,
          createdAt: DateTime.now(),
        );

        // Kirim laporan ke repository, dengan gambar opsional
        await _repository.createReport(report, image: _imageFile);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan berhasil dikirim'),
            backgroundColor: Color(0xFFF9A826),
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            _isLoading = false;
          });
          Navigator.pop(context);
        });
      } catch (e) {
        print('Error submitting report: $e'); // Logging untuk debugging
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim laporan: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lapor Barang Hilang',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Judul Barang Hilang'),
                        TextFormField(
                          controller: _titleController,
                          decoration: _buildInputDecoration('Masukkan judul barang hilang'),
                          validator: (value) =>
                              (value == null || value.isEmpty) ? 'Judul tidak boleh kosong' : null,
                        ),
                        const SizedBox(height: 20),

                        _buildSectionTitle('Deskripsi'),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 5,
                          decoration: _buildInputDecoration('Deskripsikan barang hilang dengan detail'),
                          validator: (value) =>
                              (value == null || value.isEmpty) ? 'Deskripsi tidak boleh kosong' : null,
                        ),
                        const SizedBox(height: 20),

                        _buildSectionTitle('Lokasi Terakhir'),
                        TextFormField(
                          controller: _locationController,
                          decoration: _buildInputDecoration('Masukkan lokasi terakhir barang'),
                          validator: (value) =>
                              (value == null || value.isEmpty) ? 'Lokasi tidak boleh kosong' : null,
                        ),
                        const SizedBox(height: 20),

                        _buildSectionTitle('Tanggal Hilang'),
                        TextFormField(
                          controller: _dateController,
                          readOnly: true,
                          decoration: _buildInputDecoration('Pilih tanggal').copyWith(
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          onTap: () => _selectDate(context),
                          validator: (value) =>
                              (value == null || value.isEmpty) ? 'Tanggal tidak boleh kosong' : null,
                        ),
                        const SizedBox(height: 20),

                        _buildSectionTitle('Waktu Hilang'),
                        TextFormField(
                          controller: _timeController,
                          readOnly: true,
                          decoration: _buildInputDecoration('Pilih waktu').copyWith(
                            suffixIcon: const Icon(Icons.access_time),
                          ),
                          onTap: () => _selectTime(context),
                          validator: (value) =>
                              (value == null || value.isEmpty) ? 'Waktu tidak boleh kosong' : null,
                        ),
                        const SizedBox(height: 20),

                        _buildSectionTitle('Kontak'),
                        TextFormField(
                          controller: _contactController,
                          keyboardType: TextInputType.phone,
                          decoration: _buildInputDecoration('Masukkan nomor telepon yang bisa dihubungi'),
                          validator: (value) =>
                              (value == null || value.isEmpty) ? 'Kontak tidak boleh kosong' : null,
                        ),
                        const SizedBox(height: 20),

                        _buildSectionTitle('Foto Barang (Opsional)'),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _showImageSourceActionSheet(context),
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _imageFile != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(_imageFile!, fit: BoxFit.cover),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo, size: 50, color: Colors.grey.shade400),
                                      const SizedBox(height: 8),
                                      Text('Tambahkan Foto (Opsional)', style: TextStyle(color: Colors.grey.shade600)),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF9A826),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'Kirim Laporan',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF9A826)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}