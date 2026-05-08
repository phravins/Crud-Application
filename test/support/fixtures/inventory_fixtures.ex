defmodule CrudApp.InventoryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CrudApp.Inventory` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        name: "some name",
        price: "120.5",
        stock: 42
      })
      |> CrudApp.Inventory.create_product()

    product
  end
end
