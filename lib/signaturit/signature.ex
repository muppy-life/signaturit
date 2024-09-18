defmodule Signaturit.Signature do
  alias Signaturit.Http
  alias Signaturit.Utils

  def count_signatures(params \\ %{}) do
    endpoint = Http.endpoint(:signature, "/count.json")
    res = Http.get(endpoint, params)
    with {:ok, res} <- res,
      count <- Map.get(res, "count") do
        {:ok, count}
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def list_signatures(params \\ %{}) do
    endpoint = Http.endpoint(:signature, ".json")
    res = Http.get(endpoint, params)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def get_signature(id) do
    endpoint = Http.endpoint(:signature, "/#{id}.json")
    res = Http.get(endpoint)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  @doc """
  Create a new signature request.

  ## Required parameters
    - files:          List of file paths for the documents to be signed.
    - recipients:     A dictionary with the email and fullname of the person you want to sign.
            If you wanna send only to one person:
             - [%{email: "john_doe@gmail.com", fullname: "John"}]
            For multiple recipients, yo need to submit a list of dicts:
             - [%{email: "john_doe@gmail.com", fullname: "John"}, {email:"bob@gmail.com", "fullname": Bob}]
  """
  def create_signature(files, recipients, params \\ %{}) do
    endpoint = Http.endpoint(:signature, ".json")

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
          acc ++ [Utils.build_file(file, index)]
        end)
      )

    upload_body = parameters ++ documents

    with {:ok, res} <- Http.upload(endpoint, upload_body) do
      res
      |>Utils.keys_to_atoms()
      |>then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end

  end

  def send_reminder(id) do
    endpoint = Http.endpoint(:signature, "/#{id}/reminder.json")
    res = Http.post(endpoint, %{})
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def cancel_signature(id, reason \\ nil) do
    reason = if is_nil(reason), do: %{}, else: %{"reason" => reason}
    endpoint = Http.endpoint(:signature, "/#{id}/cancel.json")
    res = Http.patch(endpoint, reason)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def delete_signature(id) do
    endpoint = Http.endpoint(:signature, "/#{id}")
    res = Http.delete(endpoint)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def download_signed_document(signature_id, document_id) do
    endpoint = Http.endpoint(:signature, "/#{signature_id}/documents/#{document_id}/download/signed")
    res = Http.download(endpoint)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  @doc """
  Change the signer email of a document.
  Only requests with an error in email delivery can be changed.
  """
  def change_signer_email(signature_id, document_id, signer_email, signer_name \\ nil) do
    endpoint = Http.endpoint(:signature, "/#{signature_id}/documents/#{document_id}/signer")
    params =
      case signer_name do
        nil -> %{"email" => signer_email}
        _ -> %{"email" => signer_email, "name" => signer_name}
      end
    res = Http.post(endpoint, params)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def generate_audit_trail(signature_id) do
    endpoint = Http.endpoint(:signature, "/#{signature_id}/generate/audit_trail")
    res = Http.post_no_response(endpoint, %{})
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def download_audit_trail(signature_id, document_id) do
    endpoint = Http.endpoint(:signature, "/#{signature_id}/documents/#{document_id}/download/audit_trail")
    res = Http.download(endpoint)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def change_signature_name(signature_id, name) do
    endpoint = Http.endpoint(:signature, "/#{signature_id}/name?name=#{name}")
    res = Http.post(endpoint, %{})
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def download_attachments(signature_id, document_id) do
    endpoint = Http.endpoint(:signature, "/#{signature_id}/documents/#{document_id}/download/attachments")
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
