// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
/// Metadados para vídeo do Youtube.
class YoutubeMetaData {
  /// ID do vídeo do Youtube do vídeo atualmente carregado.
  final String videoId;

  /// Título do vídeo atualmente carregado.
  final String title;

  /// Nome do canal ou do usuário que enviou o vídeo atualmente carregado.
  final String author;

  /// Duração total do vídeo atualmente carregado.
  final Duration duration;

  /// Cria [YoutubeMetaData] para o vídeo do Youtube.
  const YoutubeMetaData({
    this.videoId = '',
    this.title = '',
    this.author = '',
    this.duration = const Duration(),
  });

  @override
  String toString() {
    return 'YoutubeMetaData('
        'videoId: $videoId, '
        'title: $title, '
        'author: $author, '
        'duration: ${duration.inSeconds} seg.)';
  }
}