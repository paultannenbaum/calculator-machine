defmodule CalculatorWeb.PageLive do
  use CalculatorWeb, :live_view
  alias CalculatorWeb.CalculatorViewModel

  def mount(_params, _session, socket) do
    CalculatorViewModel.start_link()
    {:ok, assign(socket, get_view_data())}
  end

  def handle_event("calc-input", %{"symbol" => symbol}, socket) do
    {:noreply, assign(socket, get_view_data())}
  end

  defp get_view_data() do
    %CalculatorViewModel{value: readout, current_state: state} = CalculatorViewModel.get_data()
    %{readout: readout, state: state}
  end
end
