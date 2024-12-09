import 'package:apps_finance/screen/categoryscreen.dart';
import 'package:flutter/material.dart';
import 'package:apps_finance/service/api_cashflow.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  List<dynamic> cashflows = [];
  int totalIncome = 0;
  int totalOutcome = 0;
  int _selectedIndex = 0;

  // Variables for date filtering
  String startDate = '';
  String endDate = '';

  // Variables for transaction type filter
  String selectedFilter = 'All';
  final List<String> filterOptions = ['All', 'Income', 'Outcome'];

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch all data by default
  }

  void fetchData([String? start, String? end]) async {
    try {
      String? jenis; // Null berarti tanpa filter jenis transaksi
      if (selectedFilter == 'Income') {
        jenis = 'Pemasukan';
      } else if (selectedFilter == 'Outcome') {
        jenis = 'Pengeluaran';
      }

      // Gunakan default tanggal jika StartDate atau EndDate kosong
      String startDateToUse = start ?? '2024-01-01';
      String endDateToUse = end ?? '2024-12-31';

      print('Fetching data with:');
      print(
          'StartDate: $startDateToUse, EndDate: $endDateToUse, Jenis: $jenis');

      final data = await apiService.getCashflows(startDateToUse, endDateToUse,
          jenis: jenis);

      if (data.isEmpty) {
        print('No data found for the given filters.');
      }

      int income = 0;
      int outcome = 0;

      for (var item in data) {
        if (item['jenis'] == 'Pemasukan') {
          income += int.parse(item['nominal']);
        } else if (item['jenis'] == 'Pengeluaran') {
          outcome += int.parse(item['nominal']);
        }
      }

      setState(() {
        cashflows = data;
        totalIncome = income;
        totalOutcome = outcome;
      });
    } catch (e) {
      print('Error fetching data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        final formattedDate =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        if (isStartDate) {
          startDate = formattedDate;
        } else {
          endDate = formattedDate;
        }
      });
    }
  }

  void _resetFilter() {
    setState(() {
      // Reset the startDate and endDate
      startDate = '';
      endDate = '';
      selectedFilter = 'All'; // Reset filter jenis transaksi
    });
    // Fetch all data again
    fetchData();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Settings not implemented yet!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finance App'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter by Date and Transaction Type
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Date Filter Row
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context, true),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 16.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            startDate.isEmpty ? 'Start Date' : startDate,
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[700]),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context, false),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 16.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            endDate.isEmpty ? 'End Date' : endDate,
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[700]),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search, color: Colors.green),
                      onPressed: () {
                        fetchData(
                          startDate.isNotEmpty ? startDate : null,
                          endDate.isNotEmpty ? endDate : null,
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh, color: Colors.blue),
                      onPressed: _resetFilter, // Reset filter on button press
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Transaction Type Filter Dropdown
                DropdownButtonFormField<String>(
                  value: selectedFilter,
                  items: filterOptions.map<DropdownMenuItem<String>>((filter) {
                    return DropdownMenuItem<String>(
                      value: filter,
                      child: Text(filter),
                    );
                  }).toList(),
                  decoration:
                      InputDecoration(labelText: 'Filter Jenis Transaksi'),
                  onChanged: (value) {
                    setState(() {
                      selectedFilter = value!;
                      fetchData(
                          startDate.isNotEmpty ? startDate : null,
                          endDate.isNotEmpty ? endDate : null);
                    });
                  },
                ),
              ],
            ),
          ),

          // Section Total Income and Outcome
          Container(
            margin: EdgeInsets.all(16.0),
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.arrow_upward, color: Colors.green, size: 20),
                        SizedBox(width: 4),
                        Text('Income', style: TextStyle(color: Colors.green)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Rp $totalIncome',
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.arrow_downward, color: Colors.red, size: 20),
                        SizedBox(width: 4),
                        Text('Outcome', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Rp $totalOutcome',
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Section List Transactions
          Expanded(
            child: ListView.builder(
              itemCount: cashflows.length,
              itemBuilder: (context, index) {
                final cashflow = cashflows[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Icon(
                      cashflow['jenis'] == 'Pemasukan'
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: cashflow['jenis'] == 'Pemasukan'
                          ? Colors.green
                          : Colors.red,
                    ),
                    title: Text(
                      'Rp ${cashflow['nominal']}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: cashflow['jenis'] == 'Pemasukan'
                              ? Colors.green
                              : Colors.red),
                    ),
                    subtitle: Text(cashflow['deskripsi']),
                    trailing: Text(cashflow['tanggal']),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // Floating Action Button and Bottom Navigation Bar
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/input').then((_) {
            fetchData(); // Refresh data
          });
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  _onItemTapped(0); // Home
                },
                icon: Icon(
                  Icons.home,
                  color: _selectedIndex == 0 ? Colors.green : Colors.grey,
                ),
              ),
              SizedBox(width: 48), // Space for FAB
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CategoryScreen()),
                  );
                },
                icon: Icon(
                  Icons.settings,
                  color: _selectedIndex == 1 ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
