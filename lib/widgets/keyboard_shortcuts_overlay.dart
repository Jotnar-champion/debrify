import 'package:flutter/material.dart';

/// Keyboard shortcuts help overlay for desktop/TV users.
/// Shows all available shortcuts for the video player and navigation.
class KeyboardShortcutsOverlay {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.keyboard,
                          color: Color(0xFF6366F1), size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Keyboard Shortcuts',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Divider(color: Colors.white.withOpacity(0.06)),
              // Shortcuts list
              Flexible(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                  children: [
                    _sectionHeader('Video Player'),
                    _shortcutRow('Space', 'Play / Pause'),
                    _shortcutRow('←  →', 'Seek -10s / +10s'),
                    _shortcutRow('↑  ↓', 'Volume Up / Down'),
                    _shortcutRow('F', 'Toggle Fullscreen'),
                    _shortcutRow('M', 'Mute / Unmute'),
                    _shortcutRow('[  ]', 'Decrease / Increase Speed'),
                    _shortcutRow('S', 'Subtitle Track'),
                    _shortcutRow('A', 'Audio Track'),
                    _shortcutRow('N', 'Next Episode / Video'),
                    _shortcutRow('P', 'Previous Episode / Video'),
                    _shortcutRow('Esc', 'Exit Player / Exit Fullscreen'),
                    const SizedBox(height: 16),
                    _sectionHeader('Navigation'),
                    _shortcutRow('Tab', 'Switch Focus Areas'),
                    _shortcutRow('Enter', 'Select / Open'),
                    _shortcutRow('Backspace', 'Go Back'),
                    _shortcutRow('Esc', 'Close Dialog / Exit Fullscreen'),
                    _shortcutRow('/', 'Focus Search'),
                    const SizedBox(height: 16),
                    _sectionHeader('TV Remote (DPAD)'),
                    _shortcutRow('D-Pad', 'Navigate'),
                    _shortcutRow('Select', 'Play / Open'),
                    _shortcutRow('Back', 'Go Back / Exit'),
                    _shortcutRow('Long Press', 'More Options'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: TextStyle(
          color: const Color(0xFF6366F1).withOpacity(0.9),
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  static Widget _shortcutRow(String keys, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Wrap(
              spacing: 4,
              children: keys.split('  ').map((k) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                    border:
                        Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: Text(
                    k.trim(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
