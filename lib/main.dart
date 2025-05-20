import 'package:flutter/material.dart';
import 'api_service.dart';
import 'maintenance_record.dart';
import 'add_maintenance_screen.dart';

void main() => runApp(CarMaintenanceApp());

class CarMaintenanceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Maintenance Tracker',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MaintenanceScreen(),
    );
  }
}

class MaintenanceScreen extends StatefulWidget {
  @override
  _MaintenanceScreenState createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  late Future<List<MaintenanceRecord>> _futureRecords;

  @override
  void initState() {
    super.initState();
    _futureRecords = ApiService.fetchRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Car Maintenance'),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMaintenanceScreen()),
          ).then((_) {
            setState(() {
              _futureRecords = ApiService.fetchRecords();
            });
          });
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.indigo,
      ),

      body: FutureBuilder<List<MaintenanceRecord>>(
        future: _futureRecords,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No maintenance records found'));
          }

          final records = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            record.carModel,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            record.serviceDate.toLocal().toShortDateString(),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.build, size: 16, color: Colors.indigo),
                          const SizedBox(width: 6),
                          Text(record.serviceType),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.speed, size: 16, color: Colors.indigo),
                          const SizedBox(width: 6),
                          Text("Mileage: ${record.mileage} miles"),
                        ],
                      ),
                      if (record.notes.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text(
                          "Notes:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(record.notes),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

extension DateExtension on DateTime {
  String toShortDateString() {
    return "${this.month}/${this.day}/${this.year}";
  }
}
