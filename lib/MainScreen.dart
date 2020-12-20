import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:book/Book.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:book/DetailScreen.dart';

void main() => runApp(MainScreen());

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

List bookCoverList;

class _MainScreenState extends State<MainScreen> {
  double screenHeight, screenWidth;
  String titlecenter = "Loading Book...";

  @override
  void initState() {
    super.initState();
    _loadBook();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('List of Books'),
      ),
      body: Column(
        children: [
          bookCoverList == null
              ? Flexible(
                  child: Container(
                      child: Center(
                          child: Text(
                  titlecenter,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ))))
              : Flexible(
                  child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: (screenWidth / screenHeight) / 1.1,
                  children: List.generate(bookCoverList.length, (index) {
                    return Padding(
                        padding: EdgeInsets.all(1),
                        child: Card(
                          child: InkWell(
                            onTap: () => _loadBookDetail(index),
                            child: Column(
                              children: [
                                Container(
                                    height: screenHeight / 3.8,
                                    width: screenWidth / 1.2,
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          "http://slumberjer.com/bookdepo/bookcover/${bookCoverList[index]['cover']}.jpg",
                                      fit: BoxFit.contain,
                                      placeholder: (context, url) =>
                                          new CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          new Icon(
                                        Icons.broken_image,
                                        size: screenWidth / 3,
                                      ),
                                    )),
                                SizedBox(height: 5),
                                Text(
                                  bookCoverList[index]['booktitle'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '[' + bookCoverList[index]['author'] + ']',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'RM ' + bookCoverList[index]['price'],
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Rating: ' + bookCoverList[index]['rating'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ));
                  }),
                ))
        ],
      ),
    );
  }

  void _loadBook() {
    http.post("http://slumberjer.com/bookdepo/php/load_books.php",
        body: {}).then((res) {
      print(res.body);
      if (res.body == "nodata") {
        bookCoverList = null;
      } else {
        setState(() {
          var jsondata = json.decode(res.body);
          bookCoverList = jsondata["books"];
        });
      }
    }).catchError((err) {
      print(err);
    });
  }

  _loadBookDetail(int index) {
    print(bookCoverList[index]['booktitle']);
    Book bookDetails = new Book(
      bookid: bookCoverList[index]['bookid'],
      booktitle: bookCoverList[index]['booktitle'],
      bookauthor: bookCoverList[index]['author'],
      bookprice: bookCoverList[index]['price'],
      bookdesc: bookCoverList[index]['description'],
      bookrating: bookCoverList[index]['rating'],
      bookpublisher: bookCoverList[index]['publisher'],
      bookisbn: bookCoverList[index]['isbn'],
      bookcover: bookCoverList[index]['cover'],
    );

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                DetailScreen(book: bookDetails)));
  }
}
