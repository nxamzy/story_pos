import 'dart:math';
import 'package:flutter/material.dart';

class CounterProvider extends ChangeNotifier{
   int _count = 0;
   String _string="";
  Color _bgColor = Colors.white;
  double left = 0;
  double top = 0;

  String get string => _string;
  int get count => _count;
  Color get bgColor => _bgColor;

 void changePosition(double maxWidth, double maxHeight, double buttonSize) {
    _count++;
      if (count == 5) {
      _bgColor = Colors.green;
        _string="Good";
    }
    
    if (count == 10) {
      _bgColor = Colors.blue;
      _string = "Nice";
    }

    if (count == 15) {
      _bgColor = Colors.purple;
      _string = "Great";
    }
    
    if (count == 20) {
      _bgColor = Colors.orange;
      _string = "Perfect";
    }
    
    if (count == 25) {
      _bgColor = Colors.red;
      _string = "WOW";
    }
    
    

  Random rnd = Random();
    top = rnd.nextDouble() * (maxHeight - buttonSize);
    left = rnd.nextDouble() * (maxWidth - buttonSize);
notifyListeners();
 }
 void increment() {
    _count++;
    _checkColor();
    notifyListeners();
  }

  void decrement() {
    _count--;
    _checkColor();
    notifyListeners();
  }

  void _checkColor() {
    if (_count == 10) {
      _bgColor = Colors.blue;
    } else {
      _bgColor = Colors.white;
    }
  }
  }

