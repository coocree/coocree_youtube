import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Widget VideoPositionSeeker
///
/// Este widget é responsável por exibir um controle deslizante (Slider) que permite
/// ao usuário buscar (seek) em um vídeo do YouTube reproduzido pelo plugin YoutubePlayerIFrame.
/// O valor do Slider é atualizado com base na posição atual e duração do vídeo.
///
/// Parâmetros:
///   - key: Uma chave opcional a ser passada para o widget
///
/// Exemplo de uso:
///   VideoPositionSeeker()
///
class VideoPositionSeeker extends StatelessWidget {

  // A chave opcional passada para o widget
  const VideoPositionSeeker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Valor inicial do Slider
    var value = 0.0;

    return Row(
      children: [
        const Text(
          'Seek', // Rótulo do controle deslizante
          style: TextStyle(fontWeight: FontWeight.w300),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: StreamBuilder<YoutubeVideoState>(
            stream: context.ytController.videoStateStream, // Fluxo de dados do estado atual do vídeo
            initialData: const YoutubeVideoState(), // Estado inicial do vídeo
            builder: (context, snapshot) {
              // Posição atual do vídeo em segundos
              final position = snapshot.data?.position.inSeconds ?? 0;
              // Duração total do vídeo em segundos
              final duration = context.ytController.metadata.duration.inSeconds;

              // Cálculo do valor do Slider com base na posição atual e duração do vídeo
              value = position == 0 || duration == 0 ? 0 : position / duration;

              return StatefulBuilder(
                builder: (context, setState) {
                  return Slider(
                    value: value, // Valor atual do Slider
                    onChanged: (positionFraction) {
                      value = positionFraction; // Atualiza o valor do Slider
                      setState(() {}); // Atualiza a UI para refletir o novo valor do Slider

                      // Busca (seek) para a nova posição no vídeo
                      context.ytController.seekTo(
                        seconds: (value * duration).toDouble(),
                        allowSeekAhead: true,
                      );
                    },
                    min: 0, // Valor mínimo do Slider
                    max: 1, // Valor máximo do Slider
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
