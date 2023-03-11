/// Funções de enfileiramento permitem que você carregue e reproduza um vídeo, uma lista de reprodução ou outra lista de vídeos.
/// Se você estiver usando a sintaxe de objeto descrita abaixo para chamar essas funções,
/// então você também pode enfileirar ou carregar uma lista dos vídeos enviados por um usuário.
abstract class QueueingFunctions {
  /// Esta função carrega a miniatura do vídeo especificado e prepara o player para reproduzir o vídeo.
  /// O player não solicita o FLV até que [playVideo] ou [seekTo] seja chamado.
  ///
  /// [videoId] especifica o ID do vídeo do YouTube a ser reproduzido.
  /// Na API de dados do YouTube, a propriedade id do recurso de vídeo especifica o ID.
  ///
  /// [startSeconds] especifica o tempo a partir do qual o vídeo deve começar a ser reproduzido quando [playVideo] é chamado.
  /// Se você especificar um valor startSeconds e depois chamar [seekTo], então o player começa a reproduzir a partir do tempo especificado na chamada seekTo().
  /// Quando o vídeo está enfileirado e pronto para ser reproduzido, o player transmite um evento de vídeo enfileirado (5).
  ///
  /// [endSeconds] especifica o tempo em que o vídeo deve parar de ser reproduzido quando [playVideo] é chamado.
  /// Se você especificar um valor endSeconds e depois chamar seekTo(), o valor endSeconds não terá mais efeito.
  Future<void> cueVideoById({
    required String videoId,
    double? startSeconds,
    double? endSeconds,
  });

  /// Esta função carrega e reproduz o vídeo especificado.
  ///
  /// [videoId] especifica o ID do vídeo do YouTube a ser reproduzido.
  /// Na API de dados do YouTube, a propriedade id do recurso de vídeo especifica o ID.
  ///
  /// [startSeconds], se especificado, o vídeo começará a partir do quadro-chave mais próximo ao tempo especificado.
  ///
  /// [endSeconds], se especificado, o vídeo será interrompido no tempo especificado.
  Future<void> loadVideoById({
    required String videoId,
    double? startSeconds,
    double? endSeconds,
  });

  /// Adiciona à fila a lista especificada de vídeos.
  /// A lista pode ser uma playlist ou o feed de vídeos enviados pelo usuário.
  ///
  /// Quando a lista é carregada e está pronta para ser reproduzida, o player emitirá um evento de vídeo enfileirado (5).
  ///
  /// [list] contém uma chave que identifica a lista específica de vídeos que o YouTube deve retornar.
  ///
  /// [listType] especifica o tipo de feed de resultados que você está obtendo.
  ///
  /// [index] especifica o índice do primeiro vídeo na lista que será reproduzido.
  /// O parâmetro usa um índice baseado em zero, e o valor padrão do parâmetro é 0,
  /// então o comportamento padrão é carregar e reproduzir o primeiro vídeo da lista.
  ///
  /// [startSeconds] especifica o tempo a partir do qual o primeiro vídeo na lista deve começar a reproduzir quando a função [playVideo] é chamada.
  /// Se você especificar um valor de startSeconds e depois chamar [seekTo], o player reproduzirá a partir do tempo especificado na chamada de [seekTo()].
  /// Se você adicionar uma lista à fila e depois chamar a função [playVideoAt], o player começará a reproduzir no início do vídeo especificado.
  Future<void> cuePlaylist({
    required List<String> list,
    ListType? listType,
    int? index,
    double? startSeconds,
  });

  /// Esta função carrega a lista especificada e a reproduz.
  /// A lista pode ser uma playlist ou o feed de vídeos enviados pelo usuário.
  ///
  /// [list] contém uma chave que identifica a lista específica de vídeos que o YouTube deve retornar.
  ///
  /// [listType] especifica o tipo de feed de resultados que você está obtendo.
  ///
  /// [index] especifica o índice do primeiro vídeo na lista que será reproduzido.
  /// O parâmetro usa um índice baseado em zero, e o valor padrão do parâmetro é 0,
  /// então o comportamento padrão é carregar e reproduzir o primeiro vídeo da lista.
  ///
  /// [startSeconds] especifica o tempo a partir do qual o primeiro vídeo na lista deve começar a reproduzir.
  Future<void> loadPlaylist({
    required List<String> list,
    ListType? listType,
    int? index,
    double? startSeconds,
  });
}

/// O tipo de lista de reprodução.
enum ListType {
  /// A lista especifica o ID da lista de reprodução ou uma matriz de IDs de vídeo.
  /// Na API do YouTube Data, a propriedade id do recurso de lista de reprodução identifica o ID da lista de reprodução,
  /// e a propriedade id do recurso de vídeo especifica um ID de vídeo.
  playlist('playlist'),

  /// A lista identifica o usuário cujos vídeos enviados serão retornados.
  userUploads('user_uploads');

  /// O tipo de lista de reprodução.
  const ListType(this.value);

  /// O valor real do tipo.
  final String value;
}
