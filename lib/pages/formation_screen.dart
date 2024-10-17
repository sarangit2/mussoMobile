import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FormationsScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FormationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.pink),
          onPressed: () {},
        ),
        title: Text(
          'Formations',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Article'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Formations'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categories Section
            Text(
              'Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CategoryChip(label: 'Design'),
                CategoryChip(label: 'Design'),
                CategoryChip(label: '+'),
              ],
            ),
            SizedBox(height: 20),
            
            // Search Section
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                suffixIcon: Icon(Icons.tune),
                hintText: 'Recherche',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // Courses List
            Expanded(
              child: ListView(
                children: [
                  CourseCard(
                    title: 'Product Design v1.0',
                    instructor: 'Robertson Connie',
                    duration: '16 hours',
                    price: '',
                  ),
                  CourseCard(
                    title: 'Java Development',
                    instructor: 'Nguyen Shane',
                    duration: '16 hours',
                    price: '',
                  ),
                  CourseCard(
                    title: 'Visual Design',
                    instructor: 'Bert Pullman',
                    duration: '14 hours',
                    price: '',
                  ),
                  CourseCard(
                    title: 'Java Development',
                    instructor: 'Nguyen Shane',
                    duration: '16 hours',
                    price: '\$190',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;

  CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.pinkAccent,
      labelStyle: TextStyle(color: Colors.white),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}

class CourseCard extends StatelessWidget {
  final String title;
  final String instructor;
  final String duration;
  final String price;

  CourseCard({required this.title, required this.instructor, required this.duration, required this.price});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          color: Colors.grey[300], // Placeholder for image
        ),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(instructor),
            SizedBox(height: 4),
            Row(
              children: [
                if (price.isNotEmpty)
                  Text(
                    price,
                    style: TextStyle(
                      color: Colors.pink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                SizedBox(width: 8),
                Text(
                  duration,
                  style: TextStyle(
                    color: Colors.pinkAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
