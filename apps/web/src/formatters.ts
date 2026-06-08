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

