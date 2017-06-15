defmodule ExIssues.CLI do
  import ExIssues.TableFormatter, only: [ print_table_for_columns: 2 ]
  @default_count 4

  def run(argv) do
    argv
    |> parse_args
    |> process
  end

  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [ help: :boolean ],
                               aliases: [ h: :help ])
    case parse do
      { [ help: true ], _, _ } -> :help

      { _, [ user, project, count ], _ } ->
        { user, project, String.to_integer(count) }
      
      { _, [ user, project], _ } ->
        { user, project, @default_count }
      
      _ -> :help
    end
  end

  def process(:help) do
    IO.puts """
    usage: issues <user> <project> [ count | #{@default_count} ]
    """
    System.halt(0)
  end

  def process({user, project, count}) do
    ExIssues.GithubIssues.fetch(user, project)
    |> decode_response
    |> sort_into_ascending_order
    |> Enum.take(count)
    |> print_table_for_columns(["number", "created_at", "title"])
  end

  def decode_response({:ok, body}), do: Map.get(body, "items")

  def decode_response({:error, error}) do
    message = Map.get(error, "message") 
    IO.puts "Error fetching from Github: #{message}"
    System.halt(2)
  end

  def sort_into_ascending_order(list_of_issues) do
    Enum.sort list_of_issues,
              fn i1, i2 -> Map.get(i1, "created_at") <= Map.get(i2, "created_at") end
  end
end