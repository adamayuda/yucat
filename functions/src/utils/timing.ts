/**
 * Lightweight per-step timing for the scan pipeline.
 *
 * createTimer() records ordered marks via Date.now() (Node runtime). Call
 * mark(label) after each awaited step to capture the elapsed time since the
 * previous mark, then summary() to get the per-step breakdown plus the total.
 * Used only for measurement/logging — no behavior change.
 */

export interface TimerStep {
  label: string;
  ms: number;
}

export interface TimerSummary {
  steps: TimerStep[];
  totalMs: number;
}

export interface Timer {
  /** Record the elapsed ms since the previous mark (or timer start). */
  mark(label: string): void;
  /** Ordered per-step breakdown plus total elapsed since timer creation. */
  summary(): TimerSummary;
}

export function createTimer(): Timer {
  const start = Date.now();
  let last = start;
  const steps: TimerStep[] = [];

  return {
    mark(label: string): void {
      const now = Date.now();
      steps.push({label, ms: now - last});
      last = now;
    },
    summary(): TimerSummary {
      return {steps, totalMs: Date.now() - start};
    },
  };
}
