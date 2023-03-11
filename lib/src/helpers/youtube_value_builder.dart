// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

import '../controller/youtube_player_controller.dart';
import '../player_value.dart';
import 'youtube_value_provider.dart';

/// Widget que constrói a si mesmo com base na última captura de interação com um [YoutubePlayerController].
class YoutubeValueBuilder extends StatefulWidget {
  /// O [YoutubePlayerController].
  final YoutubePlayerController? controller;

  /// Estratégia de construção para o widget.
  final Widget Function(BuildContext, YoutubePlayerValue) builder;

  /// [buildWhen] será invocado em cada mudança de valor do value do [controller].
  /// [buildWhen] pega o valor anterior e atual do value e deve
  /// retornar um [bool] que determina se a função [builder] será
  /// invocada ou não.
  ///
  /// [buildWhen] é opcional e, se omitido, será verdadeiro.
  final bool Function(YoutubePlayerValue, YoutubePlayerValue)? buildWhen;

  /// Cria um novo [YoutubeValueBuilder] que constrói a si mesmo com base na última
  /// captura de interação com o [controller] especificado e cuja estratégia de construção
  /// é dada por [builder].
  ///
  /// A propriedade [controller] pode ser omitida se [YoutubePlayerControllerProvider] estiver acima deste widget na árvore de widgets.
  ///
  /// O [builder] não deve ser nulo.
  const YoutubeValueBuilder({
    Key? key,
    required this.builder,
    this.buildWhen,
    this.controller,
  }) : super(key: key);

  @override
  _YoutubeValueBuilderState createState() => _YoutubeValueBuilderState();
}

/// Este bloco de código é responsável por construir um widget que se atualiza automaticamente com base nos dados fornecidos
/// pelo controlador do player de vídeo do YouTube. Ele cria um estado interno que se inscreve nas atualizações do controlador
/// e chama o construtor de widgets fornecido sempre que houver uma mudança nos valores do controlador que atende ao critério
/// definido pela função buildWhen. O construtor de widgets fornecido recebe o contexto de construção e o valor atualizado do
/// controlador e retorna o widget a ser construído.
//
// Além disso, este bloco de código implementa um StreamSubscription que se inscreve nas atualizações do controlador
// e fornece uma função que é executada sempre que houver uma mudança nos valores do controlador.
// Esta função verifica se a atualização atende ao critério definido pela função buildWhen e, se sim, atualiza o estado
// interno do widget e reconstrói o widget. Caso contrário, a atualização é ignorada.
class _YoutubeValueBuilderState extends State<YoutubeValueBuilder> {
  StreamSubscription<YoutubePlayerValue>? _subscription;
  YoutubePlayerController? _controller;
  late YoutubePlayerValue _previousValue;
  late Widget _child;

  @override
  void didUpdateWidget(YoutubeValueBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Atualiza o controlador, caso haja uma mudança.
    final oldController = oldWidget.controller ?? context.ytController;
    final currentController = widget.controller ?? oldController;
    if (oldController != currentController) {
      if (_subscription != null) {
        _unsubscribe();
        _controller = currentController;
        _previousValue = _controller!.value;
      }
      _subscribe();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Obtém o controlador a partir dos parâmetros da instância atual ou do contexto.
    final controller = widget.controller ?? context.ytController;

    // Se o controlador não foi inicializado, define o controlador, o valor anterior e inicia a assinatura.
    if (_controller == null) {
      _controller = controller;
      _previousValue = _controller!.value;
      _child = widget.builder(context, _previousValue);
      _subscribe();

      // Se houver um controlador anterior e o controlador atual for diferente, substitua o controlador anterior pelo atual e inicie a assinatura novamente.
    } else if (_controller != controller) {
      if (_subscription != null) {
        _unsubscribe();
        _controller = controller;
        _previousValue = _controller!.value;
      }
      _subscribe();
    }
  }

  @override
  Widget build(BuildContext context) => _child;

  void _subscribe() {
    // Assina as mudanças do controlador do player.
    _subscription = _controller!.listen(
          (value) {
        // Se a condição de construção do widget atual for verdadeira, atualize o widget.
        if (widget.buildWhen?.call(_previousValue, value) ?? true) {
          if (!mounted) return;
          _child = widget.builder(context, value);
          setState(() {});
        }
        _previousValue = value;
      },
      onError: (e) => log(e.toString()),
    );
  }

  void _unsubscribe() {
    // Cancela a assinatura do controlador do player.
    _subscription?.cancel();
    _subscription = null;
  }
}
