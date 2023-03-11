// Copyright 2022 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Estado atual do player.
///
/// Encontre mais informações [aqui](https://developers.google.com/youtube/iframe_api_reference#Playback_status).
enum PlayerState {
  /// Indica o estado quando o player não está carregado com o vídeo.
  unknown(-2),

  /// Indica o estado quando o player carrega o primeiro vídeo.
  unStarted(-1),

  /// Indica o estado quando o player termina de reproduzir um vídeo.
  ended(0),

  /// Indica o estado quando o player está reproduzindo um vídeo.
  playing(1),

  /// Indica o estado quando o player está pausado.
  paused(2),

  /// Indica o estado quando o player está armazenando em buffer bytes da internet.
  buffering(3),

  /// Indica o estado quando o player carrega o vídeo e está pronto para ser reproduzido.
  cued(5);

  /// Retorna o [PlayerState] do código fornecido.
  const PlayerState(this.code);

  /// Código do estado do player.
  final int code;
}

