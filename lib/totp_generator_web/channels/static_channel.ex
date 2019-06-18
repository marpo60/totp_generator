defmodule TotpGeneratorWeb.StaticChannel do
  use Phoenix.Channel

  import Phoenix.HTML, only: [sigil_E: 2]

  def join("s" <> id, message, socket) do
    send(self(), :after_join)

    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    dom_id = random_id()
    session_token = sign_token(TotpGeneratorWeb.Endpoint, TotpGeneratorWeb.Endpoint.config(:live_view)[:signing_salt], %{
      id: dom_id,
      view: TotpGeneratorWeb.TotpGeneratorLive,
      parent_pid: nil,
      session: %{},
    })

    attrs = [
      {:id, dom_id},
      {:data,
        phx_view: TotpGeneratorWeb.TotpGeneratorLive,
        phx_session: session_token,
      }
    ]

    {:safe, html} = ~E"""
    <%= Phoenix.HTML.Tag.content_tag(:div, attrs) do %>
    <% end %>
    <div class="phx-loader"></div>
    """

    content = Enum.join(html)

    push(socket, "static", %{html: content})

    {:noreply, socket} # :noreply
  end

  defp sign_token(endpoint_mod, salt, data) do
    Phoenix.Token.sign(endpoint_mod, salt, data)
  end

  defp random_encoded_bytes do
    6
    |> :crypto.strong_rand_bytes()
    |> Base.encode64()
  end

  defp random_id, do: "phx-" <> random_encoded_bytes()
end
