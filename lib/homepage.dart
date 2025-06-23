import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
 
  final int rowCount = 38;
  final int columnCount = 20;
  late int totalCells;

  List <int> snakePosition = [45, 65, 85, 105, 125];
  int food = 300;
  String direction = 'down';
  Timer? timer;

  final randomNumber = Random();
  bool isPlaying = false;

  @override

  void initState() {
    super.initState();
    totalCells = rowCount * columnCount;
    generateFood();
  }

  void startGame() {
    isPlaying = true;
    const duration = Duration(milliseconds: 300);
    timer?.cancel();
    timer = Timer.periodic(duration, (Timer t) => updateSnake());
  }

  void generateFood(){
    food = randomNumber.nextInt(totalCells);
    while (snakePosition.contains(food)) {
      food = randomNumber.nextInt(totalCells);
    }
  }

  void updateSnake(){
    setState(() {
      int newHead;
      switch (direction) {
        case 'down':
          newHead = snakePosition.last + columnCount;
          if (newHead >= totalCells) {
            showGameOver();
            return;
          }
          break;
          case 'up':
          newHead = snakePosition.last - columnCount;
          if (newHead < 0) {
            showGameOver();
            return;
          }
          break;
          case 'left':
          newHead = snakePosition.last - 1;
          if(snakePosition.last % columnCount == 0) {
            showGameOver();
            return;
          }
          break;
          case 'right':
          newHead = snakePosition.last + 1;
          if(snakePosition.last % columnCount == columnCount - 1) {
            showGameOver();
            return;
          }
          break;
        default:
          return;
      }
      if (snakePosition.contains(newHead)) {
        showGameOver();
        return;
      }
      // update snake position
      if (newHead == food) {
        snakePosition.add(newHead);
        generateFood();
      } else {
        snakePosition.add(newHead);
        snakePosition.removeAt(0); 
        
      }
    });
  }

void showGameOver(){
  isPlaying = false;
  timer?.cancel();
  showDialog(
    context: context, 
    builder: (context) => AlertDialog(
      title: const Text('Game Over'),
      content: const Text('You hit the wall or yourself!'),
      actions: [
        TextButton(
          onPressed: (){
            Navigator.pop(context);
            resetGame();
          }, 
          child: const Text('Restart')),
      ],
    )
    );
}

void resetGame(){
  setState(() {
    snakePosition = [45, 65, 85, 105, 125];
    direction = 'down';
    generateFood();
    startGame();
  });
}

void changeDirection(String newDirection){
  if (direction == 'up' && newDirection == 'down' ||
      direction == 'down' && newDirection == 'up' ||
      direction == 'left' && newDirection == 'right' ||
      direction == 'right' && newDirection == 'left') {
    return; // Prevent reversing direction
  }
  direction = newDirection;
}

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onVerticalDragUpdate: (details){
                  if (direction != 'up' && details.delta.dy > 0) {
                    changeDirection('down');
                  } else if (direction != 'down' && details.delta.dy < 0) {
                    changeDirection('up');
                    
                  }
                },
                onHorizontalDragUpdate: (details){
                  if (direction != 'left' && details.delta.dx > 0) {
                    changeDirection('right');
                  } else if (direction != 'right' && details.delta.dx < 0) {
                    changeDirection('left');
                  }
                },
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: totalCells,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columnCount), 
                  itemBuilder: (context, index){
                    if (snakePosition.contains(index)) {
                      return Container(
                        margin: const EdgeInsets.all(1.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      );
                    } else if (index == food) {
                      return Container(
                        margin: const EdgeInsets.all(1.0),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      );
                    } else {
                      return Container(
                        margin: const EdgeInsets.all(1.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      );
                    }
                  }
                ),
              ),
            ),
            if(!isPlaying)
            Center(
              child: ElevatedButton(
                onPressed: (){
                  setState(() {
                    resetGame();
                    startGame();
                  });
                }, child: const Text('Start Game')),
            )
          ],
        )
        ),
    );
  }
}