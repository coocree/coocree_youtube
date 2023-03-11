import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:url_launcher/url_launcher.dart' as uri_launcher;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:youtube_player_iframe/src/iframe_api/src/functions/video_information.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'youtube_player_event_handler.dart';

/// The Web Resource Error.
typedef YoutubeWebResourceError = WebResourceError;

/// Controls the youtube player, and provides updates when the state is changing.
///
/// The video is displayed in a Flutter app by creating a [YoutubePlayer] widget.
///
/// After [YoutubePlayerController.close] all further calls are ignored.
class YoutubePlayerController implements YoutubePlayerIFrameAPI {
  /// Cria um [YoutubePlayerController].
  ///
  /// O parâmetro `params` é usado para especificar as configurações do player de vídeo.
  /// O parâmetro `onWebResourceError` é um `ValueChanged` que será chamado se houver um erro de recurso da web ao carregar a página do YouTube.
  YoutubePlayerController({
    this.params = const YoutubePlayerParams(),
    ValueChanged<YoutubeWebResourceError>? onWebResourceError,
  }) {
    _eventHandler = YoutubePlayerEventHandler(this);

    // Determina qual plataforma WebView está sendo usada e define os parâmetros adequados para a criação do WebViewController.
    late final PlatformWebViewControllerCreationParams webViewParams;

    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      webViewParams = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      webViewParams = const PlatformWebViewControllerCreationParams();
    }

    // Cria um delegate de navegação que será usado para manipular solicitações de navegação e erros de recursos da web.
    final navigationDelegate = NavigationDelegate(
      onWebResourceError: (error) {
        log(error.description, name: error.errorType.toString());
        onWebResourceError?.call(error);
      },
      onNavigationRequest: (request) {
        final uri = Uri.tryParse(request.url);
        return _decideNavigation(uri);
      },
    );

    // Cria um WebViewController e configura-o com os parâmetros e delegate apropriados.
    webViewController = WebViewController.fromPlatformCreationParams(webViewParams)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(navigationDelegate)
      ..setUserAgent(params.userAgent)
      ..addJavaScriptChannel(
        _youtubeJSChannelName,
        onMessageReceived: _eventHandler,
      )
      ..enableZoom(false);

    // Define as configurações de plataforma específicas para o WebView, se aplicável.
    final webViewPlatform = webViewController.platform;
    if (webViewPlatform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(false);
      webViewPlatform.setMediaPlaybackRequiresUserGesture(false);
    } else if (webViewPlatform is WebKitWebViewController) {
      webViewPlatform.setAllowsBackForwardNavigationGestures(false);
    }
  }

  /// Creates a [YoutubePlayerController] and initializes the player with [videoId].
  factory YoutubePlayerController.fromVideoId({
    required String videoId,
    YoutubePlayerParams params = const YoutubePlayerParams(),
    bool autoPlay = false,
    double? startSeconds,
    double? endSeconds,
  }) {
    // Cria uma nova instância do YoutubePlayerController com os parâmetros especificados.
    final controller = YoutubePlayerController(params: params);

    // Carrega ou adiciona o vídeo ao player, dependendo do valor do parâmetro autoPlay.
    if (autoPlay) {
      controller.loadVideoById(
        videoId: videoId,
        startSeconds: startSeconds,
        endSeconds: endSeconds,
      );
    } else {
      controller.cueVideoById(
        videoId: videoId,
        startSeconds: startSeconds,
        endSeconds: endSeconds,
      );
    }

    return controller;
  }

  // Define o nome do canal JavaScript usado para se comunicar com o player do YouTube.
  final String _youtubeJSChannelName = 'YoutubePlayer';

  /// Define os parâmetros do player para o vídeo do YouTube.
  final YoutubePlayerParams params;

  /// O [WebViewController] que controla o player.
  @internal
  late final WebViewController webViewController;

  // Instancia um objeto [YoutubePlayerEventHandler] que gerencia eventos do player do YouTube.
  late final YoutubePlayerEventHandler _eventHandler;

  // Um [Completer] usado para indicar se a inicialização do player está completa.
  final Completer<void> _initCompleter = Completer();

  // Um [StreamController] usado para transmitir o valor atual do player.
  final StreamController<YoutubePlayerValue> _valueController = StreamController.broadcast();

  // O valor atual do player.
  YoutubePlayerValue _value = YoutubePlayerValue();

  // Um stream de [YoutubePlayerValue], que permite se inscrever para receber atualizações no valor do controlador.
  Stream<YoutubePlayerValue> get stream => _valueController.stream;

