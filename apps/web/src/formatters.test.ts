import { describe, expect, it } from "vitest";
import {
  averageDelay,
  bestDelay,
  delayTone,
  delayTrend,
  formatDelay,
  onTimeRate,
  reliabilityLabel,
  reliabilityScore,
  worstDelay
} from "./formatters";

describe("delay formatting", () => {
  it("distinguishes early, on-time, and delayed journeys", () => {
    expect(formatDelay(-2)).toBe("2 min early");
    expect(formatDelay(0)).toBe("On time");
    expect(formatDelay(4)).toBe("4 min late");
  });

  it("uses simple reliability thresholds", () => {
    expect(delayTone(1)).toBe("good");
    expect(delayTone(5)).toBe("watch");
    expect(delayTone(6)).toBe("late");
  });

  it("returns a rounded average", () => {
    expect(averageDelay([1, 2, 5])).toBe(3);
    expect(averageDelay([])).toBeNull();
  });

  it("summarizes a sample set for the route dashboard", () => {
    const delays = [0, 1, 3, 8];

    expect(onTimeRate(delays)).toBe(50);
    expect(bestDelay(delays)).toBe(0);
    expect(worstDelay(delays)).toBe(8);
    expect(reliabilityScore(delays)).toBe(58);
    expect(reliabilityLabel(58)).toBe("Weak sample");
  });

  it("compares the latest observation with the previous one", () => {
    expect(delayTrend([1, 5])).toBe("improving");
    expect(delayTrend([6, 2])).toBe("worsening");
    expect(delayTrend([3, 4])).toBe("steady");
    expect(delayTrend([3])).toBe("unknown");
  });
});
