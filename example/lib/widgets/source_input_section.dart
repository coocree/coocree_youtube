// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

// Classe que define um widget que possui estado
class SourceInputSection extends StatefulWidget {
  // Cria uma nova instância da classe _SourceInputSectionState para controlar o estado do widget
  @override
  _SourceInputSectionState createState() => _SourceInputSectionState();
}

// Este bloco de código define a classe `_SourceInputSectionState`, que controla o estado do widget `SourceInputSection`.
// A classe possui três propriedades: `_textController`, que controla o conteúdo do `TextField`, `_playlistType`, que armazena
// o tipo de lista selecionado, e `_helperText`, que retorna o texto de ajuda para o tipo de lista selecionado.
//
// O método `initState()` é chamado quando o estado do widget é criado e inicializa o controlador do `TextField`. O método `build()`
// é sobrescrito para criar a interface gráfica do widget, que consiste em um `Column` contendo um `DropdownButtonFormField`, um
// `TextField` animado, e quatro `Buttons` personalizados.
//
// O método `_cleanId()` é responsável por limpar o ID do vídeo da entrada. Se a entrada for uma URL, ele usa o método
// `YoutubePlayerController.convertUrlToId()` para obter o ID do vídeo. Caso contrário, verifica se o comprimento da entrada é igual
// a 11 e, em caso negativo, exibe uma mensagem de erro usando o método `_showSnackBar()`. O método `_showSnackBar()` exibe
// um `SnackBar` com uma mensagem.
//
// Por fim, o método `dispose()` é chamado quando o estado do widget é destruído e libera o controlador do `TextField`.
class _SourceInputSectionState extends State<SourceInputSection> {
  late TextEditingController _textController; // Propriedade que controla o conteúdo do TextField
  ListType? _playlistType; // Propriedade que armazena o tipo de lista selecionado

  // Método que é chamado quando o estado do widget é criado
  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(); // Inicializa o controlador do TextField
  }

  // Método que cria a interface gráfica do widget
  @override
  Widget build(BuildContext context) {
    // Retorna um widget Column que contém os widgets que formam o SourceInputSection
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PlaylistTypeDropDown(
          onChanged: (type) {
            _playlistType = type;
            setState(() {});
          },
        ),
        const SizedBox(height: 10),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: TextField(
            controller: _textController, // Define o controlador do TextField
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: _hint,
              helperText: _helperText,
              fillColor: Theme.of(context).colorScheme.surfaceVariant,
              filled: true,
              hintStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w300,
                  ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => _textController.clear(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 2,
          children: [
            _Button(
              action: 'Load',
              onTap: () {
                // Carrega o vídeo com o ID informado no TextField
                context.ytController.loadVideoById(
                  videoId: _cleanId(_textController.text) ?? '',
                );
              },
            ),
            _Button(
              action: 'Cue',
              onTap: () {
                // Adiciona o vídeo com o ID informado no TextField à fila de reprodução
                context.ytController.cueVideoById(
                  videoId: _cleanId(_textController.text) ?? '',
                );
              },
            ),
            _Button(
              action: 'Load Playlist',
              onTap: _playlistType == null
                  ? null
                  : () {
                      // Carrega a lista de reprodução informada no TextField
                      context.ytController.loadPlaylist(
                        list: [_textController.text],
                        listType: _playlistType!,
                      );
                    },
            ),
            _Button(
              action: 'Cue Playlist',
              onTap: _playlistType == null
                  ? null
                  : () {
                      // Adiciona a lista de reprodução informada no TextField à fila de reprodução
                      context.ytController.cuePlaylist(
                        list: [_textController.text],
                        listType: _playlistType!,
                      );
                    },
            ),
          ],
        ),
      ],
    );
  }

  // Retorna o texto de ajuda para o tipo de lista selecionado
  String? get _helperText {
    switch (_playlistType) {
      case ListType.playlist:
        return '"PLj0L3ZL0ijTdhFSueRKK-mLFAtDuvzdje", ...';
      case ListType.userUploads:
        return '"pewdiepie", "tseries"';
      default:
        return null;
    }
  }

  // Retorna o texto de dica para o tipo de lista selecionado
  String get _hint {
    switch (_playlistType) {
      case ListType.playlist:
        return 'Enter playlist id';
      case ListType.userUploads:
        return 'Enter channel name';
      default:
        return r'Enter youtube <video id> or <link>';
    }
  }

  // Limpa o ID do vídeo da entrada
  String? _cleanId(String source) {
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return YoutubePlayerController.convertUrlToId(source);
    } else if (source.length != 11) {
      _showSnackBar('Invalid Source'); // Exibe uma mensagem de erro caso a entrada seja inválida
    }
    return source;
  }

  // Exibe um SnackBar com uma mensagem
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 16),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    );
  }

  // Método que é chamado quando o estado do widget é destruído
  @override
  void dispose() {
    _textController.dispose(); // Libera o controlador do TextField
    super.dispose();
  }
}

