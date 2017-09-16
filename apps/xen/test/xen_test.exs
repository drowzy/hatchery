defmodule XenTest do
  use ExUnit.Case
  doctest Xen

  test "greets the world" do
    assert Xen.hello() == :world
  end
end
