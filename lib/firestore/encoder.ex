defprotocol Firestore.Encoder do
  @fallback_to_any true

  def encode(payload)
end

defimpl Firestore.Encoder, for: GoogleApi.Firestore.V1.Model.Document do
  alias GoogleApi.Firestore.V1.Model.{Document, Value, ArrayValue, MapValue}

  def encode(map) when is_map(map), do: %Document{fields: Enum.into(map, %{}, &encode_field/1)}

  @spec encode_field({term, term} | term) :: {term, Value.t()} | Value.t()
  def encode_field({:__firestore_bytes, val}), do: %Value{bytesValue: val}
  def encode_field({:__firestore_ref, val}), do: %Value{referenceValue: val}

  def encode_field({:__firestore_geo, {lat, lng}}),
    do: %Value{geoPointValue: %{latitude: lat, longitude: lng}}

  def encode_field({:__firestore_time, val}),
    do: %Value{timestampValue: %{seconds: val, nanos: 0}}

  def encode_field({key, val}),
    do: {key, encode_field(val)}

  def encode_field(val) when is_list(val),
    do: %Value{arrayValue: %ArrayValue{values: Enum.map(val, &encode_field/1)}}

  def encode_field(val) when is_map(val),
    do: %Value{mapValue: %MapValue{fields: Enum.into(val, %{}, &encode_field/1)}}

  def encode_field(val) when is_boolean(val), do: %Value{booleanValue: val}
  def encode_field(val) when is_float(val), do: %Value{doubleValue: val}
  def encode_field(val) when is_integer(val), do: %Value{integerValue: val}
  def encode_field(val) when is_binary(val), do: %Value{stringValue: val}
  def encode_field(_), do: %Value{nullValue: nil}
end
