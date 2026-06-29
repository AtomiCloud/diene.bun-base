// Boundary contract for the side-effect adapter. Keeping the interface separate
// from its implementation lets the composition root and tests depend on the
// abstraction rather than on a concrete client.
export interface IKeyValueStore {
  set(key: string, value: string): Promise<void>;
  get(key: string): Promise<string | null>;
  close(): Promise<void>;
}

export interface RedisConnection {
  readonly host: string;
  readonly port: number;
}
