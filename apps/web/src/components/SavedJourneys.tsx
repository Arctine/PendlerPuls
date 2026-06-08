import { averageDelay, delayTone, formatDelay, formatTime } from "../formatters";
import type { SavedJourney } from "../types";

interface SavedJourneysProps {
  journeys: SavedJourney[];
  busyId: string | null;
  onRefresh: (journey: SavedJourney) => void;
  onDelete: (journey: SavedJourney) => void;
}

export function SavedJourneys({
  journeys,
  busyId,
  onRefresh,
  onDelete
}: SavedJourneysProps) {
  if (journeys.length === 0) {
    return (
      <div className="empty-state">
        <span>01</span>
        <p>Save your first route, then collect observations when you travel.</p>
      </div>
    );
  }

  return (
    <div className="journey-list">
      {journeys.map((journey) => {
        const latest = journey.observations[0];
        const average = averageDelay(
          journey.observations.map((item) => item.delayMinutes)
        );

        return (
          <article className="journey-card" key={journey.id}>
            <div className="journey-heading">
              <div>
                <p className="eyebrow">Saved route</p>
                <h3>{journey.name}</h3>
              </div>
              <button
                className="icon-button"
                type="button"
                aria-label={`Delete ${journey.name}`}
                onClick={() => onDelete(journey)}
              >
                x
              </button>
            </div>

            <p className="journey-route">
              {journey.from.name} <span aria-hidden="true">to</span>{" "}
              {journey.to.name}
            </p>

            <div className="journey-metrics">
              <div>
                <span>Latest</span>
                <strong className={latest ? delayTone(latest.delayMinutes) : ""}>
                  {latest ? formatDelay(latest.delayMinutes) : "No sample"}
                </strong>
              </div>
              <div>
                <span>Average</span>
                <strong>{average === null ? "--" : formatDelay(average)}</strong>
              </div>
              <div>
                <span>Samples</span>
                <strong>{journey.observations.length}</strong>
              </div>
            </div>

            {latest && (
              <p className="latest-note">
                Last checked {formatTime(latest.collectedAtUtc)} via{" "}
                {latest.lineSummary}
              </p>
            )}

            <button
              className="secondary-button full-width"
              type="button"
              disabled={busyId === journey.id}
              onClick={() => onRefresh(journey)}
            >
              {busyId === journey.id
                ? "Checking live data..."
                : "Collect new observation"}
            </button>
          </article>
        );
      })}
    </div>
  );
}

