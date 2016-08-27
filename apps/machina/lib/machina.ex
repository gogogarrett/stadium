defmodule Machina do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # worker(Machina.Stadium, []),
    children = [
      supervisor(Machina.StadiumGameSup, []),
    ]

    opts = [strategy: :one_for_one, name: Machina.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
