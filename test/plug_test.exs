defmodule Intercooler.PlugTest do
  use ExUnit.Case, async: true

  import Plug.Conn

  test "detects Intercooler requests" do
    conn = Intercooler.Plug.call(build_intercooler_conn(), [])

    assert conn.private.intercooler?
  end

  test "intercepts redirections for Intercooler requests" do
    conn =
      build_intercooler_conn()
      |> Intercooler.Plug.call([])
      |> redirect(to: "/redirection-path")

    assert conn.status == 301
    assert get_resp_header(conn, "x-ic-redirect") == ["/redirection-path"]
    assert Enum.empty?(get_resp_header(conn, "location"))
  end

  test "does not not modify redirections for normal requests" do
    conn =
      build_conn()
      |> Intercooler.Plug.call([])
      |> redirect(to: "/redirection-path")

    assert conn.status == 301
    assert get_resp_header(conn, "location") == ["/redirection-path"]
    assert Enum.empty?(get_resp_header(conn, "x-ic-redirect"))
  end

  defp build_conn do
    Plug.Adapters.Test.Conn.conn(%Plug.Conn{}, :get, "/", %{})
  end

  defp build_intercooler_conn do
    %Plug.Conn{}
    |> Plug.Adapters.Test.Conn.conn(:get, "/", %{"ic-request" => "true"})
    |> put_req_header("x-ic-request", "true")
  end

  defp redirect(conn, to: path) do
    conn
    |> resp(301, "")
    |> put_resp_header("location", path)
    |> send_resp()
  end
end
