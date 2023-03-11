import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

// Lista de IDs de vídeo do YouTube que serão usados para criar os controladores do player de vídeo
const List<String> _videoIds = [
  'dHuYBB05bYU',
  'RpoFTgWRfJ4',
  '82u-4xcsyJU',
];

// StatefulWidget que cria a lista de vídeos do YouTube
class VideoListPage extends StatefulWidget {
  // Construtor padrão
  const VideoListPage({super.key});

  @override
  State<VideoListPage> createState() => _VideoListPageState();
}

// Estado do StatefulWidget que cria a lista de vídeos do YouTube
class _VideoListPageState extends State<VideoListPage> {
  // Lista de controladores do player de vídeo
  late final List<YoutubePlayerController> _controllers;

  @override
  void initState() {
    super.initState();

    // Cria os controladores do player de vídeo usando a lista de IDs de vídeo
    _controllers = List.generate(
      _videoIds.length,
          (index) => YoutubePlayerController.fromVideoId(
        videoId: _videoIds[index],
        autoPlay: false,
        params: const YoutubePlayerParams(showFullscreenButton: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Cria uma ListView.separated que renderiza uma lista de cartões, cada um contendo um player de vídeo do YouTube
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video List Demo'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: _controllers.length,
        itemBuilder: (context, index) {
          // Obtém o controlador correspondente ao vídeo atual
          final controller = _controllers[index];

          // Renderiza um cartão contendo um player de vídeo do YouTube
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: YoutubePlayer(
                key: ObjectKey(controller),
                aspectRatio: 16 / 9,
                enableFullScreenOnVerticalDrag: false,
                // Define o controlador para o player de vídeo
                controller: controller
                // Define o listener para o botão de tela cheia
                  ..setFullScreenListener(
                        (_) async {
                      final videoData = await controller.videoData;
                      final startSeconds = await controller.currentTime;

                      // Lança a tela cheia do player de vídeo usando FullscreenYoutubePlayer
                      final currentTime = await FullscreenYoutubePlayer.launch(
                        context,
                        videoId: videoData.videoId,
                        startSeconds: startSeconds,
                      );

                      // Se o usuário sair da tela cheia, define a posição do vídeo atual para a posição antes da saída da tela cheia
                      if (currentTime != null) {
                        controller.seekTo(seconds: currentTime);
                      }
                    },
                  ),
              ),
            ),
          );
        },
        separatorBuilder: (context, _) => const SizedBox(height: 16),
      ),
    );
  }

  @override
  void dispose() {
    // Fecha todos os controladores do player de vídeo quando o StatefulWidget é descartado
    for (final controller in _controllers) {
      controller.close();
    }

    super.dispose();
  }
}

