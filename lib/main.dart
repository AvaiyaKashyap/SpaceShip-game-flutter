import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Spaceship Defense Game'),
          centerTitle: true,
        ),
        body: SpaceshipDefenseGame(),
      ),
    );
  }
}

class SpaceshipDefenseGame extends StatefulWidget {
  @override
  State<SpaceshipDefenseGame> createState() => _SpaceshipDefenseGameState();
}

class _SpaceshipDefenseGameState extends State<SpaceshipDefenseGame> {
  double spaceshipX = 0.0;
  List<Rock> rocks = [];
  bool isGameOver = false;
  Timer? gameLoop;

  @override
  void initState() {
    super.initState();

    // Start adding rocks at regular intervals
  rocksAdditionTimer = Timer.periodic(Duration(seconds: 3), (Timer t) {
    if (!isGameOver) {
      addRock();
    }
  });

    // Start the game loop to update the game
    gameLoop = startGameLoop();
    
  }
  Timer? rocksAdditionTimer;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
     gameLoop?.cancel(); 
     rocksAdditionTimer?.cancel();
  }

  void addRock() {
    double randomX = Random().nextDouble() * (MediaQuery.of(context).size.width - 50);
    double speed = 2.0;
    rocks.add(Rock(x: randomX, y: 0, speed: speed));
  }

  Timer startGameLoop() {
    const int frameRate = 60; // The desired frame rate (frames per second)
    final Duration frameDuration = Duration(milliseconds: (1000 / frameRate).round());

    return Timer.periodic(frameDuration, (Timer timer) {
      if (!isGameOver) {
        updateGame();
      }
    });
  }

  void updateGame() {
    for (int i = 0; i < rocks.length; i++) {
      Rock rock = rocks[i];
      rock.y += rock.speed;

      double spaceshipLeft = spaceshipX;
      double spaceshipRight = spaceshipX + 100;
      double spaceshipTop = MediaQuery.of(context).size.height - 100;
      double spaceshipBottom = MediaQuery.of(context).size.height;

      double rockLeft = rock.x;
      double rockRight = rock.x + 50;
      double rockTop = rock.y;
      double rockBottom = rock.y + 50;

      if (!(rockLeft > spaceshipRight ||
          rockRight < spaceshipLeft ||
          rockTop > spaceshipBottom ||
          rockBottom < spaceshipTop)) {
        print("collision detected");
        gameOver();
      }

      if (rock.y > MediaQuery.of(context).size.height) {
        rocks.removeAt(i);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Background
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  'https://blenderartists.org/uploads/default/optimized/4X/7/e/2/7e2d7bea4ac21388c4a96e1371f375c4ce00094b_2_1024x576.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Display Rocks
        for (Rock rock in rocks)
          Positioned(
            left: rock.x,
            top: rock.y,
            child: Container(
              width: 50,
              height: 50,
              color: Colors.red,
            ),
          ),

        // Spaceship at the bottom
        Positioned(
          left: spaceshipX,
          bottom: 20,
          child: GestureDetector(
            onPanUpdate: (details) {
              double newSpaceshipX = spaceshipX + details.delta.dx;
              double screenWidth = MediaQuery.of(context).size.width;
              if (newSpaceshipX >= 0 && newSpaceshipX <= (screenWidth - 100)) {
                setState(() {
                  spaceshipX = newSpaceshipX;
                });
              }
            },
            child: Container(
              width: 100,
              height: 100,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  void gameOver() {
    isGameOver = true;
    gameLoop?.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text('You lost!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                restartGame();
                Navigator.of(context).pop();
              },
              child: Text('Restart'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Exit'),
            ),
          ],
        );
      },
    );
  }

  void restartGame() {
    isGameOver = false;
    gameLoop = startGameLoop();
    spaceshipX = 0.0;
    rocks.clear();
    Navigator.of(context).pop();
  }
}

class Rock {
  double x;
  double y;
  double speed;

  Rock({required this.x, required this.y, required this.speed});
}
