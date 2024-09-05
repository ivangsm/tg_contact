defmodule TgContact.Telegram do
  @moduledoc """
  Handles sending messages to Telegram.
  """

  use Tesla

  @telegram_base_url "https://api.telegram.org/bot"

  def client do
    bot_token = config(:bot_token)
    base_url = "#{@telegram_base_url}#{bot_token}"

    # Log the full URL
    IO.inspect(base_url, label: "Telegram API Base URL")

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
