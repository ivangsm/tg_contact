import Config

config :tg_contact, TgContactWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: System.get_env("PORT") || 4000],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  url: [host: System.get_env("HOST") || "example.com", port: 80],
  server: true

# Do not print debug messages in production
config :logger, level: :info

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
