defmodule Exorthanc.RetrieveTest do
  use Exorthanc.TestCase

  alias Exorthanc.Retrieve

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "get orthanc changelog", %{bypass: bypass} do
    Bypass.expect(bypass, fn conn ->
      assert "/changes" == conn.request_path
      assert "GET" == conn.method
      Plug.Conn.resp(conn, 200, @changes_json)
    end)
    response = Retrieve.changes("http://localhost:#{bypass.port}")
    assert @changes = response
  end

  test "get orthanc instances", %{bypass: bypass} do
    Bypass.expect(bypass, fn conn ->
      assert "/instances" == conn.request_path
      assert "GET" == conn.method
      Plug.Conn.resp(conn, 200, @instances_json)
    end)
    response = Retrieve.get("http://localhost:#{bypass.port}", "instances")
    assert @instances = response
  end

  test "get orthanc modalities", %{bypass: bypass} do
    Bypass.expect(bypass, fn conn ->
      assert "/modalities" == conn.request_path
      assert "GET" == conn.method
      Plug.Conn.resp(conn, 200, @modalities_json)
    end)
    response = Retrieve.modalities("http://localhost:#{bypass.port}")
    assert @modalities = response
  end

  test "post orthanc tools_lookup", %{bypass: bypass} do
    #TODO: check if post data is right
    Bypass.expect(bypass, fn conn ->
      assert "/tools/lookup" == conn.request_path
      assert "POST" == conn.method
      Plug.Conn.resp(conn, 200, @tools_lookup_json)
    end)
    response = Retrieve.tools_lookup("http://localhost:#{bypass.port}", "1.2.3.4.5")
    assert @tools_lookup = response
  end

  test "credentials header and invalid credentials", %{bypass: bypass} do
    Bypass.expect(bypass, fn conn ->
      assert "/instances" == conn.request_path
      assert "GET" == conn.method
      refute is_nil(Enum.find(conn.req_headers, fn({k, _}) -> k == "authorization" end))
      Plug.Conn.resp(conn, 401, "")
    end)
    response = Retrieve.get("http://wrong:credentials@localhost:#{bypass.port}", "instances")
    assert {:error, {_, 401}} = response
  end

end
