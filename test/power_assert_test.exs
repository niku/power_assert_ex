defmodule PowerAssertTest do
  use PowerAssert

  #test "Enum.at should return the element at the given index" do
  #  array = [1, 2, 3]; index = 2; two = 2
  #  assert array |> Enum.at(index) == two
  #end

  test "expr" do
    import List
    assert ~w(hoge fuga) == ["hoge", "fuga"]
    x = "fuga"
    assert "hoge#{x}fuga" == "hogefugafuga"
    _one = "aiueo"
    two = 2
    assert [_one] = [two]
    assert match?(x, "fuga")
    keywords = [value: [value: "hoge"]]
    assert keywords[:value][:value] == "hoge"
    assert fn(x) -> x == 1 end.(1)
    assert __ENV__.aliases |> Kernel.==([])
    assert [1,2] |> first() |> Kernel.==(1)
    assert self |> Kernel.==(self)
    assert [1,2,3] |> Enum.take(1) |> List.delete(1) |> Enum.empty?
  end

  test "raise" do
    try do
      assert [1,2,3] |> Enum.take(1) |> Enum.empty?
    rescue
      error ->
        msg = """
        [1, 2, 3] |> Enum.take(1) |> Enum.empty?()
                          |               |
                          |               false
                          [1]
        """

        if error.message <> "\n" != msg do
          value = false
          assert value
        end
    end
  end
end

