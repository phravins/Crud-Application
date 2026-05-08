defmodule CrudApp.CRMTest do
  use CrudApp.DataCase

  alias CrudApp.CRM

  describe "clients" do
    alias CrudApp.CRM.Client

    import CrudApp.CRMFixtures

    @invalid_attrs %{name: nil, address: nil, email: nil, phone: nil}

    test "list_clients/0 returns all clients" do
      client = client_fixture()
      assert CRM.list_clients() == [client]
    end

    test "get_client!/1 returns the client with given id" do
      client = client_fixture()
      assert CRM.get_client!(client.id) == client
    end

    test "create_client/1 with valid data creates a client" do
      valid_attrs = %{name: "some name", address: "some address", email: "some email", phone: "some phone"}

      assert {:ok, %Client{} = client} = CRM.create_client(valid_attrs)
      assert client.name == "some name"
      assert client.address == "some address"
      assert client.email == "some email"
      assert client.phone == "some phone"
    end

    test "create_client/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CRM.create_client(@invalid_attrs)
    end

    test "update_client/2 with valid data updates the client" do
      client = client_fixture()
      update_attrs = %{name: "some updated name", address: "some updated address", email: "some updated email", phone: "some updated phone"}

      assert {:ok, %Client{} = client} = CRM.update_client(client, update_attrs)
      assert client.name == "some updated name"
      assert client.address == "some updated address"
      assert client.email == "some updated email"
      assert client.phone == "some updated phone"
    end

    test "update_client/2 with invalid data returns error changeset" do
      client = client_fixture()
      assert {:error, %Ecto.Changeset{}} = CRM.update_client(client, @invalid_attrs)
      assert client == CRM.get_client!(client.id)
    end

    test "delete_client/1 deletes the client" do
      client = client_fixture()
      assert {:ok, %Client{}} = CRM.delete_client(client)
      assert_raise Ecto.NoResultsError, fn -> CRM.get_client!(client.id) end
    end

    test "change_client/1 returns a client changeset" do
      client = client_fixture()
      assert %Ecto.Changeset{} = CRM.change_client(client)
    end
  end
end
