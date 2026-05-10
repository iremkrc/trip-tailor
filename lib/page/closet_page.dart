import 'dart:io';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:project/controllers/model_controller.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:project/constants/api_constants.dart';
import 'package:project/constants/color.dart';
import 'package:project/page/outfit_page.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:project/services/color_service.dart';

class ClosetPage extends StatefulWidget {
  const ClosetPage({super.key});

  @override
  _ClosetPageState createState() => _ClosetPageState();
}

class _ClosetPageState extends State<ClosetPage> {
  final picker = ImagePicker();

  String? _clothingType;
  String? _imageUrl;
  String? _imageName;
  int? _color;
  String? _colorBin;
  bool _isProcessed = true;

  final _database = FirebaseDatabase.instance.ref();
  final _auth = FirebaseAuth.instance;

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
  final boolTypes = ['Yes', 'No'];

  getClothingTypes() {
    return clothingTypes;
  }

  List<Map<String, dynamic>> myCloset = [];

  List<Map<String, dynamic>> get getCloset {
    return myCloset;
  }

  @override
  void initState() {
    super.initState();
    _fetchCloset();
  }

  Future<void> _addClothing() async {
    final user = _auth.currentUser;
    if (user != null) {
      final clothingData = {
        'userID': user.uid,
        'imageUrl': _imageUrl,
        'type': _clothingType,
        'imageName': _imageName,
        'color':_color,
        'colorBin':_colorBin
      };
      final newClothingRef = _database.child('closet').push();
      final clothingId = newClothingRef.key;
      if (clothingId != null) {
        await newClothingRef.set(clothingData);
        await _database
            .child('users/${user.uid}/closet/$clothingId')
            .set(clothingData);
        setState(() {
          myCloset.add({
            'clothingId': clothingId,
            'imageUrl': _imageUrl,
            'type': _clothingType,
            'imageName': _imageName,
            'color':_color,
            'colorBin':_colorBin
          });
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Clothing successfully added'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to generate a unique clothing identifier'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
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

  Future uploadImagetoFirebaseStorage(String path, XFile image) async {
    String imageName = DateTime.now().millisecondsSinceEpoch.toString();
    final storageRef = FirebaseStorage.instance.ref(path).child(imageName);
    UploadTask uploadTask;
    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      final blob = html.Blob([bytes]);
      uploadTask = storageRef.putBlob(blob);
    } else {
      final file = File(image.path);
      uploadTask = storageRef.putFile(file);
    }
    await uploadTask.whenComplete(() => null);
    final url = await storageRef.getDownloadURL();
    setState(() {
      _imageName = imageName;
    });
    return url;
  }

  Future getImageFromGalleryOrCamera(String source) async {
    final imageSource =
        source == 'gallery' ? ImageSource.gallery : ImageSource.camera;
    setState(() {
          _isProcessed = false;
        });
    final pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      XFile? processedImage = await removeBackground(pickedFile);
      //XFile? processedImage = pickedFile;
      final imageUrl =
          await uploadImagetoFirebaseStorage('closet_images', processedImage);
      String? predictionCheck = "No";
      var prediction = "";
      final bytes = await processedImage.readAsBytes();
      PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(Image.memory(bytes).image);
      Color dominantColor = paletteGenerator.dominantColor!.color;
      String colorBin = ColorService.sortColor(dominantColor);
      if(!kIsWeb){
        prediction = await ModelController.runModelWithImage(processedImage);
        setState(() {
          _isProcessed = true;
        });
        predictionCheck = await checkPrediction(prediction, imageUrl);
      }else{
        setState(() {
          _isProcessed = true;
        });
      }


      dynamic clothingType;
      if (predictionCheck == "Yes") {
        clothingType = prediction;
      } else {
        clothingType = await selectType(imageUrl);
      }

      if (imageUrl != null && clothingType != null) {
        setState(() {
          _imageUrl = imageUrl;
          _clothingType = clothingType;
          _color = dominantColor.value;
          _colorBin = colorBin;
        });
        _addClothing();
      }
    }
  }

  Future<void> deleteClothing(Map<String, dynamic> clothing) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseDatabase.instance
          .ref('closet/${clothing['clothingId']}')
          .remove();
      await FirebaseDatabase.instance
          .ref('users/${user.uid}/closet/${clothing['clothingId']}')
          .remove();
      await FirebaseStorage.instance
          .ref()
          .child('closet_images/${clothing['imageName']}')
          .delete();
    }
  }

  Future<XFile> removeBackground(XFile image) async {
    final apiKey = removeBgApiKey;
    final uri = Uri.parse('https://api.remove.bg/v1.0/removebg');
    if (kIsWeb) {
      //web
      Uint8List imageBytes = await image.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      final response = await http.post(
        uri,
        headers: {
          'X-Api-Key': apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'image_file_b64': base64Image,
          'size': 'auto',
        }),
      );

      if (response.statusCode == 200) {
        String contentType = response.headers['content-type'] ?? '';
        Uint8List bytes;
        if (contentType.contains('application/json')) {
          bytes = base64Decode(jsonDecode(response.body)['data']['result_b64']);
        } else if (contentType.contains('image')) {
          bytes = response.bodyBytes;
        } else {
          return image;
        }
        final blob = html.Blob([bytes]);
        final processedFile = XFile(html.Url.createObjectUrlFromBlob(blob));
        return processedFile;
      } else {
        return image;
      }
    } else {
      //web and android
      final request = http.MultipartRequest('POST', uri)
        ..fields['size'] = 'auto'
        ..files.add(await http.MultipartFile.fromPath('image_file', image.path))
        ..headers['X-Api-Key'] = apiKey;

      try {
        final response = await request.send();
        if (response.statusCode == 200) {
          final bytes = await response.stream.toBytes();
          final tempDir = await getTemporaryDirectory();
          final filePath =
              '${tempDir.path}/processed_${DateTime.now().millisecondsSinceEpoch}.png';
          final file = File(filePath);
          await file.writeAsBytes(bytes);
          return XFile(file.path);
        } else {
          final responseBody = await response.stream.bytesToString();
          return image;
        }
      } catch (e) {
        return image;
      }
    }
  }

