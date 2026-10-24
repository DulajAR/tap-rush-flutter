
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const TapRushApp());
}

class TapRushApp extends StatelessWidget {
  const TapRushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tap Rush',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Random random = Random();

  Timer? timer;
  int score = 0;
  int bestScore = 0;
  int secondsLeft = 30;

  bool isPlaying = false;
  bool hasPlayed = false;

  double targetX = 0.5;
  double targetY = 0.5;

  void moveTarget() {
    targetX = random.nextDouble();
    targetY = random.nextDouble();
  }

  void startGame() {
    timer?.cancel();

    setState(() {
      score = 0;
      secondsLeft = 30;
      isPlaying = true;
      hasPlayed = true;
      moveTarget();
    });

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) return;

        setState(() {
          secondsLeft--;

          if (secondsLeft <= 0) {
            isPlaying = false;
            timer.cancel();

            if (score > bestScore) {
              bestScore = score;
            }
          }
        });
      },
    );
  }

  void hitTarget() {
    if (!isPlaying) return;

    setState(() {
      score++;

      if (score > bestScore) {
        bestScore = score;
      }

      moveTarget();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101024),
      appBar: AppBar(
        title: const Text(
          'TAP RUSH',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: statCard(
                      'SCORE',
                      '$score',
                      Colors.cyanAccent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: statCard(
                      'TIME',
                      '${secondsLeft}s',
                      Colors.orangeAccent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: statCard(
                      'BEST',
                      '$bestScore',
                      Colors.greenAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D1D3B),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.deepPurpleAccent,
                      width: 2,
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (!isPlaying) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                hasPlayed
                                    ? Icons.emoji_events
                                    : Icons.touch_app,
                                size: 75,
                                color: Colors.amberAccent,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                hasPlayed
                                    ? 'GAME OVER!'
                                    : 'READY TO PLAY?',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                hasPlayed
                                    ? 'Your score: $score'
                                    : 'Tap the target as fast as you can!',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: startGame,
                                icon: const Icon(Icons.play_arrow),
                                label: Text(
                                  hasPlayed
                                      ? 'PLAY AGAIN'
                                      : 'START GAME',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.deepPurpleAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 28,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      const double targetSize = 70;

                      final maxX =
                          max(0.0, constraints.maxWidth - targetSize);
                      final maxY =
                          max(0.0, constraints.maxHeight - targetSize);

                      return Stack(
                        children: [
                          Positioned(
                            left: targetX * maxX,
                            top: targetY * maxY,
                            child: GestureDetector(
                              onTap: hitTarget,
                              child: Container(
                                width: targetSize,
                                height: targetSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.pinkAccent,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.pinkAccent
                                          .withValues(alpha: 0.5),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.ads_click,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Tap the glowing target before time runs out!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget statCard(
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF242447),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
