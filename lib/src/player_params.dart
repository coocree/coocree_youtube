// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
/// Define os parâmetros do player para o [YoutubePlayer].
class YoutubePlayerParams {
  /// Silencia o player.
  ///
  /// O padrão é false.
  final bool mute;

  /// Especifica o idioma padrão que o player usará para exibir legendas.
  ///
  /// Defina o valor do parâmetro como um código de idioma de duas letras ISO 639-1.
  ///
  /// Isso é ignorado se [enableCaption] for false.
  final String captionLanguage;

  /// Definir o valor do parâmetro como verdadeiro faz com que as legendas ocultas sejam exibidas por padrão, mesmo que o usuário tenha desativado as legendas.
  ///
  /// O padrão é true.
  final bool enableCaption;

  /// Define se o player reage ou não a eventos do ponteiro.
  ///
  /// Veja a documentação da Mozilla para detalhes.
  final PointerEvents pointerEvents;

  /// Especifica a cor que será usada na barra de progresso do vídeo do player para destacar a quantidade de vídeo que o visualizador já viu.
  /// Os valores válidos do parâmetro são vermelho e branco e, por padrão, o player usa a cor vermelha na barra de progresso do vídeo.
  ///
  /// Consulte o blog da API do YouTube para obter mais informações sobre as opções de cores.
  final String color;

  /// Este parâmetro indica se os controles do player são exibidos.
  ///
  /// O padrão é true.
  final bool showControls;

  /// Definir o valor do parâmetro como verdadeiro faz com que o player não responda aos controles do teclado.
  ///
  /// Os controles do teclado atualmente suportados são:
  /// Barra de espaço ou [k]: Reproduzir / Pausar
  /// Seta esquerda: Voltar 5 segundos no vídeo atual
  /// Seta direita: Avançar 5 segundos no vídeo atual
  /// Seta para cima: Aumentar o volume
  /// Seta para baixo: Diminuir o volume
  /// [f]: Alternar exibição em tela cheia
  /// [j]: Voltar 10 segundos no vídeo atual
  /// [l]: Avançar 10 segundos no vídeo atual
  /// [m]: Silenciar ou ativar o som do vídeo
  /// [0-9]: Ir para um ponto no vídeo. 0 vai para o início do vídeo, 1 vai para o ponto 10% do vídeo, 2 vai para o ponto 20% do vídeo e assim por diante.
  ///
  /// O valor padrão é 'true' para a web e 'false' para dispositivos móveis.
  final bool enableKeyboard;

  /// Definir o valor do parâmetro como verdadeiro permite que o player seja controlado por chamadas de API de JavaScript ou IFrame.
  ///
  /// O padrão é verdadeiro.
  final bool enableJavaScript;

  /// Definir esse parâmetro como false impede que o botão de tela cheia seja exibido no player.
  ///
  /// Padrão false.
  final bool showFullscreenButton;

  /// Define o idioma da interface do player.
  /// O valor do parâmetro é um código de idioma de duas letras ISO 639-1 ou um local totalmente especificado.
  ///
  /// Por exemplo, fr e fr-ca são ambos valores válidos. Outros códigos de entrada de idioma, como etiquetas de idioma IETF (BCP 47), também podem ser tratados corretamente.
  ///
  /// O idioma da interface é usado para dicas de ferramentas no player e também afeta a faixa de legenda padrão.
  /// Observe que o YouTube pode selecionar um idioma de faixa de legenda diferente para um usuário específico com base nas preferências individuais de idioma do usuário e na disponibilidade de faixas de legenda.
  final String interfaceLanguage;

  /// Definir o valor do parâmetro como true faz com que as anotações do vídeo sejam exibidas por padrão,
  /// enquanto definir como false faz com que as anotações do vídeo não sejam exibidas por padrão.
  ///
  /// O padrão é verdadeiro.
  final bool showVideoAnnotations;

  /// No caso de um único player de vídeo, a configuração como true faz com que o player reproduza o vídeo inicial repetidamente.
  ///
  /// No caso de um player de lista de reprodução (ou player personalizado), o player reproduz a lista de reprodução inteira e, em seguida, começa novamente no primeiro vídeo.
  ///
  /// O padrão é false.
  final bool loop;

  /// Este parâmetro fornece uma medida de segurança extra para a API IFrame e é suportado apenas para incorporações IFrame.
  ///
  /// Especifique seu domínio como valor.
  final String? origin;

