import { type FormEvent, useEffect, useState } from "react";
import { api, ApiError } from "./api";
import { LocationSearch } from "./components/LocationSearch";
import { SavedJourneys } from "./components/SavedJourneys";
import { TripPreviewCard } from "./components/TripPreviewCard";
import type {
  LocationReference,
  SavedJourney,
  TripPreview,
  User
} from "./types";

type AuthMode = "register" | "login";

export default function App() {
  const [from, setFrom] = useState<LocationReference | null>(null);
  const [to, setTo] = useState<LocationReference | null>(null);
  const [preview, setPreview] = useState<TripPreview | null>(null);
  const [user, setUser] = useState<User | null>(null);
  const [journeys, setJourneys] = useState<SavedJourney[]>([]);
  const [authMode, setAuthMode] = useState<AuthMode>("register");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [journeyName, setJourneyName] = useState("");
  const [isPreviewing, setIsPreviewing] = useState(false);
  const [isAuthenticating, setIsAuthenticating] = useState(false);
  const [busyJourneyId, setBusyJourneyId] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    void loadSession();
  }, []);

  async function loadSession() {
    try {
      const currentUser = await api.me();
      setUser(currentUser);
      setJourneys(await api.journeys());
    } catch (requestError) {
      if (!(requestError instanceof ApiError && requestError.status === 401)) {
        setError(toMessage(requestError));
      }
    }
  }

  async function previewJourney(event: FormEvent) {
    event.preventDefault();
    clearFeedback();

    if (!from || !to) {
      setError("Choose both locations from the search results.");
      return;
    }

    setIsPreviewing(true);
    try {
      const result = await api.preview(from, to);
      setPreview(result);
      setJourneyName(`${from.name} to ${to.name}`);
    } catch (requestError) {
      setError(toMessage(requestError));
    } finally {
      setIsPreviewing(false);
    }
  }

  async function submitAuth(event: FormEvent) {
    event.preventDefault();
    clearFeedback();
    setIsAuthenticating(true);

    try {
      const currentUser =
        authMode === "register"
          ? await api.register(email, password)
          : await api.login(email, password);

      setUser(currentUser);
      setJourneys(await api.journeys());
      setPassword("");
      setMessage(
        authMode === "register"
          ? "Account created. You can save this journey now."
          : "Signed in."
      );
    } catch (requestError) {
      setError(toMessage(requestError));
    } finally {
      setIsAuthenticating(false);
    }
  }

  async function saveCurrentJourney() {
    clearFeedback();
    if (!user || !from || !to || !preview) {
      setError("Preview a journey and sign in before saving it.");
      return;
    }

    try {
      const saved = await api.saveJourney(journeyName, from, to);
      setJourneys((current) => [saved, ...current]);
      setMessage("Journey saved. Collect an observation whenever you travel.");
    } catch (requestError) {
      setError(toMessage(requestError));
    }
  }

  async function refreshJourney(journey: SavedJourney) {
    clearFeedback();
    setBusyJourneyId(journey.id);
    try {
      const refreshed = await api.refreshJourney(journey.id);
      setJourneys((current) =>
        current.map((item) => (item.id === refreshed.id ? refreshed : item))
      );
      setMessage(`Added a live observation for ${journey.name}.`);
    } catch (requestError) {
      setError(toMessage(requestError));
    } finally {
      setBusyJourneyId(null);
    }
  }

  async function deleteJourney(journey: SavedJourney) {
    clearFeedback();
    try {
      await api.deleteJourney(journey.id);
      setJourneys((current) =>
        current.filter((item) => item.id !== journey.id)
      );
      setMessage(`${journey.name} was removed.`);
    } catch (requestError) {
      setError(toMessage(requestError));
    }
  }

  async function logout() {
    clearFeedback();
    try {
      await api.logout();
      setUser(null);
      setJourneys([]);
      setMessage("Signed out.");
    } catch (requestError) {
      setError(toMessage(requestError));
    }
  }

  function clearFeedback() {
    setMessage(null);
    setError(null);
  }

  return (
    <div className="app-shell">
      <header className="site-header">
        <a className="brand" href="#top" aria-label="PendlerPuls home">
          <span className="brand-mark" aria-hidden="true">
            PP
          </span>
          <span>PendlerPuls</span>
        </a>
        <nav aria-label="Primary navigation">
          <a href="#check">Check a route</a>
          <a href="#saved">Saved routes</a>
        </nav>
        {user ? (
          <button className="text-button" type="button" onClick={logout}>
            Sign out
          </button>
        ) : (
          <a className="header-action" href="#account">
            Save routes
          </a>
        )}
      </header>

      <main id="top">
        <section className="hero">
          <div className="hero-copy">
            <p className="eyebrow">Norwegian transit, measured over time</p>
            <h1>
              Know the route.
              <span>Learn its rhythm.</span>
            </h1>
            <p className="hero-intro">
              Check the next public transport journey, save the routes you use,
              and build a small evidence-based picture of their reliability.
            </p>
            <a className="primary-button inline-button" href="#check">
              Check a journey
            </a>
          </div>

          <aside className="hero-panel" aria-label="Project summary">
            <div className="pulse-orbit" aria-hidden="true">
              <span />
              <span />
              <span />
            </div>
            <p className="eyebrow">Live source</p>
            <strong>Entur Journey Planner</strong>
            <dl>
              <div>
                <dt>Coverage</dt>
                <dd>All Norway</dd>
              </div>
              <div>
                <dt>Project focus</dt>
                <dd>Reliability</dd>
              </div>
              <div>
                <dt>Storage</dt>
                <dd>Your samples</dd>
              </div>
            </dl>
          </aside>
        </section>

        <section className="checker-section" id="check">
          <div className="section-heading">
            <div>
              <p className="eyebrow">Live journey check</p>
              <h2>Where are you going?</h2>
            </div>
            <p>
              Search Entur's national stop register. The route preview uses the
              next available public transport journey.
            </p>
          </div>

          <form className="route-form" onSubmit={previewJourney}>
            <LocationSearch
              label="From"
              placeholder="Oslo S"
              value={from}
              onChange={(location) => {
                setFrom(location);
                setPreview(null);
              }}
            />
            <div className="route-arrow" aria-hidden="true">
              &rarr;
            </div>
            <LocationSearch
              label="To"
              placeholder="Blindern"
              value={to}
              onChange={(location) => {
                setTo(location);
                setPreview(null);
              }}
            />
            <button
              className="primary-button"
              type="submit"
              disabled={isPreviewing}
            >
              {isPreviewing ? "Checking..." : "Check next journey"}
            </button>
          </form>

          {error && (
            <p className="feedback error" role="alert">
              {error}
            </p>
          )}
          {message && (
            <p className="feedback success" role="status">
              {message}
            </p>
          )}

          {preview && (
            <div className="preview-layout">
              <TripPreviewCard preview={preview} />
              <div className="save-card">
                <p className="eyebrow">Keep measuring</p>
                <h3>Save this route</h3>
                <p>
                  A saved route can collect a new observation every time you
                  check it.
                </p>
                <label htmlFor="journey-name">Journey name</label>
                <input
                  id="journey-name"
                  value={journeyName}
                  maxLength={80}
                  onChange={(event) => setJourneyName(event.target.value)}
                />
                <button
                  className="secondary-button full-width"
                  type="button"
                  onClick={saveCurrentJourney}
                  disabled={!user}
                >
                  {user ? "Save journey" : "Sign in below to save"}
                </button>
              </div>
            </div>
          )}
        </section>

        <section className="account-section" id="saved">
          <div className="saved-column">
            <div className="section-heading compact">
              <div>
                <p className="eyebrow">Personal dataset</p>
                <h2>Your saved routes</h2>
              </div>
              {user && <span className="signed-in-as">{user.email}</span>}
            </div>
            {user ? (
              <SavedJourneys
                journeys={journeys}
                busyId={busyJourneyId}
                onRefresh={refreshJourney}
                onDelete={deleteJourney}
              />
            ) : (
              <div className="locked-state">
                <span aria-hidden="true">+</span>
                <h3>No account required to check a route</h3>
                <p>
                  Create one only when you want to save routes and build a
                  reliability history.
                </p>
              </div>
            )}
          </div>

          {!user && (
            <aside className="auth-card" id="account">
              <p className="eyebrow">Optional account</p>
              <h2>{authMode === "register" ? "Start a route log" : "Welcome back"}</h2>
              <p>
                Sessions use an HTTP-only cookie. Passwords are hashed with
                PBKDF2 before storage.
              </p>

              <div className="auth-tabs" role="tablist" aria-label="Account action">
                <button
                  type="button"
                  role="tab"
                  aria-selected={authMode === "register"}
                  onClick={() => setAuthMode("register")}
                >
                  Create account
                </button>
                <button
                  type="button"
                  role="tab"
                  aria-selected={authMode === "login"}
                  onClick={() => setAuthMode("login")}
                >
                  Sign in
                </button>
              </div>

              <form onSubmit={submitAuth}>
                <label htmlFor="email">Email</label>
                <input
                  id="email"
                  type="email"
                  required
                  autoComplete="email"
                  value={email}
                  onChange={(event) => setEmail(event.target.value)}
                />
                <label htmlFor="password">Password</label>
                <input
                  id="password"
                  type="password"
                  required
                  minLength={10}
                  autoComplete={
                    authMode === "register" ? "new-password" : "current-password"
                  }
                  value={password}
                  onChange={(event) => setPassword(event.target.value)}
                />
                <button
                  className="primary-button full-width"
                  type="submit"
                  disabled={isAuthenticating}
                >
                  {isAuthenticating
                    ? "Working..."
                    : authMode === "register"
                      ? "Create account"
                      : "Sign in"}
                </button>
              </form>
            </aside>
          )}
        </section>
      </main>

      <footer className="site-footer">
        <div>
          <strong>PendlerPuls</strong>
          <span>A full-stack student portfolio project.</span>
        </div>
        <p>Transport data made available by Entur under NLOD.</p>
      </footer>
    </div>
  );
}

function toMessage(error: unknown): string {
  if (error instanceof Error) {
    return error.message;
  }

  return "Something unexpected happened.";
}

