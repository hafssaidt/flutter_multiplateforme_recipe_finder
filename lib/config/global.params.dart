import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GlobalParams {
  static List<Map<String,dynamic>> menu = [
    {"title":"home","icon":Icon(Icons.home, color: Colors.greenAccent,),"route":"/"},
    {"title":"recipes","icon":Icon(Icons.restaurant, color: Colors.greenAccent,),"route":"/"},
  ];
}