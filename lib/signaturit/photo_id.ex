defmodule Signaturit.PhotoId do
  alias Signaturit.Http
  alias Signaturit.Utils

  def validate_photo_id(front, back, document_type, document_country) do
    endpoint = Http.endpoint(:photo_id, "/validate.json")
    front_file = [Utils.build_file(front, "front")]
    back_file = if not is_nil(back), do: Utils.build_file(back, "back"), else: []

    body =
      front_file ++
        back_file ++
        [{"document_type", document_type}] ++ [{"document_country", document_country}]

    res = Http.upload(endpoint, body)

    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end
end
