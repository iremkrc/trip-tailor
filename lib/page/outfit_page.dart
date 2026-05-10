import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:project/services/location_service.dart';
import 'package:project/services/weather_service.dart';
import 'package:project/constants/color.dart';

class OutfitPage extends StatefulWidget {
  const OutfitPage({super.key});
  @override
  _OutfitPageState createState() => _OutfitPageState();
}

class _OutfitPageState extends State<OutfitPage> {
  String? colorComboChoice = 'same';
  var colorCombos = ['same', 'close', 'similar', 'moderate'];
  List<Map<String, dynamic>> myCloset = [];
  String _weatherDegree = '';
  String _suggestionSentence = '';
  String _currentDate = '';
  Image _weatherIcon =
      Image.asset("assets/icon/placeholder.png", width: 32.0, height: 32.0);

  final clothingTypes = [
    'Winter Coat',
    'Lightweight Jacket',
    'Pullover/Hoodie',
    'T-shirt/Top',
    'Jeans/Trousers',
    'Shorts/Skirt',
    'Winter Dress',
    'Dress/Romper'
  ];
  List<Map<String, dynamic>> outfit = [];

  @override
  void initState() {
    super.initState();
    _fetchCurrentDate();
    _findOutfit();
  }

  Future<void> _fetchWeatherWithLocation() async {
    try {
      Position position = await LocationService().getCurrentLocation();
      final weatherDegree = await WeatherAPIService().fetchWeatherDegree(
        position.latitude,
        position.longitude,
      );
      final weather = await WeatherAPIService().fetchWeather(
        position.latitude,
        position.longitude,
      );
      final weatherIcon = await WeatherAPIService().fetchWeatherIcon(
        position.latitude,
        position.longitude,
      );

      var suggestionSentence = '';
      if (weather == 'Rain') {
        suggestionSentence =
            "It's raining today, don't forget to bring an umbrella!";
      } else if (weather == 'Snow') {
        suggestionSentence =
            "It's snowing today, don't forget to wear snow boats and gloves!";
      } else if (weather == 'Clear') {
        suggestionSentence = "It's a sunny day today, enjoy the sunshine!";
      } else if (weather == 'Clouds') {
        suggestionSentence = "It's a cloudy day today, enjoy the breeze!";
      } else if (weather == 'Thunderstorm') {
        suggestionSentence = "It's a thunderstorm today, stay safe!";
      } else if (weather == 'Mist') {
        suggestionSentence = "It's a misty day today, drive carefully!";
      } else if (weather == 'Fog') {
        suggestionSentence = "It's a foggy day today, drive carefully!";
      } else if (weather == 'Drizzle') {
        suggestionSentence =
            "It's drizzling today, don't forget to bring an umbrella!";
      } else if (weather == 'Haze') {
        suggestionSentence = "It's hazy today, drive carefully!";
      } else if (weather == 'Smoke') {
        suggestionSentence = "It's smoky today, stay indoors!";
      } else if (weather == 'Dust') {
        suggestionSentence = "It's dusty today, stay indoors!";
      } else if (weather == 'Sand') {
        suggestionSentence = "It's sandy today, stay indoors!";
      } else if (weather == 'Ash') {
        suggestionSentence = "It's ashy today, stay indoors!";
      } else if (weather == 'Squall') {
        suggestionSentence = "It's squally today, stay indoors!";
      } else if (weather == 'Tornado') {
        suggestionSentence = "It's a tornado today, stay safe!";
      } else {
        suggestionSentence = "Have a nice day!";
      }
      setState(() {
        _weatherDegree = weatherDegree;
        _suggestionSentence = suggestionSentence;
        _weatherIcon = weatherIcon;
      });
    } catch (e) {
      rethrow;
    }
  }

  void _fetchCurrentDate() {
    var now = DateTime.now();
    var formatter = DateFormat('dd MMMM yyyy');
    String formattedDate = formatter.format(now);
    _currentDate = formattedDate;
  }

