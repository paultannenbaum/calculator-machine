defmodule CalculatorWeb.PageLive do
  use CalculatorWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, readout: 0, machine_state: 'idle')}
  end

  def handle_event("number_click", %{"number" => number}, socket) do
    {:noreply, assign(socket, readout: number)}
  end

  def handle_event("decimal_click", socket) do
    {:noreply, socket}
  end

  def handle_event("cancel_click", socket) do
    {:noreply, socket}
  end

  def handle_event("operator_click", %{"operator" => operator}, socket) do
    {:noreply, socket}
  end
end
