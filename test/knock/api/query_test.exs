defmodule Knock.Api.QueryTest do
  use ExUnit.Case, async: true

  alias Knock.Api.Query

  test "leaves values Tesla can encode untouched" do
    query = [
      page_size: 10,
      include: ["preferences"],
      query_options: [limit: 10],
      inserted_at: [{"gte", "2024-01-01"}]
    ]

    assert Query.encode(query) == query
  end

  test "flattens nested maps with bracket keys" do
    assert Query.encode(inserted_at: %{gt: "2024-01-01"}) == [{"inserted_at[gt]", "2024-01-01"}]
  end

  test "flattens keyword lists that contain maps" do
    assert Query.encode(filter: [range: %{gt: 1}]) == [{"filter[range][gt]", 1}]
  end

  test "flattens lists of maps with indexed keys" do
    encoded =
      Query.encode(
        objects: [%{id: "p1", collection: "projects"}, %{id: "p2", collection: "projects"}]
      )

    assert Enum.sort(encoded) == [
             {"objects[0][collection]", "projects"},
             {"objects[0][id]", "p1"},
             {"objects[1][collection]", "projects"},
             {"objects[1][id]", "p2"}
           ]
  end

  test "keeps scalar-first mixed lists in bracket form" do
    encoded = Query.encode(recipients: ["u1", %{id: "p1", collection: "projects"}])

    assert Enum.sort(encoded) == [
             {"recipients[]", "u1"},
             {"recipients[][collection]", "projects"},
             {"recipients[][id]", "p1"}
           ]
  end

  test "sends dates as ISO-8601" do
    assert Query.encode(inserted_at: %{gte: ~U[2024-01-01 00:00:00Z]}) ==
             [{"inserted_at[gte]", "2024-01-01T00:00:00Z"}]

    assert Query.encode(starting_at: ~N[2024-01-01 00:00:00], day: ~D[2024-01-01]) ==
             [{"starting_at", "2024-01-01T00:00:00"}, {"day", "2024-01-01"}]
  end

  test "leaves other structs as scalar values" do
    uri = URI.parse("https://example.com")
    assert Query.encode(inserted_at: %{gte: uri}) == [{"inserted_at[gte]", uri}]
  end
end
