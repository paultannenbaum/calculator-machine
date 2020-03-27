defmodule Calculator.Repo do
  use Ecto.Repo,
    otp_app: :calculator,
    adapter: Ecto.Adapters.Postgres
end
