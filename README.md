# process-compose-flake
A [flake-parts](https://github.com/hercules-ci/flake-parts) module for [process-compose](https://github.com/F1bonacc1/process-compose).

This `flake-parts` module allows you to declare one or more `process-compose` configurations using Nix attribute sets. It will generate corresponding `apps` and `packages` that wrap `process-compose` with the given configuration.

This module is practical for local development e.g. if you have a lot of runtime dependencies that depend on each other. Stop executing these programs imperatively over and over again in a specific order, and stop the need to write complicated shell scripts to automate this. `process-compose` gives you a process dashboard for monitoring, inspecting logs for each process, and much more, all of this in a TUI.

## Usage
Let's say you want to have a `devShell` that makes a command `watch-server` available, that you can use to spin up your projects `backend-server`, `frontend-server`, and `proxy-server`.

To achieve this using `process-compose-flake` you can simply add the following code to the `perSystem` function in your `flake-parts` flake.
```
process-compose.configs = {
  watch-server.processes = {
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

`process-compose-flake` will generate the following two outputs for you:
  - `apps.${system}.watch-server`
  - `packages.${system}.watch-server`

Using the `apps` output you can spin up the processes by running `nix run .#watch-server`.

The `package` output in turn can be used to make the `watch-server` command available in your `devShell`:
```
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
