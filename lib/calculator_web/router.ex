defmodule CalculatorWeb.Router do
  use CalculatorWeb, :router
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {CalculatorWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CalculatorWeb do
    pipe_through :browser

    live "/", PageLive, :index
    live_dashboard "/dashboard", metrics: CalculatorWeb.Telemetry
  end

  # Other scopes may use custom stacks.
  # scope "/api", CalculatorWeb do
  #   pipe_through :api
  # end
end
