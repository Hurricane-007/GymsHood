import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gymshood/Utilities/Dialogs/error_dialog.dart';
import 'package:gymshood/Utilities/Dialogs/info_dialog.dart';
import 'package:gymshood/pages/mapPickerPage.dart';
import 'package:gymshood/sevices/Auth/auth_service.dart';
import 'package:gymshood/sevices/Models/AuthUser.dart';
import 'package:gymshood/sevices/gymInfo/gymserviceprovider.dart';

class Gyminfopage extends StatefulWidget {
  const Gyminfopage({super.key});

  @override
  State<Gyminfopage> createState() => _GyminfopageState();
}

class _GyminfopageState extends State<Gyminfopage> with SingleTickerProviderStateMixin {
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
  String role = 'GymOwner';

  // List<Map<String, TextEditingController>> shiftControllers = [];
  late TabController _tabController;
final List<String> weekdays = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
];
List<List<Map<String, TextEditingController>>> weeklyShiftControllers = [];
  
  @override
  void initState() {
    super.initState();
     _tabController = TabController(length: weekdays.length, vsync: this);
  for (int i = 0; i < weekdays.length; i++) {
    weeklyShiftControllers.add([]);
    addShift(i);} // Add 1 default shift to each dayd one default shift on start
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
  if(!mounted) return;
  weeklyShiftControllers[dayIndex].add({
    'name': TextEditingController(),
    'startTime': TextEditingController(),
    'endTime': TextEditingController(),
    'capacity': TextEditingController(),
  });
  setState(() {});
}

void removeShift(int dayIndex, int index) {
  if(!mounted) return;
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
        title: const Text("Register your gym / Update gym info",
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
                // DropdownButtonFormField<String>(
                //   value: role,
                //   decoration: const InputDecoration(labelText: 'Role'),
                //   items: ['Trainer', 'Staff', 'Member', 'Admin', 'GymOwner']
                //       .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                //       .toList(),
                //   onChanged: (value) => setState(() => role = value!),
                // ),
                // buildTextField(nameController, 'Name'),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                  onPressed: () async {
                    final picked = await Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const LocationPickerPage()),
                    );

                    if (picked is LatLng) {
                      coordinatesController.text =
                          "${picked.latitude},${picked.longitude}";
                    }
                  },
                  child: const Text('Pick Location from Map' , style: TextStyle(color: Colors.white),),
                ),
                buildTextField(
                    coordinatesController, 'Coordinates (auto-filled)',
                    keyboardType: TextInputType.text),

                // buildTextField(locationController, 'Location'),
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
    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
      return ListView(
        children: [
          ...weeklyShiftControllers[dayIndex].asMap().entries.map((entry) {
            final index = entry.key;
            final shift = entry.value;
            return Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text("Shift ${index + 1}",
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        IconButton(
                          onPressed: () => removeShift(dayIndex, index),
                          icon: const Icon(Icons.delete, color: Colors.red),
                        )
                      ],
                    ),
                    buildTextField(shift['name']!, 'Shift Name'),
                    buildTimeField(shift['startTime']!, 'Start Time'),
                    buildTimeField(shift['endTime']!, 'End Time'),
                    buildTextField(shift['capacity']!, 'Shift Capacity',
                        keyboardType: TextInputType.number),
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
      );
    }),
  ),
),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar:                 Padding(

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
                          if(!mounted) return;
                          final shifts = weeklyShiftControllers.expand((dayShifts) {
                            return dayShifts.map((shift) {
                              return {
                                'name': shift['name']!.text,
                                'startTime': shift['startTime']!.text,
                                'endTime': shift['endTime']!.text,
                                'capacity': int.parse(shift['capacity']!.text),
                              };
                            });
                          }).toList();
          
                          final res = await Gymserviceprovider.server().registerGym(
                            role: role,
                            name: nameController.text,
                            location: locationController.text,
                            coordinates: coordinatesController.text
                                .split(',')
                                .map((e) => num.tryParse(e.trim()))
                                .whereType<num>()
                                .toList(),
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
                            shifts: shifts,
                            userid: authuser!.userid!,
                          );
                          if(!mounted) return;
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
                          weeklyShiftControllers.clear();
                          if (res ==
                              "Successfully registered gym , will be notified once verified") {
                            showInfoDialog(context, res);
                          } else {
                            showErrorDialog(context, res);
                          }
                        }
                      },
                      child: const Text('Submit',
                          style: TextStyle(color: Colors.white)),
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
