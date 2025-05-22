import 'package:flutter/material.dart';
import 'package:gymshood/sevices/Models/planModel.dart';

class PlanDetailsPage extends StatelessWidget {
  final Plan plan;

  const PlanDetailsPage({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(plan.name , style: TextStyle(color: Colors.white),),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back, color: Colors.white,)),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withAlpha((0.2 * 255).toInt()),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Icon(Icons.attach_money, color: Colors.green),
          const SizedBox(width: 8),
          Text("₹${plan.price.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          const Icon(Icons.discount, color: Colors.redAccent),
          const SizedBox(width: 8),
          Text("${plan.discountPercent}% Off", style: const TextStyle(fontSize: 16)),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          const Icon(Icons.access_time, color: Colors.orange),
          const SizedBox(width: 8),
          Text("${plan.validity} days", style: const TextStyle(fontSize: 16)),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          const Icon(Icons.category, color: Colors.blueAccent),
          const SizedBox(width: 8),
          Text("Type: ${plan.planType}", style: const TextStyle(fontSize: 16)),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Icon(
            plan.isTrainerIncluded ? Icons.check_circle : Icons.cancel,
            color: plan.isTrainerIncluded ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            "Trainer: ${plan.isTrainerIncluded ? "Included" : "Not Included"}",
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
      const SizedBox(height: 12),
      const Text("Features:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      if (plan.features != null && plan.features!.isNotEmpty)
        ...plan.features!.map((f) => Row(
              children: [
                const Icon(Icons.check, size: 16, color: Colors.green),
                const SizedBox(width: 6),
                Flexible(child: Text(f, style: const TextStyle(fontSize: 15))),
              ],
            ))
      else
        const Text("No features listed.", style: TextStyle(fontSize: 15, color: Colors.grey)),
    ],
  ),
)

          ],
        ),
      ),
    );
  }
}
