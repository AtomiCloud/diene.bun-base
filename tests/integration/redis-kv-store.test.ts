import { afterAll, beforeAll, describe, it } from "bun:test";
import should from "should";
import { GenericContainer, type StartedTestContainer, Wait } from "testcontainers";
import type { IKeyValueStore } from "../../src/adapter/kv-store";
import { createRedisStore, persistSample } from "../../src/index";

// Integration suite: exercises the real side-effect adapter against a throwaway
// Redis container. This only runs through `bun test --config=bunfig.int.toml`,
// never on the default unit path.
describe("RedisKeyValueStore (Testcontainers)", () => {
  let container: StartedTestContainer | undefined;
  let subject: IKeyValueStore | undefined;

  beforeAll(async () => {
    // A log-message wait strategy is used instead of the default host-port
    // probe: the port probe relies on socket events that hang under the Bun
    // test runtime, whereas streaming the container log is reliable everywhere.
    container = await new GenericContainer("redis:7-alpine")
      .withExposedPorts(6379)
      .withWaitStrategy(Wait.forLogMessage(/Ready to accept connections/))
      .start();
    subject = createRedisStore({
      host: container.getHost(),
      port: container.getMappedPort(6379),
    });
  }, 120_000);

  afterAll(async () => {
    // Guard teardown so a partial beforeAll failure (e.g. container started but
    // store never assigned) does not mask the original error with a TypeError.
    await subject?.close();
    await container?.stop();
  }, 120_000);

  it("should persist and retrieve a namespaced value", async () => {
    // Arrange
    const expected = "hello";

    // Act
    const actual = await persistSample(
      subject as IKeyValueStore,
      "Bun Base",
      "sample key",
      expected,
    );

    // Assert
    should(actual).equal(expected);
  });

  it("should return null for an unknown key", async () => {
    // Arrange
    const input = "bun-base:missing";

    // Act
    const actual = await (subject as IKeyValueStore).get(input);

    // Assert
    should(actual).be.null();
  });
});
