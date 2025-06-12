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

final Map<int, String> durationOptions = {
  1: '1hr',
  2: '2hr',
  5: 'Flexible',
};

int? workoutDuration;
num? customDuration;
late TextEditingController customDurationController;



  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.plan.name);
    priceController = TextEditingController(text: widget.plan.price.toString());
    discountController = TextEditingController(text: widget.plan.discountPercent.toString());
    featuresController = TextEditingController(text: widget.plan.features?.join(', ') ?? '');
    customDurationController = TextEditingController(
      text: widget.plan.workoutDuration == 0 ? widget.plan.workoutDuration.toString() : '',
    );
    isTrainerIncluded = widget.plan.isTrainerIncluded;
    
    // Initialize workoutDuration with the plan's value, ensuring it matches our options
    final planDuration = widget.plan.workoutDuration.toInt();
    if (durationOptions.containsKey(planDuration)) {
      workoutDuration = planDuration;
    } else {
      // If the plan's duration doesn't match our options, default to Flexible (0)
      workoutDuration = 0;
      customDuration = num.tryParse(planDuration.toString());
      customDurationController.text = planDuration.toString();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    discountController.dispose();
    featuresController.dispose();
    customDurationController.dispose();
    super.dispose();
  }

  Future<void> handleUpdate() async {
    final actualDuration = workoutDuration == 0
    ? (customDuration ?? 0)
    : workoutDuration!;
    if (_formKey.currentState!.validate()) {
      bool success = await Gymserviceprovider.server().updatePlan(
        planId: widget.plan.id,
        name: nameController.text.trim(),
        price: num.tryParse(priceController.text.trim()) ?? 0,
        discountPercent: num.tryParse(discountController.text.trim()) ?? 0,
        workoutDuration: actualDuration,
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
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      DropdownButtonFormField<int>(
        value: workoutDuration,
        decoration: InputDecoration(
          labelText: 'Workout Duration',
          
        ),
        items: durationOptions.entries.map((entry) {
          return DropdownMenuItem<int>(
            value: entry.key,
            child: Text(
              entry.value,
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          );
        }).toList(),
        onChanged: (val) {
          if (val == null) return;
          setState(() {
            workoutDuration = val;
            if (val != 0) {
              customDurationController.clear();
              customDuration = null;
            }
          });
        },
        validator: (val) => val == null ? 'Select workout duration' : null,
      ),
    ],
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
          
        ),
      ),
    );
  }
}
