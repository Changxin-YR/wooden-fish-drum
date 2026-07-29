export class TextValidator {
  static readonly maxLength: number = 12;

  static normalize(value: string): string {
    return value.trim().slice(0, TextValidator.maxLength);
  }

  static isValid(value: string): boolean {
    const normalized: string = TextValidator.normalize(value);
    return normalized.length > 0 && normalized.length <= TextValidator.maxLength;
  }
}
