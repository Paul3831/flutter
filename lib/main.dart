import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(
      MemoryGame()); // Point d'entrée de l'application, lance l'application MemoryGame.
}

// Classe principale de l'application, un widget StatelessWidget.
class MemoryGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Game', // Titre de l'application.
      theme: ThemeData(
        primarySwatch: Colors.blue, // Thème de l'application.
      ),
      home: DifficultySelectionScreen(), // Page d'accueil de l'application.
    );
  }
}

// Écran de sélection de la difficulté, un widget StatelessWidget.
class DifficultySelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memory Game'), // Titre de la barre d'applications.
        centerTitle: true, // Centre le titre dans la barre d'applications.
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Choisissez la difficulté :', // Texte de sélection de la difficulté.
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 40), // Espace vertical.
            ElevatedButton(
              onPressed: () {
                // Redirige vers l'écran du jeu en mode facile.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MemoryGameScreen(isHardMode: false),
                  ),
                );
              },
              child: Text(
                'Facile', // Bouton pour le mode facile.
                style: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(height: 20), // Espace vertical.
            ElevatedButton(
              onPressed: () {
                // Redirige vers l'écran du jeu en mode difficile.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MemoryGameScreen(isHardMode: true),
                  ),
                );
              },
              child: Text(
                'Difficile', // Bouton pour le mode difficile.
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Écran principal du jeu de mémoire, un widget StatefulWidget.
class MemoryGameScreen extends StatefulWidget {
  final bool isHardMode;

  MemoryGameScreen({required this.isHardMode});

  @override
  _MemoryGameScreenState createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  // Listes de cartes pour les modes facile et difficile.
  List<String> easyCards = ['🌼', '🍎', '🐶', '🚲', '🎈', '🌟', '🚀', '🍕'];
  List<String> hardCards = [
    '🎈',
    '🌟',
    '🚀',
    '🍕',
    '🦄',
    '🌸',
    '🍌',
    '🐱',
    '🌞',
    '🎁',
    '🌍',
    '🚲'
  ];

  List<String> cards = []; // Liste de toutes les cartes mélangées.
  List<String> visibleCards = []; // Liste des cartes visibles à l'écran.
  int previousIndex = -1; // Indice de la carte précédemment sélectionnée.
  int moves = 0; // Nombre de mouvements effectués.
  bool isGameOver = false; // Indique si le jeu est terminé.
  bool isTappingEnabled = true; // Indique si les taps sont activés.

  @override
  void initState() {
    super.initState();
    initializeGame(); // Initialise le jeu au démarrage.
  }

  void initializeGame() {
    setState(() {
      cards = widget.isHardMode
          ? [...hardCards, ...hardCards]
          : [...easyCards, ...easyCards];
      cards.shuffle(); // Mélange les cartes.
      visibleCards =
          List.filled(cards.length, ''); // Initialise les cartes visibles.
      previousIndex = -1; // Réinitialise l'indice précédent.
      moves = 0; // Réinitialise le nombre de mouvements.
      isGameOver = false; // Réinitialise l'état du jeu.
    });
  }

  void onCardTap(int index) {
    if (isTappingEnabled) {
      setState(() {
        if (visibleCards[index] == '' && previousIndex != index) {
          visibleCards[index] = cards[index];
          if (previousIndex != -1) {
            isTappingEnabled = false;
            if (cards[index] == cards[previousIndex]) {
              Future.delayed(Duration(milliseconds: 500), () {
                setState(() {
                  visibleCards[index] = '✓';
                  visibleCards[previousIndex] = '✓';
                  previousIndex = -1;
                  isTappingEnabled = true;
                  moves++;
                  if (visibleCards.every((card) => card == '✓')) {
                    isGameOver = true;
                  }
                });
                if (isGameOver) {
                  showCongratulationsDialog(
                      context); // Affiche un dialogue de félicitations.
                }
              });
            } else {
              Future.delayed(Duration(milliseconds: 500), () {
                setState(() {
                  visibleCards[index] = '';
                  visibleCards[previousIndex] = '';
                  previousIndex = -1;
                  isTappingEnabled = true;
                  moves++;
                });
              });
            }
          } else {
            previousIndex = index;
          }
        }
      });
    }
  }

  void showCongratulationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Félicitations !'), // Titre du dialogue de félicitations.
          content: Text(
              'Vous avez terminé en $moves mouvements.'), // Affiche le nombre de mouvements.
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.popUntil(
                  context,
                  ModalRoute.withName('/'),
                );
              },
              child: Text(
                  'Menu principal'), // Bouton pour revenir au menu principal.
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                initializeGame(); // Bouton pour rejouer.
              },
              child: Text('Rejouer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memory Game'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              initializeGame(); // Bouton pour réinitialiser le jeu.
            },
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, // Grille de cartes avec 4 colonnes.
        ),
        itemCount: visibleCards.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (!isGameOver) {
                onCardTap(index); // Gère le tap sur une carte.
              }
            },
            child: Container(
              margin: EdgeInsets.all(4),
              color: visibleCards[index] == ''
                  ? Colors.blue
                  : Colors.green, // Couleur de la carte.
              child: Center(
                child: visibleCards[index] == ''
                    ? null
                    : Text(
                        visibleCards[index],
                        style: TextStyle(fontSize: 24),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
