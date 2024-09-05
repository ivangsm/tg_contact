defmodule TgContactWeb.ContactController do
  use TgContactWeb, :controller

  alias TgContact.Telegram
  alias Hammer

  @limit 1
  @period 60_000 # 1 minute

  def submit(conn, params) do
    # Convert remote_ip to string format
    ip_string = conn.remote_ip |> :inet.ntoa() |> to_string()

    # 1 submit attempt per minute
    case Hammer.check_rate(ip_string, @period, @limit) do
      {:allow, _count} ->
        do_submit(conn, params)

      {:deny, _limit} ->
        # Return a JSON error response when rate-limited
        conn
        |> put_status(:too_many_requests)
        |> json(%{status: "error", reason: "Rate limit exceeded. You can only send one message per minute."})

      {:error, reason} ->
        # Unexpected error handling
        conn
        |> put_status(:internal_server_error)
        |> json(%{status: "error", reason: "Rate limiting error: #{inspect(reason)}"})
    end
  end

  def do_submit(conn, %{"name" => name, "email" => email, "message" => message}) do
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
