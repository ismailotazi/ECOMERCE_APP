import 'package:flutter/material.dart';

class ItemDetails extends StatefulWidget {
  final data;
  const ItemDetails({super.key, this.data});

  @override
  State<ItemDetails> createState() => _ItemDetailsState();
}

class _ItemDetailsState extends State<ItemDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(),
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey),
        // centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shop_outlined, color: Colors.black),
            Text("Milo", style: TextStyle(color: Colors.black)),
            Text("Store", style: TextStyle(color: Colors.deepPurpleAccent)),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey[700],
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 30),
            label: ".",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag, size: 30),
            label: ".",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined, size: 30),
            label: ".",
          ),
        ],
      ),
      body: ListView(
        children: [
          Image.asset(widget.data["image"]),
          Container(
            child: Text(
              widget.data["title"],
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 10),
          Container(
            child: Text(widget.data["subtitle"], textAlign: TextAlign.center),
          ),
          SizedBox(height: 10),
          Container(
            child: Text(
              widget.data["price"],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.deepOrange,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Color:"),
              SizedBox(width: 10),
              CircleAvatar(radius: 10),
              SizedBox(width: 10),
              Text("Grey"),
              SizedBox(width: 10),
              CircleAvatar(radius: 10),
              SizedBox(width: 10),
              Text("Black"),
            ],
          ),
          SizedBox(height: 10),
          //
          Container(
            child: Text(
              "Size:35  36  37  38  39  40  41  42  43  44",
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),

          Align(
            alignment: Alignment.center,
            child: MaterialButton(
              minWidth: 0,
              height: 35,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: Colors.black,
              onPressed: () {},
              child: Text("Add To Cart", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
