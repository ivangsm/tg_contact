defmodule TgContact.Telegram do
  @moduledoc """
  Handles sending messages to Telegram.
  """

  use Tesla

  @telegram_base_url "https://api.telegram.org/bot"

  plug Tesla.Middleware.BaseUrl, "#{@telegram_base_url}#{config(:bot_token)}"
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.Headers, [{"Content-Type", "application/json"}]

  @type send_result :: {:ok, %{chat_id: integer(), message_id: integer()}} | {:error, String.t()}

  @spec send_message(String.t(), String.t(), String.t()) :: send_result()
  def send_message(name, email, message) do
    text = """
    New Contact Form Submission:
    Name: #{name}
    Email: #{email}
    Message: #{message}
    """

    body = %{
      "chat_id" => config(:chat_id),
      "text" => text
    }

    case post("/sendMessage", body) do
      {:ok, %{status: 200}} ->
        :ok

      {:ok, %{status: status, body: body}} ->
        {:error, "Telegram API returned status #{status}: #{inspect(body)}"}

      {:error, reason} ->
        {:error, "Request failed: #{inspect(reason)}"}
    end
  end

  defp config(key), do: Application.fetch_env!(:tg_contact, __MODULE__)[key]
end
