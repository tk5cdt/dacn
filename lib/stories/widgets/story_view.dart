import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/palette_generator_service.dart';

class StoryView extends StatefulWidget {
  const StoryView({
    required this.storyItems,
    required this.controller,
    required this.onStoryShow,
    required this.onComplete,
    required this.onVerticalSwipeComplete,
    this.inline = false,
    super.key,
  });

  final List<StoryItem> storyItems;
  final StoryController controller;
  final Function(StoryItem, int) onStoryShow;
  final VoidCallback onComplete;
  final Function(Direction?) onVerticalSwipeComplete;
  final bool inline;

  @override
  State<StoryView> createState() => _StoryViewState();
}

class _StoryViewState extends State<StoryView> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  VideoPlayerController? _videoController;
  int _currentIndex = 0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addStatusListener(_onProgressStatusChanged);
    
    widget.controller.playbackNotifier.addListener(_onPlaybackChanged);
    _loadStory(_currentIndex);
  }

  void _onProgressStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _nextStory();
    }
  }

  void _onPlaybackChanged() {
    final isPlaying = widget.controller.playbackNotifier.value == PlaybackState.play;
    if (isPlaying != _isPlaying) {
      setState(() {
        _isPlaying = isPlaying;
        if (_isPlaying) {
          _progressController.forward();
          _videoController?.play();
        } else {
          _progressController.stop();
          _videoController?.pause();
        }
      });
    }
  }

  Future<void> _loadStory(int index) async {
    if (index >= widget.storyItems.length) {
      widget.onComplete();
      return;
    }

    final story = widget.storyItems[index];
    widget.onStoryShow(story, index);

    _progressController.reset();
    await _videoController?.dispose();
    _videoController = null;

    if (story is VideoStoryItem) {
      _videoController = VideoPlayerController.network(story.url)
        ..initialize().then((_) {
          if (_isPlaying) {
            _videoController?.play();
          }
          setState(() {});
        });
      _progressController.duration = Duration(
        milliseconds: story.duration?.inMilliseconds ?? 5000,
      );
    } else {
      _progressController.duration = (story as ImageStoryItem).duration;
    }

    if (_isPlaying) {
      _progressController.forward();
    }
  }

  void _nextStory() {
    if (_currentIndex < widget.storyItems.length - 1) {
      setState(() {
        _currentIndex++;
        _loadStory(_currentIndex);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    } else {
      widget.onComplete();
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _loadStory(_currentIndex);
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  Future<Color> _getTextColor(String imageUrl) async {
    final shouldUseWhite = await PaletteGeneratorService.shouldUseWhiteText(
      imageUrl: imageUrl,
      region: Offset.zero & const Size(40, 40),
    );
    return shouldUseWhite ? AppColors.white : AppColors.black;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        final screenWidth = MediaQuery.of(context).size.width;
        if (details.globalPosition.dx < screenWidth / 3) {
          _previousStory();
        } else {
          _nextStory();
        }
      },
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          widget.onVerticalSwipeComplete(Direction.down);
        } else if (details.primaryVelocity! < 0) {
          widget.onVerticalSwipeComplete(Direction.up);
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.storyItems.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = widget.storyItems[index];
              if (item is ImageStoryItem) {
                return Image.network(
                  item.url,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.white),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.error, color: AppColors.white),
                    );
                  },
                );
              } else if (item is VideoStoryItem && _videoController != null) {
                if (!_videoController!.value.isInitialized) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.white),
                  );
                }
                return FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController!.value.size.width,
                    height: _videoController!.value.size.height,
                    child: VideoPlayer(_videoController!),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Row(
              children: List.generate(
                widget.storyItems.length,
                (index) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: LinearProgressIndicator(
                      value: index < _currentIndex
                          ? 1
                          : index == _currentIndex
                              ? _progressController.value
                              : 0,
                      minHeight: 2,
                      backgroundColor: AppColors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation(AppColors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _videoController?.dispose();
    widget.controller.playbackNotifier.removeListener(_onPlaybackChanged);
    super.dispose();
  }
}

abstract class StoryItem {
  const StoryItem({required this.url});
  final String url;

  static StoryItem inlineImage({
    required String url,
    required bool shown,
    required StoryController controller,
    required Duration duration,
    bool roundedTop = false,
  }) {
    return ImageStoryItem(
      url: url,
      shown: shown,
      duration: duration,
      roundedTop: roundedTop,
    );
  }

  static StoryItem pageVideo(
    String url, {
    required bool shown,
    required StoryController controller,
    Duration? duration,
  }) {
    return VideoStoryItem(
      url: url,
      shown: shown,
      duration: duration,
    );
  }
}

class ImageStoryItem extends StoryItem {
  const ImageStoryItem({
    required super.url,
    required this.shown,
    required this.duration,
    this.roundedTop = false,
  });

  final bool shown;
  final Duration duration;
  final bool roundedTop;
}

class VideoStoryItem extends StoryItem {
  const VideoStoryItem({
    required super.url,
    required this.shown,
    this.duration,
  });

  final bool shown;
  final Duration? duration;
}

class StoryController {
  final playbackNotifier = ValueNotifier<PlaybackState>(PlaybackState.pause);

  void play() {
    playbackNotifier.value = PlaybackState.play;
  }

  void pause() {
    playbackNotifier.value = PlaybackState.pause;
  }

  void previous() {
    // Implementation for going to previous story
  }

  void dispose() {
    playbackNotifier.dispose();
  }
}

enum PlaybackState { play, pause }

enum Direction { up, down }
