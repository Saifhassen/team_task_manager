import 'package:flutter/material.dart';

class WelcomeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.tag_faces, color: Colors.greenAccent),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "👋 مرحبًا بك! كيف أقدر أساعدك اليوم؟",
              style: TextStyle(color: Colors.white, fontSize: 16),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }
}
