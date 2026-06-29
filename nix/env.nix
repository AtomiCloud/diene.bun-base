{ pkgs, packages }:
with packages;
{
  dev = [
    git
    infisical
    pls
    skopeo
  ];

  lint = [
    actionlint
    biome
    gitlint
    go-task
    infralint
    knip
    pre-commit
    sg
    shellcheck
    treefmt
  ];

  main = [
    bun
  ];

  releaser = [
    sg
  ];

  system = [
    atomiutils
    infrautils
  ];
}
