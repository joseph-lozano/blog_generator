---
title: Testing with Elixir Part 0
description: The basic anatomy of a test
tags:
  - post
  - testing
---

This is the first of what I hope will be many posts on testing in Elixir.

This is part 0, and not Elixir-specific. Just the basics of testing.

### Given, When, Then

Every (unit) test should be able to be broken down into these parts.

1. **Given** some context or situation
2. **When** I invoke the function I am trying to test
3. **Then** I get the expected result

Let's take a trivial example. I am writing a function to capitalize every other letter of a string.

```elixir
def spongebob_case(string) do
 # ???
end
```

Our **given** is the various cases we are trying to put under test.

```elixir
cases = [
  "lorem ipsum dolor sit amet, consectetur adipiscing elit",
  "sed do eiusmod tempor incididunt ut labore et dolore magna aliqua",
  "Ut enim ad minim veniam",
  "quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat"
]
```

Our **when** is invoking the function with each case. We store this into a variable called _actual_.

```elixir
actual = Enum.map(cases, fn kase ->
  spongebob_case(kase)
end)
```

Our **then** is making the assertion against our expected result

```elixir
expected = [
  "lOrEm iPsUm dOlOr sIt aMeT, cOnSeCtEtUr aDiPiScInG ElIt",
  "sEd dO EiUsMoD TeMpOr iNcIdIdUnT Ut lAbOrE Et dOlOrE MaGnA AlIqUa"
  "uT EnIm aD MiNiM VeNiAm",
  "qUiS NoStRuD ExErCiTaTiOn uLlAmCo lAbOrIs nIsI Ut aLiQuIp eX Ea cOmMoDo cOnSeQuAt"
]

assert actual == expected
```

The full test looks like this:

```elixir
defmodule SpongebobTest do
  use ExUnit.Case
  import SpongeBob, only: [spongebob_case: 1]

  test "spongebob_case/1 makes every letter other letter upper case" do
    cases = [
      "lorem ipsum dolor sit amet, consectetur adipiscing elit",
      "sed do eiusmod tempor incididunt ut labore et dolore magna aliqua",
      "Ut enim ad minim veniam",
      "quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat"
    ]

    actual =
      Enum.map(cases, fn kase ->
        spongebob_case(kase)
      end)

    assert actual == [
             "lOrEm iPsUm dOlOr sIt aMeT, cOnSeCtEtUr aDiPiScInG ElIt",
             "sEd dO EiUsMoD TeMpOr iNcIdIdUnT Ut lAbOrE Et dOlOrE MaGnA AlIqUa",
             "uT EnIm aD MiNiM VeNiAm",
             "qUiS NoStRuD ExErCiTaTiOn uLlAmCo lAbOrIs nIsI Ut aLiQuIp eX Ea cOmMoDo cOnSeQuAt"
           ]
  end
end
```

Generally we want to start with 1 simple case, then add more cases, (including edge-cases) as we build out the actual implementation.

Edge cases in this example would be:

1. What if there is an integer in the input? an emoji? You can't upper case those.
2. What if the input isn't a string?

Exactly how you handle those edge-cases is usually a product question. As the engineer writing tests, however, it is important that you think about them, and make sure that they are under test.

In future parts, we will talk about how to test GenServers/Processes. Dynamically generating tests, as well as looking at other assertions.

Thanks for reading.
