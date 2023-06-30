defmodule NifSandbox do
  @moduledoc """
  Documentation for NifSandbox.
  """

  @modules [CNif, OdinNif, ZigNif]
  @functions [
    hello: {:hello, []},
    hello_binary: {:hello_binary, [42]},
    badarg_hello_binary: {:hello_binary, [4.0]}
  ]

  def all() do
    for module <- @modules do
      for {label, {function, arguments}} <- @functions do
        result =
          try do
            apply(module, function, arguments)
          rescue
            error ->
              error
          end

        [{label, result}]
      end
      |> List.flatten()
      |> then(fn values -> {module, values} end)
    end
    |> List.flatten()
    |> Enum.into(%{})
  end
end
