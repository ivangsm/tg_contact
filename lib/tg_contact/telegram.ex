defmodule TgContact.Telegram do
  @moduledoc """
  Handles sending messages to Telegram.
  """

  use Tesla
  require Logger

  @telegram_base_url "https://api.telegram.org/bot"

  def client do
    bot_token = config(:bot_token)
    base_url = "#{@telegram_base_url}#{bot_token}"

    # Log the full URL at the debug level
    Logger.debug("Telegram API Base URL: #{base_url}")

    Tesla.client([
      {Tesla.Middleware.BaseUrl, base_url},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [{"Content-Type", "application/json"}]}
    ])
  end

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

    case Tesla.post(client(), "/sendMessage", body) do
      {:ok, %{status: 200, body: response_body}} ->
        Logger.info("Telegram API Success Response: #{inspect(response_body)}")
        :ok

      {:ok, %{status: status, body: response_body}} ->
        Logger.error("Telegram API Error Response: #{inspect(response_body)}")
        {:error, "Telegram API returned status #{status}: #{inspect(response_body)}"}

      {:error, reason} ->
        Logger.error("Request to Telegram API failed: #{inspect(reason)}")
        {:error, "Request failed: #{inspect(reason)}"}
    end
  end

  defp config(key), do: Application.fetch_env!(:tg_contact, __MODULE__)[key]
end
