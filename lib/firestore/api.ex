defmodule Firestore.API do
  alias GoogleApi.Firestore.V1.Api.Projects

  defdelegate get_document(conn, path, params \\ [], opts \\ []),
    to: Projects,
    as: :firestore_projects_databases_documents_get

  defdelegate create_document(conn, parent, collection_id, params \\ [], opts \\ []),
    to: Projects,
    as: :firestore_projects_databases_documents_create_document

  defdelegate update_document(conn, path, params \\ [], opts \\ []),
    to: Projects,
    as: :firestore_projects_databases_documents_patch
end
