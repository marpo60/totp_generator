defmodule TotpGeneratorWeb.TotpGeneratorLive do
  use Phoenix.LiveView

  def mount(%{}, socket) do
    :timer.send_interval(500, self(), :update)
    {:ok, assign(socket, :services, services_with_code())}
  end

  def render(assigns) do
    TotpGeneratorWeb.PageView.render("live.html", assigns)
  end

  def handle_info(:update, socket) do
    {:noreply, assign(socket, :services, services_with_code())}
  end

  defp services_with_code() do
    refresh = 30 - Integer.mod(Map.get(DateTime.utc_now, :second), 30)
    Enum.map(services(), fn([name, secret]) ->
      [name, calculate_totp(secret), refresh]
    end)
  end

  defp services() do
    dir = Application.app_dir(:totp_generator, "priv")
    case File.read(dir <> "/services.json") do
      {:ok, body} -> body
      {:error, _err } -> File.read!(dir <> "/services_example.json")
    end
    |> Jason.decode!()
  end

  defp calculate_totp(secret) do
    secret
    |> String.replace(" ", "")
    |> :pot.totp()
  end
end
