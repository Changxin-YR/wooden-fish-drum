export class ThemeColors {
  page: string = '';
  card: string = '';
  primary: string = '';
  secondary: string = '';
  accent: string = '';
  accentSoft: string = '';
  divider: string = '';
  selectedText: string = '';
  success: string = '';
}

export class ThemePalette {
  static resolve(dark: boolean): ThemeColors {
    const colors: ThemeColors = new ThemeColors();
    colors.page = dark ? '#171513' : '#F6F1E8';
    colors.card = dark ? '#24211E' : '#FFFDF8';
    colors.primary = dark ? '#E7D4BF' : '#44352B';
    colors.secondary = dark ? '#9A8D80' : '#887A6E';
    colors.accent = dark ? '#CE914A' : '#C98C49';
    colors.accentSoft = dark ? '#3A2A1D' : '#F3E5D3';
    colors.divider = dark ? '#493B2E' : '#E8DED2';
    colors.selectedText = '#FFFFFF';
    colors.success = dark ? '#91A98D' : '#718D6C';
    return colors;
  }
}
