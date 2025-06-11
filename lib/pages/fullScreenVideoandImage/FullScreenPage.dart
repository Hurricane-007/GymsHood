import 'package:flutter/material.dart';
import 'package:gymshood/Utilities/Dialogs/showdeletedialog.dart';
import 'package:gymshood/services/Models/gym.dart';
import 'package:gymshood/services/fileserver.dart';
import 'package:gymshood/services/gymInfo/gymserviceprovider.dart'; // Import your delete function here

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;
  final Gym gym;

  const FullScreenImagePage({super.key, required this.imageUrl , required this.gym});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirm = await showDeleteDialog(context);
              if (confirm == true) {
                List<String> mediaUrlsupdated = gym.media!.mediaUrls;
                mediaUrlsupdated.remove(imageUrl);
                final success = await Gymserviceprovider.server().addGymMedia(
                  mediaType: 'photo', mediaUrl: mediaUrlsupdated , logourl: gym.media!.logoUrl, gymId: gym.gymid);
                if (success == 'Media updated successfully') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image deleted successfully')),
                  );
                  Navigator.pop(context,true); // Exit viewer
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete image')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}
