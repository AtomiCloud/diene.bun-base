// Side-effect adapter: a real Redis-backed implementation of IKeyValueStore.
// This is the boundary exercised by the Testcontainers integration suite.
import { Redis } from "ioredis";
import type { IKeyValueStore, RedisConnection } from "./kv-store";

export class RedisKeyValueStore implements IKeyValueStore {
  private readonly client: Redis;

  constructor(connection: RedisConnection) {
    this.client = new Redis({
      host: connection.host,
      port: connection.port,
      maxRetriesPerRequest: 3,
      // Defer the socket connection until the first command instead of dialing
      // eagerly from the constructor. This removes the cold-start race where a
      // freshly started server has logged readiness but not yet accepted TCP.
      lazyConnect: true,
    });
    // ioredis owns reconnection through its retry strategy, and command failures
    // still reject at their call site once `maxRetriesPerRequest` is exhausted.
    // Without an `error` listener ioredis prints "[ioredis] Unhandled error
    // event" to the console for connection-level events it is already recovering
    // from. Observe that channel here: tolerate the transient ECONNREFUSED a
    // not-yet-bound server emits, and surface anything unexpected.
    this.client.on("error", (error: Error) => {
      if ((error as NodeJS.ErrnoException).code !== "ECONNREFUSED") {
        console.error(`[redis-kv-store] unexpected connection error: ${error.message}`);
      }
    });
  }

  async set(key: string, value: string): Promise<void> {
    await this.client.set(key, value);
  }

  async get(key: string): Promise<string | null> {
    return this.client.get(key);
  }

  async close(): Promise<void> {
    await this.client.quit();
  }
}
