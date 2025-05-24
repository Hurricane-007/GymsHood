import 'package:flutter/material.dart';

class ShiftSchedulerPage extends StatefulWidget {
  const ShiftSchedulerPage({super.key});

  @override
  State<ShiftSchedulerPage> createState() => _ShiftSchedulerPageState();
}

class _ShiftSchedulerPageState extends State<ShiftSchedulerPage> {
  final List<String> days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  final Map<String, List<Shift>> shiftsByDay = {};

  @override
  void initState() {
    super.initState();
    for (String day in days) {
      shiftsByDay[day] = [];
    }
  }

  void _addShift(String day) {
    setState(() {
      shiftsByDay[day]!.add(Shift());
    });
  }

  void _removeShift(String day, int index) {
    setState(() {
      shiftsByDay[day]!.removeAt(index);
    });
  }

  void _pickTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      controller.text = picked.format(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure Shifts'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: days.map((day) {
          return ExpansionTile(
            title: Text(day),
            children: [
              ...shiftsByDay[day]!.asMap().entries.map((entry) {
                final index = entry.key;
                final shift = entry.value;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        TextField(
                          controller: shift.nameController,
                          decoration: const InputDecoration(labelText: 'Shift Name'),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: shift.startTimeController,
                                readOnly: true,
                                decoration: const InputDecoration(labelText: 'Start Time'),
                                onTap: () => _pickTime(shift.startTimeController),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: shift.endTimeController,
                                readOnly: true,
                                decoration: const InputDecoration(labelText: 'End Time'),
                                onTap: () => _pickTime(shift.endTimeController),
                              ),
                            ),
                          ],
                        ),
                        TextField(
                          controller: shift.capacityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Capacity'),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeShift(day, index),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton.icon(
                  onPressed: () => _addShift(day),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Shift'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              )
            ],
          );
        }).toList(),
      ),
    );
  }
}

class Shift {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();
}
