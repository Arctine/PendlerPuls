import { delayTone, formatDelay, formatTime } from "../formatters";
import type { TripPreview } from "../types";

interface TripPreviewCardProps {
  preview: TripPreview;
}

export function TripPreviewCard({ preview }: TripPreviewCardProps) {
  const tone = delayTone(preview.delayMinutes);

  return (
    <article className="preview-card" aria-live="polite">
      <div className="preview-topline">
        <span className={`status-pill ${tone}`}>
          <span className="status-dot" aria-hidden="true" />
          {formatDelay(preview.delayMinutes)}
        </span>
        <span className="mode-list">{preview.modes.join(" / ")}</span>
      </div>

      <div className="time-row">
        <div>
          <span className="time">{formatTime(preview.expectedStartTime)}</span>
          <span>{preview.fromName}</span>
        </div>
        <div className="route-line" aria-hidden="true">
          <span />
          <strong>{preview.durationMinutes} min</strong>
          <span />
        </div>
        <div className="align-right">
          <span className="time">{formatTime(preview.expectedEndTime)}</span>
          <span>{preview.toName}</span>
        </div>
      </div>

      <footer>
        <span>Lines {preview.lineSummary}</span>
        <span>{preview.attribution}</span>
      </footer>
    </article>
  );
}

