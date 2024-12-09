import 'package:flutter/material.dart';
import 'package:apps_finance/service/api_cashflow.dart';

class InputScreen extends StatefulWidget {
  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nominalController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();

  bool isIncome = true; // Untuk toggle income/outcome
  String? selectedCategory; // Untuk menyimpan ID kategori yang dipilih
  List<dynamic> categories = []; // Untuk menyimpan daftar kategori

  @override
  void initState() {
    super.initState();
    fetchCategories(); // Memuat kategori saat screen pertama kali dibuka
  }

  // Fungsi untuk memuat daftar kategori dari API
  Future<void> fetchCategories() async {
    try {
      final fetchedCategories = await ApiService().getCategories();
      print('Fetched Categories: $fetchedCategories'); // Debugging
      setState(() {
        categories = fetchedCategories;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat kategori: $e')),
      );
    }
  }

  // Fungsi untuk memilih tanggal menggunakan Date Picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        tanggalController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // Fungsi untuk mengirim data ke API
 Future<void> _submitForm() async {
  if (_formKey.currentState!.validate()) {
    // Konversi semua nilai dalam data menjadi String (gunakan nilai default jika null)
    final data = {
      'jenis': isIncome ? 'Pemasukan' : 'Pengeluaran',
      'nominal': nominalController.text,
      'tanggal': tanggalController.text,
      'deskripsi': deskripsiController.text,
      'category_id': selectedCategory ?? '', // Pastikan tidak null
    };

    print('Data yang dikirim: $data'); // Log untuk debugging

    try {
      await ApiService().addCashflow(data);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data berhasil disimpan')),
      );
      Navigator.pop(context); // Kembali ke layar sebelumnya
    } catch (e) {
      print('Error: $e'); // Log error untuk debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data: $e')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Input Laporan')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Toggle Button untuk Jenis Transaksi
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Switch(
                    value: isIncome,
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.red,
                    inactiveTrackColor: Colors.red[200],
                    onChanged: (value) {
                      setState(() {
                        isIncome = value;
                      });
                    },
                  ),
                  SizedBox(width: 10),
                  Text(
                    isIncome ? 'Income' : 'Expense',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isIncome ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Dropdown untuk memilih kategori
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories.map<DropdownMenuItem<String>>((category) {
                  return DropdownMenuItem<String>(
                    value: category['id'].toString(), // Gunakan ID kategori
                    child: Text(category['name']), // Tampilkan nama kategori
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Pilih Kategori'),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value; // Simpan ID kategori
                  });
                },
                validator: (value) => value == null ? 'Kategori harus dipilih' : null,
              ),
              SizedBox(height: 16),

              // Input Nominal
              TextFormField(
                controller: nominalController,
                decoration: InputDecoration(labelText: 'Nominal'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field wajib diisi';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),

              // Input Tanggal dengan Date Picker
              TextFormField(
                controller: tanggalController,
                decoration: InputDecoration(
                  labelText: 'Tanggal (YYYY-MM-DD)',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) => value == null || value.isEmpty
                    ? 'Field wajib diisi'
                    : null,
              ),

              // Input Deskripsi
              TextFormField(
                controller: deskripsiController,
                decoration: InputDecoration(labelText: 'Deskripsi'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Field wajib diisi'
                    : null,
              ),
              SizedBox(height: 20),

              // Tombol Simpan
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
