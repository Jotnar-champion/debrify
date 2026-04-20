import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/storage_service.dart';
import '../services/main_page_bridge.dart';
import 'home_focus_controller.dart';

/// "Continue Watching" horizontal section for the home screen.
/// Shows playlist items that have partial playback progress.
class HomeContinueWatchingSection extends StatefulWidget {
  final HomeFocusController? focusController;
  final VoidCallback? onRequestFocusAbove;
  final VoidCallback? onRequestFocusBelow;
  final bool isTelevision;

  const HomeContinueWatchingSection({
    super.key,
    this.focusController,
    this.onRequestFocusAbove,
    this.onRequestFocusBelow,
    this.isTelevision = false,
  });

  @override
  State<HomeContinueWatchingSection> createState() =>
      _HomeContinueWatchingSectionState();
}

class _HomeContinueWatchingSectionState
    extends State<HomeContinueWatchingSection> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;
  String? _playingItemKey;

  final List<FocusNode> _cardFocusNodes = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    widget.focusController?.unregisterSection(HomeSection.favorites);
    for (final node in _cardFocusNodes) {
      node.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _ensureFocusNodes() {
    while (_cardFocusNodes.length < _items.length) {
      _cardFocusNodes
          .add(FocusNode(debugLabel: 'cw_card_${_cardFocusNodes.length}'));
    }
    while (_cardFocusNodes.length > _items.length) {
      _cardFocusNodes.removeLast().dispose();
    }
  }

  Future<void> _loadItems() async {
    try {
      final items = await StorageService.getContinueWatchingItems();
      if (!mounted) return;
      setState(() {
        _items = items;
        _isLoading = false;
      });
      _ensureFocusNodes();
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _playItem(Map<String, dynamic> item) async {
    final dedupeKey = StorageService.computePlaylistDedupeKey(item);
    setState(() => _playingItemKey = dedupeKey);

    // Record to watch history
    await StorageService.addWatchHistoryEntry(
      title: (item['title'] as String?) ?? 'Video',
      provider: (item['provider'] as String?) ?? 'realdebrid',
      posterUrl: item['posterUrl'] as String?,
      dedupeKey: dedupeKey,
      kind: item['kind'] as String?,
    );

    final playHandler = MainPageBridge.playPlaylistItem;
    if (playHandler != null) {
      await playHandler(item);
    }

    if (mounted) {
      setState(() => _playingItemKey = null);
      _loadItems(); // Refresh after playback
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink();
    if (_items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.2),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(Icons.play_circle_outline,
                    color: Color(0xFF6366F1), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Continue Watching',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_items.length}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Horizontal card list
        SizedBox(
          height: 190,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return Padding(
                padding: EdgeInsets.only(
                    right: index < _items.length - 1 ? 14 : 0),
                child: _ContinueWatchingCard(
                  item: item,
                  isPlaying: _playingItemKey ==
                      StorageService.computePlaylistDedupeKey(item),
                  focusNode:
                      index < _cardFocusNodes.length
                          ? _cardFocusNodes[index]
                          : null,
                  onPlay: () => _playItem(item),
                  onUpArrowPressed: widget.onRequestFocusAbove,
                  onDownArrowPressed: widget.onRequestFocusBelow,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ContinueWatchingCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final bool isPlaying;
  final FocusNode? focusNode;
  final VoidCallback onPlay;
  final VoidCallback? onUpArrowPressed;
  final VoidCallback? onDownArrowPressed;

  const _ContinueWatchingCard({
    required this.item,
    this.isPlaying = false,
    this.focusNode,
    required this.onPlay,
    this.onUpArrowPressed,
    this.onDownArrowPressed,
  });

  @override
  State<_ContinueWatchingCard> createState() => _ContinueWatchingCardState();
}

class _ContinueWatchingCardState extends State<_ContinueWatchingCard> {
  bool _isHovered = false;
  bool _isFocused = false;

  String _providerLabel(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'realdebrid':
      case 'real-debrid':
        return 'RD';
      case 'torbox':
        return 'TB';
      case 'pikpak':
        return 'PP';
      default:
        return 'RD';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = (widget.item['title'] as String?) ?? 'Untitled';
    final posterUrl = widget.item['posterUrl'] as String?;
    final provider = widget.item['provider'] as String?;
    final percent = (widget.item['_progressPercent'] as double?) ?? 0.0;

    final isHighlighted = _isHovered || _isFocused;

    return Focus(
      focusNode: widget.focusNode,
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            widget.onUpArrowPressed?.call();
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            widget.onDownArrowPressed?.call();
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.select) {
            widget.onPlay();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onPlay,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isFocused
                    ? const Color(0xFF6366F1)
                    : Colors.white.withOpacity(isHighlighted ? 0.15 : 0.06),
                width: _isFocused ? 2.5 : 1,
              ),
              color: const Color(0xFF1E293B),
              boxShadow: isHighlighted
                  ? [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                        blurRadius: 16,
                      )
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Thumbnail area
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(13)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (posterUrl != null && posterUrl.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: posterUrl,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(
                              color: const Color(0xFF334155),
                              child: const Icon(Icons.movie,
                                  color: Colors.white38, size: 40),
                            ),
                          )
                        else
                          Container(
                            color: const Color(0xFF334155),
                            child: const Icon(Icons.movie,
                                color: Colors.white38, size: 40),
                          ),
                        // Play icon overlay
                        if (isHighlighted || widget.isPlaying)
                          Container(
                            color: Colors.black38,
                            child: Center(
                              child: widget.isPlaying
                                  ? const SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.play_circle_filled,
                                      color: Colors.white, size: 44),
                            ),
                          ),
                        // Provider badge
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _providerLabel(provider),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        // Progress percentage
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.85),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${(percent * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Progress bar
                ClipRRect(
                  child: LinearProgressIndicator(
                    value: percent.clamp(0.0, 1.0),
                    minHeight: 3,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor:
                        const AlwaysStoppedAnimation(Color(0xFF6366F1)),
                  ),
                ),
                // Title
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
