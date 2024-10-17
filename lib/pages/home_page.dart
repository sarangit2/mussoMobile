import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome to the Home Page!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Logout functionality or other actions can be added here
                Navigator.pushReplacementNamed(context, '/login');  // Retourner à la page de login
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
