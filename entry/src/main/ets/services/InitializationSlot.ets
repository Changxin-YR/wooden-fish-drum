export class InitializationSlot<T> {
  private generation: number = 0;
  private resource: T | null = null;

  begin(): number {
    this.generation += 1;
    return this.generation;
  }

  isCurrent(generation: number): boolean {
    return generation === this.generation;
  }

  publish(generation: number, candidate: T): T | null {
    if (!this.isCurrent(generation)) {
      return candidate;
    }
    const previous: T | null = this.resource;
    this.resource = candidate;
    return previous;
  }

  current(): T | null {
    return this.resource;
  }

  cancel(): T | null {
    this.generation += 1;
    const current: T | null = this.resource;
    this.resource = null;
    return current;
  }
}
