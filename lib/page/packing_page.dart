import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:project/model/weather_model.dart';
import 'package:project/page/closet_page.dart';
import 'package:project/services/weather_service.dart';

class PackingPage extends StatefulWidget {
  final String tripId;

  const PackingPage({
    super.key,
    required this.tripId,
  });

  @override
  _PackingPageState createState() => _PackingPageState();
}

class _PackingPageState extends State<PackingPage> {
  int tripDuration = 3;
  late Map<String, Map<String, int>> categories = {};
  Map<String, int> clothes = {};
  Map<String, Set<String>> checkedItems = {};
  final WeatherAPIService _weatherAPIService = WeatherAPIService();
  final clothingTypes = ['Winter Coat', 'Lightweight Jacket', 'Pullover/Hoodie', 'T-shirt/Top', 'Jeans/Trousers', 'Shorts/Skirt', 'Winter Dress', 'Dress/Romper'];

  List<Map<String, dynamic>> myCloset = [];
  Map<String, dynamic> chosenItems = {};
  Map<String, dynamic> unchosenItems = {};


  @override
  void initState() {
    super.initState();
    _fetchPackingListOrInitialize();
    _fetchChosenItems();
  }

  void _fetchPackingListOrInitialize() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final tripRef = FirebaseDatabase.instance
          .ref('users/${user.uid}/trips/${widget.tripId}');
      final tripSnapshot = await tripRef.get();

