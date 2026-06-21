export function formatTime(value: string): string {
  return new Intl.DateTimeFormat("en-GB", {
    hour: "2-digit",
    minute: "2-digit"
  }).format(new Date(value));
}

export function formatDelay(delayMinutes: number): string {
  if (delayMinutes < 0) {
    return `${Math.abs(delayMinutes)} min early`;
  }

  if (delayMinutes === 0) {
    return "On time";
  }

  return `${delayMinutes} min late`;
}

export function delayTone(delayMinutes: number): "good" | "watch" | "late" {
  if (delayMinutes <= 1) {
    return "good";
  }

  if (delayMinutes <= 5) {
    return "watch";
  }

  return "late";
}

export function averageDelay(delays: number[]): number | null {
  if (delays.length === 0) {
    return null;
  }

  return Math.round(
    delays.reduce((total, delay) => total + delay, 0) / delays.length
  );
}

export function onTimeRate(delays: number[]): number | null {
  if (delays.length === 0) {
    return null;
  }

  const goodSamples = delays.filter((delay) => delay <= 1).length;
  return Math.round((goodSamples / delays.length) * 100);
}

export function worstDelay(delays: number[]): number | null {
  if (delays.length === 0) {
    return null;
  }

  return Math.max(...delays);
}

export function bestDelay(delays: number[]): number | null {
  if (delays.length === 0) {
    return null;
  }

  return Math.min(...delays);
}

export function delayTrend(
  newestFirstDelays: number[]
): "improving" | "steady" | "worsening" | "unknown" {
  if (newestFirstDelays.length < 2) {
    return "unknown";
  }

  const [latest, previous] = newestFirstDelays;
  if (latest <= previous - 2) {
    return "improving";
  }

  if (latest >= previous + 2) {
    return "worsening";
  }

  return "steady";
}

export function reliabilityScore(delays: number[]): number | null {
  const rate = onTimeRate(delays);
  const average = averageDelay(delays);
  const worst = worstDelay(delays);

  if (rate === null || average === null || worst === null) {
    return null;
  }

  const averageComponent = Math.max(0, 100 - Math.max(0, average) * 8);
  const worstComponent = Math.max(0, 100 - Math.max(0, worst) * 4);

  return Math.max(
    0,
    Math.min(
      100,
      Math.round(rate * 0.65 + averageComponent * 0.25 + worstComponent * 0.1)
    )
  );
}

export function reliabilityLabel(score: number | null): string {
  if (score === null) {
    return "Not enough data";
  }

  if (score >= 80) {
    return "Strong sample";
  }

  if (score >= 60) {
    return "Mixed sample";
  }

  return "Weak sample";
}
