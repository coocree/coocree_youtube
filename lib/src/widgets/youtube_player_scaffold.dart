// Copyright 2022 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controller/youtube_player_controller.dart';
import '../helpers/youtube_value_builder.dart';
import '../helpers/youtube_value_provider.dart';
import '../player_value.dart';
import 'youtube_player.dart';

/// Um widget que envolve o [YoutubePlayer] para que ele possa ser movido facilmente na tela
/// e que gerencia a funcionalidade de tela cheia.
///
/// A classe "YoutubePlayerScaffold" é um widget que envolve o "YoutubePlayer" para que possa ser facilmente movido pela tela e gerencia
/// a funcionalidade de tela cheia.
//
// O construtor recebe diversas propriedades, como o controlador do player, a proporção de aspecto do player, as orientações do dispositivo,
// gestos reconhecíveis, entre outros. A propriedade "builder" é uma função que constrói o widget filho. É utilizada para construir
// o player de vídeo do YouTube.
//
// O método "build" é responsável por construir o player de vídeo do YouTube no widget "YoutubePlayerScaffold". Ele começa construindo
// o player de vídeo com base nas propriedades do widget "YoutubePlayerScaffold". Em seguida, verifica se o widget está sendo executado
// em um ambiente da web usando a propriedade "kIsWeb" do Flutter. Se o widget estiver sendo executado em um ambiente da web,
// o método retorna o widget construído pelo método "builder" do widget "YoutubePlayerScaffold".
//
// Se o widget não estiver sendo executado em um ambiente da web, o método retorna um objeto da classe "YoutubeValueBuilder".
// Esta classe é responsável por construir o player de vídeo do YouTube e gerenciar a transição para o modo de tela cheia.
//
// Se a opção de tela cheia do player de vídeo estiver habilitada, o método retorna um objeto da classe "_FullScreen".
// Este objeto é responsável por controlar a transição para o modo de tela cheia do player de vídeo. Caso contrário,
// o método retorna o widget construído pelo método "builder" do widget "YoutubePlayerScaffold".
class YoutubePlayerScaffold extends StatefulWidget {
  /// Cria um [YoutubePlayerScaffold].
  const YoutubePlayerScaffold({
    super.key,
    required this.builder,
    required this.controller,
    this.aspectRatio = 16 / 9,
    this.autoFullScreen = true,
    this.defaultOrientations = DeviceOrientation.values,
    this.gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{},
    this.fullscreenOrientations = const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ],
    this.lockedOrientations = const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
    this.enableFullScreenOnVerticalDrag = true,
    this.backgroundColor,
    @Deprecated('Unused parameter. Use YoutubePlayerParam.userAgent instead.') this.userAgent,
  });

  /// Constrói o widget filho.
  final Widget Function(BuildContext context, Widget player) builder;

  /// O controlador do player.
  final YoutubePlayerController controller;

  /// A proporção de aspecto do player.
  ///
  /// O valor é ignorado no modo de tela cheia.
  final double aspectRatio;

  /// Se o player deve estar em tela cheia quando houver mudanças de orientação do dispositivo.
  final bool autoFullScreen;

  /// As orientações padrão do dispositivo.
  final List<DeviceOrientation> defaultOrientations;

  /// As orientações usadas no modo de tela cheia.
  final List<DeviceOrientation> fullscreenOrientations;

  /// As orientações usadas quando não estiver em tela cheia e a rotação automática estiver desativada.
  final List<DeviceOrientation> lockedOrientations;

  /// Habilita a alternância do modo de tela cheia no arraste vertical no player.
  ///
  /// O padrão é verdadeiro.
  final bool enableFullScreenOnVerticalDrag;

  /// Quais gestos devem ser consumidos pelo player do YouTube.
  ///
  /// Essa propriedade é ignorada na web.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  /// A cor de fundo do [WebView].
  final Color? backgroundColor;

  /// O valor usado para o cabeçalho de solicitação User-Agent: HTTP.
  ///
  /// Quando nulo, o valor padrão da webview da plataforma é usado para o cabeçalho User-Agent.
  ///
  /// Por padrão, userAgent é nulo.
  final String? userAgent;

  @override
  State<YoutubePlayerScaffold> createState() => _YoutubePlayerScaffoldState();
}

