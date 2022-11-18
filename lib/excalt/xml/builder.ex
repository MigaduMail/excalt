defmodule Excalt.XML.Builder do
  @moduledoc nil

  import Saxy.XML

  def calendar_list do
    el =
      Saxy.XML.element(
        "D:propfind",
        [
          "xmlns:D": "DAV:",
          "xmlns:cs": "https://cdav.migadu.com/ns/",
          "xmlns:C": "urn:ietf:params:xml:ns:caldav"
        ],
        Saxy.XML.element("D:prop", [], [
          Saxy.XML.element("C:calendar-description", [], ""),
          Saxy.XML.element("C:supported-calendar-component-set", [], ""),
          Saxy.XML.element("D:displayname", [], ""),
          Saxy.XML.element("C:calendar-timezone", [], "")
        ])
      )

    Saxy.encode!(el, [])
  end
end
