defmodule TgContact.Telegram do
  use Tesla

  @telegram_base_url "https://api.telegram.org/bot"

  plug Tesla.Middleware.BaseUrl, "#{@telegram_base_url}#{config(:bot_token)}"
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.Headers, [{"Content-Type", "application/json"}]

  @type send_result :: :ok | {:error, String.t()}

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

    # Log the body and endpoint for debugging
    IO.inspect(body, label: "Telegram Request Body")
    IO.inspect("#{config(:bot_token)}", label: "Telegram API Token")

    case post("/sendMessage", body) do
      {:ok, %{status: 200, body: response_body}} ->
        IO.inspect(response_body, label: "Telegram API Success Response")
        :ok

      {:ok, %{status: status, body: response_body}} ->
        IO.inspect(response_body, label: "Telegram API Error Response")
        {:error, "Telegram API returned status #{status}: #{inspect(response_body)}"}

      {:error, reason} ->
        {:error, "Request failed: #{inspect(reason)}"}
    end
  end

  defp config(key), do: Application.fetch_env!(:tg_contact, __MODULE__)[key]
end
