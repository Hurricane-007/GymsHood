import 'package:flutter/material.dart';
import 'package:gymshood/services/Models/planModel.dart';
import 'package:gymshood/services/gymInfo/gymserviceprovider.dart';

class UpdatePlanPage extends StatefulWidget {
  final Plan plan;

  const UpdatePlanPage({super.key, required this.plan});

  @override
  State<UpdatePlanPage> createState() => _UpdatePlanPageState();
}

class _UpdatePlanPageState extends State<UpdatePlanPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController discountController;
  late TextEditingController featuresController;
  bool isTrainerIncluded = false;

  String selectedWorkoutDuration = '1hr';

  final List<String> workoutDurationOptions = ['1hr', '2hr', 'Flexible'];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.plan.name);
    priceController = TextEditingController(text: widget.plan.price.toString());
    discountController = TextEditingController(text: widget.plan.discountPercent.toString());
    featuresController = TextEditingController(text: widget.plan.features?.join(', ') ?? '');
    selectedWorkoutDuration = widget.plan.workoutDuration;
    isTrainerIncluded = widget.plan.isTrainerIncluded;

    // default to plan value or first dropdown item
    if (workoutDurationOptions.contains(widget.plan.workoutDuration)) {
      selectedWorkoutDuration = widget.plan.workoutDuration;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    discountController.dispose();
    featuresController.dispose();
    super.dispose();
  }

  Future<void> handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      bool success = await Gymserviceprovider.server().updatePlan(
        planId: widget.plan.id,
        name: nameController.text.trim(),
        price: num.tryParse(priceController.text.trim()) ?? 0,
        discountPercent: num.tryParse(discountController.text.trim()) ?? 0,
        workoutDuration: selectedWorkoutDuration,
        features: featuresController.text.trim(),
        isTrainerIncluded: isTrainerIncluded,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Plan updated successfully")),
        );
        Navigator.pop(context,true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update plan")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Plan", style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(nameController, "Plan Name"),
              _buildTextField(priceController, "Price", isNumber: true),
              _buildTextField(discountController, "Discount (%)", isNumber: true),
              const SizedBox(height: 16),
              _buildWorkoutDurationDropdown(),
              const SizedBox(height: 16),
              _buildTextField(featuresController, "Features (comma-separated)"),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text("Trainer Included:"),
                  Switch(
                    value: isTrainerIncluded,
                    onChanged: (value) {
                      setState(() {
                        isTrainerIncluded = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: handleUpdate,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text("Save Changes", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildWorkoutDurationDropdown() {
  return DropdownButtonFormField<String>(
    value: workoutDurationOptions.contains(selectedWorkoutDuration)
        ? selectedWorkoutDuration
        : workoutDurationOptions.first,
    decoration: InputDecoration(
      labelText: "Workout Duration",
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
    items: workoutDurationOptions.map((String duration) {
      return DropdownMenuItem<String>(
        value: duration,
        child: Text(duration),
      );
    }).toList(),
    onChanged: (value) {
      if (value != null) {
        setState(() {
          selectedWorkoutDuration = value;
        });
      }
    },
    validator: (value) =>
        value == null || value.isEmpty ? "Please select a duration" : null,
  );
}


  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) => value == null || value.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
