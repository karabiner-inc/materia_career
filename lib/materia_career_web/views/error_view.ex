defmodule MateriaCareerWeb.ErrorView do
  use MateriaCareerWeb, :view

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.html", _assigns) do
  #   "Internal Server Error"
  # end

  def render("500.json", assigns) do
    #IO.puts("#{__MODULE__} render. reason:#{inspect(assigns.conn.assigns.reason.term)}")
    #conn = assigns.conn
    #{:error, reason} = conn.assigns.reason.term
    #error = %{
    #   error: "Internal Server Error",
    #   reason: inspect(reason) ,
    #}
    #Poison.encode!(error)
    "Internal Server Error"
 end

 def render("404.json", assigns) do
  #IO.puts("#{__MODULE__} render. reason:#{inspect(assigns.conn.assigns.reason.term)}")
  #conn = assigns.conn
  #{:error, reason} = conn.assigns.reason.term
  #error = %{
  #   error: "Internal Server Error",
  #   reason: inspect(reason) ,
  #}
  #Poison.encode!(error)
  "Not Found message :#{inspect(assigns)}"
end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    IO.puts(" ----  template: #{inspect(template)}")
    Phoenix.Controller.status_message_from_template(template)
  end
end