/// Este bloco de código define uma classe chamada _PlaylistTypeDropDown que estende a classe StatefulWidget.
/// Essa classe representa um widget que pode ter seu estado alterado durante a execução do aplicativo.
//
// A classe tem um construtor que recebe uma chave opcional Key? e uma propriedade onChanged do tipo ValueChanged<ListType?>.
// A propriedade onChanged define um método que será chamado quando o valor do widget for alterado.
//
// O método createState() é sobrescrito para criar uma nova instância da classe _PlaylistTypeDropDownState que é
// responsável por controlar o estado do widget.
class _PlaylistTypeDropDown extends StatefulWidget {
  // Construtor da classe
  const _PlaylistTypeDropDown({
    Key? key,
    required this.onChanged,
  }) : super(key: key);

  // Propriedade que define um método para ser chamado quando o valor for alterado
  final ValueChanged<ListType?> onChanged;

  // Cria uma nova instância da classe _PlaylistTypeDropDownState para controlar o estado do widget
  @override
  _PlaylistTypeDropDownState createState() => _PlaylistTypeDropDownState();
}

// Este bloco de código define a classe _PlaylistTypeDropDownState, que controla o estado do widget _PlaylistTypeDropDown.
// A classe tem uma propriedade _playlistType que armazena o tipo de lista selecionado.
//
// O método build() é sobrescrito para criar a interface gráfica do widget, que é um DropdownButtonFormField que exibe
// uma lista de opções em forma de botão suspenso. O método define a decoração do botão e as opções disponíveis.
//
// Quando uma opção é selecionada, o método onChanged é chamado. Esse método altera o valor do tipo de lista selecionado
// e força a atualização da interface gráfica do widget. Ele também chama o método onChanged do widget pai para notificar
// que o valor do widget foi alterado.
class _PlaylistTypeDropDownState extends State<_PlaylistTypeDropDown> {
  ListType? _playlistType; // Propriedade que armazena o tipo de lista selecionado

  // Método que cria a interface gráfica do widget
  @override
  Widget build(BuildContext context) {
    // Retorna um widget DropdownButtonFormField que exibe uma lista de opções em forma de botão suspenso
    return DropdownButtonFormField<ListType>(
      // Define a decoração do botão
      decoration: InputDecoration(
        border: InputBorder.none,
        fillColor: Theme.of(context).colorScheme.surfaceVariant,
        filled: true,
      ),
      isExpanded: true,
      // Define se o botão suspenso será expandido para ocupar todo o espaço disponível
      value: _playlistType,
      // Define o valor atual do botão suspenso
      items: [
        // Lista de opções do botão suspenso
        DropdownMenuItem(
          // Opção para seleção do tipo de lista
          child: Text(
            'Select playlist type',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w300,
                ),
          ),
        ),
        ...ListType.values.map(
          (type) => DropdownMenuItem(child: Text(type.value), value: type),
        ),
      ],
      // Método que será chamado quando o valor do botão suspenso for alterado
      onChanged: (value) {
        // Altera o valor do tipo de lista selecionado
        _playlistType = value;
        // Força a atualização da interface gráfica do widget
        setState(() {});
        // Chama o método onChanged do widget pai
        widget.onChanged(value);
      },
    );
  }
}

// Este bloco de código define a classe _Button, que representa um botão personalizado. A classe tem duas propriedades: onTap,
// que define a ação a ser executada quando o botão for pressionado, e action, que define o texto exibido no botão.
//
// O construtor da classe recebe as propriedades do botão e chama o construtor da classe pai (super). O método build() é sobrescrito
// para criar a interface gráfica do botão, que é um ElevatedButton com o texto definido na propriedade action.
//
// Quando o botão é pressionado, o método onPressed é chamado. Se a propriedade onTap for nula, o botão é desativado. Caso contrário,
// a ação definida em onTap é executada e o foco do teclado é removido.
class _Button extends StatelessWidget {
  // Propriedades do botão
  final VoidCallback? onTap;
  final String action;

  // Construtor do botão
  const _Button({
    Key? key,
    required this.onTap,
    required this.action,
  }) : super(key: key);

  // Método que cria a interface gráfica do botão
  @override
  Widget build(BuildContext context) {
    // Retorna um ElevatedButton, que é um botão com um estilo elevado (em relevo)
    return ElevatedButton(
      // Define a ação a ser executada quando o botão for pressionado
      onPressed: onTap == null
          ? null
          : () {
              onTap?.call(); // Chama a ação do botão
              FocusScope.of(context).unfocus(); // Remove o foco do teclado
            },
      child: Padding(
        // Define o padding interno do botão
        padding: const EdgeInsets.symmetric(vertical: 8),
        // Define o texto do botão
        child: Text(action),
      ),
    );
  }
}