/// A classe "_YoutubePlayerScaffoldState" é responsável por gerenciar a transição para o modo de tela cheia do player de vídeo.
//
// O método "build" é chamado sempre que o widget precisa ser reconstruído. Ele começa construindo o player de vídeo do YouTube
// com base nas propriedades do widget "YoutubePlayerScaffold". Em seguida, ele verifica se o widget está sendo executado em um ambiente
// da web usando a propriedade "kIsWeb" do Flutter. Se o widget estiver sendo executado em um ambiente da web, o método retorna o widget
// construído pelo método "builder" do widget "YoutubePlayerScaffold".
//
// Se o widget não estiver sendo executado em um ambiente da web, o método retorna um objeto da classe "YoutubeValueBuilder".
// Esta classe é responsável por construir o player de vídeo do YouTube e gerenciar a transição para o modo de tela cheia.
//
// Se a opção de tela cheia do player de vídeo estiver habilitada, o método retorna um objeto da classe "_FullScreen".
// Este objeto é responsável por controlar a transição para o modo de tela cheia do player de vídeo. Caso contrário, o método retorna
// o widget construído pelo método "builder" do widget "YoutubePlayerScaffold".
class _YoutubePlayerScaffoldState extends State<YoutubePlayerScaffold> {
  late final GlobalObjectKey _playerKey; // chave global para o player de vídeo

  @override
  void initState() {
    super.initState();

    // define a chave global para o player de vídeo
    _playerKey = GlobalObjectKey(widget.controller);
  }

  @override
  Widget build(BuildContext context) {
    // constrói o player de vídeo do YouTube
    final player = KeyedSubtree(
      key: _playerKey,
      child: YoutubePlayer(
        controller: widget.controller,
        aspectRatio: widget.aspectRatio,
        gestureRecognizers: widget.gestureRecognizers,
        enableFullScreenOnVerticalDrag: widget.enableFullScreenOnVerticalDrag,
        backgroundColor: widget.backgroundColor,
      ),
    );

    // fornece o controlador do player de vídeo aos seus filhos
    return YoutubePlayerControllerProvider(
      controller: widget.controller,

      // verifica se o widget está sendo executado em um ambiente da web
      child: kIsWeb
          ? widget.builder(context, player)

          // se não estiver, retorna um objeto da classe "YoutubeValueBuilder"
          : YoutubeValueBuilder(
              controller: widget.controller,
              buildWhen: (o, n) => o.fullScreenOption != n.fullScreenOption,
              builder: (context, value) {
                // se a opção de tela cheia estiver habilitada, retorna um objeto da classe "_FullScreen"
                if (value.fullScreenOption.enabled)
                  return _FullScreen(
                    auto: widget.autoFullScreen,
                    defaultOrientations: widget.defaultOrientations,
                    fullscreenOrientations: widget.fullscreenOrientations,
                    lockedOrientations: widget.lockedOrientations,
                    fullScreenOption: value.fullScreenOption,
                    child: Builder(
                      builder: (context) {
                        if (value.fullScreenOption.enabled) return player;
                        return widget.builder(context, player);
                      },
                    ),
                  );
                // se não estiver, retorna o widget construído pelo método "builder"
                return widget.builder(context, player);
              },
            ),
    );
  }
}

