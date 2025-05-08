import 'package:flutter/material.dart';
import 'api_service.dart';
import 'maintenance_record.dart';

void main() => runApp(CarMaintenanceApp());

class CarMaintenanceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Maintenance',
      home: MaintenanceScreen(),
    );
  }
}

class MaintenanceScreen extends StatefulWidget {
  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serviceType = TextEditingController();
  final _serviceDate = TextEditingController();
  final _mileage = TextEditingController();
  final _notes = TextEditingController();
  final TextEditingController _serviceDateController = TextEditingController();

  late Future<List<MaintenanceRecord>> _records;

  @override
  void initState() {
    super.initState();
    _records = ApiService.fetchRecords();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      await ApiService.addRecord(MaintenanceRecord(
        serviceType: _serviceType.text,
        serviceDate: _serviceDateController.text, // not _serviceDate.text
        mileage: int.parse(_mileage.text),
        notes: _notes.text,
      ));
      setState(() {
        _records = ApiService.fetchRecords();
        _serviceType.clear();
        _serviceDateController.clear();
        _mileage.clear();
        _notes.clear();

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Car Maintenance")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Form(
            key: _formKey,
            child: Column(children: [
              TextFormField(controller: _serviceType, decoration: InputDecoration(labelText: "Service Type")),
              TextFormField(
                controller: _serviceDateController,
                decoration: InputDecoration(labelText: "Service Date"),
                readOnly: true,
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    // Format as YYYY-MM-DD and set the controller
                    _serviceDateController.text = pickedDate.toIso8601String().split("T").first;
                  }
                },
              ),

              TextFormField(controller: _mileage, decoration: InputDecoration(labelText: "Mileage")),
              TextFormField(controller: _notes, decoration: InputDecoration(labelText: "Notes")),
              SizedBox(height: 10),
              ElevatedButton(onPressed: _submit, child: Text("Add Record")),
            ]),
          ),
          Divider(),
          Expanded(
            child: FutureBuilder<List<MaintenanceRecord>>(
              future: _records,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  print("ERROR: ${snapshot.error}");
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No maintenance records found."));
                } else {
                  final records = snapshot.data!;
                  print("DATA: $records");

                  return ListView.builder(
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(record.serviceType),
                          subtitle: Text(
                            "Date: ${record.serviceDate}\nMileage: ${record.mileage} mi\nNotes: ${record.notes}",
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),


        ]),
      ),
    );
  }
}
