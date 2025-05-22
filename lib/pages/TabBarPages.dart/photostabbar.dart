import 'package:flutter/material.dart';
import 'package:gymshood/Utilities/Dialogs/error_dialog.dart';
import 'package:gymshood/pages/FullScreenPage.dart';
import 'package:gymshood/sevices/fileserver.dart';
import 'package:http/http.dart';

class PhotosTabBar extends StatefulWidget {
  const PhotosTabBar({super.key});
 
  @override
  State<PhotosTabBar> createState() => _PhotosTabBarState();
}




class _PhotosTabBarState extends State<PhotosTabBar> {
  late List<String> _imageUrlsFuture;

  Future<List<String>>? getfiles()async{
     _imageUrlsFuture = await Fileserver().fetchMediaUrls('photo');
    return _imageUrlsFuture;
}
  @override
  void initState() {
  setState(() {
        getfiles();
  });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
    onRefresh: () async {
      setState(() {
             getfiles();
      });
    },
    child: FutureBuilder<List<String>>(
      future: getfiles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final imageUrls = snapshot.data ?? [];
        return GridView.count(
          crossAxisCount: 2,
          children: imageUrls.map((url) => GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FullScreenImagePage(imageUrl: url),)),
      
            child: Image.network(url, fit: BoxFit.cover,))).toList(),
        );
      },
    ),
  );
}}