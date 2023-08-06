defmodule Firestore do
  @moduledoc """
  This is the main entry point for the Firestore application.
  """

  defmodule State do
    defstruct [
      :config,
      :client
    ]

    @type t :: %__MODULE__{
            config: map(),
            client: Connection.t()
          }
  end

  use GenServer

  alias Firestore.Connection
  alias Goth.Token

  @ets_table :firestore_table
  @refresh_token_interval_ms 45 * 60 * 1000

  @impl true
  def init(config) do
    :ets.new(@ets_table, [:set, :public, :named_table])

    with {:ok, client} <- init_client(config) do
      {:ok, %State{config: config, client: client}}
    end
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def child_spec(opts) do
    %{id: __MODULE__, start: {__MODULE__, :start_link, [opts]}}
  end

  @impl true
  def handle_info(:refresh_token, %State{config: config} = state) do
    case init_client(config) do
      {:ok, client} ->
        {:noreply, %State{state | client: client}}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  defp init_client(%{otp_app: app} = config) do
    credentials = Enum.into(config, %{}, fn {k, v} -> {to_string(k), v} end)

    with {:ok, %{token: token}} <- Token.fetch(source: {:service_account, credentials}) do
      client = Connection.init(token, config)

      :ets.insert(@ets_table, {:"#{app}_firestore_client", client})
      Process.send_after(self(), :refresh_token, @refresh_token_interval_ms)

      {:ok, client}
    end
  end
end
