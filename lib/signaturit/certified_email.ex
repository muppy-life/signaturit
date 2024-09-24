defmodule Signaturit.CertifiedEmail do
  alias Signaturit.Http
  alias Signaturit.Utils

  @type certificate_event_type() ::
          :email_processed
          | :email_delivered
          | :documents_opened
          | :document_opened
          | :document_downloaded
          | :certification_completed

  @type certificate_event_data() :: %{
          created_at: DateTime.t(),
          type: certificate_event_type()
        }

  @type attachment_data() :: %{
          name: String.t(),
          size: integer()
        }

  @type certificate_data() :: %{
          email: String.t(),
          events: [certificate_event_data()],
          attachments: [attachment_data()],
          id: String.t(),
          name: String.t(),
          status: :in_queue | :sent | :error
        }

  @type t() :: %__MODULE__{
          created_at: DateTime.t(),
          certificates: [certificate_data()],
          id: String.t(),
          data: list()
        }

  defstruct [
    :created_at,
    :certificates,
    :id,
    :data
  ]

  def count_certified_emails(params) do
    endpoint = Http.endpoint(:emails, "/count.json")
    res = Http.get(endpoint, params)

    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def list_certified_emails(params \\ %{}) do
    endpoint = Http.endpoint(:emails, ".json")
    res = Http.get(endpoint, params)

    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> Enum.map(&struct!(%__MODULE__{}, &1))
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def get_certified_email(id) do
    endpoint = Http.endpoint(:emails, "/#{id}.json")
    res = Http.get(endpoint)

    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&struct!(%__MODULE__{}, &1))
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def create_certified_email(files, recipients, subject, body, params \\ %{}) do
    endpoint = Http.endpoint(:emails, ".json")

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
        acc ++ [Utils.build_file(file, "attachments[#{index}]")]
      end)

    upload_body = parameters ++ documents ++ [{"subject", subject}, {"body", body}]

    with {:ok, res} <- Http.upload(endpoint, upload_body) do
      res
      |> Utils.keys_to_atoms()
      |> then(&struct!(%__MODULE__{}, &1))
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def download_audit_trail(email_id, certificate_id) do
    endpoint =
      Http.endpoint(:emails, "/#{email_id}/certificates/#{certificate_id}/download/audit_trail")

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
