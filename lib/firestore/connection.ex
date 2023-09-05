defmodule Firestore.Connection do
  @moduledoc """
  Handle Tesla connections for GoogleApi.Firestore.V1.
  """
  require Logger

  @type t :: Tesla.Env.client()

  @http_adapters [
    httpc: nil,
    hackney: Tesla.Adapter.Hackney,
    ibrowse: Tesla.Adapter.IBrowse,
    gun: Tesla.Adapter.Gun,
    mint: Tesla.Adapter.Mint,
    finch: Tesla.Adapter.Finch
  ]

  use GoogleApi.Gax.Connection,
    scopes: [
      # See, edit, configure, and delete your Google Cloud data and see the email address for your Google Account.
      "https://www.googleapis.com/auth/cloud-platform",

      # View and manage your Google Cloud Datastore data
      "https://www.googleapis.com/auth/datastore"
    ],
    otp_app: :google_api_firestore,
    base_url: "https://firestore.googleapis.com/"

  @spec init(String.t(), map()) :: t()
  def init(token, config) when is_binary(token) do
    http_adapter = build_http_adapter(config)
    middleware = [{Tesla.Middleware.Headers, [{"authorization", "Bearer #{token}"}]}]

    Tesla.client(middleware, http_adapter)
  end

  defp build_http_adapter(%{otp_app: _, tesla_adapter: :finch,name: name}),
    do: {@http_adapters[:finch], [name: name]}

  defp build_http_adapter(%{otp_app: _, tesla_adapter: adapter, pool_size: nil}),
    do: {@http_adapters[adapter], []}

  defp build_http_adapter(%{otp_app: app, tesla_adapter: :hackney, pool_size: pool_size}) do
    with :ok <- :hackney_pool.start_pool(:"#{app}_firestore_pool", max_connections: pool_size),
         do: {@http_adapters[:hackney], [pool: :"#{app}_firestore_pool"]}
  end

  defp build_http_adapter(%{otp_app: _, tesla_adapter: :ibrowse, pool_size: pool_size}),
    do: {@http_adapters[:ibrowse], [max_sessions: pool_size, max_pipeline_size: 1]}


  defp build_http_adapter(%{tesla_adapter: adapter} = config) do
    Logger.warning("Ignoring pool_size option as #{adapter} does not support it")

    build_http_adapter(%{config | pool_size: nil})
  end
end
