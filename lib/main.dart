import 'package:flutter/material.dart';
import 'package:idle_game/GameScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Idle Stone Picker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/options': (context) => OptionsScreen(),
        '/game': (context) => GameScreen(),
      },
    );
  }
}

// Schermata iniziale con titolo e pulsanti
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Idle Stone Picker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Idle Stone Picker',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/game');
              },
              child: Text('Avvia il gioco'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/options');
              },
              child: Text('Opzioni'),
            ),
          ],
        ),
      ),
    );
  }
}

// Schermata delle opzioni
class OptionsScreen extends StatefulWidget {
  @override
  _OptionsScreenState createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  bool isVolumeOn = true;
  String selectedLanguage = 'Italiano';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Opzioni'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text('Volume'),
              value: isVolumeOn,
              onChanged: (value) {
                setState(() {
                  isVolumeOn = value;
                });
              },
            ),
            SizedBox(height: 20),
            Text('Lingua:', style: TextStyle(fontSize: 18)),
            DropdownButton<String>(
              value: selectedLanguage,
              onChanged: (String? newValue) {
                setState(() {
                  selectedLanguage = newValue!;
                });
              },
              items: <String>['Italiano', 'Inglese', 'Francese']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Logica per collegare l'account Google
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Collega l\'account Google')),
                );
              },
              child: Text('Collega account Google'),
            ),
          ],
        ),
      ),
    );
  }
}
