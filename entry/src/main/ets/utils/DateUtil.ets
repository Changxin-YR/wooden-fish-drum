export class DateUtil {
  static toKey(date: Date): string {
    const year: string = `${date.getFullYear()}`;
    const month: string = `${date.getMonth() + 1}`.padStart(2, '0');
    const day: string = `${date.getDate()}`.padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  static todayKey(): string {
    return DateUtil.toKey(new Date());
  }

  static addDays(dateKey: string, offset: number): string {
    const parts: string[] = dateKey.split('-');
    const date: Date = new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]));
    date.setDate(date.getDate() + offset);
    return DateUtil.toKey(date);
  }

  static shortLabel(dateKey: string): string {
    return dateKey.slice(5).replace('-', '/');
  }
}
