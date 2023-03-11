import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

// Define um widget para exibir o estado atual do player de vídeo do YouTube
class PlayerStateSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Usa o YoutubeValueBuilder para obter o estado atual do player de vídeo
    return YoutubeValueBuilder(
      builder: (context, value) {
        // Cria um AnimatedContainer para exibir o estado atual do player
        return AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: _getStateColor(value.playerState),
          ),
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          child: Text(
            value.playerState.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  // Define uma função para retornar a cor apropriada com base no estado do player
  Color _getStateColor(PlayerState state) {
    switch (state) {
      case PlayerState.unknown:
        return Colors.grey[700]!;
      case PlayerState.unStarted:
        return Colors.pink;
      case PlayerState.ended:
        return Colors.red;
      case PlayerState.playing:
        return Colors.blueAccent;
      case PlayerState.paused:
        return Colors.orange;
      case PlayerState.buffering:
        return Colors.yellow;
      case PlayerState.cued:
        return Colors.blue[900]!;
      default:
        return Colors.blue;
    }
  }
}
