defmodule Elt.Router do
  use Elt.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Elt do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/load_tests", LoadTestController
    get "/load_tests/:id/progress", LoadTestController, :progress
  end

  # Other scopes may use custom stacks.
  # scope "/api", Elt do
  #   pipe_through :api
  # end
end
