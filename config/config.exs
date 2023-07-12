import Config

config :git_hooks,
  auto_install: true,
  verbose: true,
  branches: [blacklist: ["master"]],
  extra_success_returns: [
    {:noop, []},
    {:ok, []},
    :noop
  ],
  hooks: [
    pre_commit: [
      tasks: [
        {:mix_task, :compile, ["--no-compile"]},
        {:mix_task, :format},
        {:mix_task, :format, ["--check-formatted"]},
        {:mix_task, :credo, ["suggest"]},
        {:mix_task, :dialyzer}
      ]
    ]
  ]
