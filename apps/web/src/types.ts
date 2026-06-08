export interface User {
  id: string;
  email: string;
}

export interface LocationReference {
  id: string;
  name: string;
  label: string;
  latitude: number;
  longitude: number;
}

export interface TripPreview {
  fromName: string;
  toName: string;
  expectedStartTime: string;
  expectedEndTime: string;
  durationMinutes: number;
  delayMinutes: number;
  modes: string[];
  lineSummary: string;
  attribution: string;
}

export interface Observation {
  id: string;
  collectedAtUtc: string;
  expectedStartTime: string;
  expectedEndTime: string;
  durationMinutes: number;
  delayMinutes: number;
  lineSummary: string;
}

export interface SavedJourney {
  id: string;
  name: string;
  from: LocationReference;
  to: LocationReference;
  createdAtUtc: string;
  observations: Observation[];
}

