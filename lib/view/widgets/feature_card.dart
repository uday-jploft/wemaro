import 'package:flutter/material.dart';


buildWelcomeCard(){
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.blue.shade900, Colors.blue.shade300],
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.video_call,
          color: Colors.white,
          size: 40,
        ),
        const SizedBox(height: 12),
        const Text(
          'Welcome to Video Calling',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Connect with people around the world with high-quality video calls',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}

class AppFeatureWidget extends StatelessWidget {
  const AppFeatureWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        buildFeatureCard(
          icon: Icons.hd,
          title: 'HD Quality',
          description: 'Crystal clear video calls',
          color: Colors.purple,
        ),
        buildFeatureCard(
          icon: Icons.security,
          title: 'Secure',
          description: 'End-to-end encrypted',
          color: Colors.green,
        ),
        buildFeatureCard(
          icon: Icons.speed,
          title: 'Fast Connect',
          description: 'Quick peer connection',
          color: Colors.orange,
        ),
        buildFeatureCard(
          icon: Icons.devices,
          title: 'Cross Platform',
          description: 'Works on all devices',
          color: Colors.blue,
        ),
      ],
    );
  }
}


Widget buildFeatureCard({
  required IconData icon,
  required String title,
  required String description,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    ),
  );
}