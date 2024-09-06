import 'dart:async';
import 'dart:io';
import 'package:flutter_img_cap/settingsUI.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

String baseUrl = "";

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String testOutput = '';
  File? imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isFetching = false;
  bool isMobile = false;
  bool isPc = false;

  @override
  void initState() {
    super.initState();
    _checkIp();
  }

  _checkIp() async {
    var box = await Hive.openBox('ipBox');
    if (box.get("ip") == "") {
      ip.text = '192.168.0.119';
      port.text = '5000';
    } else {
      ip.text = box.get("ip");
      port.text = box.get("port");
    }
    setState(() {});
  }

  Future<void> _uploadImage() async {
    setState(() {
      _isLoading = true;
      testOutput = '';
    });
    try {
      final uri = Uri.parse('$baseUrl/upload');
      var request = http.MultipartRequest('POST', uri);

      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          imageFile!.path,
        ));

        var response = await request.send();

        if (response.statusCode == 200) {
          print('Image uploaded successfully');
          final response = await http.get(
            Uri.parse('$baseUrl/caption'),
          );
          String output = response.body;
          setState(() {
            _isLoading = false;
          });
          setState(() {
            _isFetching = true;
          });
          for (var i = 0; i < output.length; i++) {
            if (_isFetching)
              await Future.delayed(
                Duration(milliseconds: 50),
                () {
                  setState(() {
                    testOutput += output[i];
                  });
                },
              );
          }
          setState(() {
            _isFetching = false;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image upload failed'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade800,
            content: Text(
              'Choose image to generate caption',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade800,
          content: Text(
            'Check the IP Address and port',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickImage({
    required ImageSource source,
    required bool isMobile,
  }) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
    if (isMobile) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    baseUrl = "http://${ip.text}:${port.text}";
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Image Captioning',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return SettingsUI();
                },
              )).then((value) {
                setState(() {});
              });
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return _laptopView();
          } else {
            return _mobileView();
          }
        },
      ),
    );
  }

  Widget _mobileView() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSize(
            duration: Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: imageFile != null
                ? _imagePreview(false)
                : _pickImageCard(context),
          ),
          AnimatedSize(
            duration: Duration(milliseconds: 200),
            child: _isLoading
                ? Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Generating Caption...'),
                        SizedBox(
                          height: 5,
                        ),
                        LinearProgressIndicator(),
                      ],
                    ),
                  )
                : Container(),
          ),
          Expanded(
            child: Card(
              color: const Color.fromARGB(255, 229, 243, 254),
              elevation: 0,
              child: Padding(
                padding: EdgeInsets.all(15),
                child: SizedBox(
                  width: double.infinity,
                  child: Visibility(
                    visible: testOutput.isNotEmpty,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Caption',
                                style: TextStyle(fontSize: 16),
                              ),
                              Visibility(
                                visible: _isFetching,
                                child: MaterialButton(
                                  onPressed: () {
                                    setState(() {
                                      _isFetching = false;
                                    });
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.stop),
                                      Text('Stop'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          testOutput,
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    replacement: Text(
                      'Upload an image to generate a caption',
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.blue.shade200,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: MaterialButton(
                onPressed: () {
                  _uploadImage();
                },
                elevation: 0,
                color: Colors.black,
                textColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                child: SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.text_fields_rounded),
                        SizedBox(width: 10),
                        Text('Generate Caption'),
                      ],
                    )),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _laptopView() {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: double.infinity,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey.shade100,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSize(
                    duration: Duration(milliseconds: 200),
                    alignment: Alignment.topCenter,
                    child: imageFile != null
                        ? _imagePreview(true)
                        // : _pickImageCard(context),
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // showModalBottomSheet(
                                  //   context: context,
                                  //   elevation: 0,
                                  //   backgroundColor: Colors.white,
                                  //   shape: RoundedRectangleBorder(
                                  //       borderRadius: BorderRadius.circular(0)),
                                  //   builder: (context) {
                                  //     return _selectImageModal();
                                  //   },
                                  // );
                                  _pickImage(
                                      source: ImageSource.gallery,
                                      isMobile: false);
                                },
                                child: CircleAvatar(
                                  radius: 40,
                                  child: Icon(Icons.image),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                'Please choose an image',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 30,
                                  color: Colors.grey.shade400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              children: [
                AnimatedSize(
                  duration: Duration(milliseconds: 200),
                  child: _isLoading
                      ? Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Generating Caption...'),
                              SizedBox(
                                height: 5,
                              ),
                              LinearProgressIndicator(),
                            ],
                          ),
                        )
                      : Container(),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 229, 243, 254),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Visibility(
                        visible: testOutput.isNotEmpty,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 50,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Caption',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Visibility(
                                    visible: _isFetching,
                                    child: MaterialButton(
                                      onPressed: () {
                                        setState(() {
                                          _isFetching = false;
                                        });
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.stop),
                                          Text('Stop'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              testOutput,
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        replacement: Text(
                          'Upload an image to generate a caption',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.blue.shade200,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: MaterialButton(
                      onPressed: () {
                        _uploadImage();
                      },
                      elevation: 0,
                      color: Colors.black,
                      textColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.text_fields_rounded),
                            SizedBox(width: 10),
                            Text('Generate Caption'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Padding _pickImageCard(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                elevation: 0,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0)),
                builder: (context) {
                  return _selectImageModal();
                },
              );
            },
            child: CircleAvatar(
              radius: 40,
              child: Icon(Icons.image),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'Please choose an image',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 30,
              color: Colors.grey.shade400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _imagePreview(bool isPc) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.file(
              imageFile!,
              height: !isPc ? 300 : 500,
              fit: BoxFit.contain,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                imageFile = null;
                testOutput = '';
                _isFetching = false;
                _isLoading = false;
              });
            },
            icon: CircleAvatar(
              child: Icon(
                Icons.close,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectImageModal() {
    return StatefulBuilder(
      builder: (context, setState) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(15),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select image from',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _pickImage(
                            source: ImageSource.camera,
                            isMobile: true,
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              child: Icon(Icons.camera_alt),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Camera')
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _pickImage(
                            source: ImageSource.gallery,
                            isMobile: true,
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.blue.shade100,
                              child: Icon(Icons.image),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Gallery')
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
