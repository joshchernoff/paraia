defmodule ParaiaWeb.ErrorJSONTest do
  use ParaiaWeb.ConnCase, async: true

  test "renders 404" do
    assert ParaiaWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert ParaiaWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
