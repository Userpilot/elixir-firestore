defmodule Firestore do
  @moduledoc """
  This is the main entry point for the Firestore application.
  """

  use GenServer

  def init(opts) do
    credentials = Enum.into(opts, %{}, fn {k, v} -> {to_string(k), v} end)

    with {:ok, %{token: token}} <- Goth.Token.fetch(source: {:service_account, credentials}) do
      client = Firestore.Connection.client(token, opts)

      :ets.new(:firestore_conn_table, [:set, :public, :named_table])
      :ets.insert(:firestore_conn_table, {:"#{opts[:otp_app]}_firestore_client", client})
      {:ok, client}
    end
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def child_spec(opts) do
    %{id: __MODULE__, start: {__MODULE__, :start_link, [opts]}}
  end
end
