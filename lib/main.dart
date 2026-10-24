
import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TapRushApp());
}

enum GameDifficulty { easy, medium, hard }

extension DifficultySettings on GameDifficulty {
  String get label {
    switch (this) {
      case GameDifficulty.easy:
        return 'Easy';
      case GameDifficulty.medium:
        return 'Medium';
      case GameDifficulty.hard:
        return 'Hard';
    }
  }

  int get duration {
    switch (this) {
      case GameDifficulty.easy:
        return 45;
      case GameDifficulty.medium:
        return 30;
      case GameDifficulty.hard:
        return 20;
    }
  }

  double get targetSize {
    switch (this) {
      case GameDifficulty.easy:
        return 85;
      case GameDifficulty.medium:
        return 65;
      case GameDifficulty.hard:
        return 45;
    }
  }

  Duration get movementInterval {
    switch (this) {
      case GameDifficulty.easy:
        return const Duration(seconds: 3);
      case GameDifficulty.medium:
        return const Duration(milliseconds: 1500);
      case GameDifficulty.hard:
        return const Duration(milliseconds: 800);
    }
  }
}

class TapRushApp extends StatelessWidget {
  const TapRushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tap Rush 2.0',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
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

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  final Random random = Random();
  final AudioPlayer audioPlayer = AudioPlayer();

  Timer? countdownTimer;
  Timer? movementTimer;

  GameDifficulty difficulty = GameDifficulty.easy;

  int score = 0;
  int bestScore = 0;
  int secondsLeft = 45;

  bool isPlaying = false;
  bool isPaused = false;
  bool hasPlayed = false;
  bool soundEnabled = true;
  bool vibrationEnabled = true;
  bool audioReady = false;

