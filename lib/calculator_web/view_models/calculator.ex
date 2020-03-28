defmodule CalculatorWeb.CalculatorViewModel do
  use GenStateMachine

  @name CalculatorViewModel

  defstruct value: 0,
            operand_1: nil,
            operand_2: nil,
            operator: nil,
            current_state: nil

  @possible_states [
    :start,
    :operand_1_negative_number,
    :operand_1_zero,
    :operand_1_before_decimal_point,
    :operand_1_after_decimal_point,
    :operator_entered,
    :operand_2_negative_number,
    :operand_2_zero,
    :operand_2_before_decimal_point,
    :operand_2_after_decimal_point,
    :result
  ]

  # Client
  def start_link() do
    state = get_state(:start)
    data = %__MODULE__{current_state: state}

    GenStateMachine.start_link(__MODULE__, {state, data}, name: @name)
  end

  def get_data() do
    GenStateMachine.call(@name, :get_data)
  end

  def register_input(symbol) do
    GenStateMachine.cast(@name, {:record_input, symbol})
  end

  # Server (state transitions)
  def handle_event(:cast, {:record_input, symbol}, :start, data) do
    data = Map.merge(data, %{value: String.to_integer(symbol), current_state: :changed})
    {:next_state, :changed, data}
  end

  def handle_event({:call, from}, :get_data, state, data) do
    {:next_state, state, data, [{:reply, from, data}]}
  end

  def handle_event(event_type, event_content, state, data) do
    super(event_type, event_content, state, data)
  end

  # Utility
  defp get_state(state), do: Enum.find(@possible_states, fn s -> s === state end)

  defp get_symbol_type(symbol) do
    cond do
      String.match?(symbol, ~r/[1|2|3|4|5|6|7|8|9]/) -> {:number, symbol}
      String.match?(symbol, ~r/[-|+|x|÷|=|﹪]/)      -> {:operator, symbol}
      true -> {:unrecognized_symbol_type, symbol}
    end
  end
end