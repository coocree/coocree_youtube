import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

// Define um widget de barra de botões de reprodução/pausa para vídeos do YouTube
class PlayPauseButtonBar extends StatelessWidget {
  // Cria uma instância de ValueNotifier para controlar o estado de mudo da reprodução
  final ValueNotifier<bool> _isMuted = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    // Constrói uma linha de botões centralizados horizontalmente
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Botão para reproduzir o vídeo anterior
        IconButton(
          icon: const Icon(Icons.skip_previous),
          onPressed: context.ytController.previousVideo,
        ),
        // Botão de reprodução/pausa
        YoutubeValueBuilder(
          builder: (context, value) {
            return IconButton(
              // Alterna entre ícones de reprodução e pausa com base no estado atual do player
              icon: Icon(
                value.playerState == PlayerState.playing ? Icons.pause : Icons.play_arrow,
              ),
              onPressed: () {
                // Pausa ou reproduz o vídeo com base no estado atual do player
                value.playerState == PlayerState.playing ? context.ytController.pauseVideo() : context.ytController.playVideo();
              },
            );
          },
        ),
        // Botão de mudo
        ValueListenableBuilder<bool>(
          valueListenable: _isMuted,
          builder: (context, isMuted, _) {
            return IconButton(
              // Alterna entre ícones de som ativado e desativado com base no estado atual de mudo
              icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
              onPressed: () {
                // Alterna o estado de mudo e ativa ou desativa o som do player com base no estado atual de mudo
                _isMuted.value = !isMuted;
                isMuted ? context.ytController.unMute() : context.ytController.mute();
              },
            );
          },
        ),
        // Botão para reproduzir o próximo vídeo
        IconButton(
          icon: const Icon(Icons.skip_next),
          onPressed: context.ytController.nextVideo,
        ),
      ],
    );
  }
}
