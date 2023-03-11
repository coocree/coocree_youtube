import 'package:youtube_player_iframe/src/enums/player_state.dart';

/// O esqueleto para métodos de status de reprodução.
abstract class PlaybackStatus {
  /// Retorna um número entre 0 e 1 que especifica a porcentagem do vídeo que o player mostra como bufferizado.
  Future<double> get videoLoadedFraction;

  /// Retorna o estado do player.
  Future<PlayerState> get playerState;

  /// Retorna o tempo decorrido em segundos desde o início da reprodução do vídeo.
  Future<double> get currentTime;
}
