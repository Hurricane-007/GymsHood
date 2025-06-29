import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gymshood/Utilities/Dialogs/error_dialog.dart';
import 'package:gymshood/Utilities/Dialogs/info_dialog.dart';
import 'package:gymshood/pages/mapPickerPage.dart';
import 'package:gymshood/services/Auth/auth_service.dart';
import 'package:gymshood/services/Models/AuthUser.dart';
import 'package:gymshood/services/Models/gym.dart';
// import 'package:gymshood/services/Models/location.dart';
import 'package:gymshood/services/gymInfo/gymserviceprovider.dart';

class UpdateGymDetailsPage extends StatefulWidget {
  const UpdateGymDetailsPage({super.key});

  @override
  State<UpdateGymDetailsPage> createState() => _UpdateGymDetailsPageState();
}

class _UpdateGymDetailsPageState extends State<UpdateGymDetailsPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final capacityController = TextEditingController();
  final openTimeController = TextEditingController();
  final closeTimeController = TextEditingController();
  final contactEmailController = TextEditingController();
  final phoneController = TextEditingController();
  final aboutController = TextEditingController();
  final equipmentController = TextEditingController();

  List<Gym> _gyms = [];
  Gym? _selectedGym;

  final List<String> weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  List<List<Map<String, TextEditingController>>> weeklyShiftControllers = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: weekdays.length, vsync: this);
    for (int i = 0; i < weekdays.length; i++) {
      weeklyShiftControllers.add([]);
    }
    getUserGyms();
  }

  Future<void> getUserGyms() async {
    final Authuser? auth = await AuthService.server().getUser();
    final gyms = await Gymserviceprovider.server().getGymsByowner(auth!.userid!);
    setState(() {
      _gyms = gyms;
    });
  }

  // Converts a 24-hour time string (e.g., '14:30') to 12-hour format (e.g., '2:30 PM')
  String to12HourFormat(String time24h) {
    final regExp = RegExp(r'^(\d{1,2}):(\d{2})');
    final match = regExp.firstMatch(time24h.trim());
    if (match == null) return time24h;
    int hour = int.parse(match.group(1)!);
    final minute = match.group(2)!;
    final period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return '$hour:$minute $period';
  }

  void populateFields(Gym gym) {
    nameController.text = gym.name;
    capacityController.text = gym.capacity.toString();
    openTimeController.text = to12HourFormat(gym.openTime);
    closeTimeController.text = to12HourFormat(gym.closeTime);
    contactEmailController.text = gym.contactEmail;
    phoneController.text = gym.phone;
    aboutController.text = gym.about;
    equipmentController.text = gym.equipmentList.join(",");

    for (final day in weeklyShiftControllers) {
      for (var shift in day) {
        shift.forEach((_, c) => c.dispose());
      }
      day.clear();
    }

    for (final shift in gym.shifts) {
      String day = shift['day'] ?? '';
      int index = weekdays.indexWhere((d) => d.toLowerCase() == day.toLowerCase());
      if (index != -1) {
        weeklyShiftControllers[index].add({
          'name': TextEditingController(text: shift['name'] ?? ''),
          'startTime': TextEditingController(text: to12HourFormat(shift['startTime'] ?? '')),
          'endTime': TextEditingController(text: to12HourFormat(shift['endTime'] ?? '')),
          'capacity': TextEditingController(text: shift['capacity']?.toString() ?? '0'),
          'gender': TextEditingController(text: shift['gender'] ?? 'unisex'),
        });
      }
    }
    setState(() {});
  }

  void addShift(int dayIndex) {
    weeklyShiftControllers[dayIndex].add({
      'name': TextEditingController(),
      'startTime': TextEditingController(),
      'endTime': TextEditingController(),
      'capacity': TextEditingController(),
      'gender': TextEditingController(text: 'unisex'), // Default to unisex
    });
    setState(() {});
  }

  void removeShift(int dayIndex, int index) {
    weeklyShiftControllers[dayIndex][index].forEach((_, controller) => controller.dispose());
    weeklyShiftControllers[dayIndex].removeAt(index);
    setState(() {});
  }

  String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  // Converts a 12-hour time string (e.g., '2:30 PM') to 24-hour format (e.g., '14:30')
  String parseTo24Hour(String time12h) {
    final regExp = RegExp(r'^(\d{1,2}):(\d{2}) ?([AP]M)', caseSensitive: false);
    final match = regExp.firstMatch(time12h.trim());
    if (match == null) return time12h; // fallback
    int hour = int.parse(match.group(1)!);
    final minute = match.group(2)!;
    final period = match.group(3)!.toUpperCase();
    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;
    return '${hour.toString().padLeft(2, '0')}:$minute';
  }

  Future<void> pickTime(BuildContext context, TextEditingController controller) async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() {
        controller.text = formatTimeOfDay(picked);
      });
      developer.log(controller.text);
    }
  }

  Future<void> updateGymInfo() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGym == null) return;

    List<Map<String, dynamic>> allShifts = [];
    for (int i = 0; i < weekdays.length; i++) {
      for (final shift in weeklyShiftControllers[i]) {
        allShifts.add({
          'day': weekdays[i].toLowerCase(),
          'name': shift['name']!.text,
          'startTime': parseTo24Hour(shift['startTime']!.text),
          'endTime': parseTo24Hour(shift['endTime']!.text),
          'capacity': int.tryParse(shift['capacity']!.text) ?? 0,
          'gender': shift['gender']!.text,
        });
      }
    }

    final response = await Gymserviceprovider.server().updateGym(
      gymId: _selectedGym!.gymid,
      name: nameController.text,
      capacity: num.tryParse(capacityController.text) ?? 0,
      openTime: parseTo24Hour(openTimeController.text),
      closeTime: parseTo24Hour(closeTimeController.text),
      contactEmail: contactEmailController.text,
      phone: phoneController.text,
      about: aboutController.text,
      shifts: allShifts,
      equipments: equipmentController.text
                      .split(',')
                      .map((e) => e.trim())
                      .toList(),
    );

    if (!mounted) return;

    if(response){
      showInfoDialog(context, "Successfully updated your gym details!. You can announce the changes too through the announcement");
    }
    else{
      showErrorDialog(context, "Your details are not updated");
    }
  }

  Widget buildTextField(TextEditingController controller, String label, String? Function(String?)? validator,
      {TextInputType keyboardType = TextInputType.text,
      bool readOnly = false,
      VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: validator,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
      ),
    );
  }

  Widget buildGenderDropdown(TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: controller.text.isEmpty ? 'unisex' : controller.text,
        decoration: const InputDecoration(
          labelText: 'Gender',
        
        ),
        onChanged: (newValue) {
          setState(() {
            controller.text = newValue!;
          });
        },
        items: ['unisex', 'male', 'female'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        validator: (value) {
          return value == null || value.trim().isEmpty
              ? 'Please select a gender'
              : null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final day in weeklyShiftControllers) {
      for (var shift in day) {
        shift.forEach((_, c) => c.dispose());
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: GestureDetector(child: Icon(Icons.arrow_back , color: Colors.white,) , onTap: () => Navigator.pop(context),),
        title: const Text("Update Gym Info" , style: TextStyle(color: Colors.white),)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _gyms.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<Gym>(
                      value: _selectedGym,
                      items: _gyms.map((gym) {
                        return DropdownMenuItem(
                          value: gym,
                          child: Text(gym.name),
                        );
                      }).toList(),
                      onChanged: (gym) {
                        setState(() {
                          _selectedGym = gym;
                          populateFields(gym!);
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Select Gym',
                        
                      ),
                      validator: (value) => value == null ? 'Please select a gym' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    buildTextField(nameController, 'Gym Name', (val) => val!.isEmpty ? "Required" : null),
                    buildTextField(capacityController, 'Capacity', (val) => val!.isEmpty ? "Required" : null, keyboardType: TextInputType.number),
                    buildTextField(openTimeController, 'Open Time', (val) => val!.isEmpty ? "Required" : null, readOnly: true, onTap: () => pickTime(context, openTimeController)),
                    buildTextField(closeTimeController, 'Close Time', (val) => val!.isEmpty ? "Required" : null, readOnly: true, onTap: () => pickTime(context, closeTimeController)),
                    buildTextField(contactEmailController, 'Contact Email', (val) => val!.isEmpty ? "Required" : null),
                    buildTextField(phoneController, 'Phone Number', (val) => val!.isEmpty ? "Required" : null),
                    buildTextField(aboutController, 'About Gym', (val) => val!.isEmpty ? "Required" : null),
                    buildTextField(equipmentController, 'Equipment List (comma separated)', (val) => val!.isEmpty ? "Required" : null),
                    const SizedBox(height: 20),
                    const Text("Weekly Shifts", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Colors.grey,
                      tabs: weekdays.map((day) => Tab(text: day)).toList(),
                    ),
                    SizedBox(
                      height: 500,
                      child: TabBarView(
                        controller: _tabController,
                        children: List.generate(7, (dayIndex) {
                          return Column(
                            children: [
                              Expanded(
                                child: ListView(
                                  children: [
                                    ...weeklyShiftControllers[dayIndex].asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final shift = entry.value;
                                      return Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Text("Shift ${index + 1}"),
                                                  const Spacer(),
                                                  IconButton(
                                                    icon: const Icon(Icons.copy, color: Colors.blue),
                                                    tooltip: 'Copy to Other Days',
                                                    onPressed: () {
                                                      List<bool> selectedDays = List.generate(7, (index) => false);
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) => StatefulBuilder(
                                                          builder: (context, setState) => AlertDialog(
                                                            title: Text('Copy to Other Days'),
                                                            content: Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: weekdays.asMap().entries.map((entry) {
                                                                if (entry.key == dayIndex) return SizedBox.shrink();
                                                                return CheckboxListTile(
                                                                  title: Text(entry.value),
                                                                  value: selectedDays[entry.key],
                                                                  onChanged: (bool? value) {
                                                                    setState(() {
                                                                      selectedDays[entry.key] = value ?? false;
                                                                    });
                                                                  },
                                                                );
                                                              }).toList(),
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () => Navigator.pop(context),
                                                                child: Text('Cancel'),
                                                              ),
                                                              TextButton(
                                                                onPressed: () {
                                                                  for (int i = 0; i < selectedDays.length; i++) {
                                                                    if (selectedDays[i] && i != dayIndex) {
                                                                      weeklyShiftControllers[i].add({
                                                                        'name': TextEditingController(text: shift['name']!.text),
                                                                        'startTime': TextEditingController(text: shift['startTime']!.text),
                                                                        'endTime': TextEditingController(text: shift['endTime']!.text),
                                                                        'capacity': TextEditingController(text: shift['capacity']!.text),
                                                                        'gender': TextEditingController(text: shift['gender']!.text),
                                                                      });
                                                                    }
                                                                  }
                                                                  Navigator.pop(context);
                                                                  this.setState(() {});
                                                                },
                                                                child: Text('Copy'),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.delete, color: Colors.red),
                                                    onPressed: () => removeShift(dayIndex, index),
                                                  ),
                                                ],
                                              ),
                                              buildTextField(shift['name']!, 'Shift Name', null),
                                              buildTextField(shift['startTime']!, 'Start Time', null, readOnly: true, onTap: () => pickTime(context, shift['startTime']!)),
                                              buildTextField(shift['endTime']!, 'End Time', null, readOnly: true, onTap: () => pickTime(context, shift['endTime']!)),
                                              buildTextField(shift['capacity']!, 'Shift Capacity', null, keyboardType: TextInputType.number),
                                              buildGenderDropdown(shift['gender']!),
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
                    const SizedBox(height: 16),

                  ],
                ),
              ),
      ),

      bottomNavigationBar:  Padding(
        padding:  EdgeInsets.symmetric(vertical: 30 ,horizontal: 12),
        child: ElevatedButton(
                        onPressed: updateGymInfo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor
                        ),
                        child: const Text("Update Gym Info" , style: TextStyle(color: Colors.white),),
                      ),
      ),
    );
  }
}
