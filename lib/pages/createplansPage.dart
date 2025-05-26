import 'package:flutter/material.dart';
import 'package:gymshood/Utilities/Dialogs/error_dialog.dart';
import 'package:gymshood/services/Auth/auth_service.dart';
import 'package:gymshood/services/Models/AuthUser.dart';
import 'package:gymshood/services/Models/gym.dart';
import 'package:gymshood/services/Models/planModel.dart';
// import 'package:flutter/widgets.dart';
// import 'package:gymshood/Themes/theme.dart';
// import 'package:gymshood/main.dart';
import 'dart:developer' as developer;

import 'package:gymshood/services/gymInfo/gymserviceprovider.dart';

class CreatePlansPage extends StatefulWidget {
  const CreatePlansPage({super.key});

  @override
  State<CreatePlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<CreatePlansPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers or state variables
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController featuresController = TextEditingController();
  List<Gym> gyms = [];
  String? selectedPlanType;
  String? workoutDuration;
  bool isTrainerIncluded = false;
  final DateTime today = DateTime.now();
  DateTime? startdate;
  DateTime? enddate;
  Gym? selectedGym;

  @override
  void initState() {
    super.initState();
    getGym().then((_) {
      if (gyms.isNotEmpty) {
        setState(() => selectedGym = gyms.first); // default selection
      }
    });
  }

  Future<void> getGym() async {
    final Authuser? auth = await AuthService.server().getUser();
    final fetchedGyms =
        await Gymserviceprovider.server().getGymsByowner(auth!.userid!);
    setState(() {
      gyms = fetchedGyms;
    });
  }

