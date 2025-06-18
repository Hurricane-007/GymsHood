import 'package:flutter/material.dart';
import 'package:gymshood/main.dart';
import 'package:gymshood/services/Models/ratingsModel.dart';
import 'package:gymshood/services/gymInfo/gymserviceprovider.dart';
import 'package:gymshood/services/Auth/auth_service.dart';
import 'package:gymshood/services/Models/AuthUser.dart';
import 'package:intl/intl.dart';

class ReviewsTabBar extends StatefulWidget {
  final String gymId;
  const ReviewsTabBar({super.key, required this.gymId});

  @override
  State<ReviewsTabBar> createState() => _ReviewsTabBarState();
}

class _ReviewsTabBarState extends State<ReviewsTabBar> {
  List<GymRating> ratings = [];
  Map<String, String> userNames = {};
  late Size mq;
  
  @override
  void initState() {
    super.initState();
    getratings();
  }

  Future<void> getratings() async {
    List<GymRating> list = await Gymserviceprovider.server().getratings(widget.gymId);
    setState(() {
      ratings = list;
    });
    // Fetch user names for all ratings
    for (var rating in list) {
      await _fetchUserName(rating.userId);
    }
  }

  Future<void> _fetchUserName(String userId) async {
    try {
      final user = await AuthService.server().getUser();
      if (user != null) {
        setState(() {
          userNames[userId] = user.name ?? 'Unknown User';
        });
      }
    } catch (e) {
      setState(() {
        userNames[userId] = 'Unknown User';
      });
    }
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: index < rating ? Colors.amber : Colors.grey,
          size: 20,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    
    if (ratings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No reviews yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8),
      itemCount: ratings.length,
      itemBuilder: (context, index) {
        final rating = ratings[index];
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildRatingStars(rating.rating),
                  Text(
                    DateFormat('MMM dd, yyyy').format(rating.createdAt ?? DateTime.now()),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              if (rating.feedback != null && rating.feedback!.isNotEmpty)
                Text(
                  rating.feedback!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    'User Name: ${userNames[rating.userId] ?? 'Loading...'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}