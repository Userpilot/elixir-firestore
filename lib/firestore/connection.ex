defmodule Firestore.Connection do
  @moduledoc """
  Handle Tesla connections for GoogleApi.Firestore.V1.
  """

  @type t :: Tesla.Env.client()

  @default_adapter {Tesla.Adapter.Hackney, []}

  use GoogleApi.Gax.Connection,
    scopes: [
      # See, edit, configure, and delete your Google Cloud data and see the email address for your Google Account.
      "https://www.googleapis.com/auth/cloud-platform",

      # View and manage your Google Cloud Datastore data
      "https://www.googleapis.com/auth/datastore"
    ],
    otp_app: :google_api_firestore,
    base_url: "https://firestore.googleapis.com/"

  @spec client(String.t(), Module.t()) :: Tesla.Client.t()
  def client(token, adapter \\ @default_adapter) when is_binary(token) do
    middleware = [{Tesla.Middleware.Headers, [{"authorization", "Bearer #{token}"}]}]

    Tesla.client(middleware, adapter)
  end
end
