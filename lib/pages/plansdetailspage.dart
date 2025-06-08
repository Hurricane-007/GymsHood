import 'package:flutter/material.dart';
import 'package:gymshood/pages/createServicesPages/updatePlansPage.dart';
import 'package:gymshood/services/Models/gym.dart';
import 'package:gymshood/services/Models/planModel.dart';
import 'package:gymshood/services/gymInfo/gymserviceprovider.dart';

class PlanDetailsPage extends StatefulWidget {
  final Plan plan;

  const PlanDetailsPage({super.key, required this.plan});

  @override
  State<PlanDetailsPage> createState() => _PlanDetailsPageState();
}

class _PlanDetailsPageState extends State<PlanDetailsPage> {
  String gymName = "";
  Future<void> getGymName() async {
    final Gym gym =
        await Gymserviceprovider.server().getGymDetails(id: widget.plan.gymId);
    setState(() {
      gymName = gym.name;
    });
  }

  @override
  void initState() {
    getGymName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gymName, style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context,true),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              widget.plan.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(Icons.attach_money, "Price",
                      "₹${widget.plan.price.toStringAsFixed(2)}"),
                  _buildDetailRow(Icons.discount, "Discount",
                      "${widget.plan.discountPercent}% Off"),
                  _buildDetailRow(Icons.access_time, "Duration",
                      "${widget.plan.validity} days"),
                  _buildDetailRow(Icons.category, "Type", widget.plan.planType),
                  _buildDetailRow(
                    widget.plan.isTrainerIncluded
                        ? Icons.check_circle
                        : Icons.cancel,
                    "Trainer",
                    widget.plan.isTrainerIncluded ? "Included" : "Not Included",
                    iconColor: widget.plan.isTrainerIncluded
                        ? Colors.green
                        : Colors.red,
                  ),
                  _buildDetailRow(Icons.timelapse, "workoutDuration",
                      '${widget.plan.workoutDuration}hr'),
                  const SizedBox(height: 12),
                  const Text(
                    "Features",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  if (widget.plan.features != null &&
                      widget.plan.features!.isNotEmpty)
                    ...widget.plan.features!.map(
                      (feature) => Row(
                        children: [
                          const Icon(Icons.check,
                              size: 16, color: Colors.green),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              feature,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const Text("No features listed.",
                        style: TextStyle(fontSize: 15, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Placeholder for Update Plan button
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final bool res = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdatePlanPage(plan: widget.plan),
                      ));
                  if (res) {
                    final updatedGym = await Gymserviceprovider.server()
                        .getGymDetails(id: widget.plan.gymId);
                    setState(() {
                      gymName = updatedGym.name;
                    });
                  }
                },
                icon: const Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
                label: const Text(
                  "Update Plan",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value,
      {Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor ?? Colors.blueGrey),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
