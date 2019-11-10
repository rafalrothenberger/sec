defmodule SecWeb.SisView do
  use SecWeb, :view

  def render("wypiwyg.json", data) do
    data.data
  end

end
