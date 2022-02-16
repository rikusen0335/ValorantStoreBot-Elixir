defmodule ValorantStoreBotTest do
  use ExUnit.Case
  doctest ValorantStoreBot

  test "greets the world" do
    assert ValorantStoreBot.hello() == :world
  end
end
