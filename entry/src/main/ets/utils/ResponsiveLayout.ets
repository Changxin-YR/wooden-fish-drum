import { DesignTokens } from '../constants/DesignTokens';

export enum LayoutSize {
  COMPACT = 'compact',
  MEDIUM = 'medium',
  EXPANDED = 'expanded'
}

export class ResponsiveLayout {
  static resolve(width: number): LayoutSize {
    if (width <= DesignTokens.compactMax) {
      return LayoutSize.COMPACT;
    }
    if (width <= DesignTokens.mediumMax) {
      return LayoutSize.MEDIUM;
    }
    return LayoutSize.EXPANDED;
  }
}
