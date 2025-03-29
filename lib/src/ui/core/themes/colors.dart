// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';

abstract final class AppColors {
  static const black1 = Color(0xFF101010);
  static const white1 = Color(0xFFFFF7FA);
  static var grey500 = Colors.grey.shade500;
  static const grey2 = Color(0xFF4D4D4D);
  static const blackTransparent = Color(0x4D000000);
  static const red1 = Color(0xFFE74C3C);

  static const blueCardColor = Color(0xFFD3E3FD);
  static const lightCardColor = Color(0xFFE3E3E3);

  static const lightColorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.white1,
      onPrimary: AppColors.black1,
      secondary: AppColors.lightCardColor,
      onSecondary: AppColors.black1,
      tertiary: AppColors.blueCardColor,
      onTertiary: AppColors.black1,
      surface: Colors.white,
      onSurface: AppColors.black1,
      error: Colors.white,
      onError: Colors.red,
      surfaceDim: AppColors.black1);

  static var darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.black1,
    onPrimary: AppColors.white1,
    secondary: AppColors.grey2,
    onSecondary: AppColors.white1,
    tertiary: AppColors.blueCardColor,
    onTertiary: AppColors.black1,
    surface: AppColors.black1,
    onSurface: Colors.white,
    error: Colors.black,
    onError: AppColors.red1,
    surfaceDim: AppColors.grey500,
  );
}
