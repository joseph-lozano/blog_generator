---
title: I created a March Madness predictor CLI, then turned it into a web app.
description: I should have done this a week earlier.
tags: post project
---

**tl;dr** It's deployed at https://ncaa-predictor.onrender.com

First step was getting the bracket done. The NCAA Tournament is broken into 4 regions, each containing 16 teams seeded 1 through 16.

The 1 seeded team, plays the 16 seeded team, the 2 plays 15, etc. The tournament is organized to favor the better seeded team, so 1 and 2 are on opposite sides of the bracket. In the end, the first round looks something like this

```elixir
  @matchups [
    [1, 16],
    [8, 9],
    [5, 12],
    [4, 13],
    [6, 11],
    [3, 14],
    [7, 10],
    [2, 15]
  ]
```

Next, we recursivlely resolve the games, until there is only 1 left.

```elixir
def resolve([ _ | _ ] = matchups) do
  matchups
  |> Enum.map(fn [team_a, team_b] -> resolve(team_a, team_b) end)
  |> Enum.chunk_every(2)
  |> resolve()
  end
```

`Enum.chunk_every/2` is especially helpful here.

Next, we implement a naive approach, assuming the better seeded team wins

```elixir
def resolve({name_a, seed_a} = team_a, {name_b, seed_b} = team_b) do
  if seed_a < seed_b do
    IO.puts "#{name_a} beats #{name_b}"
    team_a
  else
    IO.puts "#{name_b} beats #{name_a}"
    team_b
  end
end
```

And our base case

```elixir
def resolve([{name, _seed} = team]) do
  IO.puts "#{name} wins!"
  team
end
```

Next, we just do this for each of the 4 regions, and put them in a tournament with eachother

```elixir
def play() do
  final_four = for region <- ["WEST", "EAST", "SOUTH", "MIDWEST"] do
    winner = resolve(@matchups)
    {region, winner}
  end

  resolve(final_four)
end
```

And that's basically it!

But, better seeds don't always win. So I found some data on [http://mcubed.net/ncaab/seeds.shtml](http://mcubed.net/ncaab/seeds.shtml), parsed it and came up with a map that shows the percentage of times a seed beats a given seed.

For the first seed, it looks like this

```elixir
@data %{
  1 => %{
    1 => 50.0,
    2 => 53.3,
    3 => 62.5,
    4 => 70.7,
    5 => 83.3,
    6 => 68.8,
    7 => 85.7,
    8 => 80.2,
    9 => 90.0,
    10 => 85.7,
    11 => 57.1,
    12 => 100.0,
    13 => 100.0,
    14 => 0.0,
    15 => 0.0,
    16 => 99.3
    },
  2 => %{ ... }
}
```

For some cases, like against 14 and 15 seeds, there is no data, so in that case we assume the better seed wins.

Our `resolve/2` function, now looks like

```elixir
def resolve({_, team_a} = a, {_, team_b} = b) do
  team_a_win_pct = @data[team_a][team_b]

  {winner, loser} =
    if :rand.uniform() * 100 < team_a_win_pct or (team_a_win_pct == 0.0 and team_a < team_b) do
      {a, b}
    else
      {b, a}
    end

  seed_text =
    if team_a_win_pct != 0.0 do
      winner_pct = @data[elem(winner, 1)][elem(loser, 1)]
      "#{elem(winner, 0)} beats #{elem(loser, 0)} seeds #{winner_pct}% of the time"
    else
      "No data for #{elem(winner, 0)} vs #{elem(loser, 0)}. Assuming #{elem(winner, 0)} wins"
    end

  IO.puts(
    String.pad_trailing("#{elem(winner, 0)} beats #{elem(loser, 0)}", 21) <> "\t" <> seed_text
  )

  winner
end
```

And that's basically it for the CLI! You can check it out on [Github](https://github.com/joseph-lozano/ncaa_predictor) if you'd like to check out the final version.

Now, for the deploy. I wrote a basic Plug router (no Phoenix for a project this small)

```elixir
defmodule NCAA.Server do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/" do
    {:ok, pid} = StringIO.open("")
    NCAA.play(pid)

    resp_text = StringIO.flush(pid)
    StringIO.close(pid)
    resp_text

    send_resp(conn, 200, resp_text)
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end
```

You can see we are passing in a `pid` to our `NCAA.play` function. This is because want to capture everything written, so we can send it back to the client (instead of to STDOUT).
That means all of our `IO.puts(string)` functions change to `IO.puts(pid, string)`. Very straight-forward.

After the winner is calculated, we capture the string with `StringIO.flush`, and close the process. Then we just send it to the client with `send_resp`.

Next we need to make sure our server starts up. First in our `mix.exs` we change `def application` to

```elixir
def application do
  [
    mod: {NCAA.Application, []},
    extra_applications: [:logger]
  ]
end
```

Then create `NCAA.Application`

```elixir
defmodule NCAA.Application do
  @moduledoc false
  use Application
  require Logger

  def start(_type, _args) do
    port =
      case Mix.env() do
        :prod ->
          80

        _ ->
          Logger.info("Starting application at http://localhost:4000")
          4000
      end

    children = [
      {Plug.Cowboy, scheme: :http, plug: NCAA.Server, options: [port: port]}
    ]

    opts = [strategy: :one_for_one, name: NCAA.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
```

In prod we start in port 80, otherwise 4000 is fine.

I deployed this to render. The build script is simply `mix deps.get && mix compile` and the run script is just `mix run --no-halt`.

Easy peasy. You can check out at at https://ncaa-predictor.onrender.com for the duration of the tournament, for just clone it yourself [from Github](https://github.com/joseph-lozano/ncaa_predictor) and run it with `mix run --no-halt`.

Thanks for reading.
