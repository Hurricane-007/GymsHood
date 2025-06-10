import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:gymshood/Utilities/Dialogs/showdeletedialog.dart';
import 'package:gymshood/pages/createServicesPages/Gyminfopage.dart';
import 'package:gymshood/pages/createServicesPages/createplansPage.dart';
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
                        Icon(
                          Icons.event_busy,
                          size: 80,
                          color: Theme.of(context).primaryColor.withAlpha(100),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No Plans Available",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Create your first plan to get started",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const CreatePlansPage()),
                            );
                            if (result == true) {
                              await getPlans();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          icon: const Icon(Icons.add , color: Colors.white,),
                          label: const Text(
                            "Create Plan",
                            style: TextStyle(fontSize: 16 , color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
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
                          icon: const Icon(Icons.business),
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
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
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
                                  borderRadius: BorderRadius.circular(20),
                                  side: isSelected
                                      ? BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 2)
                                      : BorderSide.none,
                                ),
                                elevation: 4,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        
                                        Colors.blue.shade900,
                                        Colors.blue.shade400,
                                      ],
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withAlpha(50),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                gymNames[plan.gymId] ?? "Loading...",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              plan.name,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "₹${plan.price.toStringAsFixed(0)}",
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const Spacer(),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withAlpha(50),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    "${plan.validity} days",
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                if (plan.discountPercent > 0)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green.withAlpha(380),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      "${plan.discountPercent}% OFF",
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: Colors.white.withOpacity(0.3),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.check_circle,
                                              color: Colors.white,
                                              size: 40,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePlansPage()),
          );
          if (result == true) {
            await getPlans();
          }
        },
        backgroundColor: Theme.of(context).primaryColor,
        icon: const Icon(Icons.add),
        label: const Text("New Plan"),
      ),
    );
  }
}
