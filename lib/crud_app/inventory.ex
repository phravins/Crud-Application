defmodule CrudApp.Inventory do
  @moduledoc """
  The Inventory context.
  """

  import Ecto.Query, warn: false
  alias CrudApp.Repo

  alias CrudApp.Inventory.Product

  alias CrudApp.Accounts.Scope

  @doc """
  Returns the list of products.
  """
  def list_products(%Scope{} = scope) do
    Repo.all_by(Product, user_id: scope.user.id)
  end

  def list_products do
    Repo.all(Product)
  end

  @doc """
  Gets a single product.
  """
  def get_product!(%Scope{} = scope, id) do
    Repo.get_by!(Product, [id: id, user_id: scope.user.id])
  end

  def get_product!(id), do: Repo.get!(Product, id)

  @doc """
  Creates a product.
  """
  def create_product(%Scope{} = scope, attrs) do
    %Product{}
    |> Product.changeset(attrs)
    |> Ecto.Changeset.put_change(:user_id, scope.user.id)
    |> Ecto.Changeset.put_change(:user_email, scope.user.email)
    |> Repo.insert()
  end

  def create_product(attrs) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a product.
  """
  def update_product(%Scope{} = scope, %Product{} = product, attrs) do
    true = product.user_id == scope.user.id
    product
    |> Product.changeset(attrs)
    |> Ecto.Changeset.put_change(:user_id, scope.user.id)
    |> Ecto.Changeset.put_change(:user_email, scope.user.email)
    |> Repo.update()
  end

  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a product.
  """
  def delete_product(%Scope{} = scope, %Product{} = product) do
    true = product.user_id == scope.user.id
    Repo.delete(product)
  end

  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.
  """
  def change_product(scope_or_product, product_or_attrs, attrs \\ %{})

  def change_product(%Scope{} = scope, %Product{} = product, attrs) do
    if product.user_id do
      true = product.user_id == scope.user.id
    end

    product
    |> Product.changeset(attrs)
    |> Ecto.Changeset.put_change(:user_id, scope.user.id)
    |> Ecto.Changeset.put_change(:user_email, scope.user.email)
  end

  def change_product(%Product{} = product, attrs, _unused) do
    Product.changeset(product, attrs)
  end
end
