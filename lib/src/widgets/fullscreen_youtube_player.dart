import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controller/youtube_player_controller.dart';
import '../player_params.dart';
import 'youtube_player.dart';

/// Um widget que reproduz um vídeo do Youtube em modo tela cheia.
///
/// Veja também:
///
/// * [YoutubePlayer], que reproduz ou transmite vídeos do YouTube no modo normal.
class FullscreenYoutubePlayer extends StatefulWidget {
  /// Cria uma instância de [FullscreenYoutubePlayer].
  const FullscreenYoutubePlayer({
    super.key,
    required this.videoId,
    this.startSeconds,
    this.endSeconds,
    this.gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{},
    this.backgroundColor,
  });

  /// O ID do vídeo do YouTube.
  final String videoId;

  /// O tempo em segundos a partir do qual o vídeo deve começar.
  final double? startSeconds;

  /// O tempo em segundos em que o vídeo deve terminar.
  final double? endSeconds;

  /// Quais gestos devem ser consumidos pelo player do YouTube.
  ///
  /// É possível que outros reconhecedores de gestos estejam competindo com o player em eventos de ponteiro,
  /// por exemplo, se o player estiver dentro de um [ListView], o [ListView] desejará lidar
  /// com arrastos verticais. O player reivindicará gestos que são reconhecidos por qualquer um dos
  /// reconhecedores nesta lista.
  ///
  /// Por padrão, gestos verticais e horizontais são absorvidos pelo player.
  /// Passar um conjunto vazio ignorará os valores padrão.
  ///
  /// Isso é ignorado na web.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  /// A cor de fundo da [WebView].
  ///
  /// O padrão é [ColorScheme.background].
  final Color? backgroundColor;

  @override
  State<FullscreenYoutubePlayer> createState() {
    return _FullscreenYoutubePlayerState();
  }

  /// Inicia o [FullscreenYoutubePlayer].
  ///
  /// Retorna o tempo em segundos em que o player foi fechado.
  static Future<double?> launch(
      BuildContext context, {
        required String videoId,
        double? startSeconds,
        double? endSeconds,
        Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers =
        const <Factory<OneSequenceGestureRecognizer>>{},
        Color? backgroundColor,
      }) {
    return Navigator.push<double>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return FullscreenYoutubePlayer(
            videoId: videoId,
            startSeconds: startSeconds,
            endSeconds: endSeconds,
            gestureRecognizers: gestureRecognizers,
            backgroundColor: backgroundColor,
          );
        },
      ),
    );
  }
}

/// A classe _FullscreenYoutubePlayerState é responsável por controlar o estado do widget FullscreenYoutubePlayer.
/// Ela inicializa um YoutubePlayerController com as informações do vídeo a ser reproduzido e registra um listener para o evento
/// de entrada em tela cheia do player, de forma que quando o usuário sair da tela cheia, o tempo de reprodução atual
/// é enviado de volta para a tela anterior.
//
// No método initState(), a classe configura as preferências de orientação da tela e o modo do sistema para modo imersivo.
// No método build(), ela constrói o widget YoutubePlayer com base no YoutubePlayerController criado no método initState() e nas
// propriedades do FullscreenYoutubePlayer que foram passadas no construtor.
//
// O método dispose() é chamado quando o widget é removido da árvore de widgets. Neste método, a classe restaura as preferências
// de orientação da tela e libera o YoutubePlayerController.
//
// O método _resetOrientation() é responsável por restaurar as preferências de orientação da tela para o modo retrato e o
// modo do sistema para o modo de borda a borda.
class _FullscreenYoutubePlayerState extends State<FullscreenYoutubePlayer> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    // Inicializa o YoutubePlayerController com as informações do vídeo a ser reproduzido e registra um listener
    // para o evento de entrada em tela cheia do player, de forma que quando o usuário sair da tela cheia,
    // o tempo de reprodução atual é enviado de volta para a tela anterior.
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      startSeconds: widget.startSeconds,
      autoPlay: true,
      params: const YoutubePlayerParams(showFullscreenButton: true),
    )..setFullScreenListener((_) async {
      Navigator.pop(context, await _controller.currentTime);
    });

    // Configura as preferências de orientação da tela e o modo do sistema para modo imersivo.
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
    );
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  Widget build(BuildContext context) {
    // Constrói o widget YoutubePlayer com base no YoutubePlayerController criado no initState()
    // e nas propriedades do FullscreenYoutubePlayer que foram passadas no construtor.
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, await _controller.currentTime);
        return false;
      },
      child: YoutubePlayer(
        controller: _controller,
        aspectRatio: MediaQuery.of(context).size.aspectRatio,
        backgroundColor: widget.backgroundColor,
        gestureRecognizers: widget.gestureRecognizers,
      ),
    );
  }

  @override
  void dispose() {
    // Restaura as preferências de orientação da tela para o modo retrato e o modo do sistema para o modo de borda a borda
    _resetOrientation();
    // Libera o YoutubePlayerController
    _controller.close();
    super.dispose();
  }

  // Restaura as preferências de orientação da tela para o modo retrato e o modo do sistema para o modo de borda a borda.
  void _resetOrientation() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}

