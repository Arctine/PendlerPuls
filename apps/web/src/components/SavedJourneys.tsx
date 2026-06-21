import { type CSSProperties } from "react";
import {
  averageDelay,
  bestDelay,
  delayTone,
  delayTrend,
  formatDelay,
  formatTime,
  onTimeRate,
  reliabilityLabel,
  reliabilityScore,
  worstDelay
} from "../formatters";
import type { SavedJourney } from "../types";

interface SavedJourneysProps {
  journeys: SavedJourney[];
  busyId: string | null;
  onRefresh: (journey: SavedJourney) => void;
  onExport: (journey: SavedJourney) => void;
  onDelete: (journey: SavedJourney) => void;
}

export function SavedJourneys({
  journeys,
  busyId,
  onRefresh,
  onExport,
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
        const delays = journey.observations.map((item) => item.delayMinutes);
        const average = averageDelay(delays);
        const score = reliabilityScore(delays);
        const onTime = onTimeRate(delays);
        const best = bestDelay(delays);
        const worst = worstDelay(delays);
        const trend = delayTrend(delays);
        const canExport = journey.observations.length > 0;

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

            <div className="journey-insights" aria-label={`${journey.name} reliability summary`}>
              <div className="score-tile">
                <span>Sample score</span>
                <strong>{score === null ? "--" : `${score}/100`}</strong>
                <small>{reliabilityLabel(score)}</small>
              </div>
              <div>
                <span>On-time rate</span>
                <strong>{onTime === null ? "--" : `${onTime}%`}</strong>
              </div>
              <div>
                <span>Best / worst</span>
                <strong>
                  {best === null || worst === null
                    ? "--"
                    : `${formatDelay(best)} / ${formatDelay(worst)}`}
                </strong>
              </div>
              <div>
                <span>Trend</span>
                <strong className={`trend-${trend}`}>{trend}</strong>
              </div>
            </div>

            {journey.observations.length > 0 && (
              <div
                className="observation-bars"
                aria-label={`Recent delay samples for ${journey.name}`}
              >
                {journey.observations.slice(0, 8).map((observation) => {
                  const height = Math.min(
                    74,
                    16 + Math.abs(observation.delayMinutes) * 7
                  );

                  return (
                    <span
                      key={observation.id}
                      className={`observation-bar ${delayTone(observation.delayMinutes)}`}
                      style={{ "--bar-height": `${height}px` } as CSSProperties}
                      title={`${formatTime(observation.collectedAtUtc)}: ${formatDelay(
                        observation.delayMinutes
                      )}`}
                    />
                  );
                })}
              </div>
            )}

            {latest && (
              <p className="latest-note">
                Last checked {formatTime(latest.collectedAtUtc)} via{" "}
                {latest.lineSummary}
              </p>
            )}

            <div className="journey-actions">
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
              <button
                className="secondary-button export-button"
                type="button"
                disabled={!canExport}
                onClick={() => onExport(journey)}
              >
                Export CSV
              </button>
            </div>
          </article>
        );
      })}
    </div>
  );
}
