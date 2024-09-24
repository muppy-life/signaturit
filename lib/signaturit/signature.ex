defmodule Signaturit.Signature do
  alias Signaturit.Http
  alias Signaturit.Utils

  @type t() :: %__MODULE__{
          created_at: DateTime.t(),
          data: signature_data(),
          documents: [document_data()],
          id: String.t()
        }

  @type signature_data() :: %{
          body: String.t(),
          branding_id: String.t(),
          callback_url: String.t(),
          data: map(),
          delivery_type: :email | :sms | :url,
          expire_time: integer(),
          events_url: String.t(),
          files: [String.t()],
          name: String.t(),
          recipients: [signature_recipient_data()],
          cc: %{
            email: String.t(),
            name: String.t()
          },
          reply_to: String.t(),
          reminders: [Integer.t()],
          signing_mode: :sequential | :parallel,
          subject: String.t(),
          templates: [String.t()],
          type: :simple | :advanced | :smart
        }

  @type document_data() :: %{
          email: String.t(),
          events: [document_event_data()],
          id: String.t(),
          file: %{
            name: String.t(),
            size: integer(),
            pages: integer()
          },
          name: String.t(),
          status:
            :in_queue | :ready | :signing | :completed | :expired | :canceled | :declined | :error
        }

  @type document_event_data() :: %{
          created_at: DateTime.t(),
          type: Signaturit.EventHooks.event_type()
        }

  @type signature_recipient_data() :: %{
          email: String.t(),
          name: String.t(),
          phone: String.t(),
          sign_with_digital_certificate_file: 0 | 1,
          digital_certificate_name: String.t(),
          require_file_attachment: integer() | [integer()],
          require_photo: integer() | [integer()],
          require_photo_id: integer() | [integer()],
          widgets: [widget_data()],
          require_sms_validation: 0 | 1,
          sms_code: boolean(),
          type: :signer | :validator
        }

  @type widget_data() :: %{
          page: integer(),
          left: integer(),
          top: integer(),
          width: integer(),
          height: integer(),
          type:
            :date
            | :image
            | :check
            | :radio
            | :select
            | :text
            | :signature
            | :digital_certificate,
          default: String.t(),
          editable: 0 | 1,
          word_anchor: String.t(),
          options: [String.t()],
          required: 0 | 1
        }

  defstruct [
    :created_at,
    :data,
    :documents,
    :id
  ]

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
      |> Enum.map(&struct!(%__MODULE__{}, &1))
      |> Enum.map(&parse_signature_document_event_type/1)
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
      |> then(&struct!(%__MODULE__{}, &1))
      |> parse_signature_document_event_type()
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
      if(is_list(recipients), do: recipients, else: List.wrap(recipients))
      |> Enum.with_index(fn element, index -> {index, element} end)
      |> Enum.reduce([], fn {index, recipient}, acc ->
        Utils.fill_array(acc, recipient, "recipients[#{index}]")
      end)
      |> Utils.fill_array(params, "")

    documents =
      if(is_list(files), do: files, else: List.wrap(files))
      |> Enum.with_index(fn element, index -> {index, element} end)
      |> Enum.reduce([], fn {index, file}, acc ->
        acc ++ [Utils.build_file(file, "files[#{index}]")]
      end)

    upload_body = parameters ++ documents

    with {:ok, res} <- Http.upload(endpoint, upload_body) do
      res
      |> Utils.keys_to_atoms()
      |> then(&struct!(%__MODULE__{}, &1))
      |> then(&{:ok, &1})
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
    endpoint =
      Http.endpoint(:signature, "/#{signature_id}/documents/#{document_id}/download/signed")

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
    endpoint =
      Http.endpoint(:signature, "/#{signature_id}/documents/#{document_id}/download/audit_trail")

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
    endpoint =
      Http.endpoint(:signature, "/#{signature_id}/documents/#{document_id}/download/attachments")

    res = Http.download(endpoint)

    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  defp parse_signature_document_event_type(signature) do
    Map.update!(signature, :documents, fn documents ->
      Enum.map(documents, fn document ->
        Map.update!(document, :events, fn events ->
          Enum.map(events, fn event ->
            Map.update!(event, :type, &Utils.handle_to_existing_atom/1)
          end)
        end)
      end)
    end)
  end
end
