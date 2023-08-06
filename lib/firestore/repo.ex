defmodule Firestore.Repo do
  @moduledoc """
  Defines a repository.

  A repository serves as a convenience module for Google's
  ![Elixir Firestore client](https://github.com/googleapis/elixir-google-api/tree/main/clients/firestore).

  To include the `Firestore.Repo` module in your application, you can put the use macro in your
  app's Repo module:

      defmodule MyApp.Firestore.Repo do
        use Firestore.Repo,
          otp_app: :my_app,
          tesla_adapter: :hackney,
          pool_size: 50,
          read_only: false
      end

  Options:
  `:tesla_adapter`: This application uses Tesla HTTP client, which supports multiple
  ![adapters](https://github.com/elixir-tesla/tesla#adapters) to process requests.

  `:pool_size`: If the adapter supports pooling, you can tune its size depending on expected
  throughput. Note that pooling is only supported for `:hackney` and `:ibrowse` HTTP adapters.
  You can set this to `nil` to disable it, or if the adapter has no support for configurability.

  `:read_only`: If true, it will not include any write operation related functions in the module.

  Then, add the appropriate Google Service Account credentials in your config file:

    config :my_app, MyApp.Firestore.Repo,
      project_id: System.fetch_env!("FIRESTORE_PROJECT_ID"),
      private_key_id: System.fetch_env!("FIRESTORE_PRIVATE_KEY_ID"),
      private_key: System.fetch_env!("FIRESTORE_PRIVATE_KEY"),
      client_email: System.fetch_env!("FIRESTORE_CLIENT_EMAIL"),
      client_id: System.fetch_env!("FIRESTORE_CLIENT_ID"),
      auth_uri: System.fetch_env!("FIRESTORE_AUTH_URI"),
      token_uri: System.fetch_env!("FIRESTORE_TOKEN_URI"),
      auth_provider_x509_cert_url: System.fetch_env!("FIRESTORE_AUTH_PROVIDER_X509_CERT_URL"),
      client_x509_cert_url: System.fetch_env!("FIRESTORE_CLIENT_X509_CERT_URL"),
      url: System.fetch_env!("FIRESTORE_URL")

  Finally you need to initialize the `Firestore` instance in your application's supervision tree:

      children = [
        # ...
        {Firestore, MyApp.Firestore.Repo.config()},
        # ...
      ]
  """

  @type t() :: module()

  @doc """
  Returns the Firestore configuration stored in the `:otp_app` environment.
  """
  @callback config() :: map()

  @doc """
  Returns a single document for a given collection path. Returns `nil` if no result was found.
  """
  @callback get(String.t(), Keyword.t()) :: {:ok, map()} | {:error, term()}

  @doc """
  Creates a document in a collection given a path.
  """
  @callback insert(String.t(), String.t(), map(), Keyword.t()) :: {:ok, map()} | {:error, term()}

  @doc """
  Updates a document in a collection.
  """
  @callback update(String.t(), map(), Keyword.t()) :: {:ok, map()} | {:error, term()}

  @supported_adapters [:httpc, :hackney, :ibrowse, :gun, :mint, :finch]

  @doc false
  defmacro __using__(opts) do
    Enum.each(opts, &validate_option/1)

    quote bind_quoted: [opts: opts] do
      @behaviour Firestore.Repo

      @otp_app opts[:otp_app]
      @tesla_adapter opts[:tesla_adapter]
      @pool_size opts[:pool_size]
      @read_only opts[:read_only]

      def config() do
        @otp_app
        |> Application.get_env(__MODULE__, [])
        |> Keyword.merge(otp_app: @otp_app, tesla_adapter: @tesla_adapter, pool_size: @pool_size)
        |> Map.new()
      end

      def get(path, opts \\ []) do
        with {:ok, client} <- get_client(),
             {:ok, response} <- Firestore.API.get_document(client, build_path(path), opts) do
          Firestore.Decoder.decode(response)
        end
      end

      unless @read_only do
        def insert(collection_id, parent, payload, opts \\ []) do
          with {:ok, client} <- get_client(),
               {:ok, response} <-
                 Firestore.API.create_document(
                   client,
                   build_path(parent),
                   collection_id,
                   Keyword.put(opts, :body, Firestore.Encoder.encode(payload))
                 ) do
            Firestore.Decoder.decode(response)
          end
        end

        def update(document_path, payload, opts \\ []) do
          with {:ok, client} <- get_client(),
               {:ok, response} <-
                 Firestore.API.update_document(
                   client,
                   build_path(document_path),
                   Keyword.put([], :body, Firestore.Encoder.encode(payload)) |> should_mask?(opts)
                 ) do
            Firestore.Decoder.decode(response)
          end
        end
      end

      defp should_mask?(keyword, opts) when opts == [], do: keyword

      defp should_mask?(keyword, opts),
        do: Keyword.put(keyword, :"updateMask.fieldPaths", opts[:fields])

      defp get_client() do
        case :ets.lookup(:firestore_table, :"#{@otp_app}_firestore_client") do
          [{_, %Tesla.Client{} = client}] ->
            {:ok, client}

          _ ->
            {:error,
             "Firestore instance not initialized. Make sure you have start Firestore in app's supervision tree"}
        end
      end

      defp build_path(path) do
        @otp_app
        |> Application.get_env(__MODULE__, [])
        |> Keyword.get(:url)
        |> then(fn db_url -> "#{db_url}/#{path}" end)
      end
    end
  end

  defp validate_option({:otp_app, app}) when not is_atom(app),
    do: raise(ArgumentError, "otp_app must be an atom, got #{inspect(app)}")

  defp validate_option({:tesla_adapter, adapter}) when adapter not in @supported_adapters,
    do:
      raise(
        ArgumentError,
        "tesla_adapter must be one of #{inspect(@supported_adapters)}, got #{inspect(adapter)}"
      )

  defp validate_option({:pool_size, size}) when not is_integer(size) and not is_nil(size),
    do: raise(ArgumentError, "pool_size must be an integer or nil, got #{inspect(size)}")

  defp validate_option({:read_only, read_only}) when not is_boolean(read_only),
    do: raise(ArgumentError, "read_only must be a boolean, got #{inspect(read_only)}")

  defp validate_option(_option),
    do: :ok
end
