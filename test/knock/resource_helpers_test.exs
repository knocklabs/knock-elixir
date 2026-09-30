defmodule Knock.ResourceHelpersTest do
  use ExUnit.Case, async: true

  alias Knock.ResourceHelpers

  describe "encode_query/1" do
    test "passes scalars through with string keys" do
      assert ResourceHelpers.encode_query(page_size: 10, after: "c") ==
               [{"page_size", 10}, {"after", "c"}]
    end

    test "encodes scalar lists with empty brackets" do
      assert ResourceHelpers.encode_query(include: ["preferences"], status: ["a", "b"]) ==
               [{"include[]", "preferences"}, {"status[]", "a"}, {"status[]", "b"}]
    end

    test "encodes nested maps and keyword lists with bracket keys" do
      assert ResourceHelpers.encode_query(inserted_at: %{gt: "2024-01-01"}) ==
               [{"inserted_at[gt]", "2024-01-01"}]

      assert ResourceHelpers.encode_query(query_options: [limit: 10, cursor: "x"]) ==
               [{"query_options[limit]", 10}, {"query_options[cursor]", "x"}]
    end

    test "encodes lists of maps with indexed keys" do
      encoded =
        ResourceHelpers.encode_query(
          objects: [%{id: "p1", collection: "projects"}, %{id: "p2", collection: "projects"}]
        )

      assert Enum.sort(encoded) == [
               {"objects[0][collection]", "projects"},
               {"objects[0][id]", "p1"},
               {"objects[1][collection]", "projects"},
               {"objects[1][id]", "p2"}
             ]
    end

    test "leaves structs such as DateTime as scalar values" do
      at = ~U[2024-01-01 00:00:00Z]
      assert ResourceHelpers.encode_query(inserted_at: %{gte: at}) == [{"inserted_at[gte]", at}]
    end

    test "treats an empty list as no params" do
      assert ResourceHelpers.encode_query(recipients: []) == []
    end
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

    test "uses the given JSON client" do
      defmodule FakeJSON do
        def encode!(_), do: "encoded"
      end

      assert ResourceHelpers.maybe_json_encode_param([data: %{}], :data, FakeJSON) ==
               [data: "encoded"]
    end
  end
end
