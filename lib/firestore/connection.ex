defmodule Firestore.Connection do
  @moduledoc """
  Handle Tesla connections for GoogleApi.Firestore.V1.
  """

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

  ## TODO: Implement connection pooling for applicable adapters

  @spec client(String.t(), Keyword.t()) :: Tesla.Client.t()
  def client(token, opts) when is_binary(token) do
    http_adapter = @http_adapters[opts[:tesla_adapter]]
    middleware = [{Tesla.Middleware.Headers, [{"authorization", "Bearer #{token}"}]}]

    Tesla.client(middleware, {http_adapter, []})
  end
end
