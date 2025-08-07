{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems =
        function:
        lib.genAttrs systems (
          system:
          function (
            import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            }
          )
        );
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            vagrant
            # ansible
            python39
          ];

          env = { };

          shellHook = ''
            if [ ! -d ./.venv ]; then
              python3 -m venv .venv
              source ./.venv/bin/activate
              pip install "ansible==2.9.0"
            else
              source ./.venv/bin/activate
            fi
          '';
        };
      });
    };
}
