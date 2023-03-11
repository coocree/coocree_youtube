
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe_example/video_position_seeker.dart';
import 'package:youtube_player_iframe_example/widgets/meta_data_section.dart';
import 'package:youtube_player_iframe_example/widgets/play_pause_button_bar.dart';
import 'package:youtube_player_iframe_example/widgets/player_state_section.dart';
import 'package:youtube_player_iframe_example/widgets/source_input_section.dart';

/// Este widget é uma classe que implementa todos os controles do player de vídeo. O construtor Controls é um construtor
/// padrão sem parâmetros.
//
// O método build é anulado para construir e retornar a interface do usuário do widget. O método build é chamado sempre
// que o widget é reconstruído.
//
// O método build retorna um widget Padding que contém todos os controles do player de vídeo. O widget Column dentro do widget
// Padding contém todos os widgets de controle do player de vídeo.
//
// A classe Controls contém várias seções de controle de vídeo, incluindo uma seção de metadados do vídeo (MetaDataSection),
// uma seção de entrada de fonte de vídeo (SourceInputSection), uma barra de botões de reprodução/pausa do vídeo (PlayPauseButtonBar),
// um indicador de posição do vídeo (VideoPositionSeeker) e uma seção de estado do player (PlayerStateSection).
//
// O método build também define um widget _space que retorna um widget SizedBox com uma altura de 10 pixels. O widget _space é
// usado para fornecer espaçamento vertical entre as seções de controle do player de vídeo.

/// Widget que contém todos os controles do player de vídeo.
class Controls extends StatelessWidget {
  /// Construtor que cria o widget.
  const Controls();

  @override
  Widget build(BuildContext context) {
    // Retorna um widget que contém todos os controles do player de vídeo.
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seção de metadados do vídeo.
          MetaDataSection(),

          // Espaçamento vertical.
          _space,

          // Seção de entrada de fonte de vídeo.
          SourceInputSection(),

          // Espaçamento vertical.
          _space,

          // Barra de botões de reprodução/pausa do vídeo.
          PlayPauseButtonBar(),

          // Espaçamento vertical.
          _space,

          // Indicador de posição do vídeo.
          const VideoPositionSeeker(),

          // Espaçamento vertical.
          _space,

          // Seção de estado do player.
          PlayerStateSection(),
        ],
      ),
    );
  }

  // Espaçamento vertical.
  Widget get _space => const SizedBox(height: 10);
}


