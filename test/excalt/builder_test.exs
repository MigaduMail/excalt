defmodule Excalt.BuilderTest do
  use ExUnit.Case, async: true
  alias Excalt.XML.Builder

  test "XML request for requesting calendar collections from server" do
    request =
      """
      <?xml version="1.0"?>
      <D:propfind xmlns:D="DAV:" xmlns:C="urn:ietf:params:xml:ns:caldav">
      <D:prop>
      <C:calendar-description>
      </C:calendar-description>
      <C:supported-calendar-component-set>
      </C:supported-calendar-component-set>
      <D:displayname>
      </D:displayname>
      <C:calendar-timezone>
      </C:calendar-timezone>
      </D:prop>
      </D:propfind>
      """
      |> String.replace("\n", "")

    assert request == Builder.calendar_list()
  end

  describe "XML request for events" do
    test "all events" do
    end

    test "timerange events"
  end
end
