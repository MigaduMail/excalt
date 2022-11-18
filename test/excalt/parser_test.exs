defmodule Excalt.ParserTest do
  use ExUnit.Case, async: true
  doctest Excalt.XML.Parser

  test "parses events from XML response" do
    # https://tools.ietf.org/html/rfc4791#section-7.8.1

    xml = """
    <?xml version="1.0" encoding="utf-8" ?>
    <D:multistatus xmlns:D="DAV:"
                xmlns:C="urn:ietf:params:xml:ns:caldav">
      <D:response>
        <D:href>http://cal.example.com/bernard/work/abcd2.ics</D:href>
        <D:propstat>
          <D:prop>
            <D:getetag>"fffff-abcd2"</D:getetag>
            <C:calendar-data>BEGIN:VCALENDAR
    VERSION:2.0
    BEGIN:VTIMEZONE
    LAST-MODIFIED:20040110T032845Z
    TZID:US/Eastern
    BEGIN:DAYLIGHT
    DTSTART:20000404T020000
    RRULE:FREQ=YEARLY;BYDAY=1SU;BYMONTH=4
    TZNAME:EDT
    TZOFFSETFROM:-0500
    TZOFFSETTO:-0400
    END:DAYLIGHT
    BEGIN:STANDARD
    DTSTART:20001026T020000
    RRULE:FREQ=YEARLY;BYDAY=-1SU;BYMONTH=10
    TZNAME:EST
    TZOFFSETFROM:-0400
    TZOFFSETTO:-0500
    END:STANDARD
    END:VTIMEZONE
    BEGIN:VEVENT
    DTSTART;TZID=US/Eastern:20060102T120000
    DURATION:PT1H
    RRULE:FREQ=DAILY;COUNT=5
    SUMMARY:Event #2
    UID:00959BC664CA650E933C892C@example.com
    END:VEVENT
    BEGIN:VEVENT
    DTSTART;TZID=US/Eastern:20060104T140000
    DURATION:PT1H
    RECURRENCE-ID;TZID=US/Eastern:20060104T120000
    SUMMARY:Event #2 bis
    UID:00959BC664CA650E933C892C@example.com
    END:VEVENT
    BEGIN:VEVENT
    DTSTART;TZID=US/Eastern:20060106T140000
    DURATION:PT1H
    RECURRENCE-ID;TZID=US/Eastern:20060106T120000
    SUMMARY:Event #2 bis bis
    UID:00959BC664CA650E933C892C@example.com
    END:VEVENT
    END:VCALENDAR
    </C:calendar-data>
          </D:prop>
          <D:status>HTTP/1.1 200 OK</D:status>
        </D:propstat>
      </D:response>
      <D:response>
        <D:href>http://cal.example.com/bernard/work/abcd3.ics</D:href>
        <D:propstat>
          <D:prop>
            <D:getetag>"fffff-abcd3"</D:getetag>
            <C:calendar-data>BEGIN:VCALENDAR
    VERSION:2.0
    PRODID:-//Example Corp.//CalDAV Client//EN
    BEGIN:VTIMEZONE
    LAST-MODIFIED:20040110T032845Z
    TZID:US/Eastern
    BEGIN:DAYLIGHT
    DTSTART:20000404T020000
    RRULE:FREQ=YEARLY;BYDAY=1SU;BYMONTH=4
    TZNAME:EDT
    TZOFFSETFROM:-0500
    TZOFFSETTO:-0400
    END:DAYLIGHT
    BEGIN:STANDARD
    DTSTART:20001026T020000
    RRULE:FREQ=YEARLY;BYDAY=-1SU;BYMONTH=10
    TZNAME:EST
    TZOFFSETFROM:-0400
    TZOFFSETTO:-0500
    END:STANDARD
    END:VTIMEZONE
    BEGIN:VEVENT
    DTSTART;TZID=US/Eastern:20060104T100000
    DURATION:PT1H
    SUMMARY:Event #3
    UID:DC6C50A017428C5216A2F1CD@example.com
    END:VEVENT
    END:VCALENDAR
    </C:calendar-data>
            </D:prop>
          <D:status>HTTP/1.1 200 OK</D:status>
        </D:propstat>
      </D:response>
    </D:multistatus>
    """

    actual = Excalt.XML.Parser.parse_events!(xml)

    expected = [
      %Excalt.Event{
        url: "http://cal.example.com/bernard/work/abcd2.ics",
        etag: "\"fffff-abcd2\"",
        icalendar: """
        BEGIN:VCALENDAR
        VERSION:2.0
        BEGIN:VTIMEZONE
        LAST-MODIFIED:20040110T032845Z
        TZID:US/Eastern
        BEGIN:DAYLIGHT
        DTSTART:20000404T020000
        RRULE:FREQ=YEARLY;BYDAY=1SU;BYMONTH=4
        TZNAME:EDT
        TZOFFSETFROM:-0500
        TZOFFSETTO:-0400
        END:DAYLIGHT
        BEGIN:STANDARD
        DTSTART:20001026T020000
        RRULE:FREQ=YEARLY;BYDAY=-1SU;BYMONTH=10
        TZNAME:EST
        TZOFFSETFROM:-0400
        TZOFFSETTO:-0500
        END:STANDARD
        END:VTIMEZONE
        BEGIN:VEVENT
        DTSTART;TZID=US/Eastern:20060102T120000
        DURATION:PT1H
        RRULE:FREQ=DAILY;COUNT=5
        SUMMARY:Event #2
        UID:00959BC664CA650E933C892C@example.com
        END:VEVENT
        BEGIN:VEVENT
        DTSTART;TZID=US/Eastern:20060104T140000
        DURATION:PT1H
        RECURRENCE-ID;TZID=US/Eastern:20060104T120000
        SUMMARY:Event #2 bis
        UID:00959BC664CA650E933C892C@example.com
        END:VEVENT
        BEGIN:VEVENT
        DTSTART;TZID=US/Eastern:20060106T140000
        DURATION:PT1H
        RECURRENCE-ID;TZID=US/Eastern:20060106T120000
        SUMMARY:Event #2 bis bis
        UID:00959BC664CA650E933C892C@example.com
        END:VEVENT
        END:VCALENDAR
        """
      },
      %Excalt.Event{
        url: "http://cal.example.com/bernard/work/abcd3.ics",
        etag: "\"fffff-abcd3\"",
        icalendar: """
        BEGIN:VCALENDAR
        VERSION:2.0
        PRODID:-//Example Corp.//CalDAV Client//EN
        BEGIN:VTIMEZONE
        LAST-MODIFIED:20040110T032845Z
        TZID:US/Eastern
        BEGIN:DAYLIGHT
        DTSTART:20000404T020000
        RRULE:FREQ=YEARLY;BYDAY=1SU;BYMONTH=4
        TZNAME:EDT
        TZOFFSETFROM:-0500
        TZOFFSETTO:-0400
        END:DAYLIGHT
        BEGIN:STANDARD
        DTSTART:20001026T020000
        RRULE:FREQ=YEARLY;BYDAY=-1SU;BYMONTH=10
        TZNAME:EST
        TZOFFSETFROM:-0400
        TZOFFSETTO:-0500
        END:STANDARD
        END:VTIMEZONE
        BEGIN:VEVENT
        DTSTART;TZID=US/Eastern:20060104T100000
        DURATION:PT1H
        SUMMARY:Event #3
        UID:DC6C50A017428C5216A2F1CD@example.com
        END:VEVENT
        END:VCALENDAR
        """
      }
    ]

    assert Enum.sort(actual) == Enum.sort(expected)
  end

  test "parses calendars from XML response" do
    xml = """
    <?xml version="1.0" encoding="utf-8"?>
        <d:multistatus xmlns:d="DAV:" xmlns:s="http://sabredav.org/ns" xmlns:cal="urn:ietf:params:xml:ns:caldav" xmlns:cs="http://calendarserver.org/ns/" xmlns:card="urn:ietf:params:xml:ns:carddav">
      <d:response>
            <d:href>/calendars/blublub/</d:href>
        <d:propstat>
          <d:prop>
            <d:resourcetype>
              <d:collection/>
            </d:resourcetype>
          </d:prop>
          <d:status>HTTP/1.1 200 OK</d:status>
        </d:propstat>
        <d:propstat>
          <d:prop>
            <cal:calendar-description/>
            <cal:supported-calendar-component-set/>
            <d:displayname/>
            <cal:calendar-timezone/>
          </d:prop>
          <d:status>HTTP/1.1 404 Not Found</d:status>
        </d:propstat>
      </d:response>
      <d:response>
        <d:href>/calendars/blublub/journals/</d:href>
        <d:propstat>
          <d:prop>
            <cal:supported-calendar-component-set>
              <cal:comp name="VJOURNAL"/>
            </cal:supported-calendar-component-set>
            <d:resourcetype>
              <d:collection/>
              <cal:calendar/>
              <cs:shared-owner/>
            </d:resourcetype>
            <d:displayname>Journals</d:displayname>
          </d:prop>
          <d:status>HTTP/1.1 200 OK</d:status>
        </d:propstat>
        <d:propstat>
          <d:prop>
            <cal:calendar-description/>
            <cal:calendar-timezone/>
          </d:prop>
          <d:status>HTTP/1.1 404 Not Found</d:status>
        </d:propstat>
      </d:response>
      <d:response>
        <d:href>/calendars/blublub/home/</d:href>
        <d:propstat>
          <d:prop>
            <cal:supported-calendar-component-set>
              <cal:comp name="VEVENT"/>
            </cal:supported-calendar-component-set>
            <d:resourcetype>
              <d:collection/>
              <cal:calendar/>
              <cs:shared-owner/>
            </d:resourcetype>
            <d:displayname>Home</d:displayname>
            <cal:calendar-timezone>BEGIN:VCALENDAR
    VERSION:2.0
    PRODID:-//Apple Inc.//macOS 12.4//EN
    CALSCALE:GREGORIAN
    BEGIN:VTIMEZONE
    TZID:Europe/Zurich
    BEGIN:DAYLIGHT
    TZOFFSETFROM:+0100
    RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=-1SU
    DTSTART:19810329T020000
    TZNAME:CEST
    TZOFFSETTO:+0200
    END:DAYLIGHT
    BEGIN:STANDARD
    TZOFFSETFROM:+0200
    RRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU
    DTSTART:19961027T030000
    TZNAME:CET
    TZOFFSETTO:+0100
    END:STANDARD
    END:VTIMEZONE
    END:VCALENDAR
    </cal:calendar-timezone>
          </d:prop>
          <d:status>HTTP/1.1 200 OK</d:status>
        </d:propstat>
        <d:propstat>
          <d:prop>
            <cal:calendar-description/>
          </d:prop>
          <d:status>HTTP/1.1 404 Not Found</d:status>
        </d:propstat>
      </d:response>
      <d:response>
        <d:href>/calendars/blublub/tasks/</d:href>
        <d:propstat>
          <d:prop>
            <cal:supported-calendar-component-set>
              <cal:comp name="VTODO"/>
            </cal:supported-calendar-component-set>
            <d:resourcetype>
              <d:collection/>
              <cal:calendar/>
              <cs:shared-owner/>
            </d:resourcetype>
            <d:displayname>Tasks</d:displayname>
          </d:prop>
          <d:status>HTTP/1.1 200 OK</d:status>
        </d:propstat>
        <d:propstat>
          <d:prop>
            <cal:calendar-description/>
            <cal:calendar-timezone/>
          </d:prop>
          <d:status>HTTP/1.1 404 Not Found</d:status>
        </d:propstat>
      </d:response>
      <d:response>
        <d:href>/calendars/blublub/work/</d:href>
        <d:propstat>
          <d:prop>
            <cal:supported-calendar-component-set>
              <cal:comp name="VEVENT"/>
            </cal:supported-calendar-component-set>
            <d:resourcetype>
              <d:collection/>
              <cal:calendar/>
              <cs:shared-owner/>
            </d:resourcetype>
            <d:displayname>Work</d:displayname>
            <cal:calendar-timezone>BEGIN:VCALENDAR
    VERSION:2.0
    PRODID:-//Apple Inc.//macOS 12.4//EN
    CALSCALE:GREGORIAN
    BEGIN:VTIMEZONE
    TZID:Europe/Zurich
    BEGIN:DAYLIGHT
    TZOFFSETFROM:+0100
    RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=-1SU
    DTSTART:19810329T020000
    TZNAME:CEST
    TZOFFSETTO:+0200
    END:DAYLIGHT
    BEGIN:STANDARD
    TZOFFSETFROM:+0200
    RRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU
    DTSTART:19961027T030000
    TZNAME:CET
    TZOFFSETTO:+0100
    END:STANDARD
    END:VTIMEZONE
    END:VCALENDAR
    </cal:calendar-timezone>
          </d:prop>
          <d:status>HTTP/1.1 200 OK</d:status>
        </d:propstat>
        <d:propstat>
          <d:prop>
            <cal:calendar-description/>
          </d:prop>
          <d:status>HTTP/1.1 404 Not Found</d:status>
        </d:propstat>
      </d:response>
      <d:response>
        <d:href>/calendars/blublub/inbox/</d:href>
        <d:propstat>
          <d:prop>
            <d:resourcetype>
              <d:collection/>
              <cal:schedule-inbox/>
            </d:resourcetype>
          </d:prop>
          <d:status>HTTP/1.1 200 OK</d:status>
        </d:propstat>
        <d:propstat>
          <d:prop>
            <cal:calendar-description/>
            <cal:supported-calendar-component-set/>
            <d:displayname/>
            <cal:calendar-timezone/>
          </d:prop>
          <d:status>HTTP/1.1 404 Not Found</d:status>
        </d:propstat>
      </d:response>
      <d:response>
        <d:href>/calendars/blublub/outbox/</d:href>
        <d:propstat>
          <d:prop>
            <d:resourcetype>
              <d:collection/>
              <cal:schedule-outbox/>
            </d:resourcetype>
      </d:prop>
      <d:status>HTTP/1.1 200 OK</d:status>
    </d:propstat>
    <d:propstat>
      <d:prop>
        <cal:calendar-description/>
        <cal:supported-calendar-component-set/>
        <d:displayname/>
        <cal:calendar-timezone/>
      </d:prop>
      <d:status>HTTP/1.1 404 Not Found</d:status>
    </d:propstat>
    </d:response>
    </d:multistatus>
    """

    actual = Excalt.XML.Parser.parse_calendars!(xml) |> Enum.sort()

    expected =
      [
        %Excalt.Calendar{name: nil, timezone: nil, type: "", url: "/calendars/blublub/"},
        %Excalt.Calendar{
          name: "Journals",
          timezone: nil,
          type: "VJOURNAL",
          url: "/calendars/blublub/journals/"
        },
        %Excalt.Calendar{
          name: "Home",
          timezone:
            "BEGIN:VCALENDAR\nVERSION:2.0\nPRODID:-//Apple Inc.//macOS 12.4//EN\nCALSCALE:GREGORIAN\nBEGIN:VTIMEZONE\nTZID:Europe/Zurich\nBEGIN:DAYLIGHT\nTZOFFSETFROM:+0100\nRRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=-1SU\nDTSTART:19810329T020000\nTZNAME:CEST\nTZOFFSETTO:+0200\nEND:DAYLIGHT\nBEGIN:STANDARD\nTZOFFSETFROM:+0200\nRRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU\nDTSTART:19961027T030000\nTZNAME:CET\nTZOFFSETTO:+0100\nEND:STANDARD\nEND:VTIMEZONE\nEND:VCALENDAR\n",
          type: "VEVENT",
          url: "/calendars/blublub/home/"
        },
        %Excalt.Calendar{
          name: "Tasks",
          timezone: nil,
          type: "VTODO",
          url: "/calendars/blublub/tasks/"
        },
        %Excalt.Calendar{
          name: "Work",
          timezone:
            "BEGIN:VCALENDAR\nVERSION:2.0\nPRODID:-//Apple Inc.//macOS 12.4//EN\nCALSCALE:GREGORIAN\nBEGIN:VTIMEZONE\nTZID:Europe/Zurich\nBEGIN:DAYLIGHT\nTZOFFSETFROM:+0100\nRRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=-1SU\nDTSTART:19810329T020000\nTZNAME:CEST\nTZOFFSETTO:+0200\nEND:DAYLIGHT\nBEGIN:STANDARD\nTZOFFSETFROM:+0200\nRRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU\nDTSTART:19961027T030000\nTZNAME:CET\nTZOFFSETTO:+0100\nEND:STANDARD\nEND:VTIMEZONE\nEND:VCALENDAR\n",
          type: "VEVENT",
          url: "/calendars/blublub/work/"
        },
        %Excalt.Calendar{
          name: nil,
          timezone: nil,
          type: "",
          url: "/calendars/blublub/inbox/"
        },
        %Excalt.Calendar{
          name: nil,
          timezone: nil,
          type: "",
          url: "/calendars/blublub/outbox/"
        }
      ]
      |> Enum.sort()

    assert actual == expected
  end

  test "parses principals from XML response" do
    # https://tools.ietf.org/html/rfc4791#section-6.2

    xml = """
    <?xml version="1.0"?>
    <d:multistatus xmlns:d="DAV:" xmlns:s="http://sabredav.org/ns" xmlns:cal="urn:ietf:params:xml:ns:caldav" xmlns:cs="http://calendarserver.org/ns/" xmlns:card="urn:ietf:params:xml:ns:carddav">
    <d:response>
    <d:href>/</d:href>
    <d:propstat>
      <d:prop>
        <d:resourcetype>
          <d:collection/>
        </d:resourcetype>
        <d:current-user-principal>
          <d:href>/principals/blubb/</d:href>
        </d:current-user-principal>
      </d:prop>
      <d:status>HTTP/1.1 200 OK</d:status>
    </d:propstat>
    </d:response>
    <d:response>
    <d:href>/principals/</d:href>
    <d:propstat>
      <d:prop>
        <d:resourcetype>
          <d:collection/>
        </d:resourcetype>
        <d:current-user-principal>
          <d:href>/principals/blubb/</d:href>
        </d:current-user-principal>
      </d:prop>
      <d:status>HTTP/1.1 200 OK</d:status>
    </d:propstat>
    </d:response>
    <d:response>
    <d:href>/calendars/</d:href>
    <d:propstat>
      <d:prop>
        <d:resourcetype>
          <d:collection/>
        </d:resourcetype>
        <d:current-user-principal>
          <d:href>/principals/blubb/</d:href>
        </d:current-user-principal>
      </d:prop>
      <d:status>HTTP/1.1 200 OK</d:status>
    </d:propstat>
    </d:response>
    <d:response>
    <d:href>/addressbooks/</d:href>
    <d:propstat>
      <d:prop>
        <d:resourcetype>
          <d:collection/>
        </d:resourcetype>
        <d:current-user-principal>
          <d:href>/principals/blubb/</d:href>
        </d:current-user-principal>
      </d:prop>
      <d:status>HTTP/1.1 200 OK</d:status>
    </d:propstat>
    </d:response>
    </d:multistatus>
    """

    actual = Excalt.XML.Parser.parse_principals!(xml) |> Enum.sort()

    expected =
      [
        %Excalt.Principal{
          current_user_principal: "/principals/blubb/",
          url: "/",
          resource_type: "collection"
        },
        %Excalt.Principal{
          current_user_principal: "/principals/blubb/",
          url: "/principals/",
          resource_type: "collection"
        },
        %Excalt.Principal{
          current_user_principal: "/principals/blubb/",
          url: "/calendars/",
          resource_type: "collection"
        },
        %Excalt.Principal{
          current_user_principal: "/principals/blubb/",
          url: "/addressbooks/",
          resource_type: "collection"
        }
      ]
      |> Enum.sort()

    assert actual == expected
  end

  test "parses todos from XML response" do
    xml = """
    <?xml version="1.0"?>
        <d:multistatus xmlns:d="DAV:" xmlns:s="http://sabredav.org/ns" xmlns:cal="urn:ietf:params:xml:ns:caldav" xmlns:cs="http://calendarserver.org/ns/" xmlns:card="urn:ietf:params:xml:ns:carddav">
        <d:response>
          <d:href>/calendars/blubb/tasks/</d:href>
            <d:propstat>
              <d:prop>
            <d:getetag/>
            <cal:calendar-data/>
              </d:prop>
              <d:status>HTTP/1.1 404 Not Found</d:status>
        </d:propstat>
      </d:response>
          <d:response>
            <d:href>/calendars/blubb/tasks/03113BF5-2202-40C6-8584-88DA44CAC7F7.ics</d:href>
        <d:propstat>
          <d:prop>
                <d:getetag>"6fcf7920d900cc279d39ef67b50e76dd"</d:getetag>
                <cal:calendar-data>BEGIN:VCALENDAR
    CALSCALE:GREGORIAN
    PRODID:-//Apple Inc.//iOS 15.6.1//EN
        VERSION:2.0
        BEGIN:VTODO
    COMPLETED:20221006T142547Z
    CREATED:20220814T184605Z
        DESCRIPTION:CLOSED: [2022-10-06 Thu 16:25]
        DTSTAMP:20221006T142547Z
    DTSTART:20220815T120000
    DUE:20220815T120000
        LAST-MODIFIED:20221006T142547Z
        PERCENT-COMPLETE:100
    STATUS:COMPLETED
    SUMMARY:fishing barracudas
        UID:03113BF5-2202-40C6-8584-88DA44CAC7F7
        BEGIN:VALARM
    ACKNOWLEDGED:20220815T144011Z
    ACTION:DISPLAY
        DESCRIPTION:Reminder
        TRIGGER;VALUE=DATE-TIME:20220815T100000Z
    UID:7D703933-B970-4163-9AD5-12316C02D2BF
    X-WR-ALARMUID:7D703933-B970-4163-9AD5-12316C02D2BF
        END:VALARM
        END:VTODO
    END:VCALENDAR
    </cal:calendar-data>
              </d:prop>
              <d:status>HTTP/1.1 200 OK</d:status>
        </d:propstat>
      </d:response>
    </d:multistatus>
    """

    actual = Excalt.XML.Parser.parse_todos!(xml) |> Enum.sort()

    expected =
      [
        %Excalt.Todo{etag: nil, icalendar: nil, url: "/calendars/blubb/tasks/"},
        %Excalt.Todo{
          etag: "\"6fcf7920d900cc279d39ef67b50e76dd\"",
          icalendar:
            "BEGIN:VCALENDAR\nCALSCALE:GREGORIAN\nPRODID:-//Apple Inc.//iOS 15.6.1//EN\n    VERSION:2.0\n    BEGIN:VTODO\nCOMPLETED:20221006T142547Z\nCREATED:20220814T184605Z\n    DESCRIPTION:CLOSED: [2022-10-06 Thu 16:25]\n    DTSTAMP:20221006T142547Z\nDTSTART:20220815T120000\nDUE:20220815T120000\n    LAST-MODIFIED:20221006T142547Z\n    PERCENT-COMPLETE:100\nSTATUS:COMPLETED\nSUMMARY:fishing barracudas\n    UID:03113BF5-2202-40C6-8584-88DA44CAC7F7\n    BEGIN:VALARM\nACKNOWLEDGED:20220815T144011Z\nACTION:DISPLAY\n    DESCRIPTION:Reminder\n    TRIGGER;VALUE=DATE-TIME:20220815T100000Z\nUID:7D703933-B970-4163-9AD5-12316C02D2BF\nX-WR-ALARMUID:7D703933-B970-4163-9AD5-12316C02D2BF\n    END:VALARM\n    END:VTODO\nEND:VCALENDAR\n",
          url: "/calendars/blubb/tasks/03113BF5-2202-40C6-8584-88DA44CAC7F7.ics"
        }
      ]
      |> Enum.sort()

    assert actual == expected
  end
end