  double targetX = 0.5;
  double targetY = 0.5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadHighScore();
    initializeAudio();
  }

  // AUDIO INITIALIZATION

  Future<void> initializeAudio() async {
    try {
      await audioPlayer.setReleaseMode(ReleaseMode.stop);
      await audioPlayer.setVolume(1.0);

      // Preload the sound so the first tap has less delay.
      await audioPlayer.setSource(
        AssetSource('sounds/tap.wav'),
      );

      audioReady = true;
      debugPrint('Tap Rush audio initialized successfully');
    } catch (error) {
      audioReady = false;
      debugPrint('Audio initialization error: $error');
    }
  }

  // SOUND PLAYBACK

  Future<void> playTapSound() async {
    if (!soundEnabled) {
      debugPrint('Sound is disabled');
      return;
    }

    try {
      if (!audioReady) {
        await initializeAudio();
      }

      if (!audioReady) {
        debugPrint('Audio is not ready');
        return;
      }

      await audioPlayer.stop();

      await audioPlayer.play(
        AssetSource('sounds/tap.wav'),
        volume: 1.0,
      );

      debugPrint('Tap sound playback requested');
    } catch (error) {
      debugPrint('Audio playback error: $error');
    }
  }

  // HIGH SCORE STORAGE

  String get scoreKey => 'tap_rush_best_${difficulty.name}';

  Future<void> loadHighScore() async {
    final selectedDifficulty = difficulty;

    try {
      final prefs = await SharedPreferences.getInstance();

      final saved = prefs.getInt(
            'tap_rush_best_${selectedDifficulty.name}',
          ) ??
          0;

      if (!mounted || difficulty != selectedDifficulty) {
        return;
      }

      setState(() {
        bestScore = saved;
      });
    } catch (error) {
      debugPrint('High score loading error: $error');
    }
  }

  Future<void> saveHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final oldBest = prefs.getInt(scoreKey) ?? 0;

      if (score > oldBest) {
        await prefs.setInt(scoreKey, score);
      }
    } catch (error) {
      debugPrint('High score saving error: $error');
    }
  }

  // GAME LOGIC

  void moveTarget() {
    if (!isPlaying) return;

    setState(() {
      targetX = random.nextDouble();
      targetY = random.nextDouble();
    });
  }

  void changeDifficulty(GameDifficulty value) {
    if (isPlaying) return;

    setState(() {
      difficulty = value;
      secondsLeft = value.duration;
      bestScore = 0;
      hasPlayed = false;
    });

    loadHighScore();
  }

  void startGame() {
    countdownTimer?.cancel();
    movementTimer?.cancel();

    setState(() {
      score = 0;
      secondsLeft = difficulty.duration;
      isPlaying = true;
      isPaused = false;
      hasPlayed = true;
      targetX = random.nextDouble();
      targetY = random.nextDouble();
    });

    startTimers();
  }

  void startTimers() {
    countdownTimer?.cancel();
    movementTimer?.cancel();

    countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted || !isPlaying || isPaused) return;
        if (secondsLeft <= 1) {
          endGame();
        } else {
          setState(() => secondsLeft--);
        }
      },
    );

    movementTimer = Timer.periodic(
      difficulty.movementInterval,
      (timer) {
        if (mounted && isPlaying && !isPaused) moveTarget();
      },
    );
  }

  void pauseGame() {
    if (!isPlaying || isPaused) return;
    countdownTimer?.cancel();
    movementTimer?.cancel();
    setState(() => isPaused = true);
  }

  void resumeGame() {
    if (!isPlaying || !isPaused) return;
    setState(() => isPaused = false);
    startTimers();
  }

  Future<void> confirmRestartGame() async {
    if (!isPlaying) return;
    pauseGame();
    final restart = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restart game?'),
        content: const Text('Your current score and remaining time will reset.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('RESTART'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (restart == true) startGame();
    // Cancel leaves the game paused; press Resume when ready.
  }

  Future<void> confirmEndGame() async {
    if (!isPlaying) return;
    pauseGame();
    final end = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('End game?'),
        content: Text('Finish this round with a score of $score?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('END GAME'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (end == true) endGame();
    // Cancel leaves the game paused; press Resume when ready.
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && isPlaying && !isPaused) {
      pauseGame();
    }
  }

  void hitTarget() {
    if (!isPlaying || isPaused) return;

    setState(() {
      score++;

      if (score > bestScore) {
        bestScore = score;
      }

      targetX = random.nextDouble();
      targetY = random.nextDouble();
    });

    // Play sound whenever the target is tapped.
    playTapSound();

    if (vibrationEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  void endGame() {
    if (!isPlaying) return;
    countdownTimer?.cancel();
    movementTimer?.cancel();

    setState(() {
      secondsLeft = 0;
      isPlaying = false;
      isPaused = false;
    });

    saveHighScore();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    countdownTimer?.cancel();
    movementTimer?.cancel();
    audioPlayer.dispose();
    super.dispose();
  }

  // SCORE CARDS

  Widget statCard(
    String label,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 4,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF242447),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 5),
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
      ),
    );
  }

  // GAME MENU

  Widget buildMenu() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasPlayed
                  ? Icons.emoji_events
                  : Icons.sports_esports,
              size: 65,
              color: Colors.amberAccent,
            ),
            const SizedBox(height: 16),
            Text(
              hasPlayed
                  ? 'GAME OVER!'
                  : 'WELCOME TO TAP RUSH',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              hasPlayed
                  ? 'Final score: $score'
                  : 'Tap the glowing target to score!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),
            const Text('SELECT DIFFICULTY'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: GameDifficulty.values.map((level) {
                return ChoiceChip(
                  label: Text(level.label),
                  selected: difficulty == level,
                  onSelected: (_) {
                    changeDifficulty(level);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text(
              'Time: ${difficulty.duration}s '
              '| Target: ${difficulty.targetSize.toInt()}px',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: startGame,
              icon: const Icon(Icons.play_arrow),
              label: Text(
                hasPlayed ? 'PLAY AGAIN' : 'START GAME',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 16,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Sound test button
            OutlinedButton.icon(
              onPressed: playTapSound,
              icon: const Icon(Icons.volume_up),
              label: const Text('TEST SOUND'),
            ),

            const SizedBox(height: 12),

            // Test haptic feedback without starting a game.
            OutlinedButton.icon(
              onPressed: vibrationEnabled
                  ? () async {
                      await HapticFeedback.mediumImpact();
                      debugPrint('Vibration test requested');
                    }
                  : null,
              icon: const Icon(Icons.vibration),
              label: const Text('TEST VIBRATION'),
            ),
          ],
        ),
      ),
    );
  }

  // PLAY AREA

  Widget buildPlayArea(BoxConstraints constraints) {
    final targetSize = difficulty.targetSize;

    final maxX = max(
      0.0,
      constraints.maxWidth - targetSize,
    );

    final maxY = max(
      0.0,
      constraints.maxHeight - targetSize,
    );

    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          left: targetX * maxX,
          top: targetY * maxY,
          child: GestureDetector(
            onTap: hitTarget,
            child: Container(
              width: targetSize,
              height: targetSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Colors.pinkAccent,
                    Colors.deepPurpleAccent,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pinkAccent.withValues(
                      alpha: 0.55,
                    ),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.ads_click,
                color: Colors.white,
              ),
            ),
          ),
        ),
        if (isPaused)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.65),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pause_circle_filled,
                        size: 72, color: Colors.amberAccent),
                    SizedBox(height: 12),
                    Text('GAME PAUSED',
                        style: TextStyle(fontSize: 24,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Press RESUME to continue'),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // MAIN SCREEN

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101024),
      appBar: AppBar(
        title: const Text(
          'TAP RUSH 2.0',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Toggle sound',
            icon: Icon(
              soundEnabled
                  ? Icons.volume_up
                  : Icons.volume_off,
            ),
            onPressed: () {
              setState(() {
                soundEnabled = !soundEnabled;
              });
            },
          ),
          IconButton(
            tooltip: 'Toggle vibration',
            icon: Icon(
              vibrationEnabled
                  ? Icons.vibration
                  : Icons.mobile_off,
            ),
            onPressed: () {
              setState(() {
                vibrationEnabled = !vibrationEnabled;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  statCard(
                    'SCORE',
                    '$score',
                    Colors.cyanAccent,
                  ),
                  const SizedBox(width: 8),
                  statCard(
                    'TIME',
                    '${secondsLeft}s',
                    Colors.orangeAccent,
                  ),
                  const SizedBox(width: 8),
                  statCard(
                    'BEST',
                    '$bestScore',
                    Colors.greenAccent,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D1D3B),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.deepPurpleAccent,
                      width: 2,
                    ),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (!isPlaying) {
                        return buildMenu();
                      }

                      return buildPlayArea(constraints);
                    },
                  ),
                ),
              ),
              if (isPlaying) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: isPaused ? resumeGame : pauseGame,
                        icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                        label: Text(isPaused ? 'RESUME' : 'PAUSE'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: confirmRestartGame,
                        icon: const Icon(Icons.restart_alt),
                        label: const Text('RESTART'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: confirmEndGame,
                        icon: const Icon(Icons.stop_circle_outlined),
                        label: const Text('END'),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 14),
              Text(
                isPlaying
                    ? '${difficulty.label.toUpperCase()} MODE'
                    : 'READY FOR THE NEXT CHALLENGE?',
                style: const TextStyle(
                  color: Colors.white70,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
