defmodule HostexTest do
  use ExUnit.Case, async: true
  use Plug.Test
  doctest Hostex

  alias Hostex.UploadPlug

  @base_url "http://localhost:4001/"
  @test_file Path.join(to_string(:code.priv_dir(:hostex)), "test.txt")

  test "GET /healthz works" do
    {:ok, %{status_code: 200, body: body}} = HTTPoison.get(Path.join(@base_url, "/healthz"))
    assert body == "OK"
  end

  test "Uploding without a token fails" do
    conn =
      conn(:post, "/file.txt")
      |> Map.put(:params, %{"file" => %Plug.Upload{}})
      |> UploadPlug.call([])

    assert conn.status == 401
    assert conn.resp_body == "UNAUTHORIZED"

    conn =
      conn(:post, "/file.txt")
      |> put_req_header("authorization", "Bearer badtoken")
      |> Map.put(:params, %{"file" => %Plug.Upload{}})
      |> UploadPlug.call([])

    assert conn.status == 401
    assert conn.resp_body == "UNAUTHORIZED"

    {:ok, %{status_code: 401, body: "UNAUTHORIZED"}} =
      HTTPoison.post(
        Path.join(@base_url, "test_file.txt"),
        {:multipart, [{:file, @test_file}]}
      )
  end

  test "Uploading without file raises 400 error" do
    {:ok, %{status_code: 400, body: error}} =
      HTTPoison.post(
        Path.join(@base_url, "test_file.txt"),
        "",
        authorization: "Bearer testtoken"
      )

    assert error =~ "`file"
  end

  test "Uploading a file and fetching it works" do
    {:ok, %{status_code: 200, body: json}} =
      HTTPoison.post(
        Path.join(@base_url, "test_file.txt"),
        {:multipart, [{:file, @test_file}]},
        authorization: "Bearer testtoken"
      )

    resp = Jason.decode!(json)

    assert resp["mime"] == "text/plain"

    {:ok, %{status_code: 200}} = HTTPoison.get(Path.join(@base_url, resp["url"]))
  end

  test "Uploading without filename works" do
    {:ok, %{status_code: 200, body: json}} =
      HTTPoison.post(
        @base_url,
        {:multipart, [{:file, @test_file}]},
        authorization: "Bearer testtoken"
      )

    resp = Jason.decode!(json)

    assert resp["mime"] == "text/plain"

    {:ok, %{status_code: 200} = result} = HTTPoison.get(Path.join(@base_url, resp["url"]))

    {"etag", etag} = Enum.find(result.headers, fn {name, _} -> name == "etag" end)

    # Test with etag
    {:ok, %{status_code: 304}} =
      HTTPoison.get(Path.join(@base_url, resp["url"]), "if-none-match": etag)
  end

  test "Getting a non existing file return 404" do
    {:ok, %{status_code: 404}} =
      HTTPoison.get(Path.join(@base_url, "2020-08-08/128dj192n912n/not_found.txt"))
  end
end
