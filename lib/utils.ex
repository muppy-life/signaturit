defmodule Signaturit.Utils do
  def keys_to_atoms(json) when is_map(json), do: Map.new(json, &reduce_keys_to_atoms/1)
  def keys_to_atoms(list) when is_list(list), do: Enum.map(list, &Map.new(&1, fn x -> reduce_keys_to_atoms(x) end))
  def keys_to_atoms(val), do: val

  def handle_to_existing_atom(key) do
    try do
      String.to_existing_atom(key)
    rescue
      ArgumentError -> key
    end
  end

  def reduce_keys_to_atoms({key, val}) when is_map(val), do: {handle_to_existing_atom(key), keys_to_atoms(val)}
  def reduce_keys_to_atoms({key, val}) when is_list(val), do: {handle_to_existing_atom(key), Enum.map(val, &keys_to_atoms(&1))}
  def reduce_keys_to_atoms({key, val}), do: {handle_to_existing_atom(key), val}

  def manage_error(res), do: manage_error(res, nil)
  def manage_error(msg, nil), do: {:error, msg}
  def manage_error(msg, context), do: {:error, "[#{context}] " <> msg}

  def fill_array(array, params, parent) do
    iterable = if is_map(params), do: Map.to_list(params), else: Enum.with_index(params, fn element, index -> {index, element} end)
    Enum.reduce(iterable, array, fn {key, value}, acc ->
      parent_key = if parent != "", do: "#{parent}[#{key}]", else: "#{key}"

      cond do
      is_map(value) ->
        fill_array(acc, value, parent_key)
      is_list(value) ->
        fill_array(acc, value, parent_key)
      true ->
        acc ++ [{parent_key, value}]
      end
    end)
  end

  def build_file(file_path, index) do
    {:file, file_path, {"form-data", [name: "files[#{index}]", filename: Path.basename(file_path)]}, []}
  end
end
