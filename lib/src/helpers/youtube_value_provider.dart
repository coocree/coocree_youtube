// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import '../controller/youtube_player_controller.dart';

/// Um widget herdado que fornece [YoutubePlayerController] aos seus descendentes.
class YoutubePlayerControllerProvider extends InheritedWidget {
  /// O [YoutubePlayerController].
  final YoutubePlayerController controller;

  /// Um widget herdado que fornece [YoutubePlayerController] aos seus descendentes.
  const YoutubePlayerControllerProvider({
    super.key,
    required this.controller,
    required super.child,
  });

  /// Encontra o [YoutubePlayerController] mais recente em seus ancestrais.
  static YoutubePlayerController of(BuildContext context) {
    final controllerProvider = context.dependOnInheritedWidgetOfExactType<YoutubePlayerControllerProvider>();
    assert(
      controllerProvider != null,
      'Não é possível encontrar YoutubePlayerControllerProvider acima. Por favor, envolva o widget pai com YoutubePlayerControllerProvider.',
    );
    return controllerProvider!.controller;
  }

  /// Encontra o [YoutubePlayerController] mais recente em seus ancestrais.
  static YoutubePlayerController? maybeOf(BuildContext context) {
    final controllerProvider = context.dependOnInheritedWidgetOfExactType<YoutubePlayerControllerProvider>();
    return controllerProvider?.controller;
  }

  @override
  bool updateShouldNotify(YoutubePlayerControllerProvider old) {
    return old.controller.hashCode != controller.hashCode;
  }
}

/// YoutubePlayerControllerExtension
extension YoutubePlayerControllerExtension on BuildContext {
  /// Encontra o [YoutubePlayerController] mais recente em seus ancestrais.
  YoutubePlayerController get ytController {
    return YoutubePlayerControllerProvider.of(this);
  }
}