defmodule PowerAssertAssertionTest do
  use ExUnit.Case

  require PowerAssert.Assertion
  alias PowerAssert.Assertion

  test "rendering" do
    expect = """
    [1, 2, 3] |> Enum.take(1) |> Enum.empty?()
                      |               |
                      |               false
                      [1]
    """
    assert_helper(expect, fn () ->
      Assertion.assert [1,2,3] |> Enum.take(1) |> Enum.empty?
    end)
  end

  test "with message" do
    expect = """
    failed with message

    [false] |> List.first()
                    |
                    false
    """
    assert_helper(expect, fn () ->
      Assertion.assert [false] |> List.first, "failed with message"
    end)
  end

  test "tuple expr" do
    expect = """
    {x, :hoge} == {\"x\", :hoge}
     |
     \"hoge\"
    """
    assert_helper(expect, fn () ->
      x = "hoge"
      Assertion.assert {x, :hoge} == {"x", :hoge}
    end)

    expect = """
    {x, :hoge, :fuga} == {\"x\", :hoge, :fuga}
     |
     \"hoge\"
    """
    assert_helper(expect, fn () ->
      x = "hoge"
      Assertion.assert {x, :hoge, :fuga} == {"x", :hoge, :fuga}
    end)
  end

  test "div, rem expr" do
    expect = """
    rem(x, y) != 1
    |   |  |
    |   |  2
    |   5
    1
    """
    assert_helper(expect, fn () ->
      x = 5
      y = 2
      Assertion.assert rem(x, y) != 1
    end)

    expect = """
    div(x, y) != 2
    |   |  |
    |   |  2
    |   5
    2
    """
    assert_helper(expect, fn () ->
      x = 5
      y = 2
      Assertion.assert div(x, y) != 2
    end)
  end

  test "string == string" do
    expect = """
    hoge == fuga
    |       |
    |       \"fuga\"
    \"hoge\"
    """
    assert_helper(expect, fn () ->
      hoge = "hoge"
      fuga = "fuga"
      Assertion.assert hoge == fuga
    end)
  end

  test "string == number" do
    expect = """
    hoge == piyo
    |       |
    |       4
    \"hoge\"
    """
    assert_helper(expect, fn () ->
      hoge = "hoge"
      piyo = 4
      Assertion.assert hoge == piyo
    end)
  end

  test "number" do
    expect = """
    3 == piyo
         |
         4
    """
    assert_helper(expect, fn () ->
      piyo = 4
      Assertion.assert 3 == piyo
    end)
  end

  test "!= expr" do
    expect = """
    hoge != piyo
    |       |
    |       4
    4
    """
    assert_helper(expect, fn () ->
      hoge = 4
      piyo = 4
      Assertion.assert hoge != piyo
    end)
  end

  test "array expr" do
    expect = """
    ary1 == ary2
    |       |
    |       [\"hoge\"]
    [\"hoge\", \"fuga\"]
    """
    assert_helper(expect, fn () ->
      ary1 = ["hoge", "fuga"]
      ary2 = ["hoge"]
      Assertion.assert ary1 == ary2
    end)
  end

  test "array with pipe expr" do
    expect = """
    ary1 |> Enum.count() == ary2 |> Enum.count()
    |            |          |            |
    |            |          |            1
    |            |          [\"hoge\"]
    |            2
    [\"hoge\", \"fuga\"]
    """
    assert_helper(expect, fn() ->
      ary1 = ["hoge", "fuga"]
      ary2 = ["hoge"]
      Assertion.assert ary1 |> Enum.count == ary2 |> Enum.count
    end)
  end

  test "&& expr" do
    expect = """
    5 < num && num < 13
        |      |
        |      16
        16
    """
    assert_helper(expect, fn () ->
      num = 16
      Assertion.assert 5 < num && num < 13
    end)
  end

  test "&& expr first" do
    expect = """
    5 < num && num < 13
        |
        4
    """
    assert_helper(expect, fn () ->
      num = 4
      Assertion.assert 5 < num && num < 13
    end)
  end

  test "|| expr" do
    expect = """
    num < 5 || 13 < num
    |               |
    |               10
    10
    """
    assert_helper(expect, fn () ->
      num = 10
      Assertion.assert num < 5 || 13 < num
    end)
  end

  test "map expr" do
    expect = """
    map.value()
    |   |
    |   false
    %{value: false}
    """
    assert_helper(expect, fn () ->
      map = %{value: false}
      Assertion.assert map.value
    end)

    expect = """
    map == %{value: "hoge"}
    |
    %{value: \"fuga\"}
    """
    assert_helper(expect, fn () ->
      map = %{value: "fuga"}
      Assertion.assert map == %{value: "hoge"}
    end)
  end

  test "nested map expr" do
    expect = """
    map.value().value()
    |   |       |
    |   |       false
    |   %{value: false}
    %{value: %{value: false}}
    """
    assert_helper(expect, fn () ->
      map = %{value: %{value: false}}
      Assertion.assert map.value.value
    end)
  end

  test "keywords expr" do
    expect = """
    keywords[:value]
    |       |
    |       false
    [value: false]
    """
    assert_helper(expect, fn () ->
      keywords = [value: false]
      Assertion.assert keywords[:value]
    end)

    expect = """
    keywords == [value: "hoge"]
    |
    [value: \"fuga\"]
    """
    assert_helper(expect, fn () ->
      keywords = [value: "fuga"]
      Assertion.assert keywords == [value: "hoge"]
    end)
  end

  test "| operator" do
    expect = """
    %{map | hoge: x} == %{hoge: "hoge", fuga: "fuga"}
      |           |
      |           \"x\"
      %{fuga: \"fuga\", hoge: \"hoge\"}
    """
    assert_helper(expect, fn () ->
      x = "x"
      map = %{hoge: "hoge", fuga: "fuga"}
      Assertion.assert %{map | hoge: x} == %{hoge: "hoge", fuga: "fuga"}
    end)

    expect = """
    [h | t] == [1, 2, 3, 4]
     |   |
     |   [2, 3]
     1
    """
    assert_helper(expect, fn () ->
      h = 1
      t = [2, 3]
      Assertion.assert [h|t] == [1,2,3,4]
    end)
  end

  test "nested keywords expr" do
    expect = """
    keywords[:value][:value]
    |       |       |
    |       |       false
    |       [value: false]
    [value: [value: false]]
    """
    assert_helper(expect, fn () ->
      keywords = [value: [value: false]]
      Assertion.assert keywords[:value][:value]
    end)
  end

  test "! expr" do
    expect = """
    !truth
    ||
    |true
    false
    """
    assert_helper(expect, fn () ->
      truth = true
      Assertion.assert !truth
    end)
  end

  test "only literal expr" do
    expect = """
    false
    """
    assert_helper(expect, fn () ->
      Assertion.assert false
    end)
  end

  test "func expr" do
    expect = ~r"""
    func.()
    |    |
    |    false
    #Function<.*>
    """
    assert_helper(expect, fn () ->
      func = fn () -> false end
      Assertion.assert func.()
    end)
  end

  test "func with an one argument expr" do
    expect = ~r"""
    func.(value)
    |    ||
    |    |false
    |    false
    #Function<.*>
    """
    assert_helper(expect, fn () ->
      value = false
      func = fn (v) -> v end
      Assertion.assert func.(value)
    end)
  end

  test "func with arguments expr" do
    expect = ~r"""
    func.(value1, value2)
    |    ||       |
    |    ||       "fuga"
    |    |"hoge"
    |    false
    #Function<.*>
    """
    assert_helper(expect, fn () ->
      value1 = "hoge"
      value2 = "fuga"
      func = fn (v1, v2) -> v1 == v2 end
      Assertion.assert func.(value1, value2)
    end)
  end

  test "compare funcs expr" do
    expect = ~r"""
    sum.(one, two) == sum.(three, one)
    |   ||    |       |   ||      |
    |   ||    |       |   ||      1
    |   ||    |       |   |3
    |   ||    |       |   4
    |   ||    |       #Function<.*>
    |   ||    2
    |   |1
    |   3
    #Function<.*>
    """
    assert_helper(expect, fn () ->
      sum = fn (x, y) -> x + y end
      one = 1
      two = 2
      three = 3
      Assertion.assert sum.(one, two) == sum.(three, one)
    end)
  end

  test "* expr" do
    expect = """
    one * two * three == 7
    |   | |   | |
    |   | |   | 3
    |   | |   6
    |   | 2
    |   2
    1
    """
    assert_helper(expect, fn () ->
      one = 1
      two = 2
      three = 3
      Assertion.assert one * two * three == 7
    end)
  end

  test "range expr" do
    expect = """
    !Range.range?(range)
    |      |      |
    |      |      1..3
    |      true
    false
    """
    assert_helper(expect, fn () ->
      range = 1..3
      Assertion.assert !Range.range?(range)
    end)
  end

  test "imported function expr" do
    expect = """
    first([false, 2, 3])
    |
    false
    """
    assert_helper(expect, fn () ->
      import List
      Assertion.assert first([false,2,3])
    end)
  end

  test "imported function with pipe expr" do
    expect = """
    [false, 2] |> first()
                  |
                  false
    """
    assert_helper(expect, fn () ->
      import List
      Assertion.assert [false, 2] |> first()
    end)
  end

  test "imported function without parentheses with pipe expr" do
    expect = """
    [false, 2] |> first
                  |
                  false
    """
    assert_helper(expect, fn () ->
      import List
      Assertion.assert [false, 2] |> first
    end)
  end

  test "operators expr" do
    expect = """
    x > y
    |   |
    |   2
    1
    """
    assert_helper(expect, fn () ->
      x = 1
      y = 2
      Assertion.assert x > y
    end)

    expect = """
    x < y
    |   |
    |   1
    2
    """
    assert_helper(expect, fn () ->
      x = 2
      y = 1
      Assertion.assert x < y
    end)

    expect = """
    x >= y
    |    |
    |    2
    1
    """
    assert_helper(expect, fn () ->
      x = 1
      y = 2
      Assertion.assert x >= y
    end)

    expect = """
    x <= y
    |    |
    |    1
    2
    """
    assert_helper(expect, fn () ->
      x = 2
      y = 1
      Assertion.assert x <= y
    end)

    expect = """
    x == y
    |    |
    |    1
    2
    """
    assert_helper(expect, fn () ->
      x = 2
      y = 1
      Assertion.assert x == y
    end)

    expect = """
    x != x
    |    |
    |    2
    2
    """
    assert_helper(expect, fn () ->
      x = 2
      Assertion.assert x != x
    end)

    expect = """
    x || y
    |    |
    |    false
    false
    """
    assert_helper(expect, fn () ->
      x = false
      y = false
      Assertion.assert x || y
    end)

    expect = """
    x && y
    |    |
    |    false
    true
    """
    assert_helper(expect, fn () ->
      x = true
      y = false
      Assertion.assert x && y
    end)

    expect = """
    x <> y == "hoge"
    |    |
    |    "ga"
    "fu"
    """
    assert_helper(expect, fn () ->
      x = "fu"
      y = "ga"
      Assertion.assert x <> y == "hoge"
    end)

    expect = """
    x === y
    |     |
    |     1.0
    1
    """
    assert_helper(expect, fn () ->
      x = 1
      y = 1.0
      Assertion.assert x === y
    end)

    expect = """
    x !== y
    |     |
    |     1
    1
    """
    assert_helper(expect, fn () ->
      x = 1
      y = 1
      Assertion.assert x !== y
    end)

    expect = """
    x and y
    |     |
    |     false
    true
    """
    assert_helper(expect, fn () ->
      x = true
      y = false
      Assertion.assert x and y
    end)

    expect = """
    x or y
    |    |
    |    false
    false
    """
    assert_helper(expect, fn () ->
      x = false
      y = false
      Assertion.assert x or y
    end)

    expect = """
    x =~ y
    |    |
    |    ~r/e/
    "abcd"
    """
    assert_helper(expect, fn () ->
      x = "abcd"
      y = ~r/e/
      Assertion.assert x =~ y
    end)

  end

  test "arithmetic ops expr" do
    expect = """
    x * y == a + b
    | | |    | | |
    | | |    | | 3
    | | |    | 5
    | | |    2
    | | 3
    | 6
    2
    """
    assert_helper(expect, fn () ->
      x = 2
      y = 3
      a = 2
      b = 3
      Assertion.assert x * y == a + b
    end)

    expect = """
    x / y == a - b
    | | |    | | |
    | | |    | | 2
    | | |    | 4
    | | |    6
    | | 2
    | 3.0
    6
    """
    assert_helper(expect, fn () ->
      x = 6
      y = 2
      a = 6
      b = 2
      Assertion.assert x / y == a - b
    end)

    expect = """
    x ++ y == a -- b
    | |  |    | |  |
    | |  |    | |  [1]
    | |  |    | [2, 3]
    | |  |    [1, 2, 3]
    | |  [4]
    | [1, 2, 3, 4]
    [1, 2, 3]
    """
    assert_helper(expect, fn () ->
      x = [1, 2, 3]
      y = [4]
      a = [1, 2, 3]
      b = [1]
      Assertion.assert x ++ y == a -- b
    end)
  end

  test "unary ops expr" do
    expect = """
    -x == +y
    ||    ||
    ||    |-1
    ||    -1
    |-1
    1
    """
    assert_helper(expect, fn () ->
      x = -1
      y = -1
      Assertion.assert -x == +y
    end)

    expect = """
    not x
    |   |
    |   true
    false
    """
    assert_helper(expect, fn () ->
      x = true
      Assertion.assert not x
    end)

    expect = """
    !x
    ||
    |true
    false
    """
    assert_helper(expect, fn () ->
      x = true
      Assertion.assert !x
    end)
  end

  defmodule TestStruct do
    defstruct value: "hoge"
  end

  test "struct expr" do
    expect = """
    x == %TestStruct{value: "fuga"}
    |
    %PowerAssertAssertionTest.TestStruct{value: \"ho\"}
    """
    assert_helper(expect, fn () ->
      x = %TestStruct{value: "ho"}
      Assertion.assert x == %TestStruct{value: "fuga"}
    end)
  end

  test "block expr" do
    expect = """
    true == (x == y)
             |    |
             |    false
             true
    """
    assert_helper(expect, fn () ->
      x = true; y = false
      Assertion.assert true == (x == y)
    end)
  end

  @test_module_attr [1, 2, 3]
  test "module attribute expr" do
    expect = """
    @test_module_attr |> Enum.at(2) == x
    |                         |        |
    |                         |        5
    |                         3
    [1, 2, 3]
    """
    assert_helper(expect, fn () ->
      x = 5
      Assertion.assert @test_module_attr |> Enum.at(2) == x
    end)
  end

  test "fn expr not supported" do
    # could not
    # expect = """
    # fn x -> x == 1 end.(x)
    #                    ||
    #                    |2
    #                    false
    # """
    expect = """
    fn x -> x == 1 end.(y)
                       ||
                       |2
                       false
    """
    assert_helper(expect, fn () ->
      y = 2
      Assertion.assert fn(x) -> x == 1 end.(y)
    end)

    expect = """
    Enum.map(array, fn x -> x == 1 end) |> List.first()
         |   |                                  |
         |   |                                  false
         |   [2, 3]
         [false, false]
    """
    assert_helper(expect, fn () ->
      array = [2, 3]
      Assertion.assert Enum.map(array, fn(x) -> x == 1 end) |> List.first
    end)

    # partials
    expect = """
    Enum.map(array, &(&1 == 1)) |> List.first()
         |   |                          |
         |   |                          false
         |   [2, 3]
         [false, false]
    """
    assert_helper(expect, fn () ->
      array = [2, 3]
      Assertion.assert Enum.map(array, &(&1 == 1)) |> List.first
    end)
  end

  test "= expr not supported" do
    expect = """
    List.first(x = array)
         |
         false
    """
    assert_helper(expect, fn () ->
      array = [false, true]
      Assertion.assert List.first(x = array)
    end)
  end

  test ":: expr not supported" do
    expect = """
    \"hoge\" == <<\"f\", Kernel.to_string(x) :: binary, \"a\">>
              |
              \"fuga\"
    """
    assert_helper(expect, fn () ->
      x = "ug"
      Assertion.assert "hoge" == "f#{x}a"
    end)
  end

  test "sigil expr not supported" do
    expect = """
    sigil_w(<<\"hoge fuga \", Kernel.to_string(x) :: binary>>, []) == y
                                                                    |
                                                                    [\"hoge\", \"fuga\"]
    """
    assert_helper(expect, fn () ->
      x = "nya"
      y = ["hoge", "fuga"]
      Assertion.assert ~w(hoge fuga #{x}) == y
    end)
  end

  @opts [context: Elixir]
  test "quote expr not supported" do
    expect = """
    quote(@opts) do
      :hoge
    end == :fuga
    |
    :hoge
    """
    assert_helper(expect, fn () ->
      Assertion.assert quote(@opts, do: :hoge) == :fuga
    end)

    expect = """
    quote() do
      unquote(x)
    end == :fuga
    |
    :hoge
    """
    assert_helper(expect, fn () ->
      x = :hoge
      Assertion.assert quote(do: unquote(x)) == :fuga
    end)
  end

  test "get_and_update_in/2, put_in/2 and update_in/2 expr are not supported" do
    expect = """
    put_in(users[\"john\"][:age], 28) == %{\"john\" => %{age: 27}}
    |
    %{\"john\" => %{age: 28}}
    """
    assert_helper(expect, fn () ->
      users = %{"john" => %{age: 27}}
      Assertion.assert put_in(users["john"][:age], 28) == %{"john" => %{age: 27}}
    end)

    expect = """
    update_in(users[\"john\"][:age], &(&1 + 1)) == %{\"john\" => %{age: 27}}
    |
    %{\"john\" => %{age: 28}}
    """
    assert_helper(expect, fn () ->
      users = %{"john" => %{age: 27}}
      Assertion.assert update_in(users["john"][:age], &(&1 + 1)) == %{"john" => %{age: 27}}
    end)

    expect = """
    get_and_update_in(users[\"john\"].age(), &{&1, &1 + 1}) == {27, %{\"john\" => %{age: 27}}}
    |
    {27, %{\"john\" => %{age: 28}}}
    """
    assert_helper(expect, fn () ->
      users = %{"john" => %{age: 27}}
      Assertion.assert get_and_update_in(users["john"].age, &{&1, &1 + 1}) == {27, %{"john" => %{age: 27}}}
    end)
  end

  test "for expr not supported" do
    expect = """
    for(x <- enum) do
      x * 2
    end == [2, 4, 6]
    |
    [2, 4, 8]
    """
    assert_helper(expect, fn () ->
      enum = [1,2,4]
      Assertion.assert for(x <- enum, do: x * 2) == [2, 4, 6]
    end)
  end

  @hello "hello"
  test ":<<>> expr includes module attribute not supported" do
    expect = """
    <<@hello, \" \", "\world\">> == \"hello world!\"
    |
    \"hello world\"
    """
    assert_helper(expect, fn () ->
      Assertion.assert <<@hello, " ", "world">> == "hello world!"
    end)
  end

  test "case expr not supported" do
    expect = """
    case(x) do
      {:ok, right} ->
        right
      {_left, right} ->
        case(right) do
          {:ok, right} ->
            right
        end
    end == :doing
    |
    :done
    """
    assert_helper(expect, fn () ->
      x = {:error, {:ok, :done}}
      Assertion.assert (case x do
        {:ok, right} ->
          right
        {_left, right} ->
          case right do
            {:ok, right}  -> right
          end
      end) == :doing
    end)
  end

  test "__VAR__ expr" do
    expect = """
    module != __MODULE__
    |         |
    |         PowerAssertAssertionTest
    PowerAssertAssertionTest
    """
    assert_helper(expect, fn () ->
      module = __ENV__.module
      Assertion.assert module != __MODULE__
    end)
  end

  def assert_helper(expect, func) when is_binary(expect) do
    try do
      func.()
      assert false, "should be failed test #{expect}"
    rescue
      error ->
        assert expect == error.message <> "\n"
    end
  end
  def assert_helper(expect, func) do
    try do
      func.()
      assert false, "should be failed test #{expect}"
    rescue
      error ->
        assert Regex.match?(expect, error.message <> "\n")
    end
  end
end