[![project chat](https://img.shields.io/badge/zulip-join_chat-brightgreen.svg)](https://nixos.zulipchat.com/#narrow/stream/414022-process-compose-flake)

# process-compose-flake
A [flake-parts](https://github.com/hercules-ci/flake-parts) module for [process-compose](https://github.com/F1bonacc1/process-compose).

## Documentation

https://community.flake.parts/process-compose-flake

## Contributing

Please run [`nix --accept-flake-config run github:juspay/omnix ci`](https://omnix.page/om/ci.html) on a NixOS machine to run the full suite of tests before pushing changes to the main branch. Our CI (Github Actions) cannot do this yet.

## Discussion

- [Zulip](https://nixos.zulipchat.com/#narrow/stream/414022-process-compose-flake)

## Related projects

- [`services-flake`](https://github.com/juspay/services-flake): NixOS-like services built on top of process-compose-flake.
- [`proc-flake`](https://github.com/srid/proc-flake): A similar module that uses a `Procfile`-based runner. It is less feature-rich, but [at times more reliable](https://github.com/Platonic-Systems/process-compose-flake/issues/30) than process-compose.
