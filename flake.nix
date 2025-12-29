{
  description = "A simple way to serve pages and files over the Reticulum network";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        python = pkgs.python3;

        pythonPackages = python.pkgs;
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            python
            poetry
            go-task
            pythonPackages.build
            pythonPackages.pip
            pythonPackages.setuptools
            pythonPackages.wheel
            pythonPackages.ruff
          ];
        };
      });
}

