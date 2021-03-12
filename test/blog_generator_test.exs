defmodule BlogGeneratorTest do
  use ExUnit.Case
  doctest BlogGenerator

  test "greets the world" do
    assert BlogGenerator.hello() == :world
  end
end
