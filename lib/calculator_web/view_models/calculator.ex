defmodule CalculatorWeb.CalculatorViewModel do
  use GenStateMachine

#  const STATE_NAMES = {
#1: 'Start',
#2: 'Negative Number',
#3.9: 'Operand 1: Zero',
#  '3.10': 'Operand 1: Before Decimal Point',
#        3.11: 'Operand 1: After Decimal Point',
#              4: 'Operator Entered',
#5: 'Negative Number',
#6.12: 'Operand 2: Zero',
# 6.13: 'Operand 2: Before Decimal Point',
#   6.14: 'Operand 2: After Decimal Point',
#       8: 'Result',
#                 }

  @default_state %{
    readout: 0,
    operand_1: nil,
    operand_2: nil,
    operator: nil
  }

  # Client
  def start_link() do
    GenStateMachine.start_link(__MODULE__, {:off, 0})
  end

  def flip(pid) do
    GenStateMachine.cast(pid, :flip)
  end

  def get_count(pid) do
    GenStateMachine.call(pid, :get_count)
  end

  # Server (callbacks)
  def handle_event(:cast, :flip, :off, data) do
    {:next_state, :on, data + 1}
  end

  def handle_event(:cast, :flip, :on, data) do
    {:next_state, :off, data}
  end

  def handle_event({:call, from}, :get_count, state, data) do
    {:next_state, state, data, [{:reply, from, data}]}
  end

  def handle_event(event_type, event_content, state, data) do
    # Call the default implementation from GenStateMachine
    super(event_type, event_content, state, data)
  end
end