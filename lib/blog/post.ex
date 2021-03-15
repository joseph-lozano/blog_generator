defmodule Blog.Post do
  @moduledoc """
  Struct for Posts
  """
  use TypedStruct

  typedstruct do
    field(:title, String.t(), enforce: true)
    field(:slug, String.t())
    field(:description, String.t())
    field(:date, Date.t())
    field(:tags, list(String.t()))
    field(:draft, boolean())
    field(:attrs, map())
    field(:content, String.t())
  end

  @spec parse(String.t(), Date.t(), String.t()) :: t()
  def parse(string, date, slug) do
    ["", yaml, content] = String.split(string, "---", parts: 3)
    attrs = YamlElixir.read_from_string!(yaml)

    %__MODULE__{
      title: title(attrs),
      slug: slug(attrs, slug),
      description: description(attrs, ""),
      date: date(attrs, date),
      tags: tags(attrs, []),
      draft: draft(attrs, false),
      attrs: attrs(attrs),
      content: content
    }
  end

  defp title(%{"title" => title}), do: title
  defp title(_), do: raise("Could not parse title from front-matter")

  defp slug(%{"slug" => slug}, _), do: slug
  defp slug(_, slug), do: slug

  defp description(%{"description" => description}, _), do: description
  defp description(_, description), do: description

  defp date(%{"date" => date}, _), do: date
  defp date(_, date), do: date

  defp tags(%{"tags" => tags}, _), do: tags
  defp tags(_, tags), do: tags

  defp draft(%{"draft" => draft}, _), do: draft
  defp draft(_, draft), do: draft

  defp attrs(attrs) do
    Map.drop(attrs, ~w[title slug date tags]a)
  end
end
