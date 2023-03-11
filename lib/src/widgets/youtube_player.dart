// Copyright 2022 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_iframe/src/widgets/fullscreen_youtube_player.dart';

import '../controller/youtube_player_controller.dart';
/// Um widget para reproduzir ou transmitir vídeos do Youtube.
///
/// Veja também:
///
/// * [FullscreenYoutubePlayer], que reproduz ou transmite vídeos do Youtube em modo de tela cheia.
class YoutubePlayer extends StatefulWidget {
  /// Um widget para reproduzir ou transmitir vídeos do Youtube.
  const YoutubePlayer({
    super.key,
    required this.controller,
    this.aspectRatio = 16 / 9,
    this.gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{},
    this.backgroundColor,
    @Deprecated('Parâmetro não utilizado. Use YoutubePlayerParam.userAgent em seu lugar.')
    this.userAgent,
    this.enableFullScreenOnVerticalDrag = true,
  });

  /// O [controller] para este player.
  final YoutubePlayerController controller;

  /// Proporção do aspecto para o player.
  final double aspectRatio;

  /// Quais gestos devem ser consumidos pelo player do Youtube.
  ///
  /// É possível que outros reconhecedores de gestos estejam competindo com o player em eventos de ponteiro,
  /// por exemplo, se o player estiver dentro de um [ListView], o [ListView] desejará lidar com
  /// arrastos verticais. O player reivindicará gestos que são reconhecidos por qualquer um dos
  /// reconhecedores nesta lista.
  ///
  /// Por padrão, os gestos verticais e horizontais são absorvidos pelo player.
  /// Passar um conjunto vazio ignorará os valores padrão.
  ///
  /// Isso é ignorado na web.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  /// A cor de fundo do [WebView].
  ///
  /// Padrão para [ColorScheme.background].
  final Color? backgroundColor;

  /// O valor usado para o cabeçalho de solicitação HTTP User-Agent:.
  ///
  /// Quando nulo, o padrão do webview da plataforma é usado para o cabeçalho User-Agent.
  ///
  /// Por padrão, userAgent é nulo.
  final String? userAgent;

  /// Habilita a mudança para o modo de tela cheia no arraste vertical no player.
  ///
  /// O padrão é true.
  final bool enableFullScreenOnVerticalDrag;

  @override
  State<YoutubePlayer> createState() => _YoutubePlayerState();
}
class _YoutubePlayerState extends State<YoutubePlayer> {
  // controlador de vídeo do YoutubePlayer
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    // inicializa o controlador com o controlador passado pelo widget
    _controller = widget.controller;

    // inicializa o player
    _initPlayer();
  }

  @override
  void didUpdateWidget(YoutubePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // verifica se a cor de fundo foi alterada
    if (widget.backgroundColor != oldWidget.backgroundColor) {
      // atualiza a cor de fundo do player
      _updateBackgroundColor(widget.backgroundColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    // controlador da visualização web do player
    Widget player = WebViewWidget(
      controller: _controller.webViewController,
      gestureRecognizers: widget.gestureRecognizers,
    );

    if (widget.enableFullScreenOnVerticalDrag) {
      // adiciona um gesto de arrastar verticalmente para entrar/sair do modo de tela cheia
      player = GestureDetector(
        onVerticalDragUpdate: _fullscreenGesture,
        child: player,
      );
    }

    return OrientationBuilder(
      builder: (context, orientation) {
        return AspectRatio(
          aspectRatio: orientation == Orientation.landscape
              ? MediaQuery.of(context).size.aspectRatio
              : widget.aspectRatio,
          child: player,
        );
      },
    );
  }

  void _fullscreenGesture(DragUpdateDetails details) {
    final delta = details.delta.dy;

    // verifica se o movimento do gesto de arrastar é maior que 10 pixels
    if (delta.abs() > 10) {
      // verifica se o movimento foi para cima ou para baixo
      delta.isNegative
          ? _controller.enterFullScreen() // entra no modo de tela cheia
          : _controller.exitFullScreen(); // sai do modo de tela cheia
    }
  }

  void _updateBackgroundColor(Color? backgroundColor) {
    final bgColor =
        backgroundColor ?? Theme.of(context).colorScheme.background;

    // atualiza a cor de fundo da visualização web do player
    _controller.webViewController.setBackgroundColor(bgColor);
  }

  Future<void> _initPlayer() async {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _updateBackgroundColor(widget.backgroundColor);
    });

    // inicializa o player
    await _controller.init();
  }
}
