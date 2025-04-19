import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart'; // Add for sound

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with TickerProviderStateMixin {
  // Timer properties
  int _totalSeconds = 6 * 60 + 4; // Example: 6:04
  int _remainingSeconds = 6 * 60 + 4;
  final int _originalTotalSeconds = 6 * 60 + 4; // Keep track of original total for progress calculation. Remove in the future.
  bool _isRunning = true; // Start with the timer running as in the image
  bool _isCompleted = false; // Track if timer has completed
  Timer? _timer;
  AudioPlayer? _audioPlayer; // Make nullable instead of late
  
  // Animation controllers
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _completedPulseController; // New controller for completed state
  late Animation<double> _pulseAnimation;
  late Animation<double> _completedPulseAnimation; // New animation for completed state
  
  @override
  void initState() {
    super.initState();
    
    // Initialize audio player
    _audioPlayer = AudioPlayer();
    
    // Initialize progress animation controller
    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _totalSeconds),
    );
    
    // Initialize pulse animation for dot effects
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    // Initialize pulse animation for completed state (faster)
    _completedPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Animation for when timer completes - more dramatic pulsing
    _completedPulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _completedPulseController, curve: Curves.easeInOut),
    );
    
    // Add listener to update UI when animation progresses
    _progressController.addListener(() {
      setState(() {
        if (_isRunning) {
          _remainingSeconds = (_totalSeconds * (1 - _progressController.value)).round();
          
          // Check if timer has reached zero
          if (_remainingSeconds <= 0 && !_isCompleted) {
            _onTimerComplete();
          }
        }
      });
    });
    
    // Auto-start the timer to match the image
    _startTimer();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _pulseController.dispose();
    _completedPulseController.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }
  
  // Handle timer completion
  void _onTimerComplete() {
    setState(() {
      _isCompleted = true;
      _isRunning = true; // Keep timer running for negative count
    });
    
    // Start the alarm sound (with silent fallback if audio fails)
    _playAlarmSound();
    
    // Start the completion animation - visual indication will work regardless of sound
    _completedPulseController.repeat(reverse: true);
    
    // Start negative counting
    _startNegativeTimer();
    
    // Ensure visual feedback works even if audio fails
    _ensureVisualFeedback();
  }
  
  // Ensure visual feedback is prominent 
  void _ensureVisualFeedback() {
    // We already have the pulsating animation, but can add additional visual feedback here
    // This is a safeguard to ensure user is notified even if audio fails
  }
  
  // Play alarm sound
  void _playAlarmSound() async {
    try {
      // Try to play the sound
      if (_audioPlayer != null) {
        // First try with asset source
        try {
          await _audioPlayer!.play(AssetSource('sounds/alarm.mp3'));
          await _audioPlayer!.setReleaseMode(ReleaseMode.loop); // Loop the sound
        } catch (e) {
          debugPrint('First method failed, trying alternative: $e');
          
          // Second try: using a built-in sound
          // This uses a simple beep sound that's more likely to work
          final player = AudioPlayer();
          _audioPlayer = player;
          
          // On Android this will use the default system alarm sound
          await player.play(AssetSource('sounds/alarm.mp3'), volume: 1.0);
          await player.setReleaseMode(ReleaseMode.loop);
          
          // If all else fails, we'll still have the visual indication
        }
      }
    } catch (e) {
      debugPrint('Error playing alarm sound: $e');
      // Continue with just visual feedback
    }
  }
  
  // Fallback sound method when audio file isn't available
  void _fallbackSound() {
    // - SystemSound.play(SystemSoundType.alert) on iOS
    // - Vibration.vibrate() with a vibration package
    debugPrint('Using fallback alarm indicator (visual only)');
  }
  
  // Start negative timer counting
  void _startNegativeTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isCompleted && _isRunning) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }
  
  // Snooze the timer
  void _snoozeTimer() {
    debugPrint('Snooze button pressed');
    
    // Stop alarm
    try {
      _audioPlayer?.stop();
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }
    
    // Reset timer state
    setState(() {
      _isCompleted = false;
      _isRunning = false;
      _remainingSeconds = _totalSeconds;
    });
    
    // Stop completion animation
    _completedPulseController.stop();
    _completedPulseController.reset();
    
    // Reset progress controller
    _progressController.reset();
    
    // Cancel negative timer
    _timer?.cancel();
  }
  
  // Start or pause the timer
  void _toggleTimer() {
    if (_isCompleted) {
      _snoozeTimer(); // If completed, snooze on play/pause button press
      return;
    }
    
    if (_isRunning) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }
  
  // Start the timer
  void _startTimer() {
    setState(() {
      _isRunning = true;
    });
    
    // Calculate progress controller duration based on remaining time
    _progressController.duration = Duration(seconds: _remainingSeconds);
    
    // Set the controller to the correct starting position
    final elapsedFraction = 1 - (_remainingSeconds / _totalSeconds);
    _progressController.value = elapsedFraction;
    
    // Start the animation
    _progressController.animateTo(
      1.0,
      duration: Duration(seconds: _remainingSeconds),
      curve: Curves.linear,
    );
  }
  
  // Pause the timer
  void _pauseTimer() {
    setState(() {
      _isRunning = false;
    });
    _progressController.stop();
  }
  
  // Reset the timer
  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _remainingSeconds = _totalSeconds;
    });
    _progressController.reset();
  }
  
  // Add or subtract time
  void _adjustTime(int secondsToAdjust) {
    final wasRunning = _isRunning;
    
    if (wasRunning) {
      _pauseTimer();
    }
    
    setState(() {
      _totalSeconds = max(0, _totalSeconds + secondsToAdjust);
      _remainingSeconds = max(0, _remainingSeconds + secondsToAdjust);
      // Do not update _originalTotalSeconds so progress calculation remains consistent
    });
    
    if (wasRunning && _remainingSeconds > 0) {
      _startTimer();
    }
  }
  
  // Format seconds to MM:SS
  String _formatTime(int seconds) {
    final isNegative = seconds < 0;
    final absSeconds = seconds.abs();
    final minutes = absSeconds ~/ 60;
    final remainingSeconds = absSeconds % 60;
    return '${isNegative ? "-" : ""}$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  // Update CustomPaint based on original total and current progress
  double get _progressRatio {
    // Calculate progress based on original total time
    if (_isCompleted) return 1.0;
    
    // Calculate elapsed seconds
    final elapsedSeconds = _originalTotalSeconds - _remainingSeconds;
    // Ensure we don't exceed 1.0 (100%)
    return min(1.0, max(0.0, elapsedSeconds / _originalTotalSeconds));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          const Spacer(flex: 1),
          // Main timer display
          Expanded(
            flex: 5,
            child: Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _progressController, 
                  _pulseAnimation, 
                  _completedPulseAnimation
                ]),
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Draw circles first
                      CustomPaint(
                        size: const Size(320, 320), // Larger canvas for circles
                        painter: TimerPainter(
                          progress: _progressRatio,
                          baseColor: const Color.fromARGB(255, 232, 228, 228),
                          progressColor: Colors.red,
                          dotCount: 64,
                          pulseAnimation: _pulseAnimation.value,
                          isRunning: _isRunning,
                          dotRadius: 2.0,
                        ),
                      ),
                      // Then draw the white circle with time
                      AnimatedScale(
                        scale: _isCompleted ? _completedPulseAnimation.value : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: child!,
                      ),
                    ],
                  );
                },
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isCompleted ? Colors.red.withOpacity(0.9) : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: _isCompleted 
                          ? Colors.red.withOpacity(0.5) 
                          : Colors.white.withOpacity(0.1),
                        blurRadius: _isCompleted ? 16 : 8,
                        spreadRadius: _isCompleted ? 4 : 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _formatTime(_remainingSeconds),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        fontFamily: 'Roboto',
                        color: _isCompleted ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Timer controls
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // -1:00 button
                  ElevatedButton(
                    onPressed: _isCompleted ? null : () => _adjustTime(-60),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF333333),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text(
                      "- 1:00",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  // Play/Pause button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: _isRunning ? 12 : 0,
                          spreadRadius: _isRunning ? 2 : 0,
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _toggleTimer,
                      icon: Icon(
                        _isCompleted ? Icons.stop : (_isRunning ? Icons.pause : Icons.play_arrow),
                        color: Colors.white,
                        size: 30,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  // Snooze button (visible when timer completes)
                  if (_isCompleted)
                    AnimatedOpacity(
                      opacity: _isCompleted ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: GestureDetector(
                        onTap: () {
                          debugPrint("Snooze GestureDetector tapped");
                          _snoozeTimer();
                        },
                        child: Container(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            color: const Color(0xFF333333),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.2),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () {
                              debugPrint("Snooze IconButton pressed");
                              _snoozeTimer();
                            },
                            icon: const Icon(
                              Icons.snooze,
                              color: Colors.white,
                              size: 24,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    )
                  else
                    // +1:00 button (hidden when timer completes)
                    ElevatedButton(
                      onPressed: () => _adjustTime(60),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF333333),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: const Text(
                        "+ 1:00",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}

// Custom painter for the timer's circular progress
class TimerPainter extends CustomPainter {
  final double progress;
  final Color baseColor;
  final Color progressColor;
  final int dotCount;
  final double pulseAnimation;
  final double dotRadius;
  final bool isRunning;
  
  TimerPainter({
    required this.progress,
    required this.baseColor,
    required this.progressColor,
    required this.dotCount,
    required this.pulseAnimation,
    required this.isRunning,
    required this.dotRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 * 0.95;
    
    // Calculate the exact number of dots that should be filled (as a float)
    final exactFilledDots = progress * dotCount;
    // Round down to get the fully filled dots
    final completelyFilledDots = exactFilledDots.floor();
    // Calculate the transition dot's progress (0.0 to 1.0)
    final transitionProgress = exactFilledDots - completelyFilledDots;
    
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 3.0;
      
    // Draw dots around the circle
    for (int i = 0; i < dotCount; i++) {
      final angle = 2 * pi * (i / dotCount) - (pi / 2); // Start from top
      
      // Determine dot color
      if (i < completelyFilledDots) {
        // Dots that should be completely filled (red)
        paint.color = progressColor;
      } else if (i == completelyFilledDots) {
        // The transition dot - lerp from base to progress color
        paint.color = Color.lerp(baseColor, progressColor, transitionProgress) ?? baseColor;
      } else {
        // Dots that should remain unfilled (base color)
        paint.color = baseColor;
      }
      
      // Calculate dot size
      double dotRadiusFinal = dotRadius;
      
      // Apply pulsing animation only to the active transition dot when running
      if (i == completelyFilledDots && isRunning && transitionProgress > 0) {
        dotRadiusFinal *= pulseAnimation;
      }
      
      final dotCenter = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      
      // Draw dot
      canvas.drawCircle(dotCenter, dotRadiusFinal, paint);
    }
  }

  @override
  bool shouldRepaint(TimerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.baseColor != baseColor ||
           oldDelegate.progressColor != progressColor ||
           oldDelegate.pulseAnimation != pulseAnimation ||
           oldDelegate.isRunning != isRunning;
  }
} 