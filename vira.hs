-- Pipeline configuration for Vira <https://vira.nixos.asia/>

\ctx pipeline ->
  pipeline
    { build.flakes =
        [ "."
        , "./example" { overrideInputs = [("process-compose-flake", ".")] }
        , "./dev" { overrideInputs = [("process-compose-flake", ".")] }
        ]
    }