  /// Este parâmetro controla se os vídeos são reproduzidos inline ou em tela cheia em um player HTML5 no iOS.
  ///
  /// O padrão é verdadeiro.
  final bool playsInline;

  /// Habilitar isso garantirá que os vídeos relacionados virão do mesmo canal que o vídeo que acabou de ser reproduzido.
  ///
  /// O padrão é false.
  final bool strictRelatedVideos;

  /// O agente do usuário para o player.
  final String? userAgent;

  /// Define os parâmetros do player para o player do YouTube.
  // mute (mudo): define se o áudio do player estará mudo por padrão. Padrão é false.
  // captionLanguage (idioma da legenda): define o idioma padrão da legenda do player. Padrão é 'en' (inglês).
  // enableCaption (habilitar legenda): define se as legendas estarão habilitadas por padrão. Padrão é true.
  // pointerEvents (eventos do ponteiro): define como os eventos do ponteiro (por exemplo, cliques) serão tratados no player. Padrão é PointerEvents.initial.
  // color (cor): define a cor do player. Padrão é "branco".
  // showControls (mostrar controles): define se os controles do player estarão visíveis por padrão. Padrão é true.
  // enableKeyboard (habilitar teclado): define se o player responderá aos comandos do teclado. O padrão é kIsWeb.
  // enableJavaScript (habilitar JavaScript): define se o JavaScript estará habilitado no player. Padrão é true.
  // showFullscreenButton (mostrar botão de tela cheia): define se o botão de tela cheia será exibido no player. Padrão é false.
  // interfaceLanguage (idioma da interface): define o idioma da interface do player. Padrão é 'en' (inglês).
  // showVideoAnnotations (mostrar anotações do vídeo): define se as anotações do vídeo serão exibidas por padrão. Padrão é true.
  // loop (repetir): define se o player repetirá automaticamente o vídeo. Padrão é false.
  // origin (origem): fornece uma medida de segurança extra para a API IFrame. O padrão é 'https://www.youtube.com'.
  // playsInline (reproduzir em linha): define se o vídeo será reproduzido em linha ou em tela cheia no iOS. Padrão é true.
  // strictRelatedVideos (vídeos relacionados estritos): define se os vídeos relacionados serão do mesmo canal que o vídeo atual. Padrão é false.
  // userAgent (agente do usuário): define o agente do usuário para o player.
  const YoutubePlayerParams({
    this.mute = false,
    this.captionLanguage = 'en',
    this.enableCaption = true,
    this.pointerEvents = PointerEvents.initial,
    this.color = 'white',
    this.showControls = true,
    this.enableKeyboard = kIsWeb,
    this.enableJavaScript = true,
    this.showFullscreenButton = false,
    this.interfaceLanguage = 'en',
    this.showVideoAnnotations = true,
    this.loop = false,
    this.origin = 'https://www.youtube.com',
    this.playsInline = true,
    this.strictRelatedVideos = false,
    this.userAgent,
  });

  /// Cria uma representação em [Map] dos [YoutubePlayerParams].
  Map<String, dynamic> toMap() {
    return {
      'autoplay': 1,
      'mute': _boolean(mute),
      'cc_lang_pref': captionLanguage,
      'cc_load_policy': _boolean(enableCaption),
      'color': color,
      'controls': _boolean(showControls),
      'disablekb': _boolean(!enableKeyboard),
      'enablejsapi': _boolean(enableJavaScript),
      'fs': _boolean(showFullscreenButton),
      'hl': interfaceLanguage,
      'iv_load_policy': showVideoAnnotations ? 1 : 3,
      'loop': _boolean(loop),
      'modestbranding': '1',
      if (origin != null && !kIsWeb) 'origin': origin,
      'playsinline': _boolean(playsInline),
      'rel': _boolean(!strictRelatedVideos),
    };
  }

  /// A representação JSON serializada dos [YoutubePlayerParams].
  String toJson() => jsonEncode(toMap());

  int _boolean(bool value) => value ? 1 : 0;
}
/// Os eventos do ponteiro.
enum PointerEvents {
  /// O player reage a eventos de ponteiro, como hover e clique.
  auto('auto'),

  /// A configuração inicial para eventos de ponteiro.
  ///
  /// Na maioria dos casos, isso se resolve para [PointerEvents.auto].
  initial('initial'),

  /// O player não reage a nenhum evento de ponteiro.
  none('none');

  /// Cria um [PointerEvents] para o [name].
  const PointerEvents(this.name);

  /// O nome do [PointerEvents].
  final String name;
}