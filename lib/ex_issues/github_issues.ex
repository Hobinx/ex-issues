defmodule ExIssues.GithubIssues do
  @user_agent [{'User-agent', "Mozilla/5.0"}]

  def fetch(user, repo) do
    issues_url(user, repo)
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  def issues_url(user, repo) do
    "https://api.github.com/search/issues?q=user:#{user}+repo:#{repo}"
  end

  def handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    {:ok, body}
  end

  def handle_response({:ok, %HTTPoison.Response{status_code: _, body: body}}) do
    {:error, body}
  end

  def handle_response({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, reason}
  end
end