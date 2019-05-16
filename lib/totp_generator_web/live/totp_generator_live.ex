defmodule TotpGeneratorWeb.TotpGeneratorLive do
  use Phoenix.LiveView

  def mount(%{}, socket) do
    :timer.send_interval(500, self(), :update)
    {:ok, assign(socket, :code, 0)}
  end

  def render(assigns) do
    TotpGeneratorWeb.PageView.render("live.html", assigns)
  end

  def handle_info(:update, socket) do
    code = socket.assigns.code + 5
    {:noreply, assign(socket, :code, code)}
  end
end
