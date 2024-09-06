import 'package:flutter/material.dart';
import 'package:idle_game/DatabaseHelper.dart';
import 'dart:async';
import 'dart:math'; // Per calcoli esponenziali

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int collectedStones = 0; // Pietre raccolte
  int stonesPerClick = 1; // Pietre raccolte per ogni click
  int autoClickers = 0; // Numero di autoclickers
  int materialsUnlocked = 0; // Materiali sbloccati

  int clickUpgradeLevel = 5; // Livello dell'upgrade per il click
  int autoClickerUpgradeLevel = 5; // Livello dell'upgrade per l'autoclicker
  int materialUpgradeLevel = 5; // Livello dell'upgrade per nuovi materiali

  Timer? autoClickerTimer; // Timer per l'auto-clicker
  final dbHelper = DatabaseHelper(); // Inizializza il database helper

  @override
  void initState() {
    super.initState();
    loadGameData(); // Carica i dati dal database
  }

  @override
  void dispose() {
    autoClickerTimer
        ?.cancel(); // Ferma il timer quando la schermata viene chiusa
    super.dispose();
  }

  // Funzione per caricare i dati dal database
  Future<void> loadGameData() async {
    Map<String, dynamic> data = await dbHelper.getGameData();
    if (data.isNotEmpty) {
      setState(() {
        collectedStones = data['collectedStones'] ?? 0;
        stonesPerClick = data['stonesPerClick'] ?? 1;
        autoClickers = data['autoClickers'] ?? 0;
        materialsUnlocked = data['materialsUnlocked'] ?? 0;
        clickUpgradeLevel = data['clickUpgradeLevel'] ?? 5;
        autoClickerUpgradeLevel = data['autoClickerUpgradeLevel'] ?? 5;
        materialUpgradeLevel = data['materialUpgradeLevel'] ?? 5;
      });
      startAutoClicker(); // Avvia l'auto-clicker con i dati caricati
    }
  }

  // Funzione per salvare i dati nel database
  Future<void> saveGameData() async {
    Map<String, dynamic> data = {
      'collectedStones': collectedStones,
      'stonesPerClick': stonesPerClick,
      'autoClickers': autoClickers,
      'materialsUnlocked': materialsUnlocked,
      'clickUpgradeLevel': clickUpgradeLevel,
      'autoClickerUpgradeLevel': autoClickerUpgradeLevel,
      'materialUpgradeLevel': materialUpgradeLevel,
    };
    await dbHelper.saveGameData(data); // Salva i dati nel database
  }

  // Funzione per avviare o fermare l'auto-clicker
  void startAutoClicker() {
    if (autoClickers > 0) {
      autoClickerTimer?.cancel(); // Cancella il timer precedente (se esiste)
      autoClickerTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          collectedStones +=
              autoClickers; // Aggiunge pietre in base al numero di auto-clickers
        });
        saveGameData(); // Salva automaticamente i dati ogni secondo
      });
    } else {
      autoClickerTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gioco'),
        automaticallyImplyLeading: false, // Rimuove la freccia "indietro"
      ),
      body: Column(
        children: <Widget>[
          // Parte superiore: La pietra da cliccare (1/3 dello schermo)
          Expanded(
            flex: 1, // Occupa 1/3 dello schermo
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Pietre raccolte: $collectedStones',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      collectedStones +=
                          stonesPerClick; // Incrementa con le pietre per click
                    });
                    saveGameData(); // Salva i dati quando viene cliccata la pietra
                  },
                  child: Image.asset(
                    'assets/stone.png', // Assicurati di avere l'immagine nel percorso assets
                    width: 100,
                    height: 100,
                  ),
                ),
                SizedBox(height: 20),
                Text('Clicca sulla pietra per raccoglierla'),
              ],
            ),
          ),

          Divider(
              thickness:
                  2), // Linea divisoria tra la parte superiore e inferiore

          // Parte inferiore: Gli upgrade (2/3 dello schermo)
          Expanded(
            flex: 2, // Occupa 2/3 dello schermo
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Upgrade',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  // Upgrade: Aumento delle pietre raccolte per click
                  ListTile(
                    title: Text('Aumento pietre per click'),
                    subtitle: Text('Raccogli più pietre per ogni click.'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        int cost = pow(2, clickUpgradeLevel)
                            .toInt(); // Costo dell'upgrade
                        if (collectedStones >= cost) {
                          setState(() {
                            collectedStones -= cost;
                            stonesPerClick += 1;
                            clickUpgradeLevel +=
                                1; // Incrementa il livello dell'upgrade
                          });
                          saveGameData(); // Salva i dati dopo l'acquisto dell'upgrade
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Non hai abbastanza pietre!')),
                          );
                        }
                      },
                      child:
                          Text('Compra (${pow(2, clickUpgradeLevel).toInt()})'),
                    ),
                  ),

                  // Upgrade: Aggiungi un auto-clicker
                  ListTile(
                    title: Text('Auto-clicker'),
                    subtitle: Text(
                        'Aggiunge un auto-clicker per raccogliere pietre automaticamente.'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        int cost = pow(3, autoClickerUpgradeLevel)
                            .toInt(); // Costo dell'auto-clicker
                        if (collectedStones >= cost) {
                          setState(() {
                            collectedStones -= cost;
                            autoClickers += 1;
                            autoClickerUpgradeLevel +=
                                1; // Incrementa il livello dell'upgrade
                            startAutoClicker(); // Riavvia l'auto-clicker con il nuovo numero
                          });
                          saveGameData(); // Salva i dati dopo l'acquisto dell'upgrade
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Non hai abbastanza pietre!')),
                          );
                        }
                      },
                      child: Text(
                          'Compra (${pow(3, autoClickerUpgradeLevel).toInt()})'),
                    ),
                  ),

                  // Upgrade: Sblocca nuovi materiali
                  ListTile(
                    title: Text('Nuovi materiali'),
                    subtitle: Text('Sblocca nuovi materiali da raccogliere.'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        int cost = pow(5, materialUpgradeLevel)
                            .toInt(); // Costo del nuovo materiale
                        if (collectedStones >= cost) {
                          setState(() {
                            collectedStones -= cost;
                            materialsUnlocked += 1;
                            materialUpgradeLevel +=
                                1; // Incrementa il livello dell'upgrade
                          });
                          saveGameData(); // Salva i dati dopo l'acquisto dell'upgrade
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Non hai abbastanza pietre!')),
                          );
                        }
                      },
                      child: Text(
                          'Sblocca (${pow(5, materialUpgradeLevel).toInt()})'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
