/// O esqueleto para os métodos de configurações do player.
abstract class PlayerSettings {
  /// Define o tamanho em pixels do <iframe> que contém o player.
  void setSize(double width, double height);

  /// Este método define a taxa de reprodução sugerida para o vídeo atual.
  /// Se a taxa de reprodução for alterada, ela só será alterada para o vídeo que já está em reprodução ou em espera.
  /// Se você definir a taxa de reprodução para um vídeo em espera, essa taxa ainda estará em vigor quando a função playVideo for chamada
  /// ou o usuário inicie a reprodução diretamente pelos controles do player.
  /// Além disso, chamar funções para reproduzir ou carregar vídeos ou listas de reprodução (cueVideoById, loadVideoById, etc.)
  /// redefinirá a taxa de reprodução para 1.
  ///
  /// Chamar esta função não garante que a taxa de reprodução realmente será alterada.
  /// No entanto, se a taxa de reprodução mudar, o evento onPlaybackRateChange será acionado
  /// e seu código deve responder ao evento em vez de responder ao fato de que ele chamou a função [setPlaybackRate].
  void setPlaybackRate(double suggestedRate);

  /// Este método indica se o player deve continuar reproduzindo uma lista de reprodução continuamente
  /// ou se deve parar de reproduzir após o término do último vídeo da lista de reprodução.
  /// O comportamento padrão é que as listas de reprodução não sejam cíclicas.
  ///
  /// Essa configuração persistirá mesmo que você carregue ou coloque em espera uma lista de reprodução diferente,
  /// o que significa que se você carregar uma lista de reprodução, chame a função setLoop com um valor true
  /// e depois carregar uma segunda lista de reprodução, a segunda lista também será cíclica.
  ///
  /// Se [loopPlaylists] for verdadeiro, o player de vídeo continuará reproduzindo listas de reprodução continuamente.
  /// Após a reprodução do último vídeo de uma lista de reprodução, o player de vídeo voltará ao início
  /// da lista de reprodução e a reproduzirá novamente.
  void setLoop({required bool loopPlaylists});

  /// Este método indica se os vídeos da lista de reprodução devem ser embaralhados para que
  /// sejam reproduzidos em uma ordem diferente da que o criador da lista de reprodução designou.
  /// Se você embaralhar uma lista de reprodução depois que ela já começou a ser reproduzida,
  /// a lista será reordenada enquanto o vídeo que está sendo reproduzido continua a ser reproduzido.
  /// O próximo vídeo que será reproduzido será selecionado com base na lista reordenada.
  ///
  /// Essa configuração não persistirá se você carregar ou colocar em espera uma lista de reprodução diferente,
  /// o que significa que se você carregar uma lista de reprodução, chame a função setShuffle,
  /// e depois carregar uma segunda lista de reprodução, a segunda lista não será embaralhada.
  ///
  /// Se [shufflePlaylists] for verdadeiro, o YouTube embaralhará a ordem da lista de reprodução.
  /// Se você instruir o método a embaralhar uma lista de reprodução que já foi embaralhada,
  /// Define o embaralhamento do conteúdo da lista de reprodução.
  void setShuffle({required bool shufflePlaylists});

  /// Recupera a taxa de reprodução atual do vídeo em reprodução.
  /// A taxa padrão de reprodução é 1, que indica que o vídeo está sendo reproduzido na velocidade normal.
  ///
  /// As taxas de reprodução podem incluir valores como 0,25, 0,5, 1, 1,5 e 2.
  Future<double> get playbackRate;

  /// Retorna o conjunto de taxas de reprodução em que o vídeo atual está disponível.
  /// O valor padrão é 1, o que indica que o vídeo está sendo reproduzido na velocidade normal.
  ///
  /// A função retorna uma matriz de números ordenados da velocidade de reprodução mais lenta para a mais rápida.
  /// Mesmo que o player não suporte taxas de reprodução variáveis, a matriz deve sempre conter pelo menos um valor (1).
  Future<List<double>> get availablePlaybackRates;
}
