import { useEffect, useId, useState } from "react";
import { api } from "../api";
import type { LocationReference } from "../types";

interface LocationSearchProps {
  label: string;
  placeholder: string;
  value: LocationReference | null;
  onChange: (location: LocationReference | null) => void;
}

export function LocationSearch({
  label,
  placeholder,
  value,
  onChange
}: LocationSearchProps) {
  const inputId = useId();
  const listId = `${inputId}-results`;
  const [query, setQuery] = useState(value?.label ?? "");
  const [results, setResults] = useState<LocationReference[]>([]);
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    if (value && query === value.label) {
      setResults([]);
      return;
    }

    if (query.trim().length < 2) {
      setResults([]);
      return;
    }

    const controller = new AbortController();
    const timer = window.setTimeout(async () => {
      setIsLoading(true);
      try {
        setResults(await api.locations(query.trim(), controller.signal));
      } catch (error) {
        if (!(error instanceof DOMException && error.name === "AbortError")) {
          setResults([]);
        }
      } finally {
        setIsLoading(false);
      }
    }, 250);

    return () => {
      window.clearTimeout(timer);
      controller.abort();
    };
  }, [query, value]);

  function select(location: LocationReference) {
    setQuery(location.label);
    setResults([]);
    onChange(location);
  }

  return (
    <div className="location-search">
      <label htmlFor={inputId}>{label}</label>
      <div className="input-shell">
        <span aria-hidden="true" className="input-dot" />
        <input
          id={inputId}
          value={query}
          placeholder={placeholder}
          autoComplete="off"
          role="combobox"
          aria-autocomplete="list"
          aria-controls={listId}
          aria-expanded={results.length > 0}
          onChange={(event) => {
            setQuery(event.target.value);
            onChange(null);
          }}
        />
        {isLoading && <span className="input-status">Searching</span>}
      </div>

      {results.length > 0 && (
        <ul className="search-results" id={listId} role="listbox">
          {results.map((location) => (
            <li key={location.id} role="option" aria-selected="false">
              <button type="button" onClick={() => select(location)}>
                <strong>{location.name}</strong>
                <span>{location.label}</span>
              </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}

