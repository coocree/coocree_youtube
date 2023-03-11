// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:youtube_player_iframe_example/controls.dart';
import 'package:youtube_player_iframe_example/video_playlist_icon_button.dart';
import 'package:youtube_player_iframe_example/video_position_indicator.dart';

const List<String> _videoIds = [
  'H5v3kku4y6Q',
  'tcodrIK2P_I',
  'nPt8bK2gbaU',
  'K18cpp_-gP8',
  'iLnmTe5Q2Qw',
  '_WoCV4c6XOE',
  'KmzdUe0RSJo',
  '6jZDSSZZxjQ',
  'p2lYr3vM_1w',
  '7QUtEmBT_-w',
  '34_PXCzGw1M'
];
// Executa a aplicação Flutter com o widget YoutubeApp
Future<void> main() async {
  runApp(YoutubeApp());
}

// Classe principal do aplicativo Flutter
class YoutubeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Retorna o widget MaterialApp, que é o widget básico de material design usado para criar aplicativos no Flutter
    return MaterialApp(
      // Define o título do aplicativo
      title: 'Youtube Player IFrame Demo',
      // Define um tema personalizado
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple, // Define a cor principal do tema
          brightness: Brightness.dark, // Define um tema escuro
        ),
        useMaterial3: true,
      ),
      // Desativa a exibição do banner de depuração
      debugShowCheckedModeBanner: false,
      // Define a tela inicial do aplicativo
      home: YoutubeAppDemo(),
    );
  }
}

// Tela inicial do aplicativo Flutter
class YoutubeAppDemo extends StatefulWidget {
  @override
  _YoutubeAppDemoState createState() => _YoutubeAppDemoState();
}

// Estado da tela inicial do aplicativo Flutter
class _YoutubeAppDemoState extends State<YoutubeAppDemo> {
  // Controlador do reprodutor de vídeo do YouTube
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Cria um objeto YoutubePlayerController com parâmetros pré-definidos
    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true, // Exibe os controles do vídeo
        mute: false, // Não coloca o vídeo no mudo
        showFullscreenButton: true, // Exibe o botão de tela cheia
        loop: false, // Não permite a reprodução em loop
      ),
    );
    // Carrega uma lista de IDs de vídeos no reprodutor de vídeo
    _controller.loadPlaylist(
      list: _videoIds, // IDs dos vídeos a serem reproduzidos
      listType: ListType.playlist,
      startSeconds: 136, // Começa a reproduzir a partir dos 136 segundos
    );
  }

  @override
  void dispose() {
    // Fecha o controlador do reprodutor de vídeo quando o widget é removido da árvore de widgets
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Retorna um widget personalizado que incorpora o reprodutor de vídeo do YouTube
    return YoutubePlayerScaffold(
      controller: _controller, // Controlador do reprodutor de vídeo
      builder: (context, player) {
        return Scaffold(
          // Define a barra de aplicativo
          appBar: AppBar(
            title: const Text('Youtube Player IFrame Demo'), // Título da tela
            actions: const [VideoPlaylistIconButton()], // Botão de lista de reprodução
          ),
          // Define o corpo do aplicativo
          body: LayoutBuilder(
            builder: (context, constraints) {
              // Verifica se está sendo executado na web e a largura da tela é maior que 750 pixels
              if (kIsWeb && constraints.maxWidth > 750) {
                // Define o layout em duas colunas
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          player, // Reprodutor de vídeo
                          const VideoPositionIndicator(), // Indicador de posição do vídeo
                        ],
                      ),
                    ),
                    const Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        child: Controls(), // Controles do vídeo
                      ),
                    ),
                  ],
                );
              }
              // Se não estiver sendo executado na web ou a largura da tela for menor ou igual a 750 pixels, define o layout em uma única coluna
              return ListView(
                children: [
                  player, // Reprodutor de vídeo
                  const VideoPositionIndicator(), // Indicador de posição do vídeo
                  const Controls(), // Controles do vídeo
                ],
              );
            },
          ),
        );
      },
    );
  }
}
