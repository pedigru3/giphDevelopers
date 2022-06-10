import 'package:flutter/material.dart';

class GifPage extends StatelessWidget {
  const GifPage(this._gifData, {Key? key}) : super(key: key);

  final Map _gifData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(_gifData['title']),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Image.network(_gifData["images"]["original"]["url"]),
      ),
    );
  }
}
