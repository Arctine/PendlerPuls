using System.Globalization;
using System.Text;
using PendlerPuls.Api.Models;

namespace PendlerPuls.Api.Services;

public sealed class ObservationCsvExporter
{
    public string BuildCsv(SavedJourney journey)
    {
        var csv = new StringBuilder();
        csv.AppendLine("CollectedAtUtc,ExpectedStartTime,ExpectedEndTime,DurationMinutes,DelayMinutes,LineSummary");

        foreach (var observation in journey.Observations.OrderBy(item => item.CollectedAtUtc))
        {
            csv.Append(FormatDate(observation.CollectedAtUtc));
            csv.Append(',');
            csv.Append(FormatDate(observation.ExpectedStartTime));
            csv.Append(',');
            csv.Append(FormatDate(observation.ExpectedEndTime));
            csv.Append(',');
            csv.Append(observation.DurationMinutes.ToString(CultureInfo.InvariantCulture));
            csv.Append(',');
            csv.Append(observation.DelayMinutes.ToString(CultureInfo.InvariantCulture));
            csv.Append(',');
            csv.Append(Escape(observation.LineSummary));
            csv.AppendLine();
        }

        return csv.ToString();
    }

    public string BuildFileName(string journeyName)
    {
        var safeName = new string(journeyName
            .ToLowerInvariant()
            .Select(character =>
                char.IsLetterOrDigit(character)
                    ? character
                    : character is ' ' or '-' or '_' ? '-' : '\0')
            .Where(character => character != '\0')
            .ToArray());

        safeName = string.Join(
            '-',
            safeName.Split('-', StringSplitOptions.RemoveEmptyEntries));

        if (string.IsNullOrWhiteSpace(safeName))
        {
            safeName = "journey";
        }

        if (safeName.Length > 48)
        {
            safeName = safeName[..48].Trim('-');
        }

        return $"pendlerpuls-{safeName}-observations.csv";
    }

    private static string FormatDate(DateTimeOffset value)
    {
        return value.ToString("O", CultureInfo.InvariantCulture);
    }

    private static string Escape(string value)
    {
        if (!value.Contains('"')
            && !value.Contains(',')
            && !value.Contains('\r')
            && !value.Contains('\n'))
        {
            return value;
        }

        return $"\"{value.Replace("\"", "\"\"", StringComparison.Ordinal)}\"";
    }
}
