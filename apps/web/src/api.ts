import type {
  LocationReference,
  SavedJourney,
  TripPreview,
  User
} from "./types";

const API_BASE =
  import.meta.env.VITE_API_BASE_URL ?? "/api";

interface ProblemResponse {
  detail?: string;
  message?: string;
  title?: string;
}

export class ApiError extends Error {
  constructor(
    message: string,
    public readonly status: number
  ) {
    super(message);
  }
}

async function request<T>(
  path: string,
  options: RequestInit = {}
): Promise<T> {
  const response = await fetch(`${API_BASE}${path}`, {
    ...options,
    credentials: "include",
    headers: {
      "Content-Type": "application/json",
      ...options.headers
    }
  });

  if (!response.ok) {
    let problem: ProblemResponse = {};
    try {
      problem = (await response.json()) as ProblemResponse;
    } catch {
      // Some responses, such as 401, intentionally have no JSON body.
    }

    throw new ApiError(
      problem.detail ??
        problem.message ??
        problem.title ??
        "The request could not be completed.",
      response.status
    );
  }

  if (response.status === 204) {
    return undefined as T;
  }

  return (await response.json()) as T;
}

export const api = {
  locations: (query: string, signal?: AbortSignal) =>
    request<LocationReference[]>(
      `/transit/locations?query=${encodeURIComponent(query)}`,
      { signal }
    ),

  preview: (from: LocationReference, to: LocationReference) =>
    request<TripPreview>("/transit/preview", {
      method: "POST",
      body: JSON.stringify({ from, to })
    }),

  me: () => request<User>("/auth/me"),

  register: (email: string, password: string) =>
    request<User>("/auth/register", {
      method: "POST",
      body: JSON.stringify({ email, password })
    }),

  login: (email: string, password: string) =>
    request<User>("/auth/login", {
      method: "POST",
      body: JSON.stringify({ email, password })
    }),

  logout: () =>
    request<void>("/auth/logout", {
      method: "POST"
    }),

  journeys: () => request<SavedJourney[]>("/journeys/"),

  saveJourney: (
    name: string,
    from: LocationReference,
    to: LocationReference
  ) =>
    request<SavedJourney>("/journeys/", {
      method: "POST",
      body: JSON.stringify({ name, from, to })
    }),

  refreshJourney: (id: string) =>
    request<SavedJourney>(`/journeys/${id}/refresh`, {
      method: "POST"
    }),

  deleteJourney: (id: string) =>
    request<void>(`/journeys/${id}`, {
      method: "DELETE"
    })
};
