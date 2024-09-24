defmodule Signaturit.EventHooks do
  alias Signaturit.Http
  alias Signaturit.Utils

  @type event_type() ::
          :email_processed
          | :email_delivered
          | :email_bounced
          | :email_deferred
          | :reminder_email_processed
          | :reminder_email_delivered
          | :sms_processed
          | :sms_delivered
          | :password_sms_processed
          | :password_sms_delivered
          | :document_opened
          | :document_signed
          | :document_completed
          | :audit_trail_completed
          | :document_declined
          | :document_expired
          | :document_canceled
          | :photo_added
          | :voice_added
          | :file_added
          | :photo_id_added

  @type t() :: %__MODULE__{
          id: String.t(),
          status_code: integer(),
          url: String.t(),
          method: String.t(),
          event_type: event_type(),
          created_at: DateTime.t()
        }

  defstruct [
    :id,
    :status_code,
    :url,
    :method,
    :event_type,
    :created_at
  ]

  def list_event_hooks do
    endpoint = Http.endpoint(:event_hooks, "")
    res = Http.get(endpoint)

    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(fn %{total: total, web_hooks: event_hooks} ->
        %{
          total: total,
          event_hooks: Enum.map(event_hooks, &struct!(%__MODULE__{}, &1))
        }
        |> Map.update!(:event_hooks, fn hooks ->
          Enum.map(hooks, fn hook ->
            Map.update!(hook, :event_type, &Utils.handle_to_existing_atom/1)
          end)
        end)
      end)
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def retry_event_hook(event_hook_id) do
    endpoint = Http.endpoint(:event_hooks, "/#{event_hook_id}/retry")
    res = Http.get(endpoint)

    with {:ok, %{}} <- res do
      {:ok, %{}}
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end
end
