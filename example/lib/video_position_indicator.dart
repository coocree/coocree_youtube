import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Este widget é uma classe que implementa um indicador de posição de vídeo. O construtor VideoPositionIndicator é um construtor
/// nomeado que recebe um parâmetro key opcional.
//
// O método build é anulado para construir e retornar a interface do usuário do widget. O método build é chamado sempre que o
// widget é reconstruído.
//
// O método build retorna um widget StreamBuilder, que é usado para reconstruir o widget sempre que o fluxo de estado do vídeo
// é atualizado. O fluxo de estado do vídeo é obtido a partir do controlador de vídeo YoutubePlayerController fornecido pelo contexto.
//
// O método build usa a classe YoutubeVideoState para obter a posição atual do vídeo e a duração total do vídeo.
// Se o objeto de snapshot.data for nulo, a posição atual do vídeo é definida como 0.
//
// O método build retorna uma barra de progresso linear que mostra a posição atual do vídeo em relação à duração total do vídeo.
// A altura mínima da barra de progresso é definida como 1.
class VideoPositionIndicator extends StatelessWidget {
  /// Widget que mostra a barra de progresso do vídeo.
  const VideoPositionIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtém o controller do player de vídeo a partir do contexto.
    final controller = context.ytController;

    // Retorna um widget que reconstrói sempre que o stream de estado do vídeo é atualizado.
    return StreamBuilder<YoutubeVideoState>(
      stream: controller.videoStateStream, // Fluxo de estado do vídeo.
      initialData: const YoutubeVideoState(), // Estado inicial.
      builder: (context, snapshot) {
        // Obtém a posição atual do vídeo em milissegundos.
        final position = snapshot.data?.position.inMilliseconds ?? 0;

        // Obtém a duração total do vídeo em milissegundos.
        final duration = controller.metadata.duration.inMilliseconds;

        // Retorna uma barra de progresso linear que indica a posição atual do vídeo em relação à sua duração total.
        return LinearProgressIndicator(
          value: duration == 0 ? 0 : position / duration, // Define o valor da barra de progresso como a proporção da posição atual em relação à duração total do vídeo.
          minHeight: 10, // Define a altura mínima da barra de progresso como 1.
        );
      },
    );
  }
}

