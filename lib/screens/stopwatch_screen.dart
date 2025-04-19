import 'package:flutter/material.dart';
import 'package:nothing_clock/providers/stopwatch_provider.dart';
import 'package:nothing_clock/widgets/stopwatch_btn_controller.dart';
import 'package:provider/provider.dart';

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen>
    with TickerProviderStateMixin {
  late AnimationController _timerAnimationController;
  late Animation<double> _timerAnimation;

  // Keep track of the current lap count
  int _lastLapCount = 0;

  // Single animation controller for all lap movements
  late AnimationController _lapsAnimationController;
  late Animation<double> _lapsAnimation;

  // Scroll controller for lap times
  final ScrollController _scrollController = ScrollController();
  
  // Flag to track if a new lap was just added
  bool _newLapAdded = false;

  // Store lap item heights for smooth animation
  final double _defaultItemHeight = 50.0; // Estimated height of a lap item

  @override
  void initState() {
    super.initState();

    // Animation for showing and hiding the timer display
    _timerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _timerAnimation = CurvedAnimation(
      parent: _timerAnimationController,
      curve: Curves.easeInOut,
    );

    // Animation controller for lap movements
    _lapsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700), // Slightly longer for smoother movement
    );

    _lapsAnimation = CurvedAnimation(
      parent: _lapsAnimationController,
      curve: Curves.easeOutCubic,
    );
    // Rebuild on each frame of lap animation
    _lapsAnimation.addListener(() {
      setState(() {});
    });

    // Rebuild on scroll to update item scales and opacities
    _scrollController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timerAnimationController.dispose();
    _lapsAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final stopwatch = Provider.of<StopwatchProvider>(context);

    // Control the animation based on timer visibility
    if (stopwatch.showTimer &&
        !_timerAnimationController.isAnimating &&
        _timerAnimationController.status != AnimationStatus.completed) {
      _timerAnimationController.forward();
    } else if (!stopwatch.showTimer &&
        !_timerAnimationController.isAnimating &&
        _timerAnimationController.status != AnimationStatus.dismissed) {
      _timerAnimationController.reverse();
    }

    // Check if a new lap has been added
    if (stopwatch.laps.length > _lastLapCount) {
      // Start the animation for all laps to move
      if (_lapsAnimationController.status != AnimationStatus.forward) {
        _lapsAnimationController.forward(from: 0.0);
      }
      _newLapAdded = true;
      _lastLapCount = stopwatch.laps.length;
      
      // Reset emphasized item to top when new lap is added
      
      // Scroll to the top when a new lap is added (after animation completes)
      _lapsAnimationController.addStatusListener((status) {
        if (status == AnimationStatus.completed && _scrollController.hasClients) {
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
        if (status == AnimationStatus.completed) {
          setState(() {
            _newLapAdded = false;
          });
        }
      });
    } else if (stopwatch.laps.isEmpty) {
      _lastLapCount = 0;
      _newLapAdded = false;
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Timer display area with fixed height to prevent layout shifts
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 80,
                    alignment: Alignment.center,
                    child: AnimatedBuilder(
                      animation: _timerAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _timerAnimation.value,
                          child: child,
                        );
                      },
                      child: Text(
                        stopwatch.formattedTime,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                          fontWeight: FontWeight.w300,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ),
                  // Lap times display
                  AnimatedOpacity(
                    opacity: stopwatch.laps.isNotEmpty ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      height: stopwatch.laps.isNotEmpty ? 3 * _defaultItemHeight : 0,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: _buildScrollableLapsList(stopwatch),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 75.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Reset button
                  StopwatchBtnController(
                      isFilled: false,
                      filledColor: null,
                      borderColor: Colors.red,
                      iconColor: null,
                      icon: Icons.refresh,
                      onTap: stopwatch.elapsedMilliseconds > 0
                          ? () {
                              // Reset animations
                              _lapsAnimationController.reset();
                              _newLapAdded = false;

                              stopwatch.reset();
                            }
                          : null),
                  const SizedBox(
                    width: 40,
                  ),
                  // Start/Pause button
                  Transform.scale(
                    scale: 1.5,
                    child: StopwatchBtnController(
                        isFilled: true,
                        filledColor: theme.colorScheme.onSurface,
                        borderColor: theme.colorScheme.onSurface,
                        iconColor: theme.colorScheme.surface,
                        icon: stopwatch.isRunning
                            ? Icons.pause
                            : Icons.play_arrow,
                        onTap: stopwatch.isRunning
                            ? stopwatch.pause
                            : stopwatch.start),
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  // Save Lap button
                  StopwatchBtnController(
                      isFilled: false,
                      filledColor: null,
                      borderColor: theme.colorScheme.onSurface,
                      iconColor: null,
                      icon: Icons.add,
                      onTap: (stopwatch.isRunning ||
                              stopwatch.elapsedMilliseconds > 0)
                          ? () {
                              // Ensure we're not already animating
                              if (_lapsAnimationController.status != AnimationStatus.forward) {
                                stopwatch.addLap();
                                // Trigger rebuild without setting state - this avoids layout jumps
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  setState(() {});
                                });
                              }
                            }
                          : null),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableLapsList(StopwatchProvider stopwatch) {
    // Create a fixed-height scrollable list showing 3 items at a time
    return ListView.builder(
      controller: _scrollController,
      reverse: false,
    padding: EdgeInsets.symmetric(vertical: _defaultItemHeight),
      itemCount: stopwatch.laps.length,
      itemExtent: _defaultItemHeight,
      physics: const PageScrollPhysics(),
      itemBuilder: (context, index) => _buildLapItem(stopwatch, index),
    );
  }

  Widget _buildLapItem(StopwatchProvider stopwatch, int index) {
    // Map display index to lap data index so newest laps appear at the top
    final effectiveIndex = stopwatch.laps.length - 1 - index;

    // Calculate continuous scale and opacity based on distance from center
    final scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;
    final viewportHeight = _scrollController.hasClients
        ? _scrollController.position.viewportDimension
        : 3 * _defaultItemHeight;
    final viewportCenter = viewportHeight / 2;
    final itemCenterOffset = index * _defaultItemHeight + _defaultItemHeight / 2;
    final distanceFromCenter =
        (itemCenterOffset - scrollOffset - viewportCenter).abs();
    final maxDistance = 2 * _defaultItemHeight;
    final dist = distanceFromCenter.clamp(0.0, maxDistance);
    final fraction = dist / maxDistance;
    final scale = 1.0 - fraction * (1.0 - 0.7);
    final opacity = 1.0 - fraction * (1.0 - 0.2);

    // Animation for newly added items
    if (_newLapAdded && index == 0) {
      // Animate newly added item by rebuilding each frame
      return Opacity(
        opacity: opacity * _lapsAnimation.value,
        child: Transform.scale(
          scale: scale * _lapsAnimation.value,
          alignment: Alignment.center,
          child: _buildLapItemContent(stopwatch, effectiveIndex),
        ),
      );
    } else {
      return Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.center,
          child: _buildLapItemContent(stopwatch, effectiveIndex),
        ),
      );
    }
  }

  Widget _buildLapItemContent(StopwatchProvider stopwatch, int index) {
    // The actual content of each lap item
    return Container(
      height: _defaultItemHeight,
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.flag, color: Colors.white70, size: 16),
          const SizedBox(width: 8),
          Text(
            stopwatch.formatMilliseconds(stopwatch.laps[index]),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
