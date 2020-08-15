defmodule HybridBlogWeb.LayoutView do
  use HybridBlogWeb, :view
  @title Application.compile_env(:hybrid_blog, :title)
  @spec title(String.t() | nil) :: String.t()
  def title(sub \\ nil)
  def title(nil), do: gettext(@title)
  def title(sub), do: "#{sub} | #{gettext(@title)}"
end
