defmodule Intercooler.Plug do
  @moduledoc """
  Recognize Intercooler.js requests and intercept redirections.

  This plug sets an `intercooler?` private key in the connection that indicates whether the request
  was made by Intercooler.js or not. This private key may be used in your own plugs or controllers
  to modify their behaviour for Intercooler requests. For example you could change the application
  layout only for Intercooler requests.

  This plug also intercepts redirections for Intercooler.js requests to ensure that Intercooler
  redirects the client as expected, instead of following the redirection itself.
  """
  @behaviour Plug

  import Plug.Conn

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, _opts) do
    conn
    |> put_private(:intercooler?, intercooler?(conn))
    |> register_before_send(&intercept_redirections/1)
  end

  # When an Intercooler requests receives a response with a normal redirection, Intercooler itself
  # follows the redirection instead of redirecting the client.
  # This behaviour can be fixed by replacing the "Location" response header by the
  # "X-IC-Redirect" header. The empty response body instructs Intercooler not to replace anything
  # in the DOM.
  defp intercept_redirections(conn) do
    if conn.private.intercooler? && redirection?(conn) do
      [location] = get_resp_header(conn, "location")

      conn
      |> delete_resp_header("location")
      |> put_resp_header("x-ic-redirect", location)
      |> struct(resp_body: [])
    else
      conn
    end
  end

  # Intercooler requests can be identified by the "X-IC-Request" header and the "ic-request" param.
  defp intercooler?(conn) do
    has_intercooler_param? = conn.params["ic-request"] == "true"
    has_intercooler_header? = get_req_header(conn, "x-ic-request") == ["true"]

    has_intercooler_param? && has_intercooler_header?
  end

  # Redirection codes as per https://en.wikipedia.org/wiki/List_of_HTTP_status_codes#3xx_Redirection
  defp redirection?(conn), do: conn.status in 301..308
end
