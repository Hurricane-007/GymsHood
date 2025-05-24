import 'package:flutter/material.dart';
import 'package:gymshood/sevices/fileserver.dart'; // Import your delete function here

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImagePage({super.key, required this.imageUrl});

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
              final confirm = await showDialog<bool>(
                // barrierColor: Colors.white,
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: Colors.white,
                  title:  Text('Delete Image' , style: TextStyle(color: Theme.of(context).colorScheme.primary),),
                  content:  Text('Are you sure you want to delete this image?' , style: TextStyle(color: Theme.of(context).primaryColor),),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child:  Text('Cancel',style: TextStyle(color: Theme.of(context).primaryColor)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child:  Text('Delete',style: TextStyle(color: Theme.of(context).primaryColor)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                final filename = imageUrl.split('/').last;
                final success = await Fileserver().deleteFileFromServer(filename);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image deleted successfully')),
                  );
                  Navigator.of(context).pop(); // Exit viewer
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
