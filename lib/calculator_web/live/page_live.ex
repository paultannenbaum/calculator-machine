defmodule CalculatorWeb.PageLive do
  use CalculatorWeb, :live_view
  alias CalculatorWeb.CalculatorViewModel, as: CVM

  def mount(_params, _session, socket) do
    {:ok, cm_pid} = CVM.start_link()

    data = Map.merge(get_view_data(cm_pid), %{
      page_title: "Calculator State Machine",
      cm_pid: cm_pid
    })

    {:ok, assign(socket, data)}
  end

  def handle_event("calc-input", %{"symbol" => symbol}, socket) do
    cm_pid = socket.assigns.cm_pid
    CVM.register_input(cm_pid, symbol)

    {:noreply, assign(socket, get_view_data(cm_pid))}
  end

  def handle_event("keypress", %{"key" => key}, socket) do
    cm_pid = socket.assigns.cm_pid

    cond do
      key === "Backspace" || key === "c" ->
        CVM.register_input(cm_pid, "C")
      key === "Enter" ->
        CVM.register_input(cm_pid, "=")
      String.match?(key, ~r/[-|0|1|2|3|4|5|6|7|8|9|.|+|*|÷|=|\/|C]/) ->
        CVM.register_input(cm_pid, key)
      true -> nil
    end

    {:noreply, assign(socket, get_view_data(cm_pid))}
  end

  defp get_view_data(cm_pid) do
    %{value: readout, current_state: state, error: error} = CVM.get_data(cm_pid)
    %{readout: readout, state: state, error: error}
  end
end
