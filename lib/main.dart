import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'dart:io';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
    home:HomePage() ,
  ));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLodaing = false;
  File _image;
  List _outputs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isLodaing = true;
    loadModel().then((value){
      setState(() {
      _isLodaing = false;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detech Animals"),
    ),
    body: _isLodaing ?
    Container(
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    ) : Container(
      width: MediaQuery.of(context).size.width,
      child:  Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _image == null ? Container() : Image.file(_image),
          SizedBox(height: 20,),
          _outputs != null ? Text(
            "${_outputs[0]["label"]}",
            style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                background: Paint()..color = Colors.white,
              ),
          ) : Container()
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        chooseImage();
    },
    child: Icon(Icons.image),
    ),
    );
  }

// Lấy image từ máy.
  chooseImage() async{
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if(image == null) {
      return null;
    }
    setState(() {
      _isLodaing = true;
      _image = image;
    });
    runModelonImage(image);
  }
  
  //Đưa ảnh vào trong TFlite phân tích với model đã train.
  runModelonImage(File image) async {
    var output = await Tflite.runModelOnImage(
    path: image.path,
    numResults: 2,
    imageMean: 127.5,
    imageStd: 127.5,
    threshold: 0.5
    );
    setState(() {
      _isLodaing = false;
      _outputs = output;
    });
  }

// Data được load vào model của TF.
  loadModel() async{
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt");
  }

  @override
   void dispose() {
    // TODO: implement dispose
    Tflite.close();
    super.dispose();
  }
}