  Future _showOptions() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
              child: const Text('Photo Gallery'),
              onPressed: () {
                // close the options modal
                Navigator.of(context).pop();
                // get image from gallery
                getImageFromGalleryOrCamera('gallery');
              }),
          CupertinoActionSheetAction(
            child: const Text('Camera'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from camera
              getImageFromGalleryOrCamera('camera');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // display clothing by type
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Closet'),
        backgroundColor: Colors.white70,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: OutlinedButton(
                onPressed: _suggestOutfit,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.deepPurple,
                  side: const BorderSide(
                    color: Colors.deepPurple,
                  ),
                ),
                child: const Text("Get Today's Outfit"),
              ),
            ),
          ),
          if (myCloset.isEmpty || !_isProcessed)
            const Center(
              child: CircularProgressIndicator(),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: clothingTypes.length,
                itemBuilder: (context, index) {
                  // Filter items for the current clothing type
                  List<Map<String, dynamic>> filteredItems = myCloset
                      .where((item) => item['type'] == clothingTypes[index])
                      .toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          clothingTypes[index],
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
                        itemCount: filteredItems.length,
                        itemBuilder: (context, itemIndex) {
                          return displayClothing(filteredItems[itemIndex]);
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showOptions,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white70),
      ),
      // suggest outfit button
    );
  }

  // display clothing by type
  // Widget displayClothingByType(String type) {
  //   return GridView.builder(
  //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //       crossAxisCount: 3,
  //       crossAxisSpacing: 4.0,
  //       mainAxisSpacing: 4.0,
  //     ),
  //     itemCount: myCloset.length,
  //     itemBuilder: (context, index) {
  //       if (myCloset[index]['type'] == type) {
  //         displayClothing(myCloset[index]);
  //       }
  //       return null;
  //     },
  //   );
  // }

  displayClothing(Map<String, dynamic> clothing) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.network(clothing['imageUrl'], fit: BoxFit.cover),
        ),
        Positioned(
          right: 5,
          top: 5,
          child: GestureDetector(
            onTap: () {
              setState(() {
                myCloset.remove(clothing);
                deleteClothing(clothing);
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

  Future<String?> checkPrediction(String pred, String imageUrl) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Is "$pred" the correct prediction?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              [Image.network(imageUrl, height: 150)],
              boolTypes.map((type) {
                return ListTile(
                  title: Text(type),
                  onTap: () {
                    Navigator.pop(context, type);
                  },
                );
              }).toList()
            ].expand((x) => x).toList(),
          ),
        );
      },
    );
  }

  Future<String?> selectType(String imageUrl) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Clothing Type'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              [Image.network(imageUrl, height: 150)],
              clothingTypes.map((type) {
                return ListTile(
                  title: Text(type),
                  onTap: () {
                    Navigator.pop(context, type);
                  },
                );
              }).toList()
            ].expand((x) => x).toList(),
          ),
        );
      },
    );
  }

  void _suggestOutfit() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OutfitPage()),
    );
  }
}
