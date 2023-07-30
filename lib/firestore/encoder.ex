defprotocol Firestore.Encoder do
  @fallback_to_any true

  def encode(payload)
end

defimpl Firestore.Encoder, for: Map do
  alias GoogleApi.Firestore.V1.Model.Document

  def encode(map), do: %Document{fields: Enum.into(map, %{}, &encode_field/1)}

  def encode_field({:__firestore_bytes, val}), do: %{bytesValue: val}
  def encode_field({:__firestore_ref, val}), do: %{referenceValue: val}

  def encode_field({:__firestore_geo, {lat, lng}}),
    do: %{geoPointValue: %{latitude: lat, longitude: lng}}

  def encode_field({:__firestore_time, val}),
    do: %{timestampValue: %{seconds: val, nanos: 0}}

  def encode_field({key, val}),
    do: {key, encode_field(val)}

  def encode_field(val) when is_list(val),
    do: %{arrayValue: %{values: Enum.map(val, &encode_field/1)}}

  def encode_field(val) when is_map(val),
    do: %{mapValue: %{fields: Enum.into(val, %{}, &encode_field/1)}}

  def encode_field(val) when is_boolean(val), do: %{booleanValue: val}
  def encode_field(val) when is_float(val), do: %{doubleValue: val}
  def encode_field(val) when is_integer(val), do: %{integerValue: val}
  def encode_field(val) when is_binary(val), do: %{stringValue: val}
  def encode_field(_), do: %{nullValue: nil}
end
