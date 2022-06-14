import 'dart:convert';
import 'package:transparent_image/transparent_image.dart';

import 'package:flutter/material.dart';
import 'package:giphys/ui/gif_page.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String requestTrend =
      'https://api.giphy.com/v1/gifs/trending?api_key=LWadDhcLG3tR6cGEdhhJaimOx2CCO4Cp&limit=20&rating=g';

  String? search;
  int offset = 0;
  final TextEditingController _searchController = TextEditingController();

  _getCount(AsyncSnapshot snapshot) {
    if (search == null) {
      return snapshot.data["data"].length;
    } else {
      return snapshot.data["data"].length + 1;
    }
  }

  Future<Map> _getGifs() async {
    http.Response response;

    if (search == null) {
      response = await http.get(Uri.parse(requestTrend));
    } else {
      response = await http.get(Uri.parse(
          'https://api.giphy.com/v1/gifs/search?api_key=LWadDhcLG3tR6cGEdhhJaimOx2CCO4Cp&q=$search&limit=19&offset=$offset&rating=g&lang=pt'));
    }
    return json.decode(response.body);
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
              onSubmitted: (text) {
                setState(() {
                  search = text;
                  offset = 0;
                });
                _searchController.text = '';
              },
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
      padding: EdgeInsets.only(top: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: _getCount(snapshot),
      itemBuilder: (context, index) {
        if (search == null || index < snapshot.data["data"].length) {
          return GestureDetector(
              onLongPress: () {
                Share.share(
                    snapshot.data["data"][index]["images"]["original"]["url"]);
              },
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            GifPage(snapshot.data["data"][index])));
              },
              child: FadeInImage.memoryNetwork(placeholder: kTransparentImage, image:
              snapshot.data["data"][index]["images"]["fixed_height"]["url"],
                height: 300,
                fit: BoxFit.cover,
              )
        );
        } else {
        return Container(
        child: GestureDetector(
        onTap: () {
        setState(() {
        offset += 19;
        });
        },
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Icon(
        Icons.add,
        color: Colors.white,
        ),
        Text(
        'Carregar mais...',
        style: TextStyle(color: Colors.white),
        ),
        ],
        ),
        ),
        );
        }
      },
    );
  }
}
