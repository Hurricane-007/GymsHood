import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:gymshood/Utilities/Dialogs/showdeletedialog.dart';
import 'package:gymshood/pages/Gyminfopage.dart';
import 'package:gymshood/pages/createplansPage.dart';
import 'package:gymshood/pages/plansdetailspage.dart';
import 'package:gymshood/services/Auth/auth_service.dart';
import 'package:gymshood/services/Models/AuthUser.dart';
import 'package:gymshood/services/Models/gym.dart';
import 'package:gymshood/services/Models/planModel.dart';
import 'package:gymshood/services/gymInfo/gymserviceprovider.dart';

class PlansPage extends StatefulWidget {
  const PlansPage({super.key});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  List<Plan> plans = [];
  bool isLoading = true;
  String selectedSort = "Name";
  Map<String, String> gymNames = {};
  bool _selectionMode = false;
  final Set<Plan> _selectedPlans = {};

  @override
  void initState() {
    super.initState();
    getPlans();
  }

  Future<void> getPlans() async {
    try {
      final Authuser? authuser = await AuthService.server().getUser();
      final List<Gym> gyms =
          await Gymserviceprovider.server().getGymsByowner(authuser!.userid!);

      List<Plan> allplans = [];
      for (Gym gym in gyms) {
        final fetchedPlans =
            await Gymserviceprovider.server().getPlans(gym.gymid);
        allplans.addAll(fetchedPlans);
        gymNames[gym.gymid] = gym.name; // Cache gym name
      }

      setState(() {
        plans = allplans;
        sortPlans();
        isLoading = false;
        _selectionMode = false;
        _selectedPlans.clear();
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load plans')),
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
        plans.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
        break;
      case "Name":
      default:
        plans.sort((a, b) => a.name.compareTo(b.name));
    }
  }

  void _toggleSelection(Plan plan) {
    setState(() {
      if (_selectedPlans.contains(plan)) {
        _selectedPlans.remove(plan);
        if (_selectedPlans.isEmpty) _selectionMode = false;
      } else {
        _selectedPlans.add(plan);
        _selectionMode = true;
      }
    });
  }

  Future<void> _deleteSelectedPlans() async {
    final confirm = await showDeleteDialog(context);
    if (!confirm) return;

    bool allSuccess = true;
    for (var plan in _selectedPlans) {
      final success =
          await Gymserviceprovider.server().deletePlan(planId: plan.id);
      if (!success) allSuccess = false;
    }

    if (allSuccess) {
      setState(() {
        plans.removeWhere((p) => _selectedPlans.contains(p));
        _selectedPlans.clear();
        _selectionMode = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected plans deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Some deletions failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectionMode
          ? AppBar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              title: Text(
                "${_selectedPlans.length} selected",
                style: TextStyle(color: Colors.white),
              ),
              leading: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _selectedPlans.clear();
                    _selectionMode = false;
                  });
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                  onPressed: _deleteSelectedPlans,
                )
              ],
            )
          : AppBar(
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
                        .map((e) => DropdownMenuItem(
                            value: e, child: Text("Sort by $e")))
                        .toList(),
                  ),
                ),
              ],
            ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : plans.isEmpty
              ? RefreshIndicator.adaptive(
                  onRefresh: getPlans,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.event_busy,
                            size: 60, color: Colors.grey),
                        const SizedBox(height: 10),
                        const Text("No Plans Available",
                            style: TextStyle(fontSize: 18)),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const CreatePlansPage()),
                            );
                            // developer.log("CreatePlansPage returned: $result");
                            if (result == true) {
                              // developer.log("Calling getPlans()...");
                              await getPlans();
                            } else {
                              developer.log("No refresh triggered");
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text("Create Plan"),
                        ),
                        const SizedBox(height: 10),
                        const Text("Your gym is not created?",
                            style: TextStyle(fontSize: 18)),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const Gyminfopage()),
                            );
                            setState(() {
                              getPlans();
                            });
                          },
                          icon: const Icon(Icons.add),
                          label: const Text("Register Gym"),
                        ),
                      ],
                    ),
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
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3 / 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: plans.length,
                      itemBuilder: (context, index) {
                        final plan = plans[index];
                        final isSelected = _selectedPlans.contains(plan);
                        return GestureDetector(
                          onTap: () async {
                            if (_selectionMode) {
                              _toggleSelection(plan);
                            } else {
                              final res = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PlanDetailsPage(plan: plan),
                                ),
                              );
                              if (res) {
                                getPlans();
                              }
                            }
                          },
                          onLongPress: () => _toggleSelection(plan),
                          child: Stack(
                            children: [
                              Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                                color: isSelected
                                    ? Colors.blue[100]
                                    : Colors.blue[50],
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        gymNames[plan.gymId] ?? "Loading...",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.fitness_center,
                                              color: Theme.of(context)
                                                  .primaryColor),
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
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.green)),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(plan.planType.toUpperCase(),
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54)),
                                          Text("${plan.validity} days",
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black87)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Icon(Icons.check_circle,
                                      color: Colors.blue, size: 26),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePlansPage()),
          );
          developer.log("CreatePlansPage returned: $result");
          if (result == true) {
            developer.log("Calling getPlans()...");
            await getPlans();
          } else {
            developer.log("No refresh triggered");
          }
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