  Future<void> _fetchCloset() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot =
          await FirebaseDatabase.instance.ref('users/${user.uid}/closet').get();
      if (snapshot.exists) {
        final closetData = Map<String, dynamic>.from(snapshot.value as Map);
        final List<Map<String, dynamic>> closetList = [];
        for (final clothingId in closetData.keys) {
          final clothingSnapshot =
              await FirebaseDatabase.instance.ref('closet/$clothingId').get();
          if (clothingSnapshot.exists) {
            final clothingInfo =
                Map<String, dynamic>.from(clothingSnapshot.value as Map);
            closetList.add({
              'clothingId': clothingId,
              'imageUrl': clothingInfo['imageUrl'],
              'type': clothingInfo['type'],
              'colorBin': clothingInfo['colorBin']
            });
          }
        }
        setState(() {
          myCloset = closetList;
        });
      }
    }
  }

  void _suggestOutfit() async {
    Map<String, List<Map<String, dynamic>>> clothingMap = {};
    Map<String, int> colorComboChoices = {'same': 0, 'close': 1, 'similar': 2, 'moderate': 3};
    Map<String, List<String>> colorMap = colorMaps[colorComboChoices[colorComboChoice] ?? 0];
    for (var type in clothingTypes) {
      clothingMap[type] = [];
    }
    for (var color in colorBinNames){
      clothingMap[color] = [];
    }
    for (var clothing in myCloset) {
      clothingMap[clothing['type']]?.add(clothing);
      clothingMap[clothing['colorBin']]?.add(clothing);
    }

    List<Map<String, dynamic>> suggestedOutfit = [];

    Random random = Random();
    double temperature = double.parse(_weatherDegree);
    String? color;
    bool jacketAdded = false;
    bool topAdded = false;
    bool bottomAdded = false;
    bool dressAdded = false;
    bool coatAdded = false;
    if(temperature >= 18){
      var len = clothingMap['Dress/Romper']!.length + clothingMap['T-shirt/Top']!.length;
      if (clothingMap['Dress/Romper']!.isEmpty && clothingMap['T-shirt/Top']!.isEmpty && clothingMap['Shorts/Skirt']!.isEmpty) notEnoughClothes();
      // Suggest a Dress/Romper or a T-shirt/Top and Shorts/Skirt
      var dresses = clothingMap['Dress/Romper'];
      dresses?.shuffle();
      var tops = clothingMap['T-shirt/Top'];
      tops?.shuffle();
      var bottoms = clothingMap['Shorts/Skirt'];
      bottoms?.shuffle();
      var jackets = clothingMap['Lightweight Jacket'];
      jackets?.shuffle();
      var index = random.nextInt(len);
      if (dresses!.isNotEmpty && (index < clothingMap['Dress/Romper']!.length || bottoms!.isEmpty)){
        suggestedOutfit.add(dresses[0]);
        color = dresses[0]['colorBin'];
        dressAdded = true;
      } else if (tops!.isNotEmpty && bottoms!.isNotEmpty){
        suggestedOutfit.add(tops[0]);
        color = tops[0]['colorBin'];
        topAdded = true;

        for (Map<String, dynamic> bottom in bottoms){
          if (colorMap[color]!.contains(bottom['colorBin'])){
            suggestedOutfit.add(bottom);
            bottomAdded = true;
            break;
          }
        }
        if (!bottomAdded){
          suggestedOutfit.add(bottoms[0]);
        }
      }
      if(temperature < 20){
        if(jackets!.isNotEmpty) {
          for (Map<String, dynamic> jacket in jackets) {
            if (colorMap[color]!.contains(jacket['colorBin'])) {
              suggestedOutfit.add(jacket);
              jacketAdded = true;
              break;
            }
          }
          if (!jacketAdded) {
            suggestedOutfit.add(jackets[0]);
          }
        } else {notEnoughClothes();}
      }
    }else{
      var len = clothingMap['Winter Dress']!.length + clothingMap['Pullover/Hoodie']!.length;
      if (clothingMap['Winter Dress']!.isEmpty && clothingMap['Pullover/Hoodie']!.isEmpty && clothingMap['Jeans/Trousers']!.isEmpty) notEnoughClothes();
      // Suggest a Dress/Romper or a T-shirt/Top and Shorts/Skirt
      var dresses = clothingMap['Winter Dress'];
      dresses?.shuffle();
      var tops = clothingMap['Pullover/Hoodie'];
      tops?.shuffle();
      var bottoms = clothingMap['Jeans/Trousers'];
      bottoms?.shuffle();
      var jackets = clothingMap['Lightweight Jacket'];
      jackets?.shuffle();
      var coats = clothingMap['Winter Coat'];
      coats?.shuffle();
      var index = random.nextInt(len);
      if (dresses!.isNotEmpty && (index < clothingMap['Winter Dress']!.length || bottoms!.isEmpty)){
        suggestedOutfit.add(dresses[0]);
        color = dresses[0]['colorBin'];
        dressAdded = true;
      } else if (tops!.isNotEmpty && bottoms!.isNotEmpty){
        suggestedOutfit.add(tops[0]);
        color = tops[0]['colorBin'];
        topAdded = true;

        for (Map<String, dynamic> bottom in bottoms){
          if (colorMap[color]!.contains(bottom['colorBin'])){
            suggestedOutfit.add(bottom);
            bottomAdded = true;
            break;
          }
        }
        if (!bottomAdded){
          suggestedOutfit.add(bottoms[0]);
        }
      }
      if(temperature < 10){
        if(coats!.isNotEmpty) {
          for (Map<String, dynamic> coat in coats) {
            if (colorMap[color]!.contains(coat['colorBin'])) {
              suggestedOutfit.add(coat);
              coatAdded = true;
              break;
            }
          }
          if (!coatAdded) {
            suggestedOutfit.add(coats[0]);
          }
        } else {notEnoughClothes();}
      } else if (temperature >= 10) {
        if(jackets!.isNotEmpty) {
          for (Map<String, dynamic> jacket in jackets) {
            if (colorMap[color]!.contains(jacket['colorBin'])) {
              suggestedOutfit.add(jacket);
              jacketAdded = true;
              break;
            }
          }
          if (!jacketAdded) {
            suggestedOutfit.add(jackets[0]);
          }
        } else {notEnoughClothes();}
      }
    }
    if (suggestedOutfit.length == 3){
      var temp = suggestedOutfit[2];
      suggestedOutfit[2] = suggestedOutfit[1];
      suggestedOutfit[1] = suggestedOutfit[0];
      suggestedOutfit[0] = temp;
    } else if ((jacketAdded || coatAdded) && dressAdded){
      var temp = suggestedOutfit[1];
      suggestedOutfit[1] = suggestedOutfit[0];
      suggestedOutfit[0] = temp;
    }
    var outfitTypes = suggestedOutfit.map((item) => item['type']).toList();

    setState(() {
      outfit = suggestedOutfit;
    });
    if (outfit.isNotEmpty) {
      await _saveOutfit();
    }
  }

  @override
  Widget build(BuildContext context) {
    // display clothing by type
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outfit of the Day'),
        backgroundColor: Colors.white70,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: OutlinedButton(
                  onPressed: _suggestSomethingElse,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepPurple, side: const BorderSide(
                      color: Colors.deepPurple,
                    ),
                  ),
                  child: const Text("Suggest Something Else"),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: DropdownButton(
              //     value: colorComboChoice,
              //     items: colorCombos.map((String colorCombos) {
              //       return DropdownMenuItem(
              //         value: colorCombos,
              //         child: Text(colorCombos),
              //       );
              //     }).toList(),
              //     onChanged: (String? newValue){
              //       setState(() {
              //         colorComboChoice = newValue;
              //       });
              //     },
              //   ),
              // )
            ]
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
            child: Row(
              children: [
                Icon(Icons.thermostat_outlined,
                    size: 28.0, color: Colors.red[400]),
                    Flexible(child: Text('The temperature is $_weatherDegree°C.',
                    style: const TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.w600)),)
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                _weatherIcon,
                Flexible(
                  child:
                  Text(_suggestionSentence,
                      style: const TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w600)),
                )
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Icon(Icons.style_outlined,
                    size: 28.0, color: Colors.purple[300]),
                    Flexible(
                      child: Text('Here is your perfect outfit for $_currentDate:',
                      style: const TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w600)),
                    ),
               
              ],
            ),
          ),
          if (outfit.isEmpty)
            const Center(
              child: CircularProgressIndicator(),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: outfit.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          outfit.map((item) => item['type']).toList()[index],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 4.0,
                        ),
                        itemCount: 1,
                        itemBuilder: (context, itemIndex) {
                          return displayClothing(outfit[index]);
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _saveOutfit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final outfitRef = FirebaseDatabase.instance
          .ref('users/${user.uid}/outfits/$_currentDate');
      outfitRef.set(outfit);
    }
  }

  Future<Image> displayWeatherIcon(String iconCode) async {
    return Image.network('http://openweathermap.org/img/w/$iconCode.png',
        width: 32.0, height: 32.0);
  }

  void _findOutfit() async {
    await _fetchWeatherWithLocation();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseDatabase.instance
          .ref('users/${user.uid}/outfits/$_currentDate')
          .get();
      if (snapshot.exists) {
        // Cast snapshot.value to List<dynamic>
        final List<dynamic> data = snapshot.value as List<dynamic>;
        // Convert List<dynamic> to List<Map<String, dynamic>>
        final List<Map<String, dynamic>> outfitData = [];
        for (final item in data) {
          outfitData.add(Map<String, dynamic>.from(item as Map));
        }
        setState(() {
          outfit = outfitData;
        });
      }
      if (outfit.isEmpty) {
        await _fetchCloset();
        _suggestOutfit();
      }
    }
  }

  void _suggestSomethingElse() {
    // Delete outfit from database
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseDatabase.instance
          .ref('users/${user.uid}/outfits/$_currentDate')
          .remove();
    }
    // delete outfit
    setState(() {
      outfit = [];
    });
    _findOutfit();
  }

  displayClothing(Map<String, dynamic> clothing) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.network(clothing['imageUrl'], fit: BoxFit.cover),
        ),
        Positioned(
          left: 5,
          bottom: 5,
          child: GestureDetector(
            onTap: () {
              // show larger version of image
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    child: Image.network(clothing['imageUrl']),
                  );
                },
              );
            },
            child: const Icon(Icons.zoom_in, color: Colors.blue),
          ),
        ),
      ],
    );
  }

  notEnoughClothes() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Not Enough Clothes'),
          content: const Text(
              'You don\'t have clothes suitable for the weather in your closet. Please add more clothes to get an outfit suggestion.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
