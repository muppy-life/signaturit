defmodule Signaturit.Http do
  alias HTTPoison.Response

  def get(route) do
    with {:ok, %Response{body: res}} <- HTTPoison.get(route, headers()),
      {:ok, res} <- Jason.decode(res) do
        {:ok, res}
    else
      {:error, msg} -> {:error, msg}
    end
  end

  def get(route, params) do
    params
    |> Enum.reduce("", &merge_args(&1, &2))
    |> String.slice(1..-1//1)
    |> then(&(route <> "?" <> &1))
    |> get()
  end

  def post(route, data) do
    with {:ok, data} <- Jason.encode(data),
      _ <- IO.inspect(data),
      {:ok, %Response{body: res}} <- HTTPoison.post(route, data, headers()),
      {:ok, res} <- Jason.decode(res) do
        case res do
          %{"status_code" => _, "message" => msg} -> {:error, msg}
          _ -> {:ok, res}
        end
    else
      {:error, msg} -> {:error, msg}
    end
  end

  def post_no_response(route, data) do
    with {:ok, data} <- Jason.encode(data),
      {:ok, %Response{status_code: 202}} <- HTTPoison.post(route, data, headers()) do
        {:ok, nil}
    else
      {:error, msg} -> {:error, msg}
      {:ok, %Response{status_code: status_code}} -> {:error, "Status code: #{status_code}"}
      error -> {:error, error}
    end
  end

  def upload(route, data) do
    with {:ok, %Response{body: res}} <- HTTPoison.post(route, {:multipart, data}, headers(:json), [recv_timeout: 40000]),
         {:ok, res} <- Jason.decode(res)
    do
      case res do
        %{"status_code" => _status, "message" => msg} -> {:error, msg}
        _ -> {:ok, res}
      end
    else
      {:error, msg} -> {:error, msg}
      error -> {:error, error}
    end
  end

  def put(route, data) do
    with {:ok, data} <- Jason.encode(data),
      {:ok, %Response{body: res}} <- HTTPoison.put(route, data, headers()),
      {:ok, res} <- Jason.decode(res) do
        case res do
          %{"status_code" => _, "message" => msg} -> {:error, msg}
          _ -> {:ok, res}
        end
    else
      {:error, msg} -> {:error, msg}
    end
  end

  def delete(route) do
    with {:ok, %Response{body: res}} <- HTTPoison.delete(route, headers()),
      {:ok, res} <- Jason.decode(res) do
        case res do
          %{"status_code" => _, "message" => msg} -> {:error, msg}
          _ -> {:ok, res}
        end
    else
      {:error, msg} -> {:error, msg}
    end
  end

  def patch(route, data) do
    with {:ok, data} <- Jason.encode(data),
      {:ok, %Response{body: res}} <- HTTPoison.patch(route, data, headers()),
      {:ok, res} <- Jason.decode(res) do
        case res do
          %{"status_code" => _, "message" => msg} -> {:error, msg}
          _ -> {:ok, res}
        end
    else
      {:error, msg} -> {:error, msg}
    end
  end

  def download(route) do
    with {:ok, %Response{body: res}} <- HTTPoison.get(route, headers(), [recv_timeout: 40000]) do
      {:ok, res}
    else
      {:error, msg} -> {:error, msg}
    end
  end

  def endpoint(:signature, endpoint), do: base_url() <> "v3/signatures" <> endpoint
  def endpoint(), do: base_url()

  def base_url, do: Application.fetch_env!(:signaturit, :url)

  defp headers(content_type \\ :json) do
    [auth_header(), content_headers(content_type)]
  end
  defp content_headers(:json) do
      {"accept", "application/json"}
  end
  defp content_headers(:multipart) do
      {"accept", "multipart/form-data"}
  end
  defp auth_header do
    {"Authorization", "Bearer " <> Application.fetch_env!(:signaturit, :api_key)}
  end

  defp merge_args({_arg, nil}, _acc), do: ""
  defp merge_args({arg, val}, acc), do: "#{acc}&#{arg}=#{val}"
end
