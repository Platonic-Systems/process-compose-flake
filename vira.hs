-- Pipeline configuration for Vira <https://vira.nixos.asia/>

\ctx pipeline ->
  pipeline
    { build.systems =
        [ "x86_64-linux"
        -- , "aarch64-darwin"
        ]
    , build.flakes =
        [ "."
        , "./example" { overrideInputs = [("process-compose-flake", ".")] }
        , "./dev" { overrideInputs = [("process-compose-flake", ".")] }
        ]
    }
