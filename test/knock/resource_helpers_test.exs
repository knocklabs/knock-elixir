defmodule Knock.ResourceHelpersTest do
  use ExUnit.Case, async: true

  alias Knock.ResourceHelpers

  defmodule FakeJSON do
    def encode!(_), do: "encoded"
  end

  describe "maybe_json_encode_param/3" do
    test "encodes maps" do
      assert ResourceHelpers.maybe_json_encode_param([trigger_data: %{"a" => 1}], :trigger_data) ==
               [trigger_data: ~s({"a":1})]
    end

    test "passes JSON-encoded strings through" do
      assert ResourceHelpers.maybe_json_encode_param([trigger_data: ~s({"a":1})], :trigger_data) ==
               [trigger_data: ~s({"a":1})]
    end

    test "leaves options untouched when the param is absent" do
      assert ResourceHelpers.maybe_json_encode_param([page_size: 1], :trigger_data) ==
               [page_size: 1]
    end

    test "raises for other types" do
      assert_raise ArgumentError, fn ->
        ResourceHelpers.maybe_json_encode_param([trigger_data: 1], :trigger_data)
      end
    end

    test "falls back to Jason when the JSON client has no encode!/1" do
      assert ResourceHelpers.maybe_json_encode_param([data: %{"a" => 1}], :data, URI) ==
               [data: ~s({"a":1})]
    end

    test "uses the given JSON client" do
      assert ResourceHelpers.maybe_json_encode_param([data: %{}], :data, FakeJSON) ==
               [data: "encoded"]
    end
  end

  test "build_setting_param/1" do
    assert ResourceHelpers.build_setting_param(true) == %{subscribed: true}
    assert ResourceHelpers.build_setting_param(%{channel_types: %{}}) == %{channel_types: %{}}
  end
end