// O [YoutubePlayerValue] do controlador.
  YoutubePlayerValue get value => _value;

  /// Carrega uma lista de reprodução ou uma lista de vídeos pelos seus IDs, com o índice de início e o tempo de início.
  @override
  Future<void> cuePlaylist({
    required List<String> list,
    ListType? listType,
    int? index,
    double? startSeconds,
  }) {
    return _run(
      'cuePlaylist',
      data: {
        list.length == 1 ? 'list' : 'playlist': list,
        'listType': listType?.value,
        'index': index,
        'startSeconds': startSeconds,
      },
    );
  }

  /// Sobrescreve o método cueVideoById para tocar o vídeo pelo seu ID sem reprodução.
  @override
  Future<void> cueVideoById({
    required String videoId,
    double? startSeconds,
    double? endSeconds,
  }) {
    return _run(
      'cueVideoById',
      data: {
        'videoId': videoId,
        'startSeconds': startSeconds,
        'endSeconds': endSeconds,
      },
    );
  }

  /// Sobrescreve o método cueVideoByUrl para tocar o vídeo pela sua URL sem reprodução.
  @override
  Future<void> cueVideoByUrl({
    required String mediaContentUrl,
    double? startSeconds,
    double? endSeconds,
  }) {
    return _run(
      'cueVideoByUrl',
      data: {
        'mediaContentUrl': mediaContentUrl,
        'startSeconds': startSeconds,
        'endSeconds': endSeconds,
      },
    );
  }

  /// Sobrescreve o método loadPlaylist para carregar a lista de reprodução do YouTube.
  @override
  Future<void> loadPlaylist({
    required List<String> list,
    ListType? listType,
    int? index,
    double? startSeconds,
  }) {
    return _run(
      'loadPlaylist',
      data: {
        list.length == 1 ? 'list' : 'playlist': list,
        'listType': listType?.value,
        'index': index,
        'startSeconds': startSeconds,
      },
    );
  }

  /// Sobrescreve o método loadVideoById para carregar e tocar o vídeo pelo seu ID.
  @override
  Future<void> loadVideoById({
    required String videoId,
    double? startSeconds,
    double? endSeconds,
  }) {
    return _run(
      'loadVideoById',
      data: {
        'videoId': videoId,
        'startSeconds': startSeconds,
        'endSeconds': endSeconds,
      },
    );
  }

  /// Sobrescreve o método loadVideoByUrl para carregar e tocar o vídeo pela sua URL.
  @override
  Future<void> loadVideoByUrl({
    required String mediaContentUrl,
    double? startSeconds,
    double? endSeconds,
  }) {
    return _run(
      'loadVideoByUrl',
      data: {
        'mediaContentUrl': mediaContentUrl,
        'startSeconds': startSeconds,
        'endSeconds': endSeconds,
      },
    );
  }

  /// Carrega um vídeo do Youtube através de uma URL.
  ///
  /// The [url] must be a valid youtube video watch url.
  /// i.e. https://www.youtube.com/watch?v=VIDEO_ID
  Future<void> loadVideo(String url) {
    assert(
      RegExp(r'^https://(?:www\.|m\.)?youtube\.com/watch.*').hasMatch(url),
      'Only YouTube watch URLs are supported.',
    );

    final params = Uri.parse(url).queryParameters;
    final videoId = params['v'];

    assert(
      videoId != null && videoId.isNotEmpty,
      'Video ID is missing from the provided url.',
    );

    return loadVideoById(
      videoId: videoId!,
      startSeconds: double.tryParse(params['t'] ?? ''),
    );
  }

  /// Inicializa o player com os parâmetros padrões [params].
  @internal
  Future<void> init() async {
    await load(params: params, baseUrl: params.origin);

    if (!_initCompleter.isCompleted) _initCompleter.complete();
  }

  /// Carrega o player com os parâmetros fornecidos em [params].
  ///
  /// [baseUrl] define a origem do player.
  Future<void> load({
    required YoutubePlayerParams params,
    String? baseUrl,
  }) async {
    final playerHtml = await rootBundle.loadString('packages/youtube_player_iframe/assets/player.html');

    final platform = kIsWeb ? 'web' : defaultTargetPlatform.name.toLowerCase();

    print('params ${params.pointerEvents.name}');
    print('params ${params.toJson()}');
    print('params ${platform}');
    print('params ${params.origin}');

    await webViewController.loadHtmlString(
      playerHtml
          .replaceFirst('<<pointerEvents>>', params.pointerEvents.name)
          .replaceFirst('<<playerVars>>', params.toJson())
          .replaceFirst('<<platform>>', platform)
          .replaceFirst('<<host>>', params.origin ?? 'https://www.youtube.com'),
      baseUrl: baseUrl,
    );
  }

  /// Executa uma função Javascript de nome [functionName] no player iframe.
  /// Aceita argumentos em forma de mapa com string e dinâmico.
  /// Essa função espera até que o player esteja inicializado antes de executar a função
  Future<void> _run(
    String functionName, {
    Map<String, dynamic>? data,
  }) async {
    await _initCompleter.future;

    final varArgs = await _prepareData(data);

    return webViewController.runJavaScript('player.$functionName($varArgs);');
  }

  /// Executa uma função Javascript de nome [functionName] no player iframe e retorna o resultado como uma String.
  /// Aceita argumentos em forma de mapa com string e dinâmico.
  /// Essa função espera até que o player esteja inicializado antes de executar a função Javascript.
  Future<String> _runWithResult(
    String functionName, {
    Map<String, dynamic>? data,
  }) async {
    await _initCompleter.future;

    final varArgs = await _prepareData(data);

    final result = await webViewController.runJavaScriptReturningResult(
      'player.$functionName($varArgs);',
    );
    return result.toString();
  }

  /// Executa um script Javascript.
  /// Essa função espera até que o player esteja inicializado antes de executar o script Javascript.
  Future<void> _eval(String javascript) async {
    await _eventHandler.isReady;

    return webViewController.runJavaScript(javascript);
  }

  /// Executa um script Javascript e retorna um resultado.
  /// Essa função espera até que o player esteja inicializado antes de executar o script Javascript.
  Future<String> _evalWithResult(String javascript) async {
    await _eventHandler.isReady;

    final result = await webViewController.runJavaScriptReturningResult(
      javascript,
    );

    return result.toString();
  }

  /// Prepara um mapa de argumentos em formato string e dinâmico para serem passados para as funções Javascript.
  /// Essa função espera até que o player esteja inicializado antes de executar o script Javascript.
  Future<String> _prepareData(Map<String, dynamic>? data) async {
    await _eventHandler.isReady;
    return data == null ? '' : jsonEncode(data);
  }

  /// Retorna os metadados do vídeo atualmente carregado ou em fila.
  YoutubeMetaData get metadata => _value.metaData;

  /// Cria um novo [YoutubePlayerValue] com os parâmetros atribuídos e sobrescreve
  /// o antigo.
  void update({
    FullScreenOption? fullScreenOption,
    PlayerState? playerState,
    double? playbackRate,
    String? playbackQuality,
    YoutubeError? error,
    YoutubeMetaData? metaData,
  }) {
    final updatedValue = YoutubePlayerValue(
      fullScreenOption: fullScreenOption ?? value.fullScreenOption,
      playerState: playerState ?? value.playerState,
      playbackRate: playbackRate ?? value.playbackRate,
      playbackQuality: playbackQuality ?? value.playbackQuality,
      error: error ?? value.error,
      metaData: metaData ?? value.metaData,
    );

    _valueController.add(updatedValue);
  }

  /// Escute as atualizações no [YoutubePlayerController].
  StreamSubscription<YoutubePlayerValue> listen(
    void Function(YoutubePlayerValue event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _valueController.stream.listen(
      (value) {
        _value = value;
        onData?.call(value);
      },
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  /// Converte uma URL totalmente qualificada do YouTube para um ID de vídeo.
  ///
  /// Se o videoId for passado como url, nenhuma conversão será feita.
  static String? convertUrlToId(String url, {bool trimWhitespaces = true}) {
    if (!url.contains("http") && (url.length == 11)) return url;
    if (trimWhitespaces) url = url.trim();

    const contentUrlPattern = r'^https:\/\/(?:www\.|m\.)?youtube\.com\/watch\?';
    const embedUrlPattern = r'^https:\/\/(?:www\.|m\.)?youtube(?:-nocookie)?\.com\/embed\/';
    const altUrlPattern = r'^https:\/\/youtu\.be\/';
    const shortsUrlPattern = r'^https:\/\/(?:www\.|m\.)?youtube\.com\/shorts\/';
    const musicUrlPattern = r'^https:\/\/(?:music\.)?youtube\.com\/watch\?';
    const idPattern = r'([_\-a-zA-Z0-9]{11}).*$';

    for (var regex in [
      '${contentUrlPattern}v=$idPattern',
      '$embedUrlPattern$idPattern',
      '$altUrlPattern$idPattern',
      '$shortsUrlPattern$idPattern',
      '$musicUrlPattern?v=$idPattern',
    ]) {
      Match? match = RegExp(regex).firstMatch(url);
      if (match != null && match.groupCount >= 1) return match.group(1);
    }

    return null;
  }

  /// Obtém a miniatura do vídeo do YouTube para o ID do vídeo fornecido.
  ///
  /// Se [webp] for verdadeiro, a versão webp da miniatura será recuperada,
  /// caso contrário, uma miniatura JPG.
  static String getThumbnail({
    required String videoId,
    String quality = ThumbnailQuality.standard,
    bool webp = true,
  }) {
    return webp ? 'https://i3.ytimg.com/vi_webp/$videoId/$quality.webp' : 'https://i3.ytimg.com/vi/$videoId/$quality.jpg';
  }

  /// Obtém a duração do vídeo atualmente carregado ou enfileirado no player do YouTube.
  /// Retorna um [Future] que contém a duração do vídeo como um [double].
  @override
  Future<double> get duration async {
    final duration = await _runWithResult('getDuration');
    return double.tryParse(duration) ?? 0;
  }

  /// Obtém a lista de reprodução do player.
  @override
  Future<List<String>> get playlist async {
    final playlist = await _evalWithResult('getPlaylist()');

    return List.from(jsonDecode(playlist));
  }

  /// Retorna um [Future] que retorna o índice do item atualmente reproduzido na playlist.
  @override
  Future<int> get playlistIndex async {
    final index = await _runWithResult('getPlaylistIndex');

    return int.tryParse(index) ?? 0;
  }

  @override
  Future<VideoData> get videoData async {
    /// Obtém os dados do vídeo atual do player.
    final videoData = await _evalWithResult('getVideoData()');

    return VideoData.fromMap(jsonDecode(videoData));
  }

  @override
  Future<String> get videoEmbedCode {
    /// Obtém o código de incorporação do vídeo atual.
    return _runWithResult('getVideoEmbedCode');
  }

  @override
  Future<String> get videoUrl async {
    /// Obtém a URL do vídeo atual.
    final videoUrl = await _runWithResult('getVideoUrl');

    if (videoUrl.startsWith('"')) {
      return videoUrl.substring(1, videoUrl.length - 1);
    }

    return videoUrl;
  }

  @override
  Future<List<double>> get availablePlaybackRates async {
    /// Obtém as taxas de reprodução disponíveis do vídeo.
    final rates = await _evalWithResult('getAvailablePlaybackRates()');

    return List<num>.from(jsonDecode(rates)).map((r) => r.toDouble()).toList(growable: false);
  }

  @override
  Future<double> get playbackRate async {
    /// Obtém a taxa de reprodução atual do vídeo.
    final rate = await _runWithResult('getPlaybackRate');
    return double.tryParse(rate) ?? 0;
  }

  @override
  Future<void> setLoop({required bool loopPlaylists}) {
    /// Define se o player deve repetir o playlist atual.
    return _eval('player.setLoop($loopPlaylists)');
  }

  @override
  Future<void> setPlaybackRate(double suggestedRate) {
    /// Define a taxa de reprodução sugerida para o vídeo.
    return _eval('player.setPlaybackRate($suggestedRate)');
  }

  @override
  Future<void> setShuffle({required bool shufflePlaylists}) {
    // Define aleatoriedade na reprodução de listas de vídeos.
    return _eval('player.setShuffle($shufflePlaylists)');
  }

  @override
  Future<void> setSize(double width, double height) {
    // Define a largura e altura da janela de reprodução.
    return _eval('player.setSize($width, $height)');
  }

  @override
  Future<bool> get isMuted async {
    // Verifica se o player está no modo mudo.
    final isMuted = await _runWithResult('isMuted');
    return isMuted == '1';
  }

  @override
  Future<void> mute() {
    // Coloca o player no modo mudo.
    return _run('mute');
  }

  @override
  Future<void> nextVideo() {
    // Reproduz o próximo vídeo da lista de reprodução.
    return _run('nextVideo');
  }

  @override
  Future<void> pauseVideo() {
    // Pausa a reprodução do vídeo atual.
    return _run('pauseVideo');
  }

  @override
  Future<void> playVideo() {
    // Inicia a reprodução do vídeo atual.
    return _run('playVideo');
  }

  @override
  Future<void> myFunction() {
    // Chama a função myFunction() do player.
    _eval('myPlayer.myFunction()');
    return _run('myFunction');
  }

  @override
  Future<void> playVideoAt(int index) {
    // Reproduz o vídeo da lista de reprodução no índice especificado.
    return _eval('player.playVideoAt($index)');
  }

  @override
  Future<void> previousVideo() {
    // Reproduz o vídeo anterior da lista de reprodução.
    return _run('previousVideo');
  }

  @override
  Future<void> seekTo({required double seconds, bool allowSeekAhead = false}) {
    // Move a posição de reprodução do vídeo para o tempo especificado.
    return _eval('player.seekTo($seconds, $allowSeekAhead)');
  }

  @override
  Future<void> setVolume(int volume) {
    // Define o volume de reprodução do vídeo.
    return _eval('player.setVolume($volume)');
  }

  @override
  Future<void> stopVideo() {
    // Para a reprodução do vídeo atual.
    return _run('stopVideo');
  }

  @override
  Future<void> unMute() {
    // Cancela o modo mudo do player.
    return _run('unMute');
  }

  @override
  Future<int> get volume async {
    // Obtém o volume atual de reprodução do vídeo.
    final volume = await _runWithResult('getVolume');

    return int.tryParse(volume) ?? 0;
  }

  @override
  Future<double> get currentTime async {
    // Obtém a hora atual do vídeo usando o método "_runWithResult", que não está definido aqui.
    final time = await _runWithResult('getCurrentTime');

    // Retorna a hora atual como um número de ponto flutuante, ou 0 se não foi possível convertê-la.
    return double.tryParse(time) ?? 0;
  }

  @override
  Future<PlayerState> get playerState async {
    // Obtém o estado atual do player usando o método "_runWithResult", que não está definido aqui.
    final stateCode = await _runWithResult('getPlayerState');

    // Retorna o estado atual do player como um valor da enumeração "PlayerState".
    return PlayerState.values.firstWhere(
      (state) => state.code.toString() == stateCode,
      orElse: () => PlayerState.unknown,
    );
  }

  @override
  Future<double> get videoLoadedFraction async {
    // Obtém a fração do vídeo carregada usando o método "_runWithResult", que não está definido aqui.
    final loadedFraction = await _runWithResult('getVideoLoadedFraction');

    // Retorna a fração do vídeo carregada como um número de ponto flutuante entre 0 e 1, ou 0 se não foi possível convertê-la.
    return double.tryParse(loadedFraction) ?? 0;
  }

  /// Entra no modo de tela cheia.
  ///
  /// Se [lock] for verdadeiro, a rotação automática será desativada.
  void enterFullScreen({bool lock = true}) {
    update(fullScreenOption: FullScreenOption(enabled: true, locked: lock));
    _onFullscreenChanged?.call(true);
  }

  /// Sai do modo de tela cheia.
  ///
  /// Se [lock] for verdadeiro, a rotação automática será desativada.
  void exitFullScreen({bool lock = true}) {
    update(fullScreenOption: FullScreenOption(enabled: false, locked: lock));
    _onFullscreenChanged?.call(false);
  }

  ValueChanged<bool>? _onFullscreenChanged;

  /// Define o ouvinte para o modo de tela cheia.
// ignore: use_setters_to_change_properties
  void setFullScreenListener(ValueChanged<bool> callback) {
    _onFullscreenChanged = callback;
  }

  /// Chamado quando o modo de tela cheia do player muda.
  @Deprecated('Use setFullScreenListener instead')
  void Function(bool isFullscreen) onFullscreenChange = (_) {};

  /// Alterna o modo de tela cheia.
  ///
  /// Se [lock] for verdadeiro, a rotação automática será desativada.
  void toggleFullScreen({bool lock = true}) {
    if (value.fullScreenOption.enabled) {
      exitFullScreen(lock: lock);
    } else {
      enterFullScreen(lock: lock);
    }
  }

  /// Fluxo de mudanças de estado do [YoutubeVideoState].
  Stream<YoutubeVideoState> get videoStateStream {
    return _eventHandler.videoStateController.stream;
  }

  /// Cria um fluxo que emite repetidamente a hora atual em intervalos de [period].
  @Deprecated('Use videoStateStream instead')
  Stream<Duration> getCurrentPositionStream({
    // Não utilizado
    Duration period = const Duration(seconds: 1),
  }) {
    return videoStateStream.map((state) => state.position);
  }

  NavigationDecision _decideNavigation(Uri? uri) {
    // Se a URL for nula, impede a navegação.
    if (uri == null) return NavigationDecision.prevent;

    // Obtém os parâmetros da consulta, o host e o caminho da URL.
    final params = uri.queryParameters;
    final host = uri.host;
    final path = uri.path;

    // Define o nome do recurso a ser carregado, com base no host, nos parâmetros ou no caminho da URL.
    String? featureName;
    if (host.contains('facebook') || host.contains('twitter') || host == 'youtu') {
      featureName = 'social';
    } else if (params.containsKey('feature')) {
      featureName = params['feature'];
    } else if (path == '/watch') {
      featureName = 'emb_info';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return NavigationDecision.navigate;
    }

    // Verifica qual recurso deve ser carregado com base no nome do recurso definido anteriormente.
    switch (featureName) {
      case 'emb_rel_pause':
      case 'emb_rel_end':
      case 'emb_info':
        // Obtém o ID do vídeo dos parâmetros da consulta e o carrega.
        final videoId = params['v'];
        if (videoId != null) loadVideoById(videoId: videoId);
        break;
      case 'emb_logo':
      case 'social':
      case 'wl_button':
        // Abre a URL com o pacote uri_launcher.
        uri_launcher.launchUrl(uri);
        break;
    }

    // Impede a navegação.
    return NavigationDecision.prevent;
  }

  /// Disposes the resources created by [YoutubePlayerController].
  Future<void> close() async {
    // Para o vídeo atual.
    await stopVideo();

    // Remove o canal JavaScript usado para a comunicação com o player de vídeo.
    await webViewController.removeJavaScriptChannel(_youtubeJSChannelName);

    // Fecha o controlador de estado do vídeo.
    await _eventHandler.videoStateController.close();

    // Fecha o controlador de valores.
    await _valueController.close();
  }
}
