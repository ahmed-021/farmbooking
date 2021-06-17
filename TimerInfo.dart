
import 'package:flutter/foundation.dart';

class TimerInfo extends ChangeNotifier{
  int seconds = 60;
  decreaseTime(){
      seconds--;
      notifyListeners();
  }
  void setSecods (){
    seconds = 60;
  }

  int getSeconds() => seconds;



}