import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :tg_contact, TgContactWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "6sXZBNzcGVRc1n5XhSYbi331KVGrhuUqfyCGNQ35q/0hQI+wX2zhVMde4sCO2CbA",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
