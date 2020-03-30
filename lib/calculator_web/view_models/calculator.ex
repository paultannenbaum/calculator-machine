defmodule CalculatorWeb.CalculatorViewModel do
  use GenStateMachine

  @name CalculatorViewModel

  @default_data value: '0',
                operand_1: nil,
                operator: nil,
                current_state: nil,
                error: nil

  defstruct @default_data

  @possible_states [
    :start,
    :operand_1,
    :operator_registered,
    :operand_2,
    :result
  ]

  # Client
  def start_link() do
    {state, data} = initial_state()
    GenStateMachine.start_link(__MODULE__, {state, data}, name: @name)
  end

  def get_data() do
    GenStateMachine.call(@name, :get_data)
  end

  def register_input(input) do
    GenStateMachine.cast(@name, {:handle_input, input})
  end

  # Server
  def handle_event({:call, from}, :get_data, state, data) do
    {:next_state, state, data, [{:reply, from, data}]}
  end

  def handle_event(:cast, {:handle_input, input}, state, data) do
    {input_type, input_value} = get_input_type(input)
    {next_state, data} = handle_input(state, input_type, input_value, data)

    if (@possible_states |> Enum.member?(next_state)) do
      data = %{data | current_state: next_state}
      {:next_state, next_state, data}
    else
      {:error, 'Invalid State'}
    end
  end

  def handle_event(event_type, event_content, state, data) do
    super(event_type, event_content, state, data)
  end

  ## TODO: Add specs and docs
  # handle_input(current_state, input_type, input_value, data)

  ## start
  def handle_input(:start, :number, num, data) do
    {state, data} = cond do
      num |> is_decimal? ->
        state = :operand_1
        data = %{data | value: "0."}
        {state, data}
      true ->
        state = :operand_1
        data = %{data | value: num}
        {state, data}
    end

    {state, data}
  end

  def handle_input(:start, :operator, operator, data) do
    {state, data} = cond do
      operator |> is_minus_operator? ->
        state = :operand_1
        data = %{data | value: operator}
        {state, data}
      true -> {:start, data}
    end

    {state, data}
  end

  ## operand_1
  def handle_input(:operand_1, :number, num, data) do
    {state, data} = cond do
      num |> is_decimal? &&
      data.value === "-"  ->
        state = :operand_1
        data = %{data | value: "-0."}
        {state, data}
      true ->
        state = :operand_1
        data = %{data | value: data.value <> num}
        {state, data}
    end

    {state, data}
  end

  def handle_input(:operand_1, :operator, operator, data) do
    {state, data} = cond do
      operator |> is_percent_operator? ->
        {state, data} = calculate_result("#{data.value}/100", data)
      true ->
        state = :operator_registered
        data = Map.merge(data, %{operand_1: data.value, operator: operator})
        {state, data}
    end

    {state, data}
  end

  ## operator
  def handle_input(:operator_registered, :number, num, data) do
    {state, data} = cond do
      num |> is_decimal? ->
        state = :operand_2
        data = %{data | value: "0."}
        {state, data}
      true ->
        state = :operand_2
        data = %{data | value: num}
        {state, data}
    end

    {state, data}
  end

  def handle_input(:operator_registered, :operator, operator, data) do
    {state, data} = cond do
      operator |> is_minus_operator? ->
        state = :operand_2
        data = %{data | value: operator}
        {state, data}
      true ->
        state = :operator_registered
        data = %{data | operator: operator}
        {state, data}
    end

    {state, data}
  end

  ## operand_2
  def handle_input(:operand_2, :number, num, data) do
    state = :operand_2
    data = %{data | value: data.value <> num}

    {state, data}
  end

  def handle_input(:operand_2, :operator, operator, data) do
    {state, data} = cond do
      operator |> is_equals_operator? ->
        {state, data} = calculate_result("#{data.operand_1}#{data.operator}#{data.value}", data)
      true ->
        {:operand_2, data}
    end

    {state, data}
  end

  ## result
  def handle_input(:result, :operator, operator, data) do
    {state, data} = cond do
      operator |> is_equals_operator? ->
        {:result, data}
      operator |> is_percent_operator? ->
        {state, data} = calculate_result("#{data.value}/100", data)
      true ->
        data = Map.merge(data, %{
          operator: operator,
          operand_1: data.value,
          value: data.value
        })
        {:operator_registered, data}
    end

    {state, data}
  end

  ## cancel
  def handle_input(_current_state, :cancel, _input_value, _data), do: initial_state()

  ## catch all (just returns the existing state and data)
  def handle_input(state, _input_type, _input_value, data) do
    {state, data}
  end

  # Utility
  defp initial_state() do
    state = :start
    data = %__MODULE__{current_state: state}
    {state, data}
  end

  defp get_input_type(input) do
    cond do
      String.match?(input, ~r/[0|1|2|3|4|5|6|7|8|9|.]/) -> {:number, input}
      String.match?(input, ~r/[-|+|*|÷|=|\/]/) -> {:operator, input}
      String.match?(input, ~r/[C]/) -> {:cancel, input}
      true -> {:unrecognized_symbol_type, input}
    end
  end

  defp is_decimal?(input), do: String.match?(input, ~r/[.]/)

  defp is_minus_operator?(input), do: String.match?(input, ~r/[-]/)

  defp is_percent_operator?(input), do: String.match?(input, ~r/[%]/)

  defp is_equals_operator?(input), do: String.match?(input, ~r/[=]/)

  defp calculate_result(string, data) do
    try do
      {result,_} = Code.eval_string(string)
      result_string =  result |> to_string
      {int_result, _precision} =  result_string |> Integer.parse

      # Checks for floats that are actually integers
      calculated_result = cond do
        is_float(result)
        && int_result >= result
        && int_result <= result ->
          int_result |> to_string
        true ->
          result_string
      end

      {:result, Map.merge(data, %{
        value: calculated_result,
        error: nil
      })}
    rescue
      ArithmeticError ->
        {state, data}  = initial_state()
        {state, %{data | error: "Bad expression: #{string}"}}
    end
  end
end