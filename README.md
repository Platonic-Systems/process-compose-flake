# process-compose-flake
Based on [process-compose](https://github.com/F1bonacc1/process-compose)

## Usage
Let's say you want to have a devShell which makes a command `watch-server` available, that you can use to spin up your projects `backend-server`, `frontend-server` and `proxy-server`.

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

The `package` output in turn can be used to make the `watch-server` command available in your devShell:
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
