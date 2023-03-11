// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Erros do YouTube
/// A enumeração YoutubeError define as constantes de erro que correspondem aos diferentes códigos de erro do YouTube.
/// Cada constante tem um valor de código associado e uma descrição do erro. A função errorEnum() mapeia o código de erro
/// fornecido para a constante de erro correspondente e a retorna.
enum YoutubeError {
  /// Sem erros
  none(0),

  /// A solicitação contém um valor de parâmetro inválido.
  ///
  /// Por exemplo, esse erro ocorre se você especificar um ID de vídeo que não tenha 11 caracteres,
  /// ou se o ID do vídeo contiver caracteres inválidos, como pontos de exclamação ou asteriscos.
  invalidParam(2),

  /// O conteúdo solicitado não pode ser reproduzido em um player HTML5 ou ocorreu outro erro relacionado ao player HTML5.
  html5Error(5),

  /// O vídeo solicitado não foi encontrado. Esse erro ocorre quando um vídeo foi removido (por qualquer motivo) ou foi marcado como privado.
  videoNotFound(100),

  /// O proprietário do vídeo solicitado não permite que ele seja reproduzido em players incorporados.
  notEmbeddable(101),

  /// O vídeo solicitado não pôde ser encontrado.
  cannotFindVideo(105),

  /// Esse erro é o mesmo que [YoutubeError.notEmbeddable] disfarçado!
  sameAsNotEmbeddable(150),

  /// Erro desconhecido
  unknown(-1);

  /// Retorna o [YoutubeError] correspondente ao código fornecido.
  const YoutubeError(this.code);

  /// Código do erro.
  final int code;
}

///
YoutubeError errorEnum(int errorCode) {
  switch (errorCode) {
    case 2:
      return YoutubeError.invalidParam;
    case 5:
      return YoutubeError.html5Error;
    case 100:
      return YoutubeError.videoNotFound;
    case 101:
      return YoutubeError.notEmbeddable;
    case 105:
      return YoutubeError.cannotFindVideo;
    case 150:
      return YoutubeError.sameAsNotEmbeddable;
    default:
      return YoutubeError.unknown;
  }
}
