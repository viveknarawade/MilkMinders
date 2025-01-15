import 'package:flutter/material.dart';

class CustomSearchbar {
  static showCustomSearchbar(String title) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
      ),
      child: TextField(
        decoration: InputDecoration(
            suffixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
            hintText: title),
      ),
    );
  }
}
