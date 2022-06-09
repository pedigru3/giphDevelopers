import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String requestTrend =
      'https://api.giphy.com/v1/gifs/trending?api_key=LWadDhcLG3tR6cGEdhhJaimOx2CCO4Cp&limit=20&rating=g';

  String? search;
  int page = 0;
  final TextEditingController _searchController = TextEditingController();

  Future<Map> _getGifs() async {
    http.Response response;

    if (search == null) {
      response = await http.get(Uri.parse(requestTrend));
    } else {
      response = await http.get(Uri.parse(
          'https://api.giphy.com/v1/gifs/search?api_key=LWadDhcLG3tR6cGEdhhJaimOx2CCO4Cp&q=$search&limit=20&offset=$page&rating=g&lang=pt'));
    }
    return json.decode(response.body);
  }

  void _search() {
    search = _searchController.text;
  }

  @override
  void initState() {
    super.initState();
    _getGifs().then((map) => print(map));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            'https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif'),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    Text(
                      'Pesquisar',
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
                labelStyle: const TextStyle(color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            FutureBuilder(future: _getGifs(), builder: gifsGridBuilder),
          ],
        ),
      ),
    );
  }

  Widget gifsGridBuilder(context, snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
      case ConnectionState.waiting:
        return Container(
          width: 200,
          height: 200,
          alignment: Alignment.center,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 5.0,
          ),
        );
      default:
        if (snapshot.hasError) {
          return const Expanded(
            child: Center(
                child: Text(
              'Erro ao carregar dados',
              style: TextStyle(color: Colors.white),
            )),
          );
        } else {
          return Expanded(child: creatGifsTable(context, snapshot));
        }
    }
  }

  Widget creatGifsTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: EdgeInsets.only(top:16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: snapshot.data["data"].length,
      itemBuilder: (context, index) {
        return GestureDetector(
          child: Image.network(
            snapshot.data["data"][index]["images"]["fixed_height"]["url"],
            height: 300,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
