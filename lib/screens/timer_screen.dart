import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// Add for sound
import 'package:provider/provider.dart';
import 'package:nothing_clock/providers/timer_provider.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _completedPulseController; // New controller for completed state
  late Animation<double> _pulseAnimation;
  late Animation<double> _completedPulseAnimation; // New animation for completed state
  
  @override
  void initState() {
    super.initState();
    
    // Initialize progress animation controller - duration will be set in didChangeDependencies
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Placeholder, will be updated
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
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final timerProvider = Provider.of<TimerProvider>(context);
    
    // Update progress controller based on provider state
    _progressController.duration = Duration(seconds: timerProvider.remainingSeconds);
    
    // Set the progress controller to the correct value
    final elapsedFraction = timerProvider.remainingSeconds > 0 
        ? 1 - (timerProvider.remainingSeconds / timerProvider.totalSeconds) 
        : 1.0;
    
    _progressController.value = elapsedFraction;
    
    // Start or stop animations based on timer state
    if (timerProvider.isRunning && !timerProvider.isCompleted) {
      // Continue the animation from current position
      _progressController.animateTo(
        1.0,
        duration: Duration(seconds: timerProvider.remainingSeconds),
        curve: Curves.linear,
      );
    }
    
    // Handle completed state
    if (timerProvider.isCompleted) {
      _completedPulseController.repeat(reverse: true);
    } else {
      _completedPulseController.reset();
    }
  }
  
  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _completedPulseController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<TimerProvider>(
        builder: (context, timerProvider, child) {
          // Update the progress controller when remaining time changes
          final elapsedFraction = timerProvider.remainingSeconds > 0 
              ? 1 - (timerProvider.remainingSeconds / timerProvider.totalSeconds) 
              : 1.0;
              
          // Only restart the animation if something significant changed
          if (timerProvider.isRunning && !timerProvider.isCompleted &&
              (!_progressController.isAnimating || 
               _progressController.value != elapsedFraction)) {
            
            _progressController.duration = Duration(seconds: timerProvider.remainingSeconds);
            _progressController.value = elapsedFraction;
            
            if (timerProvider.remainingSeconds > 0) {
              _progressController.animateTo(
                1.0,
                duration: Duration(seconds: timerProvider.remainingSeconds),
                curve: Curves.linear,
              );
            }
          } else if (!timerProvider.isRunning && _progressController.isAnimating) {
            // Pause the animation if the timer is paused
            _progressController.stop();
          }
          
          // Handle completed state animations
          if (timerProvider.isCompleted && !_completedPulseController.isAnimating) {
            _completedPulseController.repeat(reverse: true);
          } else if (!timerProvider.isCompleted && _completedPulseController.isAnimating) {
            _completedPulseController.reset();
          }
          
          return Column(
            children: [
              const Spacer(flex: 1),
              // Main timer display
              Expanded(
                flex: 5,
                child: Center(
                  child: _buildTimerDisplay(timerProvider),
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
                          timerProvider.isPickerMode
                            ? ElevatedButton(
                                onPressed: () {
                                  timerProvider.togglePickerMode();
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
                                onPressed: timerProvider.isCompleted ? null : () => timerProvider.adjustTime(-60),
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
                          timerProvider.isPickerMode
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
                                    timerProvider.togglePickerMode();
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
                                  color: timerProvider.isCompleted ? Colors.blue : Colors.red,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (timerProvider.isCompleted ? Colors.blue : Colors.red).withOpacity(0.3),
                                      blurRadius: timerProvider.isRunning ? 12 : 0,
                                      spreadRadius: timerProvider.isRunning ? 2 : 0,
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  onPressed: () => timerProvider.toggleTimer(),
                                  icon: Icon(
                                    timerProvider.isCompleted ? Icons.stop : (timerProvider.isRunning ? Icons.pause : Icons.play_arrow),
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                          // Right button: +1:00 or Edit
                          timerProvider.isPickerMode
                            ? const SizedBox(width: 90) // Placeholder for symmetry
                            : !timerProvider.isCompleted
                              ? ElevatedButton(
                                  onPressed: () => timerProvider.adjustTime(60),
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
                                  onPressed: timerProvider.snoozeTimer,
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
          );
        },
      ),
    );
  }
  
  // Build the timer display widget
  Widget _buildTimerDisplay(TimerProvider timerProvider) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _progressController, 
        _pulseAnimation, 
        _completedPulseAnimation
      ]),
      builder: (context, child) {
        // Calculate progress ratio
        double progressRatio = _getProgressRatio(timerProvider);
        
        return Stack(
          alignment: Alignment.center,
          children: [
            // Draw circles first
            CustomPaint(
              size: const Size(320, 320), // Larger canvas for circles
              painter: TimerPainter(
                progress: progressRatio,
                baseColor: const Color.fromARGB(255, 232, 228, 228),
                progressColor: Colors.red,
                dotCount: 64,
                pulseAnimation: _pulseAnimation.value,
                isRunning: timerProvider.isRunning,
                dotRadius: 2.0,
              ),
            ),
            // Then draw the white circle with time or picker
            AnimatedScale(
              scale: timerProvider.isCompleted ? _completedPulseAnimation.value : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: 210,
                height: 210,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: timerProvider.isCompleted ? Colors.red.withOpacity(0.9) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: timerProvider.isCompleted 
                        ? Colors.red.withOpacity(0.5) 
                        : Colors.white.withOpacity(0.1),
                      blurRadius: timerProvider.isCompleted ? 16 : 8,
                      spreadRadius: timerProvider.isCompleted ? 4 : 2,
                    ),
                  ],
                ),
                child: timerProvider.isPickerMode ? _buildInlineTimerPicker(timerProvider) : _buildTimeDisplay(timerProvider),
              ),
            ),
          ],
        );
      },
    );
  }
  
  // Calculate progress ratio for the timer
  double _getProgressRatio(TimerProvider timerProvider) {
    // Return full progress when completed or if original total is zero/negative
    if (timerProvider.isCompleted || timerProvider.originalTotalSeconds <= 0) return 1.0;
    
    // Calculate elapsed seconds
    final elapsedSeconds = timerProvider.originalTotalSeconds - timerProvider.remainingSeconds;
    
    // Ensure we don't exceed 1.0 (100%) and handle negative cases
    return min(1.0, max(0.0, elapsedSeconds / max(1, timerProvider.originalTotalSeconds)));
  }
  
  // Build the time display widget
  Widget _buildTimeDisplay(TimerProvider timerProvider) {
    return GestureDetector(
      onTap: () {
        if (!timerProvider.isCompleted) {
          timerProvider.togglePickerMode();
        }
      },
      child: Center(
        child: Text(
          _formatTime(timerProvider.remainingSeconds),
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w300,
            fontFamily: 'Roboto',
            color: timerProvider.isCompleted ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
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
  
  // Build the inline timer picker that fits inside the circle (light theme)
  Widget _buildInlineTimerPicker(TimerProvider timerProvider) {
    return Center(
      child: SizedBox(
        width: 200,
        height: 180,
        child: _buildCustomTimerPicker(timerProvider, isInline: true),
      ),
    );
  }

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

  Widget _buildCustomTimerPicker(TimerProvider timerProvider, {required bool isInline}) {
    final h = timerProvider.pickerDuration.inHours.remainder(24);
    final m = timerProvider.pickerDuration.inMinutes.remainder(60);
    final s = timerProvider.pickerDuration.inSeconds.remainder(60);

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
              timerProvider.updatePickerDuration(Duration(
                hours: index,
                minutes: timerProvider.pickerDuration.inMinutes.remainder(60),
                seconds: timerProvider.pickerDuration.inSeconds.remainder(60),
              ));
            },
          ),
          const SizedBox(width: 4),
          // Minutes
          _buildPickerColumn(
            values: List.generate(60, (i) => i.toString().padLeft(2, '0')),
            initial: m,
            isInline: isInline,
            onSelected: (index) {
              timerProvider.updatePickerDuration(Duration(
                hours: timerProvider.pickerDuration.inHours.remainder(24),
                minutes: index,
                seconds: timerProvider.pickerDuration.inSeconds.remainder(60),
              ));
            },
          ),
          const SizedBox(width: 4),
          // Seconds
          _buildPickerColumn(
            values: List.generate(60, (i) => i.toString().padLeft(2, '0')),
            initial: s,
            isInline: isInline,
            onSelected: (index) {
              timerProvider.updatePickerDuration(Duration(
                hours: timerProvider.pickerDuration.inHours.remainder(24),
                minutes: timerProvider.pickerDuration.inMinutes.remainder(60),
                seconds: index,
              ));
            },
          ),
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