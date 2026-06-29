{
  atomi,
  pkgs,
  pkgs-2605,
  pkgs-unstable,
}:
let
  all = rec {
    atomipkgs = (
      with atomi;
      {
        inherit
          atomiutils
          infralint
          infrautils
          pls
          sg
          ;
      }
    );

    nix-2605 = (
      with pkgs-2605;
      {
        inherit
          actionlint
          biome
          bun
          git
          gitlint
          go-task
          infisical
          pre-commit
          shellcheck
          skopeo
          treefmt
          ;
      }
    );

    nix-unstable = (
      with pkgs-unstable;
      {
      }
    );

    # Knip is not packaged in nixpkgs, so expose a thin wrapper that runs the
    # project-local Knip (a devDependency) through Bun. This keeps the binary on
    # PATH in every shell while the actual version stays pinned by bun.lock.
    custom = {
      knip = pkgs.writeShellScriptBin "knip" ''
        exec ${pkgs-2605.bun}/bin/bunx --bun knip "$@"
      '';
    };
  };
in
with all;
atomipkgs // nix-2605 // nix-unstable // custom