      if (tripSnapshot.exists && tripSnapshot.value != null) {
        final tripData = tripSnapshot.value as Map;

        if (tripData.containsKey('startDate') &&
            tripData.containsKey('endDate')) {
          DateTime startDate = DateFormat("yyyy-MM-ddTHH:mm:ss.SSS")
              .parse(tripData['startDate']);
          DateTime endDate =
              DateFormat("yyyy-MM-ddTHH:mm:ss.SSS").parse(tripData['endDate']);
          setState(() {
            tripDuration = endDate.difference(startDate).inDays;
          });
        }

        List<String> tripTypes = [];

        if (tripData.containsKey('tripTypes') &&
            tripData['tripTypes'] is List) {
          tripTypes = List<String>.from(tripData['tripTypes']);
        }
        if (tripData.containsKey('packingList') &&
            tripData['packingList'] != null) {
          Map packingListData = tripData['packingList'];
          initializePackingListWithTypes(packingListData, tripTypes);
        } else {
          initializeHardcodedList(tripTypes);
        }
      } else {
        initializeHardcodedList([]);
      }
    }
  }

  void initializeHardcodedList(List<String> tripTypes) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final tripRef = FirebaseDatabase.instance
          .ref('users/${user.uid}/trips/${widget.tripId}');
      final tripSnapshot = await tripRef.get();
      WeatherModel weatherModel = WeatherModel();
      if (tripSnapshot.exists && tripSnapshot.value != null) {
        final tripData = tripSnapshot.value as Map;

        DateTime today = DateTime.now();
        DateTime fourDaysLater = today.add(const Duration(days: 4));

        DateTime? startDate = DateTime.tryParse(tripData['startDate']);
        DateTime? endDate = DateTime.tryParse(tripData['endDate']);

        if (startDate == null ||
            endDate == null ||
            startDate.isAfter(today.add(const Duration(days: 5))) ||
            endDate.isAfter(today.add(const Duration(days: 5)))) {
          startDate = today;
          endDate = fourDaysLater;
        }

        String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
        String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

        if (tripData.containsKey('city') || tripData.containsKey('state')) {
          if (tripData.containsKey('city')) {
            weatherModel = await _weatherAPIService.fetchCityDegree(
                tripData['city'], formattedStartDate, formattedEndDate);
          } else {
            weatherModel = await _weatherAPIService.fetchCityDegree(
                tripData['state'], formattedStartDate, formattedEndDate);
          }

          double? avgTemperature;

          if (weatherModel.daily?.temperature2mMin != null &&
              weatherModel.daily!.temperature2mMin!.isNotEmpty) {
            avgTemperature =
                weatherModel.daily!.temperature2mMin!.reduce((a, b) => a + b) /
                    weatherModel.daily!.temperature2mMin!.length;
          } else {
            avgTemperature = null;
          }
          if (avgTemperature != null) {
            setState(() {
              clothes = {
                  'Winter Coat': avgTemperature! <= 0 ? tripDuration : 0,
                  'Pullover/Hoodie': avgTemperature <= 15 ? tripDuration : 0,
                  'Lightweight Jacket':
                      (avgTemperature > 10 && avgTemperature <= 15)
                          ? (tripDuration/4).ceil()
                          : 1,
                  'T-shirt/Top':
                      avgTemperature > 15 ? (tripDuration / 2).ceil() : 0,
                  'Shorts/Skirt': avgTemperature >= 20 ? tripDuration : 0,
                  'Jeans/Trousers': (avgTemperature < 20) ? (tripDuration/3).ceil() : 0,
                  'Dress/Romper':
                      avgTemperature >= 15 ? (tripDuration / 2).ceil() : 0,
                  'Winter Dress':
                      avgTemperature < 0 ? (tripDuration / 2).ceil() : 0,
                };
              categories = {
                'Accessories': {
                  'Umbrella': 1,
                  'Optical Glasses': 1,
                  'Sunglasses': (tripDuration / 7).ceil(),
                  'Hat': (tripDuration / 5).ceil(),
                },
                'Personal Care': {
                  'Toothbrush': 1,
                  'Toothpaste': 1,
                  'Roll-on': 1,
                  'Cologne': (tripDuration / 5).ceil(),
                  'Shampoo': (tripDuration / 5).ceil(),
                  'Conditioner': (tripDuration / 5).ceil(),
                  'Soap': (tripDuration / 3).ceil(),
                },
                'Travel Documents': {
                  'Passport': 1,
                  'Visa': 1,
                  'Health Insurance': 1,
                  'Cash': 1,
                  'Credit Card': 1,
                },
              };
              adjustCategoriesForTripTypes(tripTypes);
            });
          } else {
            setState(() {
              clothes = {
                  'Winter Coat': tripDuration,
                  'Pullover/Hoodie': tripDuration,
                  'Lightweight Jacket': tripDuration,
                  'T-shirt/Top': tripDuration,
                  'Jeans/Trousers': tripDuration,
                  'Dress/Romper': tripDuration,
                  'Winter Dress': tripDuration,
                };
              categories = {
                'Accessories': {
                  'Umbrella': 1,
                  'Optical Glasses': 1,
                  'Sunglasses': (tripDuration / 7).ceil(),
                  'Hat': (tripDuration / 5).ceil(),
                },
                'Personal Care': {
                  'Toothbrush': 1,
                  'Toothpaste': 1,
                  'Roll-on': 1,
                  'Cologne': (tripDuration / 5).ceil(),
                  'Shampoo': (tripDuration / 5).ceil(),
                  'Conditioner': (tripDuration / 5).ceil(),
                  'Soap': (tripDuration / 3).ceil(),
                },
                'Travel Documents': {
                  'Passport': 1,
                  'Visa': 1,
                  'Health Insurance': 1,
                  'Cash': 1,
                  'Credit Card': 1,
                },
              };
              
              adjustCategoriesForTripTypes(tripTypes);
            });
          }
        }
      }
    }
  }

  void initializePackingListWithTypes(Map data, List<String> tripTypes) {
    setState(() {
      categories = {};
      checkedItems = {};
      data.forEach((category, details) {
        Map<String, int> items = {};
        Set<String> checked = <String>{};
        if (details['items'] != null) {
          Map itemsData = details['items'];
          itemsData.forEach((itemName, itemDetails) {
            items[itemName] = itemDetails['quantity'];
            if (itemDetails['checked']) {
              checked.add(itemName);
            }
          });
        }
        categories[category] = items;
        checkedItems[category] = checked;
      });
      adjustCategoriesForTripTypes(tripTypes);
    });
  }

  void adjustCategoriesForTripTypes(List<String> tripTypes) {
    for (var type in tripTypes) {
      switch (type) {
        case 'Business':
          categories['Accessories']!['Laptop'] = 1;
          categories['Accessories']!['Business Cards'] = 50;
          break;
        case 'Leisure':
          categories['Accessories']!['Swimwear'] = 2;
          categories['Accessories']!['Beach Towel'] = 1;
          break;
        case 'Adventure':
          categories['Accessories']!['Hiking Boots'] = 1;
          categories['Accessories']!['Backpack'] = 1;
          break;
        case 'Cultural':
          categories['Accessories']!['Guide Book'] = 1;
          categories['Accessories']!['Event Tickets'] = 1;
          break;
        case 'Romantic':
          categories['Accessories']!['Fine Dining Outfit'] = 1;
          categories['Personal Care']!['Perfume'] = 1;
          break;
        case 'Family':
          //categories['Clothing']!['Kids Clothes'] = 3;
          categories['Toys & Games'] = {'Board Games': 2};
          break;
        case 'Sports':
          categories['Equipment'] = {'Sports Gear': 1};
          break;
        case 'Relaxation':
          categories['Accessories']!['Spa Outfit'] = 1;
          categories['Personal Care']!['Massage Oil'] = 1;
          break;
        case 'Exploration':
          categories['Accessories']!['Binoculars'] = 1;
          categories['Accessories']!['Maps'] = 1;
          break;
      }
    }

    categories.forEach((key, value) {
      checkedItems[key] = {};
    });
  }

  Widget _counterWidget(String category, String item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: categories[category]![item]! > 0
                ? () {
                    setState(() {
                      categories[category]![item] =
                          categories[category]![item]! - 1;
                    });
                  }
                : null,
          ),
          Text(
            '${categories[category]![item]}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                categories[category]![item] = categories[category]![item]! + 1;
              });
            },
          ),
        ],
      ),
    );
  }

  void _addItemToCategory(String category) async {
    final TextEditingController itemNameController = TextEditingController();
    final TextEditingController itemCountController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Item to $category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: itemNameController,
                decoration: const InputDecoration(hintText: 'Item Name'),
              ),
              TextField(
                controller: itemCountController,
                decoration: const InputDecoration(hintText: 'Quantity'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final itemName = itemNameController.text.trim();
                final itemCountText = itemCountController.text.trim();

                if (itemName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Item name cannot be empty'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                if (itemCountText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Quantity cannot be empty'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                final itemCount = int.parse(itemCountText);

                if (categories.containsKey(category) &&
                    categories[category]!.containsKey(itemName)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Item already exists in this category'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                setState(() {
                  if (categories.containsKey(category)) {
                    categories[category]![itemName] = itemCount;
                  } else {
                    categories[category] = {itemName: itemCount};
                    checkedItems[category] = {};
                  }
                });
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeletion(BuildContext context, String category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(
              'Are you sure you want to delete the "$category" category and all its items?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                setState(() {
                  categories.remove(category);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildListItemClothing(String itemName){
    if (chosenItems.isEmpty){
              return const Center(
                child: CircularProgressIndicator(),
              );}
          else
    {return 
    Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: ExpansionTile(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Flexible(child:
            Text(
              '$itemName - ${chosenItems[itemName].length}/${clothes[itemName]} packed',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),)
          ],
        ),
        children: [
          // show clothes
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
            ),
            
            itemCount: chosenItems[itemName].length + 1,
            itemBuilder: (context, itemIndex) {
              if (itemIndex == chosenItems[itemName].length) {
                return displayAddItem(itemName);
              } else{
              return displayClothing(itemName, itemIndex);
              }
            },
          ),
        ],
      ),
    );
    }
  }

  Widget displayAddItem(String itemName) {
    return Card(
      color: Colors.grey[200],
      child: IconButton(
        icon: const Icon(Icons.add),
        onPressed: () {
          addItemCheck(itemName);
        },
      ),
    );
  }

  void addItem(String itemName) {
    if (unchosenItems[itemName].length < 1){
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('No more $itemName in closet'),
            content: Text(
                'There are no more items of type $itemName in your closet. Please add more items to your closet before packing more for this trip.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ClosetPage()),
                );
                },
                child: const Text('Go to Closet'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else{
      setState(() {
        Map<String, dynamic> item = unchosenItems[itemName].removeLast().cast<String, dynamic>();
        chosenItems[itemName].add(item);
      });
    }
  }

  void addItemCheck(String itemName) async{
    if (clothes[itemName]! <= chosenItems[itemName].length){
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('No more $itemName needed'),
            content: Text(
                'You have already packed the required number of $itemName for this trip.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  addItem(itemName);
                },
                child: const Text('Add Anyway'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
    else{
      addItem(itemName);
    }
  }

  

  displayClothing(String itemName, int itemIndex) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.network(chosenItems[itemName][itemIndex]['imageUrl'], fit: BoxFit.cover),
        ),
        Positioned(
          right: 5,
          top: 5,
          child: GestureDetector(
            onTap: () {
              setState(() {
                Map<String, dynamic> item = chosenItems[itemName][itemIndex].cast<String, dynamic>();
                unchosenItems[itemName].add(item);
                chosenItems[itemName].removeAt(itemIndex);
              });
            },
            child: const Icon(Icons.delete, color: Colors.red),
          ),
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
                    child: Image.network(chosenItems[itemName][itemIndex]['imageUrl']),
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

  void _fetchChosenItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final chosenClothesRef = FirebaseDatabase.instance
          .ref('users/${user.uid}/trips/${widget.tripId}/clothingList/ChosenClothes');
      final chosenClothesSnapshot = await chosenClothesRef.get();

      final allClothesRef = FirebaseDatabase.instance
          .ref('users/${user.uid}/trips/${widget.tripId}/clothingList/AllClothes');
      final allClothesSnapshot = await allClothesRef.get();
      if (allClothesSnapshot.exists) {
        final allClothesData = Map<String, int>.from(allClothesSnapshot.value as Map);
        Map<String, int> allClothesDataUpdated = {}; 
        allClothesData.forEach((itemName, value) {
          String key = itemName.replaceAll('_', '/');
          allClothesDataUpdated[key] = value;
        });
        setState(() {
          clothes = allClothesDataUpdated;
        });
      }

      if (chosenClothesSnapshot.exists) {
        final chosenClothesData = Map<String, dynamic>.from(chosenClothesSnapshot.value as Map);
      
        Map<String, dynamic> chosenClothesDataUpdated = {}; 
        Map<String, dynamic> unchosenClothesDataUpdated = {}; 

        for (var itemType in clothes.keys) {
          chosenClothesDataUpdated[itemType] = [];
          unchosenClothesDataUpdated[itemType] = [];
        }

        await _fetchCloset();

        chosenClothesData.forEach((itemName, value) {
          String key = itemName.replaceAll('_', '/');
          value = value.values.toList();
          chosenClothesDataUpdated[key] = value;

          List<Map<String, dynamic>> filteredItems = myCloset.where((item) => item['type'] == key).toList();
          List<dynamic> clothingIds = chosenClothesDataUpdated[key].map((map) => map['clothingId']).toList();
          filteredItems.removeWhere((item) => clothingIds.contains(item['clothingId']));
          unchosenClothesDataUpdated[key] = filteredItems;
          
        });
        

        setState(() {
          chosenItems = chosenClothesDataUpdated;
          unchosenItems = unchosenClothesDataUpdated;
        });
      }else{
        chooseClothing();
      }
      
    }

  }
  
  Future<void> chooseClothing() async {
    print("Choosing clothing...");
    await _fetchCloset();
    for (var itemType in clothes.keys) {
      List<Map<String, dynamic>> chosen = [];
      List<Map<String, dynamic>> unchosen = [];
      List<Map<String, dynamic>> filteredItems = myCloset
                    .where((item) => item['type'] == itemType)
                    .toList();
      if (filteredItems.length < clothes[itemType]!) {
        chosen.addAll(filteredItems);
      } else {
        filteredItems.shuffle();
        chosen.addAll(filteredItems.sublist(0, clothes[itemType]!));
        unchosen.addAll(filteredItems.sublist(clothes[itemType]!));
      }
      setState(() {
        chosenItems[itemType] = chosen;
        unchosenItems[itemType] = unchosen;
      });
      
    }
  }

  Widget _buildListItem(String category, String item) {
    bool isChecked = checkedItems[category]?.contains(item) ?? false;

    return Card(
      child: ListTile(
        leading: IconButton(
          icon: Icon(
              isChecked ? Icons.check_box : Icons.check_box_outline_blank,
              color: isChecked ? Colors.green : null),
          onPressed: () {
            setState(() {
              if (isChecked) {
                checkedItems[category]?.remove(item);
              } else {
                if (checkedItems[category] == null) {
                  checkedItems[category] = {};
                }
                checkedItems[category]?.add(item);
              }
            });
          },
        ),
        title: Text(item),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _counterWidget(category, item),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                setState(() {
                  categories[category]?.remove(item);
                  checkedItems[category]?.remove(item);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionTile(String category) {
    List<Widget> itemTiles = categories[category]!
        .keys
        .map((item) => _buildListItem(category, item))
        .toList();

    itemTiles.add(
      ListTile(
        leading: const Icon(Icons.add_circle_outline, color: Colors.green),
        title: const Text('Add new item'),
        onTap: () => _addItemToCategory(category),
      ),
    );

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: ExpansionTile(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                _confirmDeletion(context, category);
              },
            ),
            Flexible(child:
            Text(
              '$category - ${categories[category]!.length} objects',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),)
          ],
        ),
        children: itemTiles,
      ),
    );
  }

  Widget _buildExpansionTileClothing() {
    // List<Widget> itemTiles = clothes
    //     .keys
    //     .map((item) => _buildListItem("Clothing", item))
    //     .toList();
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: ExpansionTile(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.checkroom),
            Flexible(child:
            Text(
              '    Clothing - ${clothes.length} objects',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),)
          ],
        ),
        children: [
          for (var item in clothes.keys) _buildListItemClothing(item)
        ],
      ),
    );
  }
  


  void _saveList() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final packingListRef = FirebaseDatabase.instance
          .ref('users/${user.uid}/trips/${widget.tripId}/packingList');

      packingListRef.get().then((snapshot) {
        if (snapshot.exists) {
          Map<String, dynamic> packedData = {};
          categories.forEach((categoryName, items) {
            Map<String, dynamic> itemDetails = {};
            items.forEach((itemName, quantity) {
              itemDetails[itemName] = {
                'quantity': quantity,
                'checked':
                    checkedItems[categoryName]?.contains(itemName) ?? false
            };
          });

          packedData[categoryName] = {'items': itemDetails};
          });
          packingListRef.set(packedData).then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Packing list saved!')));
          
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to save packing list: $error')));
          });
        } else {
          Map<String, dynamic> packedData = {};
          categories.forEach((categoryName, items) {
            Map<String, dynamic> itemDetails = {};
            items.forEach((itemName, quantity) {
              itemDetails[itemName] = {
                'quantity': quantity,
                'checked':
                    checkedItems[categoryName]?.contains(itemName) ?? false
              };
            });
            packedData[categoryName] = {'items': itemDetails};
          });

          packingListRef.set(packedData);
        }
        
      }).catchError((error) {
        print('Error fetching packing list data: $error');
      });

      await FirebaseDatabase.instance
          .ref('users/${user.uid}/trips/${widget.tripId}/clothingList/AllClothes')
          .remove();
      await FirebaseDatabase.instance
          .ref('users/${user.uid}/trips/${widget.tripId}/clothingList/ChosenClothes')
          .remove();
      // await FirebaseDatabase.instance
      //     .ref('users/${user.uid}/trips/${widget.tripId}/clothingList/UnchosenClothes')
      //     .remove();

      final clothingListRef = FirebaseDatabase.instance
          .ref('users/${user.uid}/trips/${widget.tripId}/clothingList');

      

      clothes.forEach((itemName, quantity) {
        itemName = itemName.replaceAll('/', '_');
        clothingListRef.child("AllClothes/$itemName").set(quantity);
      });
      chosenItems.forEach((itemName, items) {
        itemName = itemName.replaceAll('/', '_');
        for (var item in items) {
          clothingListRef.child("ChosenClothes/$itemName").push().set(item);
        }
      });
      // unchosenItems.forEach((itemName, items) {
      //   itemName = itemName.replaceAll('/', '_');
      //   for (var item in items) {
      //     clothingListRef.child("UnchosenClothes/$itemName").push().set(item);
      //   }
      // });

    } else {
      print("User not logged in.");
    }
  }

  void _addNewCategory() async {
    final TextEditingController categoryController = TextEditingController();
    bool showDialogAgain = true;
    while (showDialogAgain) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add New Category'),
            content: TextField(
              controller: categoryController,
              decoration: const InputDecoration(hintText: 'Category Name'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  showDialogAgain = false;
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final String categoryName = categoryController.text.trim();
                  if (categoryName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Category name cannot be empty'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else if (categories.containsKey(categoryName)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Category already exists'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    setState(() {
                      categories[categoryName] = {};
                      checkedItems[categoryName] = {};
                    });
                    Navigator.of(context).pop();
                    showDialogAgain = false;
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    }
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
            });
          }
        }
        setState(() {
          myCloset = closetList;
        });
      }
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Packing List'),
        elevation: 4.0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == categories.length) {
            return ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add new category'),
              onTap: _addNewCategory,
            );
          } else if(index == 0){
            return _buildExpansionTileClothing();
          } else {
            String category = categories.keys.elementAt(index);
            return _buildExpansionTile(category);
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: BottomAppBar(
        child: InkWell(
          onTap: _saveList,
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.save),
                SizedBox(width: 8),
                Text('Save List'),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  
}
