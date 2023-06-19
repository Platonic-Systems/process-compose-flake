# process-compose-flake
A [flake-parts](https://github.com/hercules-ci/flake-parts) module for [process-compose](https://github.com/F1bonacc1/process-compose).

This `flake-parts` module allows you to declare one or more `process-compose` configurations using Nix attribute sets. It will generate corresponding `packages` that wrap the `process-compose` binary with the given configuration.

This module is practical for local development e.g. if you have a lot of runtime dependencies that depend on each other. Stop executing these programs imperatively over and over again in a specific order, and stop the need to write complicated shell scripts to automate this. `process-compose` gives you a process dashboard for monitoring, inspecting logs for each process, and much more, all of this in a TUI.

## Quick Example

See [`./example/flake.nix`](example/flake.nix) for an example flake. This example shows a demo of [sqlite-web](https://github.com/coleifer/sqlite-web) using the sample [chinhook-database](https://github.com/lerocha/chinook-database).

To run this example locally,

```sh
mkdir example && cd example
nix flake init -t github:Platonic-Systems/process-compose-flake
nix run
```

This should open http://127.0.0.1:8213/ in your web browser. If not, navigate to the logs for the `sqlite-web` process and access the URL. The interface should look like this:

<img width="879" alt="image" src="https://github.com/Platonic-Systems/process-compose-flake/assets/3998/254443fa-f3c2-4675-9ced-2a39ac23591d">


## Usage
Let's say you want to have a `devShell` that makes a command `watch-server` available, that you can use to spin up your projects `backend-server`, `frontend-server`, and `proxy-server`.

To achieve this using `process-compose-flake` you can simply add the following code to the `perSystem` function in your `flake-parts` flake.
```nix
process-compose.watch-server = {
  settings.processes = {
    backend-server.command = "${self'.apps.backend-server.program} --port 9000";
    frontend-server.command = "${self'.apps.frontend-server.program} --port 9001";
    proxy-server.command =
      let
        proxyConfig = pkgs.writeTextFile {
          name = "proxy.conf";
          text = ''
            ...
          '';
        };
      in
      "${self'.apps.proxy-server.program} -c ${proxyConfig} -p 8000";
  };
};
```

`process-compose-flake` will generate the `packages.${system}.watch-server` output for you.

You can then spin up the processes by running `nix run .#watch-server`.

The `package` output in turn can be used to make the `watch-server` command available in your `devShell`:
```nix
devShells = {
  default = pkgs.mkShell {
    name = "my-shell";
    nativeBuildInputs = [
      self'.packages.watch-server
    ];
  };
};
```

You can enter your devShell by running `nix develop` and run `watch-server` to run your processes.

## Module API

Our submodule mirrors the [process-compose YAML schema](https://github.com/F1bonacc1/process-compose/blob/main/process-compose.yaml), except in a few places where it makes sense to deviate a bit so as to be in line with the general Nix philosophy:

- `process-compose.<name>.environment`: In the YAML config, a list of environment strings are specified. While this is supported, you can also specify the env vars as a Nix attrset
- `process-compose.<name>.processes.<name>.command`: The command string (unless it is a Nix package) is necessarily wrapped in a `pkgs.writeShellApplication` (see [\#22](https://github.com/Platonic-Systems/process-compose-flake/issues/22)) which is done to avoid cases where your command tries to access an environment variable (set in the same process-compose config) but is actually unset due to the way process-compose itself invokes the process.

## Alternatives

For a similar (and less feature-rich) module that uses a `Procfile`-based runner, see https://github.com/srid/proc-flake

## Contributing

Please run `./test.sh` on a NixOS machine to run the full suite of tests before pushing changes to the main branch. Our CI (Github Actions) cannot do this yet.

## Related projects

- [`services-flake`](https://github.com/juspay/services-flake): NixOS-like services built on top of process-compose-flake.
