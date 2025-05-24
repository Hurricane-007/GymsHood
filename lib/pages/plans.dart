import 'package:flutter/material.dart';
import 'package:gymshood/pages/createplansPage.dart';
import 'package:gymshood/pages/plansdetailspage.dart';
import 'package:gymshood/sevices/Models/planModel.dart';
import 'package:gymshood/sevices/gymInfo/gymserviceprovider.dart';

class PlansPage extends StatefulWidget {
  const PlansPage({super.key});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  List<Plan> plans = [];
  bool isLoading = true;
  String selectedSort = "Name";

  @override
  void initState() {
    super.initState();
    getPlans();
  }

  Future<void> getPlans() async {
    try {
      final fetchedPlans = await Gymserviceprovider.server().getPlans();
      setState(() {
        plans = fetchedPlans;
        sortPlans();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load plans: $e')),
      );
    }
  }

  void sortPlans() {
    switch (selectedSort) {
      case "Price":
        plans.sort((a, b) => a.price.compareTo(b.price));
        break;
      case "Duration":
        plans.sort((a, b) => a.validity.compareTo(b.validity));
        break;
      case "Discount":
        plans.sort((a,b) => b.discountPercent.compareTo(a.discountPercent));
      case "Name":
      default:
        plans.sort((a, b) => a.name.compareTo(b.name));
    }
  }

  Future<void> _deletePlan(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title:  Text('Delete Plan', style: TextStyle(color: Theme.of(context).primaryColor), ),
        content:  Text('Are you sure you want to delete this plan?', style: TextStyle(color: Theme.of(context).primaryColor),),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      final planId = plans[index].id;
      final success = await Gymserviceprovider.server().deletePlan(planId: planId); // Implement this in your service
      if (success) {
        setState(() => plans.removeAt(index));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plan deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete plan')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plans", style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<String>(
              value: selectedSort,
              underline: const SizedBox(),
              dropdownColor: Colors.white,
              style: TextStyle(color: Theme.of(context).primaryColor),
              iconEnabledColor: Colors.white,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedSort = value;
                    sortPlans();
                  });
                }
              },
              items: ["Name", "Price", "Duration", "Discount"]
                  .map((e) => DropdownMenuItem(value: e, child: Text("Sort by $e")))
                  .toList(),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : plans.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 60, color: Colors.grey),
                      const SizedBox(height: 10),
                      const Text("No Plans Available", style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CreatePlansPage()),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Create Plan"),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator.adaptive(
                  onRefresh: getPlans,
                  backgroundColor: Colors.white,
                  color: Theme.of(context).colorScheme.primary,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3 / 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: plans.length,
                      itemBuilder: (context, index) {
                        final plan = plans[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlanDetailsPage(plan: plan),
                              ),
                            );
                          },
                          onLongPress: () => _deletePlan(index),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            color: Colors.blue[50],
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.fitness_center, color: Theme.of(context).primaryColor),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          plan.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text("₹${plan.price.toStringAsFixed(0)}",
                                      style: const TextStyle(fontSize: 14, color: Colors.green)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(plan.planType.toUpperCase(),
                                          style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                      Text("${plan.validity} days",
                                          style: const TextStyle(fontSize: 12, color: Colors.black87)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePlansPage()),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
