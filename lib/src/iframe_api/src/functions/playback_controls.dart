/// O esqueleto para métodos de controles de reprodução.
abstract class PlaybackControls {
  /// Reproduz o vídeo atualmente em espera/carregado.
  /// O estado final do player após a execução desta função será reproduzindo (1).
  ///
  /// Uma reprodução só conta para a contagem de visualizações oficiais de um vídeo se for iniciada por um botão de reprodução nativo no player.
  Future<void> playVideo();

  /// Pausa o vídeo atualmente em reprodução.
  /// O estado final do player após a execução desta função será pausado (2)
  /// a menos que o player esteja no estado final (0) quando a função é chamada,
  /// caso em que o estado do player não mudará.
  Future<void> pauseVideo();

  /// Para e cancela o carregamento do vídeo atual.
  /// Esta função deve ser reservada para situações raras em que você sabe que
  /// o usuário não estará assistindo a vídeos adicionais no player.
  /// Se sua intenção é pausar o vídeo, você deve apenas chamar a função [pauseVideo].
  /// Se você deseja mudar o vídeo que o player está reproduzindo,
  /// você pode chamar uma das funções de enfileiramento sem chamar [stopVideo] primeiro.
  ///
  /// Ao contrário da função [pauseVideo], que deixa o player no estado pausado (2),
  /// a função stopVideo poderia colocar o player em qualquer estado que não esteja reproduzindo,
  /// incluindo finalizado (0), pausado (2), vídeo em espera (5) ou não iniciado (-1).
  Future<void> stopVideo();

  /// Vai para um tempo especificado no vídeo.
  /// Se o player estiver pausado quando a função for chamada, ele permanecerá pausado.
  /// Se a função for chamada de outro estado (reproduzindo, vídeo em espera, etc.), o player reproduzirá o vídeo.
  ///
  /// [seconds] identifica o tempo para o qual o player deve avançar.
  /// O player avançará para o quadro-chave mais próximo antes desse tempo, a menos que
  /// o player já tenha baixado a porção do vídeo para a qual o usuário está procurando.
  ///
  /// [allowSeekAhead] determina se o player fará uma nova solicitação ao servidor
  /// se o parâmetro seconds especificar um tempo fora dos dados de vídeo atualmente armazenados em buffer.
  ///
  /// Recomendamos que você defina esse parâmetro como false enquanto o usuário arrasta o mouse
  /// ao longo de uma barra de progresso do vídeo e depois defina-o como true quando o usuário soltar o mouse.
  /// Esta abordagem permite que um usuário role para diferentes pontos de um vídeo
  /// sem solicitar novos fluxos de vídeo ao rolar além de pontos não armazenados em buffer no vídeo.
  /// Quando o usuário solta o botão do mouse, o player avança para o ponto desejado
  /// no vídeo e solicita um novo fluxo de vídeo, se necessário.
  Future<void> seekTo({
    required double seconds,
    bool allowSeekAhead = false,
  });

  /// Esta função carrega e reproduz o próximo vídeo na lista de reprodução.
  Future<void> nextVideo();

  /// Esta função carrega e reproduz o vídeo anterior na lista
  Future<void> previousVideo();

  /// Esta função carrega e reproduz o vídeo especificado na lista de reprodução.
  Future<void> playVideoAt(int index);

  /// Muda o volume do player para mudo.
  Future<void> mute();

  /// Desativa o mudo do player.
  Future<void> unMute();

  /// Define o [volume]. Aceita um valor inteiro entre 0 e 100.
  Future<void> setVolume(int volume);

  /// Retorna verdadeiro se o player estiver em mudo, falso se não estiver.
  Future<bool> get isMuted;

  /// Retorna o volume atual do player, um inteiro entre 0 e 100.
  /// Observe que ele retornará o volume mesmo se o player estiver em mudo.
  Future<int> get volume;
}
