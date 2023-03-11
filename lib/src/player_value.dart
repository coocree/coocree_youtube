// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'enums/playback_rate.dart';
import 'enums/player_state.dart';
import 'enums/youtube_error.dart';
import 'meta_data.dart';

/// Valor do player do YouTube.
class YoutubePlayerValue {
  /// A duração, posição atual, estado de buffer, estado de erro e configurações
  /// de um [YoutubePlayerController].
  YoutubePlayerValue({
    this.fullScreenOption = const FullScreenOption(enabled: false),
    this.playerState = PlayerState.unknown,
    this.playbackRate = PlaybackRate.normal,
    this.playbackQuality,
    this.error = YoutubeError.none,
    this.metaData = const YoutubeMetaData(),
  });

  /// A opção inicial de tela cheia.
  final FullScreenOption fullScreenOption;

  /// O estado atual do player definido como [PlayerState].
  final PlayerState playerState;

  /// A taxa atual de reprodução do vídeo definida como [PlaybackRate].
  final double playbackRate;

  /// Reporta o código de erro conforme descrito aqui.
  ///
  /// Consulte a seção onError.
  final YoutubeError error;

  /// Retorna true se o player tiver erros.
  bool get hasError => error != YoutubeError.none;

  /// Reporta a qualidade atual da reprodução do vídeo.
  final String? playbackQuality;

  /// Retorna metadados do vídeo carregado/reproduzido atualmente.
  final YoutubeMetaData metaData;

  @override
  String toString() {
    return '$runtimeType('
        'metaData: ${metaData.toString()}, '
        'playerState: $playerState, '
        'playbackRate: $playbackRate, '
        'playbackQuality: $playbackQuality, '
        'isFullScreen: ${fullScreenOption.enabled}, '
        'error: $error)';
  }
}

/// A opção de tela cheia.
class FullScreenOption {
  /// Cria [FullScreenOption].
  const FullScreenOption({
    required this.enabled,
    this.locked = false,
  });

  /// Indica se o modo de tela cheia está atualmente habilitado.
  final bool enabled;

  /// Indica se o modo de tela cheia está atualmente bloqueado para atualização automática.
  final bool locked;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is FullScreenOption && runtimeType == other.runtimeType && enabled == other.enabled && locked == other.locked;
  }

  @override
  int get hashCode => enabled.hashCode ^ locked.hashCode;
}
