import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TrackpadSection extends StatefulWidget {
  final bool trackpadActive;
  final void Function(DragStartDetails) onPanStart;
  final void Function(DragUpdateDetails) onPanUpdate;
  final void Function(DragEndDetails) onPanEnd;
  final void Function(double dx, double dy) onScroll;
  final VoidCallback onLeftClick;
  final VoidCallback onRightClick;
  final VoidCallback onLeftMouseDown;
  final VoidCallback onLeftMouseUp;

  const TrackpadSection({
    super.key,
    required this.trackpadActive,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.onScroll,
    required this.onLeftClick,
    required this.onRightClick,
    required this.onLeftMouseDown,
    required this.onLeftMouseUp,
  });

  @override
  State<TrackpadSection> createState() => _TrackpadSectionState();
}

class _TrackpadSectionState extends State<TrackpadSection> {
  DateTime? _lastTapTime;
  int _lastTapPointers = 0;
  bool _isDragging = false;
  int _currentPointers = 0;
  int _maxPointers = 0;
  Offset? _initialPosition;
  bool _hasMoved = false;
  bool _panStarted = false; // Track if we've sent onPanStart
  static const double _movementThreshold = 20.0; // Threshold for single-finger pan
  static const double _scrollThreshold = 15.0; // Threshold for 2-finger scroll
  double _totalScrollDistance = 0.0; // Track cumulative scroll distance
  double _totalPanDistance = 0.0; // Track cumulative pan distance for single finger

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        setState(() {
          _currentPointers++;
          // Track the maximum number of pointers in this gesture
          if (_currentPointers > _maxPointers) {
            _maxPointers = _currentPointers;
          }
          
          
          if (_currentPointers == 1) {
            _initialPosition = event.position;
            _hasMoved = false;
            _totalPanDistance = 0.0; // Reset pan distance for new single-finger gesture
            
            // Check for double-tap (only for single finger)
            final now = DateTime.now();
            if (_lastTapTime != null && 
                _lastTapPointers == 1 &&
                now.difference(_lastTapTime!) < const Duration(milliseconds: 300)) {
              print('DOUBLE TAP DETECTED - Starting drag');
              _isDragging = true;
              print('Calling onLeftMouseDown()');
              widget.onLeftMouseDown();
              print('onLeftMouseDown() called');
            } else {
              print('Single tap down - lastTap: $_lastTapPointers, timeDiff: ${_lastTapTime != null ? now.difference(_lastTapTime!).inMilliseconds : "null"}ms');
            }
          } else if (_currentPointers == 2) {
            // Second finger down - this cancels any drag mode and resets for 2-finger tap
            if (_isDragging) {
              widget.onLeftMouseUp(); // End the drag
              _isDragging = false;
            }
            _hasMoved = false;
            _totalScrollDistance = 0.0; // Reset scroll distance for new 2-finger gesture
          }
        });
      },
      onPointerMove: (event) {
        // Only track movement for single-finger gestures (not for 2-finger taps)
        // Don't check for movement if we're already dragging
        if (_currentPointers == 1 && !_isDragging && _initialPosition != null && !_hasMoved) {
          final distance = (event.position - _initialPosition!).distance;
          if (distance > _movementThreshold) {
            _hasMoved = true;
          }
        }
      },
      onPointerUp: (event) {
        setState(() {
          _currentPointers--;
          
          if (_currentPointers == 0) {
            // All fingers lifted
            if (_isDragging) {
              widget.onLeftMouseUp();
              _isDragging = false;
            } else if (!_hasMoved && _initialPosition != null) {
              // It was a tap - use maxPointers to know how many fingers
              if (_maxPointers == 1) {
                widget.onLeftClick();
              } else if (_maxPointers == 2) {
                widget.onRightClick();
              }
            }
            
            _lastTapTime = DateTime.now();
            _lastTapPointers = _maxPointers; // Remember how many fingers were used
            _maxPointers = 0; // Reset for next gesture
            _initialPosition = null;
            _hasMoved = false; // Reset movement flag
            _panStarted = false; // Reset pan started flag
            _totalScrollDistance = 0.0; // Reset scroll distance
            _totalPanDistance = 0.0; // Reset pan distance
          }
        });
      },
      child: RawGestureDetector(
        gestures: {
          ScaleGestureRecognizer: GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
            () => ScaleGestureRecognizer(),
            (ScaleGestureRecognizer instance) {
              instance
                ..onStart = (details) {
                  // Don't call onPanStart immediately - wait until threshold is exceeded
                  // Exception: always start pan when dragging
                  if (_isDragging) {
                    _panStarted = true;
                    final d = DragStartDetails(
                      globalPosition: details.focalPoint,
                      localPosition: details.localFocalPoint,
                    );
                    widget.onPanStart(d);
                  }
                }
                ..onUpdate = (details) {
                  if (details.pointerCount == 2 && !_isDragging) {
                    // Track cumulative scroll distance
                    final scrollDelta = details.focalPointDelta.distance;
                    setState(() {
                      _totalScrollDistance += scrollDelta;
                      // Only mark as moved if scroll distance exceeds threshold
                      if (_totalScrollDistance > _scrollThreshold) {
                        _hasMoved = true;
                      }
                    });
                    // Only send scroll if we've exceeded the threshold (not a tap)
                    if (_hasMoved) {
                      widget.onScroll(details.focalPointDelta.dx, details.focalPointDelta.dy);
                    }
                  } else if (details.pointerCount == 1 || _isDragging) {
                    // Track cumulative pan distance for single finger (unless dragging)
                    if (!_isDragging) {
                      final panDelta = details.focalPointDelta.distance;
                      setState(() {
                        _totalPanDistance += panDelta;
                        // Only mark as moved if pan distance exceeds threshold
                        if (_totalPanDistance > _movementThreshold) {
                          _hasMoved = true;
                          // Call onPanStart the first time threshold is exceeded
                          if (!_panStarted) {
                            _panStarted = true;
                            final startDetails = DragStartDetails(
                              globalPosition: details.focalPoint,
                              localPosition: details.localFocalPoint,
                            );
                            widget.onPanStart(startDetails);
                          }
                        }
                      });
                    }
                    
                    // Only send pan update if threshold exceeded (or if dragging)
                    if (_isDragging || _hasMoved) {
                      final d = DragUpdateDetails(
                        globalPosition: details.focalPoint,
                        localPosition: details.localFocalPoint,
                        delta: details.focalPointDelta,
                      );
                      widget.onPanUpdate(d);
                    }
                  }
                }
                ..onEnd = (details) {
                  final d = DragEndDetails(velocity: details.velocity);
                  widget.onPanEnd(d);
                };
            },
          ),
        },
        child: Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          children: [
            // Main Trackpad
            Expanded(
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF334155), // slate-700
                        Color(0xFF1e293b), // slate-800
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFF334155),
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Trackpad gesture area
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            color: widget.trackpadActive
                                ? const Color(0xFF475569).withOpacity(0.5)
                                : Colors.transparent,
                          ),
                          child: const Center(
                            child: Opacity(
                              opacity: 0.2,
                              child: Text(
                                '🖱️',
                                style: TextStyle(fontSize: 64),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Vertical scroll indicator
                      Positioned(
                        right: 12,
                        top: 0,
                        bottom: 0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.arrow_drop_up,
                              color: Color(0xFF60a5fa),
                              size: 28,
                            ),
                            Container(
                              width: 2,
                              height: 200,
                              decoration: BoxDecoration(
                                color: const Color(0xFF60a5fa).withOpacity(0.5),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Color(0xFF60a5fa),
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ),
            
            const SizedBox(height: 16),
            
            // Mouse Click Buttons
            Row(
              children: [
                Expanded(
                  child: _buildMouseButton('Left Click', widget.onLeftClick),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMouseButton('Right Click', widget.onRightClick),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildMouseButton(String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF334155), // slate-700
                Color(0xFF1e293b), // slate-800
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF334155),
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF94a3b8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
