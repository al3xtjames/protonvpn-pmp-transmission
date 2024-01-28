{
  description = "A daemon to allocate ProtonVPN port mappings and inform Transmission of said mappings.";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  inputs.poetry2nix.url = "github:nix-community/poetry2nix";
  inputs.poetry2nix.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, flake-utils, poetry2nix }: {
    overlay = nixpkgs.lib.composeManyExtensions [
      poetry2nix.overlays.default
      (final: prev: {
        protonvpn-pmp-transmission = prev.poetry2nix.mkPoetryApplication {
          projectDir = ./.;
        };
      })
    ];
  } // (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlay ];
      };
    in rec {
      packages.protonvpn-pmp-transmission = pkgs.protonvpn-pmp-transmission;
      defaultPackage = pkgs.protonvpn-pmp-transmission;

      devShells.default = with pkgs; mkShell {
        buildInputs = [ poetry ];
      };
    }
  ));
}
