defmodule HybridBlogWeb.LayoutViewTest do
  use HybridBlogWeb.ConnCase, async: true

  # When testing helpers, you may want to import Phoenix.HTML and
  # use functions such as safe_to_string() to convert the helper
  # result into an HTML string.
  # import Phoenix.HTML
  alias HybridBlogWeb.LayoutView

  test "title/1 without subtitle" do
    assert LayoutView.title(nil) == Application.get_env(:hybrid_blog, :title)
  end

  test "title/1 with subtitle" do
    assert LayoutView.title("Sub title 123") ==
             "Sub title 123 | #{Application.get_env(:hybrid_blog, :title)}"
  end
end
