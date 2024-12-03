defmodule ParaiaWeb.HomeLive do
  use ParaiaWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-5xl mb-20">
      <.search_field id="descriptions" value={@query} />
      <h3 :if={@count > 0} class="mt-6">Users Found: <%= @count %></h3>
    </div>

    <div
      id="users"
      phx-update="stream"
      phx-viewport-bottom={!@end_of_timeline? && "next-page"}
      phx-page-loading
      class="flex flex-col gap-y-6 max-w-5xl mx-auto"
    >
      <div :for={{id, user} <- @streams.users} id={id} class="relative  w-full h-full">
        <a target="blank" href={"https://bsky.app/profile/#{user.did}"}>
          <div class="w-full h-full opacity-40 absolute z-0 top-0 left-0 bg-zinc-100">
            <img class="cover w-full h-full" src={user.banner} />
          </div>

          <h2 class="relative font-black px-6 pt-6 z-20"><%= user.display_name || user.handle %></h2>
          <div class="relative flex p-6 font-bold text-lg">
            <img class="relative w-[100px] h-[100px] cover" src={user.avatar} />
            <p class="relative pl-6 font-semibold text-lg bg-zinc-100/30">
              <%= user.description %>
            </p>
          </div>
          <div class="inline relative bg-white/70 p-2">
            <span>Posts: <%= user.posts_count %></span>
            <span>Followers: <%= user.followers_count %></span>
            <span>Following: <%= user.follows_count %></span>
          </div>
        </a>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream_configure(:users, dom_id: &"user-#{&1.did}")
     |> stream(:users, [])
     |> assign(page: 0)
     |> assign(:count, nil)
     |> assign(:end_of_timeline?, false)}
  end

  def handle_params(%{"query" => query}, _uri, socket) do
    {users, count} = Paraia.BlueSky.search_users(query)

    socket =
      socket
      |> stream(:users, users, reset: true)
      |> assign(:count, count)
      |> assign(:query, query)
      |> assign(page: 0)
      |> assign(:end_of_timeline?, false)

    {:noreply, socket}
  end

  def handle_params(_, _uri, socket) do
    {:noreply,
     socket
     |> stream(:users, [], reset: true)
     |> assign(:query, nil)
     |> assign(page: 0)
     |> assign(:end_of_timeline?, false)}
  end

  def handle_event("search", %{"query" => query}, socket) do
    {:noreply, push_patch(socket, to: ~p"/?query=#{query}")}
  end

  # def handle_event("prev-page", unsigned_params, socket) do

  # end

  def handle_event("next-page", _unsigned_params, socket) do
    page = socket.assigns.page + 1
    {users, count} = Paraia.BlueSky.search_users(socket.assigns.query, page)

    {:noreply, socket |> assign(:page, page) |> stream(:users, users) |> assign(:count, count)}
  end
end
