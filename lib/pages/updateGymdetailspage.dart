import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gymshood/pages/mapPickerPage.dart';
import 'package:gymshood/services/Auth/auth_service.dart';
import 'package:gymshood/services/Models/AuthUser.dart';
import 'package:gymshood/services/Models/gym.dart';
import 'package:gymshood/services/Models/location.dart';
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
  final locationController = TextEditingController();
  final coordinatesController = TextEditingController();
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

  void populateFields(Gym gym) {
    nameController.text = gym.name;
    locationController.text = gym.location.address;
    coordinatesController.text = gym.location.coordinates.join(",");
    capacityController.text = gym.capacity.toString();
    openTimeController.text = gym.openTime;
    closeTimeController.text = gym.closeTime;
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
          'startTime': TextEditingController(text: shift['startTime'] ?? ''),
          'endTime': TextEditingController(text: shift['endTime'] ?? ''),
          'capacity': TextEditingController(text: shift['capacity']?.toString() ?? '0'),
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
    });
    setState(() {});
  }

  void removeShift(int dayIndex, int index) {
    weeklyShiftControllers[dayIndex][index].forEach((_, controller) => controller.dispose());
    weeklyShiftControllers[dayIndex].removeAt(index);
    setState(() {});
  }

  Future<void> pickTime(BuildContext context, TextEditingController controller) async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      controller.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
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
          'startTime': shift['startTime']!.text,
          'endTime': shift['endTime']!.text,
          'capacity': int.tryParse(shift['capacity']!.text) ?? 0,
        });
      }
    }

    final response = await Gymserviceprovider.server().updateGym(
      gymId: _selectedGym!.gymid,
      name: nameController.text,
      location: {
        'address': locationController.text,
        'coordinates':coordinatesController.text
                      .split(',')
                      .map((e) => num.tryParse(e.trim()))
                      .whereType<num>()
                      .toList(),
      },
      capacity: num.tryParse(capacityController.text) ?? 0,
      openTime: openTimeController.text,
      closeTime: closeTimeController.text,
      contactEmail: contactEmailController.text,
      phone: phoneController.text,
      about: aboutController.text,
      shifts: allShifts,
    );

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(response ? "Success" : "Error"),
        content: Text("successfully updated"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label, String? Function(String?)? validator,
      {TextInputType keyboardType = TextInputType.text,
      bool readOnly = false,
      VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: validator,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
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
      appBar: AppBar(title: const Text("Update Gym Info")),
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
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null ? 'Please select a gym' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    buildTextField(nameController, 'Gym Name', (val) => val!.isEmpty ? "Required" : null),
                    buildTextField(locationController, 'Address', (val) => val!.isEmpty ? "Required" : null),
                     ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor),
                  onPressed: () async {
                    final picked = await Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const LocationPickerPage()),
                    );

                    if (picked is LatLng) {
                      coordinatesController.text =
                          "${picked.longitude},${picked.latitude}";
                    }
                  },
                  child: const Text(
                    'Pick Coordinates from Map',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                    buildTextField(coordinatesController, 'Coordinates', (val) => val!.isEmpty ? "Required" : null),
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
                                                    icon: const Icon(Icons.delete, color: Colors.red),
                                                    onPressed: () => removeShift(dayIndex, index),
                                                  ),
                                                ],
                                              ),
                                              buildTextField(shift['name']!, 'Shift Name', null),
                                              buildTextField(shift['startTime']!, 'Start Time', null, readOnly: true, onTap: () => pickTime(context, shift['startTime']!)),
                                              buildTextField(shift['endTime']!, 'End Time', null, readOnly: true, onTap: () => pickTime(context, shift['endTime']!)),
                                              buildTextField(shift['capacity']!, 'Shift Capacity', null, keyboardType: TextInputType.number),
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
        padding: const EdgeInsets.all(16.0),
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
