import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// O esqueleto para obter informações de vídeo.
abstract class VideoInformation {
  /// Retorna a duração em segundos do vídeo atualmente reproduzido.
  /// Observe que [duration] retornará 0 até que os metadados do vídeo sejam carregados,
  /// o que normalmente acontece logo após o início da reprodução do vídeo.
  ///
  /// Se o vídeo atualmente reproduzido for um evento ao vivo,
  /// a [duration] retornará o tempo decorrido desde o início da transmissão ao vivo do vídeo.
  /// Especificamente, este é o tempo que o vídeo foi transmitido sem ser redefinido ou interrompido.
  /// Além disso, essa duração é comumente maior que o tempo real do evento, pois a transmissão pode começar antes do horário de início do evento.
  Future<double> get duration;

  /// Retorna a URL do YouTube.com para o vídeo atualmente carregado/reproduzido.
  Future<String> get videoUrl;

  /// Retorna o [VideoData] para o vídeo atualmente carregado/reproduzido.
  Future<VideoData> get videoData;

  /// Retorna o código de incorporação para o vídeo atualmente carregado/reproduzido.
  Future<String> get videoEmbedCode;

  /// Esta função retorna uma lista dos IDs de vídeo na playlist na ordem atual.
  /// Por padrão, esta função retornará os IDs de vídeo na ordem designada pelo proprietário da playlist.
  ///
  /// No entanto, se você chamou o [YoutubePlayerController.setShuffle] para embaralhar a ordem da playlist,
  /// então o valor de retorno refletirá a ordem embaralhada.
  Future<List<String>> get playlist;

  /// Esta função retorna o índice do vídeo da playlist que está sendo reproduzido no momento.
  Future<int> get playlistIndex;
}

/// Os dados do vídeo para o vídeo atualmente carregado/reproduzido.
class VideoData {
  /// Cria [VideoData].
  const VideoData({
    required this.videoId,
    required this.author,
    required this.title,
    required this.videoQuality,
    required this.videoQualityFeatures,
  });

  /// O id do vídeo do YouTube para o vídeo.
  final String videoId;

  /// O nome do canal do vídeo.
  final String author;

  /// O título do vídeo.
  final String title;

  /// A qualidade de reprodução do vídeo.
  final String videoQuality;

  /// Os recursos de qualidade do vídeo.
  final List<Object> videoQualityFeatures;

  /// Cria [VideoData] a partir do [map].
  factory VideoData.fromMap(Map<String, dynamic> map) {
    return VideoData(
      videoId: map['video_id'] ?? '',
      author: map['author'] ?? '',
      title: map['title'] ?? '',
      videoQuality: map['videoQuality'] ?? '',
      videoQualityFeatures: List.from(map['videoQualityFeatures'] ?? []),
    );
  }
}
