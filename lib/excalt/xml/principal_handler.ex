defmodule Excalt.XML.PrincipalHandler do
  @moduledoc nil

  @behaviour Saxy.Handler

  def handle_event(:start_document, _prolog, state) do
    {:ok, state}
  end

  def handle_event(:end_document, _, {_previous_tag, _current_tag, principals}) do
    {:ok, principals}
  end

  def handle_event(:start_element, {tag_name, _attributes}, {current_tag, principals}) do
    {:ok, {nil, tag_name, principals}}
  end

  def handle_event(
        :start_element,
        {tag_name, _attributes},
        {previous_tag, current_tag, principals}
      ) do
    principals =
      if not is_nil(current_tag) and String.match?(current_tag, ~r/resourcetype/) and
           String.match?(tag_name, ~r/collection/) do
        [current_principal | principals] = principals
        current_principal = Map.put(current_principal, :resource_type, "collection")

        [current_principal | principals]
      else
        principals
      end

    if String.match?(tag_name, ~r/response$/) do
      principals = [%Excalt.Principal{} | principals]
      {:ok, {current_tag, tag_name, principals}}
    else
      {:ok, {current_tag, tag_name, principals}}
    end
  end

  def handle_event(:end_element, _, state) do
    {:ok, state}
  end

  # Ignore empty lines
  def handle_event(:characters, "\n", stack) do
    {:ok, stack}
  end

  def handle_event(:characters, content, {previous_tag, current_tag, principals}) do
    principals =
      if not is_nil(previous_tag) and String.match?(previous_tag, ~r/response/) and
           String.match?(current_tag, ~r/href/) and String.length(String.trim(content)) > 0 do
        [current_principal | principals] = principals
        current_principal = Map.put(current_principal, :url, content)
        [current_principal | principals]
      else
        principals
      end

    principals =
      if not is_nil(previous_tag) and String.match?(previous_tag, ~r/current-user-principal/) and
           String.match?(current_tag, ~r/href/) and String.length(String.trim(content)) > 0 do
        [current_principal | principals] = principals
        current_principal = Map.put(current_principal, :current_user_principal, content)
        [current_principal | principals]
      else
        principals
      end

    principals =
      if String.match?(current_tag, ~r/calendar-data/) and String.match?(content, ~r/BEGIN/) do
        [current_principal | principals] = principals
        current_principal = Map.put(current_principal, :icalendar, content)

        [current_principal | principals]
      else
        principals
      end

    {:ok, {previous_tag, current_tag, principals}}
  end
end
