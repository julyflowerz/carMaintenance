import 'package:flutter/material.dart';
import 'api_service.dart';
import 'maintenance_record.dart';

// Entry point of the app; runs the CarMaintenanceApp widget
void main() => runApp(CarMaintenanceApp());

// The root widget of the application
class CarMaintenanceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Maintenance',            // Sets the app title
      home: MaintenanceScreen(),           // Sets the first screen to be shown
    );
  }
}

// A StatefulWidget to handle form submission and data updates
class MaintenanceScreen extends StatefulWidget {
  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

// The state class for MaintenanceScreen
class _MaintenanceScreenState extends State<MaintenanceScreen> {
  // Key to uniquely identify the form and validate it
  final formKey = GlobalKey<FormState>();

  // Controllers to manage input from text fields
  final serviceType = TextEditingController();
  final serviceDate = TextEditingController(); // Unused (could be removed)
  final mileage = TextEditingController();
  final notes = TextEditingController();
  final TextEditingController serviceDateController = TextEditingController(); // Actually used

  // Holds the list of records fetched from the API
  late Future<List<MaintenanceRecord>> records;

  // Called when the widget is first created; initiates data loading
  @override
  void initState() {
    super.initState();
    records = ApiService.fetchRecords(); // Fetch existing records from backend
  }

  // Handles form submission
  void submit() async {
    if (formKey.currentState!.validate()) { // Check if form input is valid
      await ApiService.addRecord(          // Send new record to backend
        MaintenanceRecord(
          serviceType: serviceType.text,
          serviceDate: serviceDateController.text,
          mileage: int.parse(mileage.text),
          notes: notes.text,
        ),
      );

      // Refresh the UI with updated data and clear form
      setState(() {
        records = ApiService.fetchRecords(); // Re-fetch records after insert
        serviceType.clear();                 // Reset form fields
        serviceDateController.clear();
        mileage.clear();
        notes.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Car Maintenance")), // Top app bar
      body: Padding(
        padding: const EdgeInsets.all(16), // Outer padding around body
        child: Column(
          children: [
            // Form for entering new maintenance data
            Form(
              key: formKey, // Links the form to formKey for validation
              child: Column(
                children: [
                  TextFormField(
                    controller: serviceType,
                    decoration: InputDecoration(labelText: "Service Type"),
                  ),
                  TextFormField(
                    controller: serviceDateController,
                    decoration: InputDecoration(labelText: "Service Date"),
                    readOnly: true, // Prevents manual typing
                    onTap: () async {
                      // Opens date picker dialog
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        // Converts picked date to YYYY-MM-DD
                        serviceDateController.text = pickedDate.toIso8601String().split("T").first;
                      }
                    },
                  ),
                  TextFormField(
                    controller: mileage,
                    decoration: InputDecoration(labelText: "Mileage"),
                  ),
                  TextFormField(
                    controller: notes,
                    decoration: InputDecoration(labelText: "Notes"),
                  ),
                  SizedBox(height: 10), // Spacing between fields and button
                  ElevatedButton(
                    onPressed: submit, // Calls submit function
                    child: Text("Add Record"),
                  ),
                ],
              ),
            ),
            Divider(), // Line separating form from list
            Expanded(
              // Widget to expand and show fetched records
              child: FutureBuilder<List<MaintenanceRecord>>(
                future: records, // Future being watched
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // While waiting for data
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    // If error occurred
                    print("ERROR: ${snapshot.error}");
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    // If data is empty
                    return Center(child: Text("No maintenance records found."));
                  } else {
                    // If data is available
                    final records = snapshot.data!;
                    print("DATA: $records");

                    return ListView.builder(
                      itemCount: records.length, // Number of items in list
                      itemBuilder: (context, index) {
                        final record = records[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(record.serviceType),
                            subtitle: Text(
                              "Date: ${record.serviceDate}\nMileage: ${record.mileage} mi\nNotes: ${record.notes}",
                            ),
                            isThreeLine: true, // Allows three lines of text
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
