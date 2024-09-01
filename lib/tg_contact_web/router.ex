defmodule TgContactWeb.Router do
  use TgContactWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", TgContactWeb do
    pipe_through :api

    post "/contact", ContactController, :submit
  end
end
