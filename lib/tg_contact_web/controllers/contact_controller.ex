defmodule TgContactWeb.ContactController do
  use TgContactWeb, :controller

  alias TgContact.Telegram

  def submit(conn, %{"name" => name, "email" => email, "message" => message}) do
    case Telegram.send_message(name, email, message) do
      :ok ->
        json(conn, %{status: "success"})

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{status: "error", reason: reason})
    end
  end
end
