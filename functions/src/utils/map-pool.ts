/**
 * Runs `fn` over `items` with at most `concurrency` in flight, preserving
 * order. Ported from `scripts/backfill-images.ts` so the nightly self-heal job
 * (`jobs/self-heal.ts`) and the manual script share one implementation.
 */
export async function mapPool<T, R>(
  items: T[],
  concurrency: number,
  fn: (item: T, index: number) => Promise<R>
): Promise<R[]> {
  const results: R[] = new Array(items.length);
  let next = 0;
  async function worker() {
    while (next < items.length) {
      const i = next++;
      results[i] = await fn(items[i], i);
    }
  }
  await Promise.all(
    Array.from({length: Math.min(concurrency, items.length)}, worker)
  );
  return results;
}
