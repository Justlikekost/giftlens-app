import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Home());
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File? image;
  List<String> gifts = [];
  bool loading = false;

  Future pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => image = File(picked.path));
    }
  }

  Future send() async {
    if (image == null) return;

    setState(() => loading = true);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://giftlens-backend.onrender.com'),
    );

    request.files.add(await http.MultipartFile.fromPath('image', image!.path));
    request.fields['budget'] = 'medium';

    var res = await request.send();
    var body = await http.Response.fromStream(res);

    final data = json.decode(body.body);

    setState(() {
      gifts = List<String>.from(data['gifts']);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("GiftLens")),
      body: Column(
        children: [
          ElevatedButton(onPressed: pickImage, child: const Text("Выбрать фото")),
          ElevatedButton(onPressed: send, child: const Text("Подобрать подарок")),
          if (loading) const CircularProgressIndicator(),
          Expanded(
            child: ListView(
              children: gifts.map((g) => ListTile(title: Text(g))).toList(),
            ),
          )
        ],
      ),
    );
  }
}
