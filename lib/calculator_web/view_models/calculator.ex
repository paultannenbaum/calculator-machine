defmodule CalculatorWeb.CalculatorViewModel do
  use GenStateMachine

  @name CalculatorViewModel

  @default_data value: '0',
                operand_1: nil,
                operator: nil,
                current_state: nil

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
    {next_state, data} = handle_transition(state, input_type, input_value, data)

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

  # Transitions
  ## TODO: Add specs and docs
  # handle_transition(current_state, input_type, input_value, data)

  ## start
  def handle_transition(:start, :number, num, data) do
    state = :operand_1
    data  = %{data | value: num}

    {state, data}
  end

  def handle_transition(:start, :operator, operator, data) do
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
  def handle_transition(:operand_1, :number, num, data) do
    state = :operand_1
    data = %{data | value: data.value <> num}

    {state, data}
  end

  def handle_transition(:operand_1, :operator, operator, data) do
    {state, data} = cond do
      operator |> is_percent_operator? ->
        state = :result
        data = %{data | value: calculate_result("#{data.value}/100")}
        {state, data}
      true ->
        state = :operator_registered
        data = Map.merge(data, %{operand_1: data.value, operator: operator})
        {state, data}
    end

    {state, data}
  end

  ## operator
  def handle_transition(:operator_registered, :number, num, data) do
    state = :operand_2
    data = %{data | value: num}

    {state, data}
  end

  def handle_transition(:operator_registered, :operator, operator, data) do
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
  def handle_transition(:operand_2, :number, num, data) do
    state = :operand_2
    data = %{data | value: data.value <> num}

    {state, data}
  end

  def handle_transition(:operand_2, :operator, operator, data) do
    {state, data} = cond do
      operator |> is_equals_operator? ->
        state = :result
        data = %{data | value: calculate_result("#{data.operand_1}#{data.operator}#{data.value}")}
        {state, data}
      true ->
        {:operand_2, data}
    end

    {state, data}
  end

  ## result
  def handle_transition(:result, :operator, operator, data) do
    {state, data} = cond do
      operator |> is_equals_operator? ->
        {:result, data}
      operator |> is_percent_operator? ->
        data = %{data | value: calculate_result("#{data.value}/100")}
        {:result, data}
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
  def handle_transition(_current_state, :cancel, _input_value, _data), do: initial_state()

  ## cancel entry
  def handle_transition(_current_state, :cancel_entry, _input_value, _data), do: initial_state()

  ## catch all (just returns the existing state and data)
  def handle_transition(state, _input_type, _input_value, data) do
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
      String.match?(input, ~r/[CE]/) -> {:cancel_entry, input}
      true -> {:unrecognized_symbol_type, input}
    end
  end

  defp is_minus_operator?(operator), do: String.match?(operator, ~r/[-]/)

  defp is_percent_operator?(operator), do: String.match?(operator, ~r/[%]/)

  defp is_equals_operator?(operator), do: String.match?(operator, ~r/[=]/)

  defp calculate_result(string) do
    {result,_} = Code.eval_string(string)
    result |> to_string
  end
end