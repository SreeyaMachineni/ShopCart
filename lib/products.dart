import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;

Future<List<Photo>> fetchPhotos(http.Client client) async {
  final response = await client.get(Uri.parse(
      'https://run.mocky.io/v3/f2e5b25d-f121-4db3-9b42-b81bea641cac'));

  // Use the compute function to run parsePhotos in a separate isolate.
  return compute(parsePhotos, response.body);
}

// A function that converts a response body into a List<Photo>.
List<Photo> parsePhotos(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  // print(parsed);

  return parsed.map<Photo>((json) => Photo.fromJson(json)).toList();
}

class Photo {
  final String name;
  final int price;
  final String details;
  final double rating;
  final String model;

  const Photo({
    required this.name,
    required this.price,
    required this.details,
    required this.rating,
    required this.model,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      name: json['name'] as String,
      price: json['price'] as int,
      details: json['details'] as String,
      rating: json['rating'] as double,
      model: json['model'] as String,
    );
  }
}

class Products extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Products"),
      ),
      body: FutureBuilder<List<Photo>>(
        future: fetchPhotos(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return const Center(
              child: Text('An error has occurred!'),
            );
          } else if (snapshot.hasData) {
            return PhotosList(photos: snapshot.data!);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class PhotosList extends StatelessWidget {
  const PhotosList({Key? key, required this.photos}) : super(key: key);

  final List<Photo> photos;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: photos.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(photos[index].model),
            ),
            title: Text(photos[index].name),
            onTap: () {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => ProductDetail(photos[index])));
            },
          );
        });
  }
}

class ProductDetail extends StatelessWidget {
  final Photo photo;

  ProductDetail(this.photo);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Product details"),
        ),
        body: Card(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Center(
              child: Column(
                children: [
                  Image.network(photo.model),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      photo.name,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 25),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      photo.details,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 25),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'Price: ' + '₹' + photo.price.toString(),
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 25),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'Rating: ' + photo.rating.toString(),
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 25),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => Checkout(photo)));
                      },
                      child: Text('Checkout'))
                ],
              ),
            )));
  }
}

class Checkout extends StatefulWidget {
  final Photo photo;
  Checkout(this.photo);
  @override
  CheckoutState createState() {
    return CheckoutState(photo);
  }
}

class CheckoutState extends State<Checkout> {
  final Photo photo;
  String radioVal = '';

  CheckoutState(this.photo);
  void _handleRadioValueChange(int value) {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Checkout"),
      ),
      body: Center(
          child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(), hintText: 'Quantity'),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(), hintText: 'Shipping Address'),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(), hintText: 'Mobile'),
            ),
          ),
          Padding(
              padding: EdgeInsets.all(10),
              child: Text('Payment Type',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 25))),
          Row(
            children: [
              Radio(
                value: 'upi',
                groupValue: radioVal,
                onChanged: (val) {
                  setState(() => {radioVal = val.toString()});
                },
              ),
              Text('UPI')
            ],
          ),
          Row(
            children: [
              Radio(
                value: 'Netbanking',
                groupValue: radioVal,
                onChanged: (val) {
                  setState(() => {radioVal = val.toString()});
                },
              ),
              Text('Netbanking')
            ],
          ),
          Row(
            children: [
              Radio(
                value: 'Debit card',
                groupValue: radioVal,
                onChanged: (val) {
                  setState(() => {radioVal = val.toString()});
                },
              ),
              Text('Debit card')
            ],
          ),
          ElevatedButton(
              onPressed: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Dummy payment Success'),
                    ),
                  ),
              child: Text('Make Payment'))
        ],
      )),
    );
  }
}
