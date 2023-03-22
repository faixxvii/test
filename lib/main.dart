import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Send Image Example')),
        body: Center(child: SendImageButton()),
      ),
    );
  }
}

class SendImageButton extends StatefulWidget {
  @override
  _SendImageButtonState createState() => _SendImageButtonState();
}

class _SendImageButtonState extends State<SendImageButton> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _sendImage() async {
    // Select image from gallery
    final XFile? imageFile = await _picker.pickImage(source: ImageSource.gallery);
    if (imageFile == null) {
      return;
    }

    // Create a MultipartRequest with "POST" method
    final url = Uri.parse('http://localhost:5000/');
    final request = http.MultipartRequest('POST', url);

    // Attach the image file to the request using the "image" key
    final file = await http.MultipartFile.fromPath('image', imageFile.path);
    request.files.add(file);

    // Create a client and send the request
    final client = http.Client();
    try {
      final response = await client.send(request);
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);

      // Show the result
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Result'),
          content: Text(jsonResponse['result']),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _sendImage,
      child: const Text('Send Image'),
    );
  }
}