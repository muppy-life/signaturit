defmodule Signaturit.CertifiedSms do
  alias Signaturit.Http
  alias Signaturit.Utils

  def count_certified_sms(params) do
    endpoint = Http.endpoint(:sms, "/count.json")
    res = Http.get(endpoint, params)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def list_certified_sms(params) do
    endpoint = Http.endpoint(:sms, ".json")
    res = Http.get(endpoint, params)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def get_certified_sms(id) do
    endpoint = Http.endpoint(:sms, "/#{id}.json")
    res = Http.get(endpoint)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def create_certified_sms(files, recipients, body, params \\ %{}) do
    endpoint = Http.endpoint(:sms, ".json")
    parameters =
      (if is_list(recipients), do: recipients, else: List.wrap(recipients))
      |> Enum.with_index(fn element, index -> {index, element} end)
      |> Enum.reduce([], fn {index, recipient}, acc ->
        Utils.fill_array(acc, recipient, "recipients[#{index}]")
      end)
      |> Utils.fill_array(params, "")
    documents =
      (
        (if is_list(files), do: files, else: List.wrap(files))
        |> Enum.with_index(fn element, index -> {index, element} end)
        |> Enum.reduce([], fn {index, file}, acc ->
          acc ++ [Utils.build_file(file, "attachments[#{index}]")]
        end)
      )
    upload_body = parameters ++ documents ++ [{"body", body}]
    with {:ok, res} <- Http.upload(endpoint, upload_body) do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def download_audit_trail(sms_id, certificate_id) do
    endpoint = Http.endpoint(:sms, "/#{sms_id}/certificates/#{certificate_id}/audit_trail")
    res = Http.download(endpoint)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end
end
