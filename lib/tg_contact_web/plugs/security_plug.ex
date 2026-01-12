defmodule TgContactWeb.Plugs.SecurityPlug do
  @moduledoc """
  Security plug to block common malicious requests and scanner bots.

  This plug can be reused across Phoenix projects to protect against:
  - WordPress vulnerability scanners
  - .env file access attempts
  - Git repository exposure
  - PHP file probes
  - Other common attack vectors
  """

  import Plug.Conn
  require Logger

  @behaviour Plug

  # Suspicious paths that should be blocked
  @blocked_paths [
    # WordPress
    ~r{/wp-},
    ~r{/wordpress},
    ~r{/website/wp-},
    ~r{/news/wp-},
    ~r{/shop/wp-},
    ~r{/cms/wp-},
    ~r{/site/wp-},
    ~r{/sito/wp-},
    ~r{wlwmanifest\.xml},
    ~r{/xmlrpc\.php},

    # Environment files
    ~r{/\.env},
    ~r{/\.env\.},

    # Git files
    ~r{/\.git},
    ~r{/\.gitconfig},
    ~r{/\.git-credentials},

    # PHP files
    ~r{\.php$},
    ~r{/phpinfo},

    # Config files
    ~r{/appsettings\.json},
    ~r{/web\.config},
    ~r{/config\.json},

    # Database dumps
    ~r{\.sql$},
    ~r{\.sql\.gz$},
    ~r{/backup},
    ~r{\.bak$},

    # Common admin panels
    ~r{/phpmyadmin},
    ~r{/admin\.php},
    ~r{/administrator},
  ]

  def init(opts), do: opts

  def call(conn, _opts) do
    path = conn.request_path

    if blocked_path?(path) do
      Logger.warning("Blocked malicious request: #{path} from #{format_ip(conn.remote_ip)}")

      conn
      |> send_resp(404, "Not Found")
      |> halt()
    else
      conn
    end
  end

  defp blocked_path?(path) do
    Enum.any?(@blocked_paths, fn pattern ->
      Regex.match?(pattern, path)
    end)
  end

  defp format_ip(ip) do
    ip |> :inet.ntoa() |> to_string()
  end
end
