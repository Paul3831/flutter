import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(MemoryGame());
}

class MemoryGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DifficultySelectionScreen(),
    );
  }
}

class DifficultySelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memory Game'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Choisissez la difficulté :',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MemoryGameScreen(isHardMode: false),
                  ),
                );
              },
              child: Text(
                'Facile',
                style: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MemoryGameScreen(isHardMode: true),
                  ),
                );
              },
              child: Text(
                'Difficile',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MemoryGameScreen extends StatefulWidget {
  final bool isHardMode;

  MemoryGameScreen({required this.isHardMode});

  @override
  _MemoryGameScreenState createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
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
  List<String> cards = [];
  List<String> visibleCards = [];
  int previousIndex = -1;
  int moves = 0;
  bool isGameOver = false;
  bool isTappingEnabled = true;

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  void initializeGame() {
    setState(() {
      cards = widget.isHardMode
          ? [...hardCards, ...hardCards]
          : [...easyCards, ...easyCards];
      cards.shuffle();
      visibleCards = List.filled(cards.length, '');
      previousIndex = -1;
      moves = 0;
      isGameOver = false;
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
                  showCongratulationsDialog(context);
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
          title: Text('Félicitations !'),
          content: Text('Vous avez terminé en $moves mouvements.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.popUntil(
                  context,
                  ModalRoute.withName('/'),
                );
              },
              child: Text('Menu principal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                initializeGame();
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
              initializeGame();
            },
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
        ),
        itemCount: visibleCards.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (!isGameOver) {
                onCardTap(index);
              }
            },
            child: Container(
              margin: EdgeInsets.all(4),
              color: visibleCards[index] == '' ? Colors.blue : Colors.green,
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
