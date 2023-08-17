defprotocol Firestore.Decoder do
  @fallback_to_any true

  def decode(response)
end

defimpl Firestore.Decoder, for: List do
  alias GoogleApi.Firestore.V1.Model.RunQueryResponse

  def decode(response) do
    response =
      Enum.map(response, fn
        %RunQueryResponse{document: document} -> Firestore.Decoder.decode(document)
        entry -> Firestore.Decoder.decode(entry)
      end)

    {:ok, response}
  end
end

defimpl Firestore.Decoder, for: GoogleApi.Firestore.V1.Model.Empty do
  def decode(_response), do: {:ok, []}
end

defimpl Firestore.Decoder, for: GoogleApi.Firestore.V1.Model.ListDocumentsResponse do
  def decode(%{documents: docs, nextPageToken: next}) do
    response = %{documents: Enum.map(docs, &decode/1), nextPageToken: next}
    {:ok, response}
  end
end

defimpl Firestore.Decoder, for: GoogleApi.Firestore.V1.Model.Document do
  alias GoogleApi.Firestore.V1.Model.Value

  def decode(%{fields: fields}), do: {:ok, Enum.into(fields, %{}, &decode_field/1)}

  defp decode_field({key, value}), do: {key, decode_field(value)}

  defp decode_field(%Value{arrayValue: %{values: list}}) when is_list(list),
    do: Enum.map(list, &decode_field/1)

  defp decode_field(%Value{arrayValue: %{values: list}}) when is_nil(list),
    do: []

  defp decode_field(%Value{mapValue: %{fields: map}}) when is_map(map),
    do: Enum.into(map, %{}, &decode_field/1)

  defp decode_field(%Value{mapValue: %{fields: map}}) when is_nil(map),
    do: %{}

  defp decode_field(%Value{booleanValue: value}) when not is_nil(value), do: value
  defp decode_field(%Value{bytesValue: value}) when not is_nil(value), do: value
  defp decode_field(%Value{doubleValue: value}) when not is_nil(value), do: value
  defp decode_field(%Value{geoPointValue: value}) when not is_nil(value), do: value
  defp decode_field(%Value{integerValue: value}) when not is_nil(value), do: value
  defp decode_field(%Value{referenceValue: value}) when not is_nil(value), do: value
  defp decode_field(%Value{stringValue: value}) when not is_nil(value), do: value
  defp decode_field(%Value{timestampValue: value}) when not is_nil(value), do: value
  defp decode_field(_), do: nil
end

defimpl Firestore.Decoder, for: Any do
  def decode(response), do: {:ok, response}
end
