import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:youtube_player_iframe_example/video_list_page.dart';


/// Este widget é uma classe que implementa um botão de ícone que abre uma lista de reprodução de vídeos quando pressionado.
/// O construtor VideoPlaylistIconButton é um construtor nomeado que recebe um parâmetro key opcional.
//
// O método build é anulado para construir e retornar a interface do usuário do widget. O método build é chamado sempre
// que o widget é reconstruído.
//
// O método build usa o controlador de vídeo YoutubePlayerController fornecido pelo contexto para pausar a reprodução do vídeo.
// Em seguida, ele navega para a página de lista de reprodução de vídeos usando a classe Navigator.
//
// Depois que a navegação é concluída, o método build continua a reprodução do vídeo chamando o método playVideo() do controlador de vídeo.
//
// O método build retorna um widget IconButton que exibe o ícone de lista de reprodução de vídeos. O ícone do botão
// é fornecido como um objeto Icon. O método onPressed do botão é um objeto async que executa uma sequência
// de operações quando o botão é pressionado.

/// Widget que exibe um botão de ícone de lista de reprodução de vídeo.
class VideoPlaylistIconButton extends StatelessWidget {
  /// Construtor que cria o widget.
  const VideoPlaylistIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtém o controlador do player de vídeo do contexto.
    final controller = context.ytController;

    // Retorna um botão de ícone que mostra uma lista de reprodução de vídeos quando pressionado.
    return IconButton(
      onPressed: () async {
        // Pausa a reprodução do vídeo.
        controller.pauseVideo();

        // Navega para a página de lista de reprodução de vídeos e aguarda o resultado da navegação.
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const VideoListPage()),
        );

        // Continua a reprodução do vídeo após a navegação ser concluída.
        controller.playVideo();
      },
      icon: const Icon(Icons.playlist_play_sharp), // Ícone do botão.
    );
  }
}

