export class DesignTokens {
  static readonly lightBackground: string = '#F6F1E8';
  static readonly lightCard: string = '#FFFDF8';
  static readonly lightText: string = '#2E2924';
  static readonly lightSecondary: string = '#817970';
  static readonly lightDivider: string = '#EEE7DE';
  static readonly lightField: string = '#F7EFE4';
  static readonly darkBackground: string = '#171513';
  static readonly darkCard: string = '#24211E';
  static readonly darkText: string = '#F1ECE4';
  static readonly darkSecondary: string = '#AAA198';
  static readonly darkDivider: string = '#3B3530';
  static readonly darkField: string = '#2D2925';
  static readonly wood: string = '#8A5635';
  static readonly woodDark: string = '#99613E';
  static readonly accent: string = '#A9824B';
  static readonly accentDark: string = '#C29961';
  static readonly accentLight: string = '#D8B28C';
  static readonly success: string = '#A7C1A1';
  static readonly danger: string = '#E8A39A';
  static readonly radiusCard: number = 18;
  static readonly radiusPanel: number = 8;
  static readonly radiusControl: number = 8;
  static readonly touchSize: number = 48;
  static readonly controlHeight: number = 52;
  static readonly spaceSmall: number = 8;
  static readonly spaceMedium: number = 16;
  static readonly spaceLarge: number = 24;
  static readonly contentPhoneMax: number = 560;
  static readonly contentTabletMax: number = 920;
  static readonly contentExpandedMax: number = 1180;
  static readonly compactMax: number = 599;
  static readonly mediumMax: number = 1023;

  static pageInset(width: number): number {
    return width < 600 ? 20 : 24;
  }

  static titleSize(width: number): number {
    return width < 1024 ? 32 : 34;
  }

  static summaryHeight(_width: number): number {
    return 76;
  }

  static toolBarHeight(_width: number): number {
    return 52;
  }

  static bottomNavHeight(_width: number): number {
    return 76;
  }
}
