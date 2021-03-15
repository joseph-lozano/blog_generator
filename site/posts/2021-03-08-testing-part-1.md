---
title: "Testing with Elixir Part 1: GenServers"
permalink: testing-with-elixir-part-1.html
description: How to test processes and GenServers
layout: post.njk
tags:
  - post
  - testing
---

In [Part 0](/testing-with-elixir-part-0.html) we looked at the basic anatomy of a test: **given**, **when**, and **then**. Now we will put that into action.

In a lot of ways, a GenServer can be though of like a class. It holds state and responds to messages. Let's look at a basic example.

```elixir
defmodule Counter do
  use GenServer

  ### API ###

 def start_link(init \\ 0) do
  GenServer.start_link(__MODULE__, init, name: __MODULE__)
 end

  def increment() do
    GenServer.call(__MODULE__, :increment)
  end

  def current() do
    GenServer.call(__MODULE__, :state)
  end

  ### Implementation

  def init(arg), do: {:ok, arg}

  def handle_call(:increment, _from, state) do
    new_state = state + 1
    {:reply, new_state, new_state}
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end
end

{:ok, _} = Counter.start_link()
Counter.increment() # 1
Counter.increment() # 2
Counter.increment() # 3
```

Testing this module is equally straight-forward.

1. **Given** a counter
2. **When** increment is called
3. **Then** I expect a higher number

```elixir
test "Counter increments" do
  # Given
  Counter.start_link()

  # When
  Counter.increment()

  # Then
  assert 1 == Counter.current()
end
```

But, what happens where there a lot of tests?

```elixir

setup do
  Counter.start_link()
  :ok
end

for i <- 1..2000 do
  test "Counter increments #{i}" do
    Counter.increment()

    assert 1 == Counter.current()
  end
end
```

Obviously this is a bit of a contrived example, but if you run these tests, eventually, it breaks.

```
1) test Counter increments 1131 (CounterTest)
    code_examples/2021-03-08-counter.exs:47
    ** (exit) exited in: GenServer.call(Counter, :increment, 5000)
        ** (EXIT) no process: the process is not alive or there's no process currently associated with the given name, possibly because its application isn't started
    code: Counter.increment()
```

So, what happened? Well, because every `Counter` had the same `name` option, there was a race-condition where a previous test's `Counter` had not shut down before the `setup` call, but did get shut down before the `increment` call. Hence the faiure `the process is not alive`

As I said, this is a contrived example. But even a little bit of flakiness is something to be avoided. Especially since the solution is so easy. So what's the solution? `start_supervised`, which gurantees that supervised process (`Counter` in our example) is ended **before** the test process ends (and more importantly, before the next test starts)

Changing just our setup block to the following guarantees that our tests will pass.

```elixir
setup do
  start_supervised!({Counter, 0})
  :ok
end
```

Thanks for reading
