import 'package:flutter/material.dart';
import 'api_service.dart';
import 'maintenance_record.dart';

class AddMaintenanceScreen extends StatefulWidget {
  @override
  _AddMaintenanceScreenState createState() => _AddMaintenanceScreenState();
}

class _AddMaintenanceScreenState extends State<AddMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _carModelController = TextEditingController();
  final TextEditingController _serviceTypeController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _selectedDate;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final record = MaintenanceRecord(
        id: null,
        carModel: _carModelController.text,
        serviceType: _serviceTypeController.text,
        serviceDate: _selectedDate!,
        mileage: int.parse(_mileageController.text),
        notes: _notesController.text,
      );

      try {
        await ApiService.addRecord(record);
        Navigator.pop(context); // Return to previous screen
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add record: $e')),
        );
      }
    }
  }

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Maintenance Record')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _carModelController,
                decoration: InputDecoration(labelText: 'Car Model'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter a car model' : null,
              ),
              TextFormField(
                controller: _serviceTypeController,
                decoration: InputDecoration(labelText: 'Service Type'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter a service type' : null,
              ),
              TextFormField(
                controller: _mileageController,
                decoration: InputDecoration(labelText: 'Mileage'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? 'Enter mileage' : null,
              ),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    _selectedDate == null
                        ? 'No date selected'
                        : 'Date: ${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}',
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: _pickDate,
                    child: Text('Select Date'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Add Record'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
