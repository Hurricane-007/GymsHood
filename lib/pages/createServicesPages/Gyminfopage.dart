import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gymshood/Utilities/Dialogs/error_dialog.dart';
import 'package:gymshood/Utilities/Dialogs/info_dialog.dart';
import 'package:gymshood/pages/mapPickerPage.dart';
import 'package:gymshood/services/Auth/auth_service.dart';
import 'package:gymshood/services/Models/AuthUser.dart';
import 'package:gymshood/services/gymInfo/gymserviceprovider.dart';

class Gyminfopage extends StatefulWidget {
  const Gyminfopage({super.key});

  @override
  State<Gyminfopage> createState() => _GyminfopageState();
}

class _GyminfopageState extends State<Gyminfopage>
    with SingleTickerProviderStateMixin {
  //
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final coordinatesController = TextEditingController();
  final capacityController = TextEditingController();
  final openTimeController = TextEditingController();
  final closeTimeController = TextEditingController();
  final contactEmailController = TextEditingController();
  final phoneController = TextEditingController();
  final aboutController = TextEditingController();
  final equipmentController = TextEditingController();
  final userIdController = TextEditingController();
  final gymsloganController = TextEditingController();
  String role = 'GymOwner';
  late TabController _tabController;
  final List<String> weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  List<List<Map<String, TextEditingController>>> weeklyShiftControllers = [];
  void clearWeeklyShiftControllers() {
    for (var day in weeklyShiftControllers) {
      for (var shift in day) {
        for (var controller in shift.values) {
          controller.dispose();
        }
      }
    }
    weeklyShiftControllers.clear(); // Now safe to clear
  }

  void copyShiftsToOtherDays(int fromDayIndex) async {
    final selectedDays = await showDialog<List<int>>(
      context: context,
      builder: (context) {
        final selected = <int>{};
        return AlertDialog(
          title: const Text("Copy shifts to days"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(weekdays.length, (i) {
                  if (i == fromDayIndex) {
                    return const SizedBox.shrink();
                  } // Skip source day
                  return CheckboxListTile(
                    title: Text(weekdays[i],
                        style:
                            TextStyle(color: Theme.of(context).primaryColor)),
                    value: selected.contains(i),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          selected.add(i);
                        } else {
                          selected.remove(i);
                        }
                      });
                    },
                  );
                }),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text("Cancel" , style: TextStyle(color:   Color(0xFF071952),),),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, selected.toList()),
              child: const Text("Copy" , style: TextStyle(color:   Color(0xFF071952),),),
            ),
          ],
        );
      },
    );

    if (selectedDays == null || selectedDays.isEmpty) return;

    final sourceShifts = weeklyShiftControllers[fromDayIndex];
    for (final targetDay in selectedDays) {
      // Clear existing
      for (var shift in weeklyShiftControllers[targetDay]) {
        shift.forEach((_, c) => c.dispose());
      }
      weeklyShiftControllers[targetDay].clear();

      // Copy shifts
      for (final shift in sourceShifts) {
        weeklyShiftControllers[targetDay].add({
          'name': TextEditingController(text: shift['name']!.text),
          'startTime': TextEditingController(text: shift['startTime']!.text),
          'endTime': TextEditingController(text: shift['endTime']!.text),
          'capacity': TextEditingController(text: shift['capacity']!.text),
        });
      }
    }

    if (mounted) setState(() {});
  }

  // List<Map<String, TextEditingController>> shiftControllers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: weekdays.length, vsync: this);
    for (int i = 0; i < weekdays.length; i++) {
      weeklyShiftControllers.add([]);
    } // Add 1 default shift to each dayd one default shift on start
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var dayShifts in weeklyShiftControllers) {
      for (var shift in dayShifts) {
        shift.forEach((_, controller) => controller.dispose());
      }
    }
    super.dispose();
  }

  void addShift(int dayIndex) {
    if (!mounted) return;
    weeklyShiftControllers[dayIndex].add({
      'name': TextEditingController(),
      'startTime': TextEditingController(),
      'endTime': TextEditingController(),
      'capacity': TextEditingController(),
    });
    setState(() {});
  }

  void removeShift(int dayIndex, int index) {
    if (!mounted) return;
    weeklyShiftControllers[dayIndex][index]
        .forEach((_, controller) => controller.dispose());
    weeklyShiftControllers[dayIndex].removeAt(index);
    setState(() {});
  }

  String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> pickTime(
      BuildContext context, TextEditingController controller) async {
    final picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) controller.text = formatTimeOfDay(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register your gym",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: BackButton(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: coordinatesController,
                  readOnly: true,
                  onTap: () async {
                    final picked = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LocationPickerPage(),
                      ),
                    );

                    if (picked is LatLng) {
                      coordinatesController.text =
                          "${picked.longitude},${picked.latitude}";
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Coordinates (pick from map)',
                    suffixIcon: Icon(Icons.map),
                  ),
                ),
                buildTextField(locationController, 'Address'),
                buildTextField(nameController, 'Gym Name'),
                buildTextField(gymsloganController, 'Gym Slogan'),
                buildTextField(capacityController, 'Capacity',
                    keyboardType: TextInputType.number),
                buildTimeField(openTimeController, 'Open Time'),
                buildTimeField(closeTimeController, 'Close Time'),
                buildTextField(contactEmailController, 'Contact Email'),
                buildTextField(phoneController, 'Phone',
                    keyboardType: TextInputType.phone),
                buildTextField(aboutController, 'About'),
                buildTextField(
                    equipmentController, 'Equipment List (comma-separated)'),
                const SizedBox(height: 20),
                const Text("Weekly Shifts",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                  tabs: weekdays.map((day) => Tab(text: day)).toList(),
                ),
                SizedBox(
                  height: 500, // Adjust height based on content
                  child: TabBarView(
                    controller: _tabController,
                    children: List.generate(7, (dayIndex) {
                      return Column(
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => copyShiftsToOtherDays(dayIndex),
                              icon: const Icon(Icons.copy),
                              label: const Text("Copy to Other Days"),
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              children: [
                                ...weeklyShiftControllers[dayIndex]
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final index = entry.key;
                                  final shift = entry.value;
                                  return Card(
                                    color: Colors.white,
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text("Shift ${index + 1}",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              const Spacer(),
                                              IconButton(
                                                onPressed: () => removeShift(
                                                    dayIndex, index),
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.red),
                                              )
                                            ],
                                          ),
                                          buildTextField(
                                              shift['name']!, 'Shift Name'),
                                          buildTimeField(shift['startTime']!,
                                              'Start Time'),
                                          buildTimeField(
                                              shift['endTime']!, 'End Time'),
                                          buildTextField(shift['capacity']!,
                                              'Shift Capacity',
                                              keyboardType:
                                                  TextInputType.number),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () => addShift(dayIndex),
                                    icon: const Icon(Icons.add),
                                    label: const Text("Add Shift"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: SizedBox(
          width: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                overlayColor: Colors.white),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                Authuser? authuser = await AuthService.server().getUser();
                if (!mounted) return;
                List<Map<String, Object>> allShifts = [];
                for (int i = 0; i < weekdays.length; i++) {
                  for (final shift in weeklyShiftControllers[i]) {
                    allShifts.add({
                      'day': weekdays[i].toLowerCase(),
                      'name': shift['name']!.text,
                      'startTime': shift['startTime']!.text,
                      'endTime': shift['endTime']!.text,
                      'capacity': int.tryParse(shift['capacity']!.text) ?? 0,
                    });
                  }
                }

                final coords = coordinatesController.text
                    .split(',')
                    .map((e) => num.tryParse(e.trim()))
                    .whereType<num>()
                    .toList();

                developer.log('Parsed coordinates: $coords'); // Debug

                final res = await Gymserviceprovider.server().registerGym(
                  role: role,
                  name: nameController.text,
                  location: locationController.text,
                  coordinates: coordinatesController.text
                      .split(',')
                      .map((e) => num.tryParse(e.trim()))
                      .whereType<num>()
                      .toList(),
                  gymSlogan: gymsloganController.text,
                  capacity: num.parse(capacityController.text),
                  openTime: openTimeController.text,
                  closeTime: closeTimeController.text,
                  contactEmail: contactEmailController.text,
                  phone: phoneController.text,
                  about: aboutController.text,
                  equipmentList: equipmentController.text
                      .split(',')
                      .map((e) => e.trim())
                      .toList(),
                  shifts: allShifts,
                  userid: authuser!.userid!,
                );
                if (!mounted) return;

                if (res['success']) {
                  showInfoDialog(context, res['message']);
                  _formKey.currentState!.reset();
                  nameController.clear();
                  locationController.clear();
                  coordinatesController.clear();
                  capacityController.clear();
                  openTimeController.clear();
                  closeTimeController.clear();
                  contactEmailController.clear();
                  phoneController.clear();
                  aboutController.clear();
                  equipmentController.clear();
                  equipmentController.clear();
                  clearWeeklyShiftControllers();
                } else {
                  showErrorDialog(context, res['message']);
                }
              }
            },
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
      ),
      validator: (value) => value == null || value.trim().isEmpty
          ? 'This field is required'
          : null,
    );
  }

  Widget buildTimeField(TextEditingController controller, String label) {
    return GestureDetector(
      onTap: () => pickTime(context, controller),
      child: AbsorbPointer(
        child: buildTextField(controller, label),
      ),
    );
  }
}