  Future<String> getGymInfo(Plan plan)async{
      final gym = await Gymserviceprovider.server().getGymDetails(id: plan.gymId);
      return gym.name;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      barrierColor: Theme.of(context).colorScheme.secondary,
      context: context,
      initialDate: startdate ?? today,
      firstDate: today,
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
            data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                    primary: Theme.of(context).colorScheme.primary,
                    onPrimary: Colors.white,
                    onSurface: Theme.of(context).colorScheme.primary)),
            child: child!);
      },
    );
    if (picked != null) {
      setState(() {
        startdate = picked;
        if (enddate != null && enddate!.isBefore(startdate!)) {
          enddate = null;
        }
      });
    }
  }



  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      barrierColor: Theme.of(context).colorScheme.secondary,
      context: context,
      initialDate: enddate ?? (startdate ?? DateTime.now()),
      firstDate: startdate ?? DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              onSurface: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        enddate = picked;
      });
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Create Plan",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: GestureDetector(
            onTap: () => Navigator.pop(context,true),
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (gyms.isNotEmpty)
                DropdownButtonFormField<Gym>(
                  value: selectedGym,
                  decoration: InputDecoration(
                    labelText: 'Select Gym',
                    labelStyle:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  items: gyms
                      .map((gym) => DropdownMenuItem(
                            value: gym,
                            child: Text(gym.name),
                          ))
                      .toList(),
                  onChanged: (gym) {
                    setState(() => selectedGym = gym);
                  },
                  validator: (val) => val == null ? 'Select a gym' : null,
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text('No gyms found. Please register a gym first.',
                      style: TextStyle(color: Colors.red)),
                ),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter name' : null,
              ),
              SizedBox(height: 10),

              // Date Picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("Start Date"),
                subtitle: Text(
                  startdate != null
                      ? "${startdate!.toLocal()}".split(' ')[0]
                      : "No date selected",
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("End Date"),
                subtitle: Text(
                  enddate != null
                      ? "${enddate!.toLocal()}".split(' ')[0]
                      : "No date selected",
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: startdate == null ? null : () => _selectEndDate(context),
              ),
              SizedBox(height: 10),

              TextFormField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty
                    ? 'Enter price'
                    : double.tryParse(val) == null
                        ? 'Invalid number'
                        : null,
              ),
              SizedBox(height: 10),

              TextFormField(
                controller: discountController,
                decoration: InputDecoration(labelText: 'Discount (%)'),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty
                    ? 'Enter discount'
                    : double.tryParse(val) == null
                        ? 'Invalid number'
                        : null,
              ),
              SizedBox(height: 10),

              TextFormField(
                controller: featuresController,
                decoration: InputDecoration(labelText: 'Features'),
                maxLines: 3,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter features' : null,
              ),
              SizedBox(height: 10),

              // Plan Type Dropdown
              DropdownButtonFormField<String>(
                value: selectedPlanType,
                dropdownColor: Colors.white,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
                decoration: InputDecoration(
                    labelText: 'Plan Type',
                    labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.primary)),
                items: ['day', 'monthly', 'yearly']
                    .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(
                          type,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        )))
                    .toList(),
                onChanged: (val) {
                  setState(() => selectedPlanType = val);
                },
                validator: (val) => val == null ? 'Select plan type' : null,
              ),
              SizedBox(height: 10),

              // Trainer Included
              SwitchListTile(
                // activeColor: Colors.white,

                activeTrackColor: Theme.of(context).colorScheme.primary,
                inactiveTrackColor: Colors.white,
                // inactiveThumbColor: Theme.of(context).primaryColor,
                title: Text("Is Trainer Included?"),
                value: isTrainerIncluded,
                onChanged: (val) {
                  setState(() => isTrainerIncluded = val);
                },
              ),
              SizedBox(height: 10),

              // Workout Duration
              DropdownButtonFormField<String>(
                value: workoutDuration,
                dropdownColor: Colors.white,
                decoration: InputDecoration(
                    labelText: 'Workout Duration',
                    labelStyle:
                        TextStyle(color: Theme.of(context).primaryColor)),
                items: ['1hr', '2hr', 'flexible']
                    .map((dur) => DropdownMenuItem(
                        value: dur,
                        child: Text(
                          dur,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                        )))
                    .toList(),
                onChanged: (val) {
                  setState(() => workoutDuration = val);
                },
                validator: (val) =>
                    val == null ? 'Select workout duration' : null,
              ),
              SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    overlayColor: Colors.white),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // developer.log('call recieved inside form');
                    if(gyms.isEmpty){
                      showErrorDialog(context, "Register your gym first");
                           _formKey.currentState!.reset();
                    nameController.clear();
                    priceController.clear();
                    discountController.clear();
                    featuresController.clear();

                    setState(() {
                      selectedPlanType = null;
                      workoutDuration = null;
                      isTrainerIncluded = false;
                      startdate = null;
                      enddate = null;
                    });
                    }
                    Duration validity = enddate!.difference(startdate!);
                    final response = await Gymserviceprovider.server()
                        .createPlan(
                            name: nameController.text,
                            validity: validity.inDays,
                            price: num.parse(priceController.text),
                            discountPercent: num.parse(discountController.text),
                            features: featuresController.text,
                            planType: selectedPlanType!,
                            isTrainerIncluded: isTrainerIncluded,
                            workoutDuration: workoutDuration!,
                            gymId: selectedGym!.gymid);
                    //  developer.log(response);
                     if (response == 'Successfull') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Plan submitted")),
                      );
                    } else {
                      showErrorDialog(context, response);
                    }
                    _formKey.currentState!.reset();
                    nameController.clear();
                    priceController.clear();
                    discountController.clear();
                    featuresController.clear();

                    setState(() {
                      selectedPlanType = null;
                      workoutDuration = null;
                      isTrainerIncluded = false;
                      startdate = null;
                      enddate = null;
                    });
                  }
                },
                child: Text(
                  "Submit",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              )
            ],
          ),
        ),
      ),
    );
   
  }
}


    // name,
    // validity,
    // price,
    // discountPercent,
    // features,
    // planType,
    // isTrainerIncluded,
    // workoutDuration