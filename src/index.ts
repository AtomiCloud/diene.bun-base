// Composition root: thinly wires the pure library (src/lib) to the side-effect
// adapter (src/adapter) and exposes a neutral sample executable entrypoint.
import type { IKeyValueStore, RedisConnection } from "./adapter/kv-store";
import { RedisKeyValueStore } from "./adapter/redis-kv-store";
import { namespacedKey } from "./lib/slug";

/** Builds the canonical key for a sample record using the pure library. */
export function buildSampleKey(namespace: string, key: string): string {
  return namespacedKey(namespace, key);
}

/** Constructs the Redis-backed store. Kept here so the wiring lives in one place. */
export function createRedisStore(connection: RedisConnection): IKeyValueStore {
  return new RedisKeyValueStore(connection);
}

/**
 * Sample use case: compose a key with the pure library, persist a value through
 * the adapter boundary, then read it back. Returns the round-tripped value.
 */
export async function persistSample(
  store: IKeyValueStore,
  namespace: string,
  key: string,
  value: string,
): Promise<string | null> {
  const composed = buildSampleKey(namespace, key);
  await store.set(composed, value);
  return store.get(composed);
}

async function main(): Promise<void> {
  const connection =
    process.env.REDIS_HOST && process.env.REDIS_PORT
      ? {
          host: process.env.REDIS_HOST,
          port: Number(process.env.REDIS_PORT),
        }
      : undefined;

  if (connection) {
    const store = createRedisStore(connection);
    try {
      const value = await persistSample(store, "Bun Base", "sample key", "sample value");
      console.log(`round-tripped value: ${value}`);
    } finally {
      await store.close();
    }
    return;
  }

  console.log(`composed key: ${buildSampleKey("Bun Base", "sample key")}`);
}

if (import.meta.main) {
  await main();
}
