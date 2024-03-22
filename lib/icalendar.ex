defmodule ICalendar do
  @moduledoc """
  Generating ICalendars.
  """

  defstruct events: []
  defdelegate to_ics(events, options \\ []), to: ICalendar.Serialize
  defdelegate from_ics(events), to: ICalendar.Deserialize

  @doc """
  To create a Phoenix/Plug controller and view that output ics format:

  Add to your config.exs:

      config :phoenix, :format_encoders,
        ics: ICalendar

  In your controller use:

      calendar = %ICalendar{ events: events }
      render(conn, "index.ics", calendar: calendar)

  The important part here is `.ics`. This triggers the `format_encoder`.

  In your view can put:

      def render("index.ics", %{calendar: calendar}) do
        calendar
      end

  """
  def encode_to_iodata(calendar, options \\ []) do
    {:ok, encode_to_iodata!(calendar, options)}
  end

  def encode_to_iodata!(calendar, _options \\ []) do
    to_ics(calendar)
  end
end

defimpl ICalendar.Serialize, for: ICalendar do
  def to_ics(calendar, options \\ []) do
    events = Enum.map(calendar.events, &ICalendar.Serialize.to_ics/1)
    vendor = Keyword.get(options, :vendor, "Elixir ICalendar")

    """
    BEGIN:VCALENDAR
    CALSCALE:GREGORIAN
    VERSION:2.0
    PRODID:-//Elixir ICalendar//#{vendor}//EN
    BEGIN:VTIMEZONE
    TZID:Europe/Berlin
    LAST-MODIFIED:20231222T233358Z
    TZURL:https://www.tzurl.org/zoneinfo-outlook/Europe/Berlin
    X-LIC-LOCATION:Europe/Berlin
    BEGIN:DAYLIGHT
    TZNAME:CEST
    TZOFFSETFROM:+0100
    TZOFFSETTO:+0200
    DTSTART:19700329T020000
    RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=-1SU
    END:DAYLIGHT
    BEGIN:STANDARD
    TZNAME:CET
    TZOFFSETFROM:+0200
    TZOFFSETTO:+0100
    DTSTART:19701025T030000
    RRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU
    END:STANDARD
    END:VTIMEZONE
    #{events}END:VCALENDAR
    """
  end
end
