import { describe, expect, it } from "vitest";
import { averageDelay, delayTone, formatDelay } from "./formatters";

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
});

