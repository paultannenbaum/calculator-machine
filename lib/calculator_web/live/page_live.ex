defmodule CalculatorWeb.PageLive do
  use CalculatorWeb, :live_view
  alias CalculatorWeb.CalculatorViewModel, as: CVM

  def mount(_params, _session, socket) do
    CVM.start_link()
    data = Map.merge(get_view_data(), %{page_title: "Calculator State Machine"})
    {:ok, assign(socket, data)}
  end

  def handle_event("calc-input", %{"symbol" => symbol}, socket) do
    CVM.register_input(symbol)
    {:noreply, assign(socket, get_view_data())}
  end

  def handle_event("keypress", %{"key" => key}, socket) do
    cond do
      key === "Backspace" || key === "c" ->
        CVM.register_input("C")
      key === "Enter" ->
        CVM.register_input("=")
      String.match?(key, ~r/[-|0|1|2|3|4|5|6|7|8|9|.|+|*|÷|=|\/|C]/) ->
        CVM.register_input(key)
      true -> nil
    end

    {:noreply, assign(socket, get_view_data())}
  end

  defp get_view_data() do
    %{value: readout, current_state: state, error: error} = CVM.get_data()
    %{readout: readout, state: state, error: error}
  end
end
