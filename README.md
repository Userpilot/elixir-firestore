# Elixir Firestore Wrapper

## Installation

The package can be installed by adding `firestore` to your list of dependencies in `mix.exs`:
```elixir
def deps do
  [
    {:firestore, git: "https://github.com/Userpilot/elixir-firestore.git", ref: "{{COMMIT_HASH}}"}
  ]
end
```

Include the `Firestore.Repo` module in your application, you can put the use macro in your app's Repo module:

      defmodule MyApp.Firestore.Repo do
        use Firestore.Repo,
          otp_app: :my_app,
          tesla_adapter: Tesla.Adapter.Hackney,
          pool_size: 50,
          read_only: false
      end

  Options:
  `:tesla_adapter`: This application uses Tesla HTTP client, which supports multiple
  ![adapters](https://github.com/elixir-tesla/tesla#adapters) to process requests.

  `:pool_size`: If the adapter supports pooling, you can tune its size depending on expected
  throughput. Note that pooling is only supported for `Tesla.Adapter.Hackney`
  and `Tesla.Adapter.IBrowse` adapters.

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



## Usage (TODO)

