defmodule Excalt.XML.Builder do
  @moduledoc """
  Builds the xml used to query the caldav server.
  """

  @doc """
  Builds the XML request for listing calendar collections on calendar server.
  It requests description, timezone, displayname, supported components of the calendar collection (VEVENT, VTODO, VJOURNALS etc..).
  """
  @spec calendar_list() :: String.t()
  def calendar_list do
    Saxy.XML.element(
      "D:propfind",
      [
        "xmlns:D": "DAV:",
        "xmlns:C": "urn:ietf:params:xml:ns:caldav"
      ],
      Saxy.XML.element("D:prop", [], [
        Saxy.XML.element("C:calendar-description", [], ""),
        Saxy.XML.element("C:supported-calendar-component-set", [], ""),
        Saxy.XML.element("D:displayname", [], ""),
        Saxy.XML.element("C:calendar-timezone", [], "")
      ])
    )
    |> Saxy.encode!([])
  end

  @doc """
  Builds XML request for listing events from a calendar collections.
  Gets only the VEVENT in VCALENDAR object.
  """
  @spec event_list() :: String.t()
  def event_list() do
    el =
      Saxy.XML.element(
        "D:propfind",
        [
          "xmlns:D": "DAV:",
          "xmlns:C": "urn:ietf:params:xml:ns:caldav"
        ],
        [
          Saxy.XML.element(
            "D:prop",
            [],
            [
              Saxy.XML.element("D:getetag", [], ""),
              Saxy.XML.element("C:calendar-data", [], "")
            ]
          ),
          Saxy.XML.element("C:filter", [], [
            Saxy.XML.element("C:comp-filter", [name: "VCALENDAR"], [
              Saxy.XML.element("C:comp-filter", [name: "VEVENT"], [])
            ])
          ])
        ]
      )

    Saxy.encode!(el, [])
  end

  def event_list(from, to) do
    el =
      if is_nil(from) or is_nil(to) do
        Saxy.XML.element(
          "C:calendar-query",
          [
            "xmlns:D": "DAV:",
            "xmlns:C": "urn:ietf:params:xml:ns:caldav"
          ],
          [
            Saxy.XML.element(
              "D:prop",
              [],
              [
                Saxy.XML.element("D:getetag", [], ""),
                Saxy.XML.element("C:calendar-data", [], "")
              ]
            ),
            Saxy.XML.element("C:filter", [], [
              Saxy.XML.element("C:comp-filter", [name: "VCALENDAR"], [
                Saxy.XML.element("C:comp-filter", [name: "VEVENT"], [])
              ])
            ])
          ]
        )
      else
        Saxy.XML.element(
          "C:calendar-query",
          [
            "xmlns:D": "DAV:",
            "xmlns:C": "urn:ietf:params:xml:ns:caldav"
          ],
          [
            Saxy.XML.element(
              "D:prop",
              [],
              [
                Saxy.XML.element("D:getetag", [], ""),
                Saxy.XML.element("C:calendar-data", [], "")
              ]
            ),
            Saxy.XML.element("C:filter", [], [
              Saxy.XML.element("C:comp-filter", [name: "VCALENDAR"], [
                Saxy.XML.element("C:comp-filter", [name: "VEVENT"], [
                  Saxy.XML.element(
                    "C:time-range",
                    [start: format_datetime(from), end: format_datetime(to)],
                    ""
                  )
                ])
              ])
            ])
          ]
        )
      end

    Saxy.encode!(el, [])
  end

  def todo_list do
    el =
      Saxy.XML.element(
        "C:calendar-query",
        [
          "xmlns:D": "DAV:",
          "xmlns:C": "urn:ietf:params:xml:ns:caldav"
        ],
        [
          Saxy.XML.element(
            "D:prop",
            [],
            [
              Saxy.XML.element("D:getetag", [], ""),
              Saxy.XML.element("C:calendar-data", [], "")
            ]
          ),
          Saxy.XML.element("C:filter", [], [
            Saxy.XML.element("C:comp-filter", [name: "VCALENDAR"], [
              Saxy.XML.element("C:comp-filter", [name: "VTODO"], [])
            ])
          ])
        ]
      )

    Saxy.encode!(el, [])
  end

  defp format_datetime(datetime) do
    DateTime.shift_zone!(datetime, "Etc/UTC")
    |> DateTime.truncate(:second)
    |> DateTime.to_iso8601(:basic)
  end
end
