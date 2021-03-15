---
title: "Testing with Elixir Part 2"
permalink: testing-with-elixir-part-2.html
description: How to test processes and GenServers
layout: post.njk
draft: true
tags:
  - post
  - testing
---

In [Part 0](/testing-with-elixir-part-0.html) we looked at the basic anatomy of a test: **given**, **when**, and **then**. Now we will put that into action.


Very easy. But that that is because this is a simple GenServer. What if instead of a counter, our GenServer was rate-limiting API calls?

```elixir
defmodule RateLimiter do
  alias API
  @min_time_between_requests :timer.seconds(2)

  ### API

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def get() do
    GenServer.call(__MODULE__, :get)
  end

  ### Implementation

  def init(_) do
    min_time_ago =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(-1 * @min_time_between_requests, :millisecond)

    {:ok, %{last_request: min_time_ago}}
  end

  def handle_call(:get, _from, %{last_request: last_request}) do
    now = NaiveDateTime.utc_now()

    api_resp =
      case NaiveDateTime.diff(now, last_request, :millisecond) do
        millis when millis > @min_time_between_requests ->
          API.get()

        millis ->
          Process.sleep(millis)
          API.get()
      end

    {:reply, api_resp, %{last_request: now}}
  end
end
```

The meat of the module is in the `handle_call(:get, ...)` function. If the time since the last request is greater than the minimum time we should wait. We need to pause until that amount of time has passed.

This is obviously not production quality code, as there are way too many edge-cases not handled, but it is complex enough to really make us wonder how we are going to test this.

Here's the dirty secret: We can't test this. At least not safely. Any test of the `get()` function will call an external API. Bad news considering this is the same API we are trying to rate-limit!

What we can do is _change_ the code to make it testable. If you TDD you never have to do this since the code will always be testable. So let's start from scratch and TDD this.

First things first, let's not worry about rate-limiting at all. Let's just make sure we can call an `API.get()` and test it.

```elixir
test "can call API.get()" do
  # Given a rate limiter
  rate_limiter = RateLimiter.start_link()

  # When I call get
  actual = RateLimiter.get()

  # Then I get a response
  assert %{some_response: true} == actual
end
```

But wait! We don't want to call the actual API, instead we are going to call a `FakeAPI`.

```elixir
defmodule FakeAPI do
  def get() do
    %{some_response: true}
  end
end
```

An our given changes ever so slightly

```elixir
  # Given a rate limiter
  rate_limiter = RateLimiter.start_link(%{api: FakeAPI})
```

Our implementation code:

```elixir
defmodule RateLimiter
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def get() do
    GenServer.call(__MODULE__, :get)
  end

  def init(opts) do
    {:ok, opts}
  end

  def handle_call(:get, _from, {api: api} = state) do
    resp = api.get()
    {:ok, resp, state}
  end
end
```

And our test should pass! By injecting our API dependency into the GenServer, we made our module much more testable.

We can test the rate-limiting quite easily by also injecting it. We can also leverage processes to capture exactly when a request was received. Here's what the test looks like.

```elixir
test "rate limits API calls" do
  timer = :timer.seconds(0.1)
  rate_limiter = RateLimiter.start_link(%{api: FakeAPI, timer: timer)})

  send_request = fn pid ->
    Task.async(fn ->
      RateLimiter.get()
      send(pid, %{recieved_at: NaiveDateTime.utc_now()})
    end)
  end

  send_request.(self())
  send_request.(self())

  assert_received %{recieved_at: time_a}
  assert_received %{recieved_at: time_b}

  assert NaiveDateTime.diff(time_a, time_b, :milliseconds) >  timer
end
```

# TODO: Rope in `start_supervised`

Final code:

```elixir
defmodule RateLimiter do
  alias API
  use GenServer

  ### API

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def get() do
    GenServer.call(__MODULE__, :get)
  end

  ### Implementation

  def init(%{api: api, timer: timer}) do
    min_time_ago =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(-1 * timer, :millisecond)

    {:ok, %{last_request: min_time_ago, api: api, timer: timer}}
  end

  def handle_call(:get, _from, %{last_request: last_request, api: api, timer: timer} = state) do
    now = NaiveDateTime.utc_now()

    api_resp =
      case NaiveDateTime.diff(now, last_request, :millisecond) do
        millis when millis < timer ->
          IO.inspect(millis, label: "DIFF")
          api.get()

        millis ->
          IO.inspect(millis, label: "DIFF")
          Process.sleep(millis)
          api.get()
      end

    {:reply, api_resp, %{state | last_request: now}}
  end
end

defmodule FakeAPI do
  def get() do
    %{some_response: true}
  end
end

ExUnit.start()

defmodule RateLimiterTest do
  use ExUnit.Case

  setup do
    start_supervised({RateLimiter, %{api: FakeAPI, timer: timer}})
    %{timer: timer}
  end

  test "can call API.get()" do
    # Given a rate limiter
    # RateLimiter.start_link(%{api: FakeAPI, timer: timer})

    # When I call get
    actual = RateLimiter.get()

    # Then I get a response
    assert %{some_response: true} == actual
  end

  test "rate limits API calls", %{timer: timer} do
    # rate_limiter = RateLimiter.start_link(%{api: FakeAPI, timer: timer})

    send_request = fn pid ->
      Task.async(fn ->
        RateLimiter.get()
        send(pid, %{recieved_at: NaiveDateTime.utc_now()})
      end)
    end

    send_request.(self())
    send_request.(self())

    assert_receive %{recieved_at: time_first}, timer * 2
    assert_receive %{recieved_at: time_second}, timer * 2

    assert NaiveDateTime.diff(time_second, time_first, :millisecond) > timer
  end
end
```
