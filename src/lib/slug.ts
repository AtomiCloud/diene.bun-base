// Pure domain/library behavior. No side effects — safe to delete or replace
// in sibling templates. Covered by tests/unit.

/**
 * Normalizes arbitrary text into a lowercase, hyphen-delimited slug.
 *
 * Pure: the same input always yields the same output and nothing outside the
 * function is observed or mutated.
 */
export function slugify(input: string): string {
  return (
    input
      .normalize("NFKD")
      // Strip the combining diacritical marks (U+0300–U+036F) that NFKD splits
      // off accented letters (e.g. ñ -> n + U+0303). Without this they would fall
      // outside [a-z0-9] and the separator pass below would turn an accent into a
      // spurious hyphen, splitting a single word (mañana -> "man-ana").
      .replace(/[\u0300-\u036f]/g, "")
      .toLowerCase()
      .trim()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-+|-+$/g, "")
  );
}

/**
 * Domain error raised when a part of a namespaced key slugifies to empty.
 * Class-based so callers can branch on the typed error (and the offending
 * `field`) rather than parsing a bare `Error` message.
 */
export class NamespacedKeyValidationError extends Error {
  constructor(
    readonly field: "namespace" | "key",
    readonly reason: string,
  ) {
    super(`${field} ${reason}`);
    this.name = "NamespacedKeyValidationError";
  }
}

/**
 * Composes a `namespace:key` identifier from two human-readable parts, each
 * slugified independently. Throws {@link NamespacedKeyValidationError} when
 * either part slugifies to empty so the adapter never persists an ambiguous key.
 */
export function namespacedKey(namespace: string, key: string): string {
  const ns = slugify(namespace);
  const k = slugify(key);
  if (ns === "") throw new NamespacedKeyValidationError("namespace", "must not be empty");
  if (k === "") throw new NamespacedKeyValidationError("key", "must not be empty");
  return `${ns}:${k}`;
}