/// Esta é uma classe chamada "_FullScreen" que é um widget estatal que recebe vários parâmetros:
//
// "fullScreenOption": um objeto da classe "FullScreenOption" que define as opções de tela cheia do player de vídeo.
// "defaultOrientations": uma lista de orientações preferidas do dispositivo quando o player de vídeo não está em modo de tela cheia.
// "fullscreenOrientations": uma lista de orientações preferidas do dispositivo quando o player de vídeo está em modo de tela cheia.
// "lockedOrientations": uma lista de orientações preferidas do dispositivo quando o player de vídeo está em modo de tela cheia
// e a opção de orientação bloqueada está habilitada.
// "child": um widget que será exibido em tela cheia.
// "auto": um booleano que indica se o widget deve observar automaticamente a mudança de orientação do dispositivo.
// A classe retorna um objeto da classe "_FullScreenState", que é responsável por controlar a transição para o modo
// de tela cheia do player de vídeo.
class _FullScreen extends StatefulWidget {
  const _FullScreen({
    required this.fullScreenOption,
    required this.defaultOrientations,
    required this.fullscreenOrientations,
    required this.lockedOrientations,
    required this.child,
    required this.auto,
  });

  final FullScreenOption fullScreenOption;
  final List<DeviceOrientation> defaultOrientations;
  final List<DeviceOrientation> fullscreenOrientations;
  final List<DeviceOrientation> lockedOrientations;
  final Widget child;
  final bool auto;

  @override
  State<_FullScreen> createState() => _FullScreenState();
}

class _FullScreenState extends State<_FullScreen> with WidgetsBindingObserver {
  Orientation? _previousOrientation; // variável para armazenar a orientação anterior do dispositivo

  @override
  void initState() {
    super.initState();

    // adiciona o objeto como observador do estado da aplicação se o parâmetro "auto" for verdadeiro
    if (widget.auto) WidgetsBinding.instance.addObserver(this);

    // define as orientações preferidas para o sistema
    SystemChrome.setPreferredOrientations(_deviceOrientations);

    // habilita o modo de tela cheia
    SystemChrome.setEnabledSystemUIMode(_uiMode);
  }

  @override
  void didUpdateWidget(_FullScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // verifica se a opção de tela cheia foi alterada
    if (oldWidget.fullScreenOption != widget.fullScreenOption) {
      // redefine as orientações preferidas para o sistema
      SystemChrome.setPreferredOrientations(_deviceOrientations);

      // habilita o modo de tela cheia
      SystemChrome.setEnabledSystemUIMode(_uiMode);
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    // obtém a orientação atual do dispositivo
    final orientation = MediaQuery.of(context).orientation;

    // obtém o controlador do player de vídeo
    final controller = YoutubePlayerControllerProvider.of(context);

    // verifica se o player está em modo de tela cheia
    final isFullScreen = controller.value.fullScreenOption.enabled;

    // verifica se a orientação atual é igual à anterior
    if (_previousOrientation == orientation) return;

    // se o player não estiver em modo de tela cheia e a orientação for paisagem
    if (!isFullScreen && orientation == Orientation.landscape) {
      // entra no modo de tela cheia
      controller.enterFullScreen(lock: false);

      // habilita o modo de tela cheia imersiva
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    }

    // armazena a orientação atual
    _previousOrientation = orientation;
  }

  @override
  Widget build(BuildContext context) {
    // permite que o botão voltar seja usado para sair do modo de tela cheia
    return WillPopScope(
      onWillPop: _handleFullScreenBackAction,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    // remove o objeto como observador do estado da aplicação se o parâmetro "auto" for verdadeiro
    if (widget.auto) WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // retorna uma lista com as orientações preferidas para o sistema
  List<DeviceOrientation> get _deviceOrientations {
    final fullscreen = widget.fullScreenOption;

    if (!fullscreen.enabled && fullscreen.locked) {
      return widget.lockedOrientations;
    } else if (fullscreen.enabled) {
      return widget.fullscreenOrientations;
    }

    return widget.defaultOrientations;
  }

  // retorna o modo de tela cheia a ser habilitado
  SystemUiMode get _uiMode {
    return widget.fullScreenOption.enabled ? SystemUiMode.immersive : SystemUiMode.edgeToEdge;
  }

  // trata o evento de pressionar o botão voltar
  Future<bool> _handleFullScreenBackAction() async {
    if (mounted && widget.fullScreenOption.enabled) {
      // sai do modo de tela cheia
      YoutubePlayerControllerProvider.of(context).exitFullScreen();
      return false;
    }

    return true;
  }
}
