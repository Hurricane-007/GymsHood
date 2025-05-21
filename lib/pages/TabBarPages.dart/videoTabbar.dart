import 'package:flutter/material.dart';
import 'package:gymshood/sevices/fileserver.dart';

class VideoTabBar extends StatefulWidget {
  const VideoTabBar({super.key});

  @override
  State<VideoTabBar> createState() => _VideoTabBarState();
}

class _VideoTabBarState extends State<VideoTabBar> {
    late List<String> _videoUrlsFuture;

  Future<List<String>>? getfiles()async{
     _videoUrlsFuture = await Fileserver().fetchMediaUrls('video');
    return _videoUrlsFuture;
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
          children: imageUrls.map((url) => Image.network(url, fit: BoxFit.cover,)).toList(),
        );
      },
    ),
  );
}
}