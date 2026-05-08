defmodule CrudApp.CRMFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CrudApp.CRM` context.
  """

  @doc """
  Generate a client.
  """
  def client_fixture(attrs \\ %{}) do
    {:ok, client} =
      attrs
      |> Enum.into(%{
        address: "some address",
        email: "some email",
        name: "some name",
        phone: "some phone"
      })
      |> CrudApp.CRM.create_client()

    client
  end
end
