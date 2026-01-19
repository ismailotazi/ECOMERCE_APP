import 'package:ecomerce_app/item_details.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List Products = [
    {"iconename": Icons.laptop, "title": "Laptop"},
    {"iconename": Icons.phone_iphone, "title": "Phone"},
    {"iconename": Icons.watch, "title": "Watch"},
    {"iconename": Icons.headphones, "title": "Headphones"},
    {"iconename": Icons.print, "title": "Print"},
  ];
  final List Best = [
    {
      "image": "images/phone17.png",
      "title": "Iphone 17 Pro Max",
      "subtitle": "Original.High Quality",
      "price": "1000\$",
    },
    {
      "image": "images/watch.jpg",
      "title": "Apple Watch S9",
      "subtitle": "Original.High Quality",
      "price": "700\$",
    },
    {
      "image": "images/casque.jpg",
      "title": "Wireless Headphone",
      "subtitle": "Original.High Quality",
      "price": "200\$",
    },
    {
      "image": "images/pc.jpg",
      "title": "Macbook Pro",
      "subtitle": "Original.High Quality",
      "price": "700\$",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Container(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: "Search",
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      fillColor: Colors.grey[200],
                      filled: true,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Icon(Icons.menu, size: 40),
                ),
              ],
            ),
            Container(height: 30),
            Text(
              "Categories",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Container(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: Products.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          child: Icon(
                            Products[index]["iconename"],
                            size: 40,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          Products[index]["title"],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Best Selling",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            GridView.builder(
              itemCount: Best.length,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 230,
              ),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ItemDetails(data: Best[index]),
                      ),
                    );
                  },
                  child: Card(
                    child: Column(
                      children: [
                        Container(
                          color: Colors.grey[100],
                          child: Image.asset(
                            Best[index]["image"],
                            height: 130,
                            fit: BoxFit.contain,
                            width: 300,
                          ),
                        ),
                        Text(
                          Best[index]["title"],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          Best[index]["subtitle"],
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          Best[index]["price"],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
