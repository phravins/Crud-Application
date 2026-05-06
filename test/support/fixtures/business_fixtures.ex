defmodule CrudApp.BusinessFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CrudApp.Business` context.
  """

  @doc """
  Generate a record.
  """
  def record_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        category: "some category",
        metadata: %{},
        name: "some name"
      })

    {:ok, record} = CrudApp.Business.create_record(scope, attrs)
    record
  end
end
