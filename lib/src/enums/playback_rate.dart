// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Direitos autorais 2020 Sarbagya Dhaubanjar. Todos os direitos reservados.
// O uso deste código-fonte é regido por uma licença do tipo BSD que pode ser encontrada no arquivo LICENSE.

/// Taxa de reprodução ou velocidade para o vídeo.
///
/// Saiba mais [aqui](https://developers.google.com/youtube/iframe_api_reference#getPlaybackRate).
/// A classe PlaybackRate define constantes estáticas para as taxas de reprodução de um vídeo do YouTube.
/// As constantes são números de ponto flutuante que representam a taxa de reprodução, em que 1.0 é a taxa de reprodução normal.
/// A constante all é uma lista que contém todas as taxas de reprodução possíveis.
/// A documentação da classe também contém um link para mais informações sobre as taxas de reprodução.
class PlaybackRate {
  /// Define a taxa de reprodução para 2,0 vezes.
  static const double twice = 2.0;

  /// Define a taxa de reprodução para 1,75 vezes.
  static const double oneAndAThreeQuarter = 1.75;

  /// Define a taxa de reprodução para 1,5 vezes.
  static const double oneAndAHalf = 1.5;

  /// Define a taxa de reprodução para 1,25 vezes.
  static const double oneAndAQuarter = 1.25;

  /// Define a taxa de reprodução para 1,0 vezes.
  static const double normal = 1.0;

  /// Define a taxa de reprodução para 0,75 vezes.
  static const double threeQuarter = 0.75;

  /// Define a taxa de reprodução para 0,5 vezes.
  static const double half = 0.5;

  /// Define a taxa de reprodução para 0,25 vezes.
  static const double quarter = 0.25;

  /// Todas as taxas de reprodução possíveis.
  static const List<double> all = [
    twice,
    oneAndAThreeQuarter,
    oneAndAHalf,
    oneAndAQuarter,
    normal,
    threeQuarter,
    half,
    quarter,
  ];
}
