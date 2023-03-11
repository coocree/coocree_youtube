import 'dart:convert';

/// O estado atual do vídeo do Youtube.
/// A classe possui dois campos: position e loadedFraction. position é uma instância de Duration que representa a posição
/// atual do vídeo, enquanto loadedFraction é um double que representa a fração do vídeo que foi carregada.
/// O construtor cria uma nova instância de YoutubeVideoState com valores padrão para position e loadedFraction.
/// O método fromJson é um construtor de fábrica que recebe uma string JSON como entrada e decodifica os valores
/// de currentTime e loadedFraction a partir dele. Em seguida, ele converte o tempo atual em milissegundos
/// e retorna uma nova instância de YoutubeVideoState com os valores atualizados.
class YoutubeVideoState {
  /// A posição atual do vídeo.
  final Duration position;

  /// A fração do vídeo que foi carregada.
  final double loadedFraction;

  /// Cria uma nova instância de [YoutubeVideoState].
  const YoutubeVideoState({
    this.position = Duration.zero,
    this.loadedFraction = 0,
  });

  /// Cria uma nova instância de [YoutubeVideoState] a partir do [json] fornecido.
  factory YoutubeVideoState.fromJson(String json) {
    final state = jsonDecode(json);
    final currentTime = state['currentTime'] as num? ?? 0;
    final loadedFraction = state['loadedFraction'] as num? ?? 0;
    final positionInMs = (currentTime * 1000).truncate();

    return YoutubeVideoState(
      position: Duration(milliseconds: positionInMs),
      loadedFraction: loadedFraction.toDouble(),
    );
  }
}

