import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// Embeds Bunny's own player in an iframe.
///
/// The backend hands out iframe.mediadelivery.net URLs rather than raw HLS,
/// so there is no file for video_player to open. That also means playback
/// state stays inside the iframe: the app cannot know where the student is or
/// whether they finished.
class BunnyPlayer extends StatefulWidget {
  const BunnyPlayer({super.key, required this.url});

  final String url;

  @override
  State<BunnyPlayer> createState() => _BunnyPlayerState();
}

class _BunnyPlayerState extends State<BunnyPlayer> {
  late String _viewType;

  @override
  void initState() {
    super.initState();
    _register();
  }

  @override
  void didUpdateWidget(BunnyPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A new signed URL means a different view type: the registry keys on the
    // type string, so reusing it would keep showing the previous lesson.
    if (oldWidget.url != widget.url) _register();
  }

  void _register() {
    _viewType = 'bunny-${widget.url.hashCode}';

    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int _) => web.HTMLIFrameElement()
        ..src = widget.url
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        // Flutter paints onto a canvas that sits above HTML platform views.
        // Without its own stacking context the iframe renders behind it: the
        // controls bleed through but the picture stays hidden.
        ..style.position = 'relative'
        ..style.zIndex = '1'
        ..allow =
            'accelerometer; gyroscope; autoplay; encrypted-media; picture-in-picture'
        ..allowFullscreen = true,
      // (int _) => web.HTMLIFrameElement()
      //   ..src = widget.url
      //   ..style.border = 'none'
      //   ..style.width = '100%'
      //   ..style.height = '100%'
      //   // Flutter paints onto a canvas that sits above HTML platform views.
      //   // Without an explicit stacking context the iframe renders behind it:
      //   // the controls bleed through but the picture stays hidden.
      //   ..style.position = 'relative'
      //   ..style.zIndex = '1'
      //   ..allow =
      //       'accelerometer; gyroscope; autoplay; encrypted-media; picture-in-picture'
      //   ..allowFullscreen = true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: HtmlElementView(key: ValueKey(_viewType), viewType: _viewType),
      ),
    );
  }
}
