import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_iframe/src/controller/youtube_video_state.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Lida com todos os eventos do player recebidos do player iframe.
class YoutubePlayerEventHandler {
  /// O [YoutubePlayerController].
  final YoutubePlayerController controller;

  /// O controlador de fluxo [YoutubeVideoState].
  final StreamController<YoutubeVideoState> videoStateController = StreamController.broadcast();

  final Completer<void> _readyCompleter = Completer();
  late final Map<String, ValueChanged<Object>> _events;

  /// Cria o [YoutubePlayerEventHandler] com o [controller] fornecido.
  YoutubePlayerEventHandler(this.controller) {
    _events = {
      'Ready': onReady,
      'StateChange': onStateChange,
      'PlaybackQualityChange': onPlaybackQualityChange,
      'PlaybackRateChange': onPlaybackRateChange,
      'PlayerError': onError,
      'FullscreenButtonPressed': onFullscreenButtonPressed,
      'VideoState': onVideoState,
    };
  }

  /// Lida com a [javaScriptMessage] do player iframe e cria eventos.
  void call(JavaScriptMessage javaScriptMessage) {
    final data = Map.from(jsonDecode(javaScriptMessage.message));

    for (final entry in data.entries) {
      if (entry.key == 'ApiChange') {
        onApiChange(entry.value);
      } else {
        _events[entry.key]?.call(entry.value);
      }
    }
  }

  /// Esse evento dispara sempre que o player termina de carregar e está pronto para receber chamadas da API.
  /// Sua aplicação deve implementar essa função se você desejar executar automaticamente certas operações,
  /// como reproduzir o vídeo ou exibir informações sobre o vídeo, assim que o player estiver pronto.
  void onReady(Object data) {
    if (!_readyCompleter.isCompleted) _readyCompleter.complete();
  }

  /// Esse evento dispara sempre que o estado do player muda.
  /// A propriedade "data" do objeto de evento que a API passa para a sua função ouvinte
  /// irá especificar um inteiro que corresponde ao novo estado do player.
  Future<void> onStateChange(Object data) async {
    final stateCode = data as int;

    // Este código faz uma pesquisa na lista de todos os estados possíveis do player, representados pela enumeração PlayerState,
    // para encontrar o estado correspondente ao stateCode fornecido. O estado do player é representado por um valor numérico, que é o stateCode.
    //
    // A função firstWhere() é usada para pesquisar o primeiro estado na lista que atenda à condição definida em sua função de retorno,
    // que é comparar o código do estado com o stateCode fornecido. Se nenhum estado na lista satisfizer essa condição, a função orElse()
    // será chamada e retornará o estado PlayerState.unknown, que é o estado padrão se nenhum outro estado corresponder.
    //
    // O resultado final dessa operação é o estado PlayerState correspondente ao stateCode fornecido ou o estado PlayerState.unknown
    // se nenhum estado na lista corresponder. O estado resultante é então armazenado na variável playerState.
    final playerState = PlayerState.values.firstWhere(
          (state) => state.code == stateCode,
      orElse: () => PlayerState.unknown,
    );

    if (playerState == PlayerState.playing) {
      controller.update(playerState: playerState, error: YoutubeError.none);

      final duration = await controller.duration;
      final videoData = await controller.videoData;

      final metaData = YoutubeMetaData(
        duration: Duration(milliseconds: (duration * 1000).truncate()),
        videoId: videoData.videoId,
        author: videoData.author,
        title: videoData.title,
      );

      controller.update(metaData: metaData);
    } else {
      controller.update(playerState: playerState);
    }
  }

  /// Esse evento dispara sempre que a qualidade de reprodução do vídeo mudar.
  /// Isso pode indicar uma mudança no ambiente de reprodução do visualizador.
  /// Veja o [Centro de Ajuda do YouTube](https://support.google.com/youtube/answer/91449)
  /// para mais informações sobre fatores que afetam as condições de reprodução ou que podem fazer o evento disparar.
  void onPlaybackQualityChange(Object data) {
    controller.update(playbackQuality: data as String);
  }

  /// Esse evento dispara sempre que a taxa de reprodução do vídeo mudar.
  /// Por exemplo, se você chamar a função [YoutubePlayerController.setPlaybackRate],
  /// esse evento irá disparar se a taxa de reprodução realmente mudar.
  /// Sua aplicação deve responder ao evento e não deve assumir
  /// que a taxa de reprodução mudará automaticamente quando a função [YoutubePlayerController.setPlaybackRate] for chamada.
  ///
  /// Da mesma forma, seu código não deve assumir que a taxa de reprodução do vídeo mudará apenas
  /// como resultado de uma chamada explícita a [YoutubePlayerController.setPlaybackRate].
  void onPlaybackRateChange(Object data) {
    controller.update(playbackRate: (data as num).toDouble());
  }

  /// Esse evento é disparado para indicar que o player carregou (ou descarregou) um módulo com métodos de API expostos.
  /// Sua aplicação pode ouvir esse evento e, em seguida, verificar o player para determinar
  /// quais opções estão expostas para o módulo carregado recentemente.
  /// Sua aplicação pode então recuperar ou atualizar as configurações existentes para essas opções.
  void onApiChange(Object? data) {}

  /// Esse evento é disparado para indicar que o botão de tela cheia foi clicado.
  void onFullscreenButtonPressed(Object data) {
    controller.toggleFullScreen();
  }

  /// Esse evento dispara se ocorrer um erro no player.
  /// A API irá passar um objeto de evento para a função ouvinte do evento.
  /// Aquela propriedade [data] especificará um inteiro que identifica o tipo de erro que ocorreu.
  void onError(Object data) {
    final error = YoutubeError.values.firstWhere(
          (error) => error.code == data,
      orElse: () => YoutubeError.unknown,
    );

    controller.update(error: error);
  }

  /// Esse evento dispara quando o player recebe informações sobre os estados do vídeo.
  void onVideoState(Object data) {
    videoStateController.add(YoutubeVideoState.fromJson(data.toString()));
  }

  /// Retorna um [Future] que é concluído quando o player estiver pronto.
  Future<void> get isReady => _readyCompleter.future;
}
