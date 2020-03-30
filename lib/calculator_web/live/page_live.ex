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

  defp get_view_data() do
    %{value: readout, current_state: state} = CVM.get_data()
    %{readout: readout, state: state}
  end
end
