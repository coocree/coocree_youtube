import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

// Classe que define a seção de metadados.
class MetaDataSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // O componente YoutubeValueBuilder é utilizado para escutar mudanças no player de vídeo do YouTube.
    return YoutubeValueBuilder(
      // A função buildWhen é utilizada para definir as condições para que o componente seja atualizado.
      buildWhen: (o, n) {
        return o.metaData != n.metaData || o.playbackQuality != n.playbackQuality;
      },
      // A função builder é utilizada para construir o componente com base nas informações recebidas.
      builder: (context, value) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exibe o título do vídeo.
            _Text('Title', value.metaData.title),
            const SizedBox(height: 10),
            // Exibe o nome do canal.
            _Text('Channel', value.metaData.author),
            const SizedBox(height: 10),
            // Exibe a qualidade de reprodução.
            _Text(
              'Playback Quality',
              value.playbackQuality ?? '',
            ),
            const SizedBox(height: 10),
            // Exibe o ID do vídeo e a opção de alterar a velocidade de reprodução.
            Row(
              children: [
                _Text('Video Id', value.metaData.videoId),
                const Spacer(),
                const _Text(
                  'Speed',
                  '',
                ),
                // O componente DropdownButton é utilizado para criar uma lista de opções de velocidade de reprodução.
                YoutubeValueBuilder(
                  builder: (context, value) {
                    return DropdownButton(
                      value: value.playbackRate,
                      isDense: true,
                      underline: const SizedBox(),
                      items: PlaybackRate.all
                          .map(
                            (rate) => DropdownMenuItem(
                              child: Text(
                                '${rate}x',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              value: rate,
                            ),
                          )
                          .toList(),
                      onChanged: (double? newValue) {
                        if (newValue != null) {
                          context.ytController.setPlaybackRate(newValue);
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// Classe que define um texto personalizado.
class _Text extends StatelessWidget {
  final String title;
  final String value;

  const _Text(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      // Utiliza o componente TextSpan para exibir o título e o valor do texto personalizado.
      TextSpan(
        text: '$title : ',
        style: Theme.of(context).textTheme.labelLarge,
        children: [
          TextSpan(
            text: value,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }
}
