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

  test "leaves structs such as DateTime as scalar values" do
    at = ~U[2024-01-01 00:00:00Z]
    assert Query.encode(inserted_at: %{gte: at}) == [{"inserted_at[gte]", at}]
  end
end
