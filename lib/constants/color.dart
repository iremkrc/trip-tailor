import 'package:flutter/cupertino.dart';

const Color black = Color(0xFF191555);
const Color white = Color(0xFFFFFFFF);
const Color bgColor = Color(0xFF4448FF);
const Color selectColor = Color(0xFF4B3FFF);
const List<Color> colorBins = [Color(0xFFFF0000), Color(0xFFFF00FF), Color(0xFF8000FF),
                              Color(0xFF330099), Color(0xFF0000FF), Color(0xFF008080),
                              Color(0xFF00FF00), Color(0xFF80FF00), Color(0xFFFFFF00),
                              Color(0xFFFFc000), Color(0xFFFF8000), Color(0xFFFF4000),
                              Color(0xFF000000), Color(0xFFFFFFFF)];
const List<String> colorBinNames = ['RED', 'RED-VIOLET', 'VIOLET',
                                    'BLUE-VIOLET', 'BLUE', 'BLUE-GREEN',
                                    'GREEN', 'YELLOW-GREEN', 'YELLOW',
                                    'YELLOW-ORANGE', 'ORANGE', 'RED-ORANGE',
                                    'BLACK', 'WHITE'];

//colors in the same bin
final Map<String, List<String>> sameColors = {colorBinNames[0]: [colorBinNames[0], colorBinNames[12], colorBinNames[13]],
  colorBinNames[1]: [colorBinNames[1], colorBinNames[12], colorBinNames[13]],
  colorBinNames[2]: [colorBinNames[2], colorBinNames[12], colorBinNames[13]],
  colorBinNames[3]: [colorBinNames[3], colorBinNames[12], colorBinNames[13]],
  colorBinNames[4]: [colorBinNames[4], colorBinNames[12], colorBinNames[13]],
  colorBinNames[5]: [colorBinNames[5], colorBinNames[12], colorBinNames[13]],
  colorBinNames[6]: [colorBinNames[6], colorBinNames[12], colorBinNames[13]],
  colorBinNames[7]: [colorBinNames[7], colorBinNames[12], colorBinNames[13]],
  colorBinNames[8]: [colorBinNames[8], colorBinNames[12], colorBinNames[13]],
  colorBinNames[9]: [colorBinNames[9], colorBinNames[12], colorBinNames[13]],
  colorBinNames[10]: [colorBinNames[10], colorBinNames[12], colorBinNames[13]],
  colorBinNames[11]: [colorBinNames[11], colorBinNames[12], colorBinNames[13]],
  colorBinNames[12]: colorBinNames,
  colorBinNames[13]: colorBinNames};

//colors 1 bin apart
final Map<String, List<String>> closeColors = {colorBinNames[0]: [colorBinNames[11], colorBinNames[1], colorBinNames[12], colorBinNames[13]],
  colorBinNames[1]: [colorBinNames[0], colorBinNames[2], colorBinNames[12], colorBinNames[13]],
  colorBinNames[2]: [colorBinNames[1], colorBinNames[3], colorBinNames[12], colorBinNames[13]],
  colorBinNames[3]: [colorBinNames[2], colorBinNames[4], colorBinNames[12], colorBinNames[13]],
  colorBinNames[4]: [colorBinNames[3], colorBinNames[5], colorBinNames[12], colorBinNames[13]],
  colorBinNames[5]: [colorBinNames[4], colorBinNames[6], colorBinNames[12], colorBinNames[13]],
  colorBinNames[6]: [colorBinNames[5], colorBinNames[7], colorBinNames[12], colorBinNames[13]],
  colorBinNames[7]: [colorBinNames[6], colorBinNames[8], colorBinNames[12], colorBinNames[13]],
  colorBinNames[8]: [colorBinNames[7], colorBinNames[9], colorBinNames[12], colorBinNames[13]],
  colorBinNames[9]: [colorBinNames[8], colorBinNames[10], colorBinNames[12], colorBinNames[13]],
  colorBinNames[10]: [colorBinNames[9], colorBinNames[11], colorBinNames[12], colorBinNames[13]],
  colorBinNames[11]: [colorBinNames[10], colorBinNames[0], colorBinNames[12], colorBinNames[13]],
  colorBinNames[12]: colorBinNames,
  colorBinNames[13]: colorBinNames};

//colors 2 bins apart
final Map<String, List<String>> similarColors = {colorBinNames[0]: [colorBinNames[10], colorBinNames[2], colorBinNames[12], colorBinNames[13]],
  colorBinNames[1]: [colorBinNames[11], colorBinNames[3], colorBinNames[12], colorBinNames[13]],
  colorBinNames[2]: [colorBinNames[0], colorBinNames[4], colorBinNames[12], colorBinNames[13]],
  colorBinNames[3]: [colorBinNames[1], colorBinNames[5], colorBinNames[12], colorBinNames[13]],
  colorBinNames[4]: [colorBinNames[2], colorBinNames[6], colorBinNames[12], colorBinNames[13]],
  colorBinNames[5]: [colorBinNames[3], colorBinNames[7], colorBinNames[12], colorBinNames[13]],
  colorBinNames[6]: [colorBinNames[4], colorBinNames[8], colorBinNames[12], colorBinNames[13]],
  colorBinNames[7]: [colorBinNames[5], colorBinNames[9], colorBinNames[12], colorBinNames[13]],
  colorBinNames[8]: [colorBinNames[6], colorBinNames[10], colorBinNames[12], colorBinNames[13]],
  colorBinNames[9]: [colorBinNames[7], colorBinNames[11], colorBinNames[12], colorBinNames[13]],
  colorBinNames[10]: [colorBinNames[8], colorBinNames[0], colorBinNames[12], colorBinNames[13]],
  colorBinNames[11]: [colorBinNames[9], colorBinNames[1], colorBinNames[12], colorBinNames[13]],
  colorBinNames[12]: colorBinNames,
  colorBinNames[13]: colorBinNames};

//colors 3 bins apart
final Map<String, List<String>> moderateColors = {colorBinNames[0]: [colorBinNames[9], colorBinNames[3], colorBinNames[12], colorBinNames[13]],
  colorBinNames[1]: [colorBinNames[10], colorBinNames[4], colorBinNames[12], colorBinNames[13]],
  colorBinNames[2]: [colorBinNames[11], colorBinNames[5], colorBinNames[12], colorBinNames[13]],
  colorBinNames[3]: [colorBinNames[0], colorBinNames[6], colorBinNames[12], colorBinNames[13]],
  colorBinNames[4]: [colorBinNames[1], colorBinNames[7], colorBinNames[12], colorBinNames[13]],
  colorBinNames[5]: [colorBinNames[2], colorBinNames[8], colorBinNames[12], colorBinNames[13]],
  colorBinNames[6]: [colorBinNames[3], colorBinNames[9], colorBinNames[12], colorBinNames[13]],
  colorBinNames[7]: [colorBinNames[4], colorBinNames[10], colorBinNames[12], colorBinNames[13]],
  colorBinNames[8]: [colorBinNames[5], colorBinNames[11], colorBinNames[12], colorBinNames[13]],
  colorBinNames[9]: [colorBinNames[6], colorBinNames[0], colorBinNames[12], colorBinNames[13]],
  colorBinNames[10]: [colorBinNames[7], colorBinNames[1], colorBinNames[12], colorBinNames[13]],
  colorBinNames[11]: [colorBinNames[8], colorBinNames[2], colorBinNames[12], colorBinNames[13]],
  colorBinNames[12]: colorBinNames,
  colorBinNames[13]: colorBinNames};

final List<Map<String, List<String>>> colorMaps = [sameColors, closeColors, similarColors, moderateColors];