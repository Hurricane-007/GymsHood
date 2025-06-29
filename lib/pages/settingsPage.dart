import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymshood/Utilities/Dialogs/error_dialog.dart';
import 'package:gymshood/Utilities/Dialogs/info_dialog.dart';
import 'package:gymshood/Utilities/Dialogs/showLogout_dialog.dart';
import 'package:gymshood/pages/announcementPage.dart';
import 'package:gymshood/pages/bankDetailsPage.dart';
import 'package:gymshood/pages/createServicesPages/Gyminfopage.dart';
import 'package:gymshood/pages/createServicesPages/addGymMediaPage.dart';
import 'package:gymshood/pages/createServicesPages/createplansPage.dart';
import 'package:gymshood/pages/generateQrPage.dart';
import 'package:gymshood/pages/helpAndSupportPage.dart';
import 'package:gymshood/pages/paymentHistory.dart';

import 'package:gymshood/pages/privacyPolicyPage.dart';
import 'package:gymshood/pages/updateGymdetailspage.dart';
import 'package:gymshood/services/Auth/bloc/auth_bloc.dart';
import 'package:gymshood/services/Auth/bloc/auth_event.dart';
import 'package:gymshood/services/Models/gym.dart';
import 'package:gymshood/services/gymInfo/gymserviceprovider.dart';

class SettingsPage extends StatelessWidget {
  final Gym? selectedGym;

  const SettingsPage({Key? key, this.selectedGym}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: BackButton(color: Colors.white,),
        title: Text(
          "Settings",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Gym Profile Section
          _buildSectionHeader(context, "Gym Profile"),
          _buildSettingsTile(
            context,
            icon: Icons.edit,
            title: "Update Gym Info",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UpdateGymDetailsPage()),
            ),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.photo_library,
            title: "Add Gym Media",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UploadMultipleImagesPage(
                  gym: selectedGym!,
                ),
              ),
            ),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.card_membership,
            title: "Create Gym Plans",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreatePlansPage()),
            ),
          ),

          // Gym Status Section
          // _buildSectionHeader(context, "Gym Status"),
          // if (selectedGym != null) _GymStatusToggle(gymId: selectedGym!.gymid),

          // Account Section
          _buildSectionHeader(context, "Account"),
          // _buildSettingsTile(
          //   context,
          //   icon: Icons.account_balance,
          //   title: "Payment contact info",
          //   onTap: () {
          //     Navigator.push(context, MaterialPageRoute(builder: (context) => BankDetailsPage(),));
          //   },
          // ),
          _buildSettingsTile(context, icon: Icons.payment, title: "Payment history", onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentHistoryPage(),))),
          _buildSettingsTile(
            context, icon: Icons.qr_code, title: "Create Gym Qr", onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> QrPage()));
            }),
          _buildSettingsTile(
            context,
            icon: Icons.notifications,
            title: "Announcements",
            onTap: () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => AnnouncementPage(),));
            },
          ),

          // Support Section
          _buildSectionHeader(context, "Support"),
          _buildSettingsTile(
            context,
            icon: Icons.help,
            title: "Help & Support",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpAndSupportPage()),
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.privacy_tip,
            title: "Privacy Policy",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
              );
            },
          ),

          // Logout Section
          _buildSectionHeader(context, ""),
          _buildSettingsTile(
            context,
            icon: Icons.logout,
            title: "Logout",
            textColor: Colors.red,
            onTap: () async{
              final res =  await showLogoutDialog(context);
             if(res){
               context.read<AuthBloc>().add(AuthEventLogOut());
               Navigator.pop(context);
             }
              
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    if (title.isEmpty) return SizedBox(height: 20);
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Theme.of(context).primaryColor),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: textColor ?? Colors.grey,
      ),
      onTap: onTap,
    );
  }
}

class _GymStatusToggle extends StatefulWidget {
  final String gymId;
  const _GymStatusToggle({required this.gymId});

  @override
  State<_GymStatusToggle> createState() => _GymStatusToggleState();
}

class _GymStatusToggleState extends State<_GymStatusToggle> {
  bool? isOpen;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    setState(() => isLoading = true);
    try {
      final gym = await Gymserviceprovider.server().getGymDetails(id: widget.gymId);
      setState(() {
        isOpen = gym.status.toString().split('.').last == 'open';
      });
    } catch (e) {
      showErrorDialog(context, 'Failed to fetch gym status');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _toggleStatus() async {
    setState(() => isLoading = true);
    final res = await Gymserviceprovider.server().toggleGymstatus();
    if (res) {
      setState(() {
        isOpen = !(isOpen ?? true);
      });
      showInfoDialog(context, 'Your gym status is now changed');
    } else {
      showErrorDialog(context, 'Error occurred');
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isOpen == null || isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return SwitchListTile(
      title: Text('Gym Status: ${isOpen! ? 'Open' : 'Closed'}'),
      value: isOpen!,
      activeColor: Colors.white,
      activeTrackColor: Theme.of(context).primaryColor,
      inactiveThumbColor: Theme.of(context).primaryColor,
      inactiveTrackColor: Colors.white,
      onChanged: (_) => _toggleStatus(),
    );
  }
} 