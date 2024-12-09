import 'package:flutter/material.dart';
import 'package:apps_finance/service/api_category.dart';

class CategoryScreen extends StatefulWidget {
  // Nama class diperbarui
  @override
  _CategoryScreenState createState() =>
      _CategoryScreenState(); // Nama class State juga diperbarui
}

class _CategoryScreenState extends State<CategoryScreen> {
  // Nama class State diperbarui
  final CategoryService categoryService = CategoryService();
  final TextEditingController categoryController = TextEditingController();
  List<dynamic> categories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  void fetchCategories() async {
    try {
      final data = await categoryService.getCategories();
      setState(() {
        categories = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal memuat kategori: $e')));
    }
  }

  void addCategory() async {
    if (categoryController.text.isNotEmpty) {
      try {
        await categoryService.addCategory(categoryController.text);
        fetchCategories();
        categoryController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Kategori berhasil ditambahkan')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menambahkan kategori: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pengaturan Kategori')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: categoryController,
              decoration: InputDecoration(
                labelText: 'Nama Kategori',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: addCategory,
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(categories[index]['name']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
