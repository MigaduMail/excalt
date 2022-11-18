defmodule ExcaltTest do
  use ExUnit.Case
  doctest Excalt

  test "greets the world" do
    assert Excalt.hello() == :world
  end
end
