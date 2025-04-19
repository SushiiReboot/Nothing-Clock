import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
  int _originalTotalSeconds = 6 * 60 + 4; // Keep track of original total for progress calculation. Remove in the future.
  bool _isRunning = true; // Start with the timer running as in the image
  bool _isCompleted = false; // Track if timer has completed
  Timer? _timer;
  AudioPlayer? _audioPlayer; // Make nullable instead of late
  
  // Timer picker mode
  bool _isPickerMode = false;
  Duration _pickerDuration = const Duration(hours: 0, minutes: 6, seconds: 4);
  
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
      // If we're adjusting time, we need to update both total and remaining seconds
      int newTotalSeconds = max(0, _totalSeconds + secondsToAdjust);
      int newRemainingSeconds = _remainingSeconds + secondsToAdjust;
      
      // Check if the timer would go negative
      if (newRemainingSeconds <= 0 && !_isCompleted) {
        // Timer is hitting zero - trigger completion
        _totalSeconds = max(1, newTotalSeconds); // Ensure total is not zero to avoid division by zero
        _remainingSeconds = 0;
        _originalTotalSeconds = _totalSeconds;
        _onTimerComplete(); // This will handle starting the negative countdown
      } else {
        // Normal adjustment
        _totalSeconds = newTotalSeconds;
        _remainingSeconds = max(0, newRemainingSeconds);
        _originalTotalSeconds = _totalSeconds;
      }
    });
    
    if (wasRunning && _remainingSeconds > 0) {
      _startTimer();
    }
  }
  
  // Format seconds to HH:MM:SS
  String _formatTime(int seconds) {
    final isNegative = seconds < 0;
    final absSeconds = seconds.abs();
    
    final hours = absSeconds ~/ 3600;
    final minutes = (absSeconds % 3600) ~/ 60;
    final remainingSeconds = absSeconds % 60;
    
    if (hours > 0) {
      return '${isNegative ? "-" : ""}$hours:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      return '${isNegative ? "-" : ""}${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }
  
  // Update CustomPaint based on original total and current progress
  double get _progressRatio {
    // Return full progress when completed or if original total is zero/negative
    if (_isCompleted || _originalTotalSeconds <= 0) return 1.0;
    
    // Calculate elapsed seconds
    final elapsedSeconds = _originalTotalSeconds - _remainingSeconds;
    
    // Ensure we don't exceed 1.0 (100%) and handle negative cases
    return min(1.0, max(0.0, elapsedSeconds / max(1, _originalTotalSeconds)));
  }
  
  // Toggle between timer and picker mode
  void _togglePickerMode() {
    if (_isCompleted) {
      _snoozeTimer();
    }
    
    debugPrint("Toggling picker mode, current mode: $_isPickerMode");
    setState(() {
      _isPickerMode = !_isPickerMode;
      
      if (!_isPickerMode) {
        // User selected a time, update the timer
        _totalSeconds = _pickerDuration.inSeconds;
        _remainingSeconds = _totalSeconds;
        _originalTotalSeconds = _totalSeconds; // Reset progress calculation base
        
        // Reset the timer
        _progressController.reset();
        
        // If timer was running, restart with new duration
        if (_isRunning) {
          _pauseTimer();
          _startTimer();
        }
      } else {
        // User is entering picker mode, pause the timer
        if (_isRunning) {
          _pauseTimer();
        }
        
        // Update picker with current timer value
        _pickerDuration = Duration(seconds: _remainingSeconds);
      }
    });
  }

  // -----------------------------------------------------------------
  // Helpers to build custom three‑wheel timer picker with tight gaps
  Widget _buildPickerColumn({
    required List<String> values,
    required int initial,
    required ValueChanged<int> onSelected,
    required bool isInline,
  }) {
    return SizedBox(
      width: 46,          // narrower than CupertinoTimerPicker default
      height: isInline ? 150 : 200,
      child: CupertinoPicker(
        scrollController: FixedExtentScrollController(initialItem: initial),
        itemExtent: 32,
        magnification: 1.1,
        useMagnifier: false,
        onSelectedItemChanged: onSelected,
        children:
            values.map((v) => Center(child: Text(v))).toList(growable: false),
      ),
    );
  }

  Widget _buildCustomTimerPicker({required bool isInline}) {
    final h = _pickerDuration.inHours.remainder(24);
    final m = _pickerDuration.inMinutes.remainder(60);
    final s = _pickerDuration.inSeconds.remainder(60);

    final textStyle = TextStyle(
      color: isInline ? Colors.black : Colors.white,
      fontSize: isInline ? 18 : 22,
      fontWeight: isInline ? FontWeight.w400 : FontWeight.w600,
    );

    return CupertinoTheme(
      data: CupertinoThemeData(
        brightness: isInline ? Brightness.light : Brightness.dark,
        textTheme: CupertinoTextThemeData(pickerTextStyle: textStyle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hours
          _buildPickerColumn(
            values: List.generate(24, (i) => i.toString().padLeft(2, '0')),
            initial: h,
            isInline: isInline,
            onSelected: (index) {
              setState(() {
                _pickerDuration = Duration(
                  hours: index,
                  minutes: _pickerDuration.inMinutes.remainder(60),
                  seconds: _pickerDuration.inSeconds.remainder(60),
                );
              });
            },
          ),
          const SizedBox(width: 4),
          // Minutes
          _buildPickerColumn(
            values: List.generate(60, (i) => i.toString().padLeft(2, '0')),
            initial: m,
            isInline: isInline,
            onSelected: (index) {
              setState(() {
                _pickerDuration = Duration(
                  hours: _pickerDuration.inHours.remainder(24),
                  minutes: index,
                  seconds: _pickerDuration.inSeconds.remainder(60),
                );
              });
            },
          ),
          const SizedBox(width: 4),
          // Seconds
          _buildPickerColumn(
            values: List.generate(60, (i) => i.toString().padLeft(2, '0')),
            initial: s,
            isInline: isInline,
            onSelected: (index) {
              setState(() {
                _pickerDuration = Duration(
                  hours: _pickerDuration.inHours.remainder(24),
                  minutes: _pickerDuration.inMinutes.remainder(60),
                  seconds: index,
                );
              });
            },
          ),
        ],
      ),
    );
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
              child: _buildTimerDisplay(),
            ),
          ),
          // Timer controls
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // Main row of controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Left button: -1:00 or Cancel
                      _isPickerMode
                        ? ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isPickerMode = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF333333),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : ElevatedButton(
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
                      // Middle button: Play/Pause or Set
                      _isPickerMode
                        ? AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 65,
                            height: 65,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _totalSeconds = _pickerDuration.inSeconds;
                                  _remainingSeconds = _totalSeconds;
                                  _originalTotalSeconds = _totalSeconds; // Update original total for progress calculation
                                  _isPickerMode = false;
                                  
                                  // Reset the timer and progress
                                  _progressController.reset();
                                });
                              },
                              icon: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 30,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          )
                        : AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 65,
                            height: 65,
                            decoration: BoxDecoration(
                              color: _isCompleted ? Colors.blue : Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (_isCompleted ? Colors.blue : Colors.red).withOpacity(0.3),
                                  blurRadius: _isRunning ? 12 : 0,
                                  spreadRadius: _isRunning ? 2 : 0,
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: _isCompleted ? _snoozeTimer : _toggleTimer,
                              icon: Icon(
                                _isCompleted ? Icons.stop : (_isRunning ? Icons.pause : Icons.play_arrow),
                                color: Colors.white,
                                size: 30,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                      // Right button: +1:00 or Edit
                      _isPickerMode
                        ? const SizedBox(width: 90) // Placeholder for symmetry
                        : !_isCompleted
                          ? ElevatedButton(
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
                            )
                          : ElevatedButton(
                              onPressed: _snoozeTimer,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF333333),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              child: const Text(
                                "Snooze",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                    ],
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
  
  // Build the timer display widget
  Widget _buildTimerDisplay() {
    return AnimatedBuilder(
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
            // Then draw the white circle with time or picker
            AnimatedScale(
              scale: _isCompleted ? _completedPulseAnimation.value : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: 210,
                height: 210,
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
                child: _isPickerMode ? _buildInlineTimerPicker() : _buildTimeDisplay(),
              ),
            ),
            
          ],
        );
      },
    );
  }
  
  // Build the time display widget
  Widget _buildTimeDisplay() {
    return GestureDetector(
      onTap: () {
        debugPrint("Time display tapped");
        if (!_isCompleted) {
          _togglePickerMode();
        }
      },
      child: Center(
        child: Text(
          _formatTime(_remainingSeconds),
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w300,
            fontFamily: 'Roboto',
            color: _isCompleted ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
  
  // Build the inline timer picker that fits inside the circle (light theme)
  Widget _buildInlineTimerPicker() {
    return Center(
      child: SizedBox(
        width: 200,
        height: 180,
        child: _buildCustomTimerPicker(isInline: true),
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
    
    // Safety check to prevent numerical errors
    final safeProgress = min(1.0, max(0.0, progress));
    
    // Calculate the exact number of dots that should be filled (as a float)
    final exactFilledDots = safeProgress * dotCount;
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