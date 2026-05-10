import 'dart:ui';
import 'dart:math';
import 'package:project/constants/color.dart';

class ColorService{

  static String sortColor(Color clothingColor){
    double minDistance = 1000.0;
    double distance;
    int colorBin = -1;
    for (int i = 0; i < colorBins.length; i++){
      distance = colorDistance(colorBins[i], clothingColor);
      if (distance < minDistance){
        minDistance = distance;
        colorBin = i;
      }
    }
    return colorBinNames[colorBin];
  }

  static double colorDistance(Color colorOne, Color colorTwo){
    int red = colorOne.red - colorTwo.red;
    int green = colorOne.green - colorTwo.green;
    int blue = colorOne.blue - colorTwo.blue;
    red *= red;
    green *= green;
    blue *= blue;
    return sqrt(red + green + blue);
  }
}