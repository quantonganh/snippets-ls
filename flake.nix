{
  description = "Snippet LSP for helix";

  # nixpkgs version to use
  inputs.nixpkgs.url = "nixpkgs/nixos-21.11";

  outputs = { self, nixpkgs }:
    let
      # work with older version of flakes
      lastModifiedDate =
        self.lastModifiedDate or self.lastModified or "19700101";

      # user-friendly version number
      version = builtins.substring 0 8 lastModifiedDate;

      # system types to support
      supportedSystems =
        [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # nixpkgs instantiated for supported system types
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

    in {
      # provide some binary packages for selected system types
      packages = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in {
          snippets-ls = pkgs.buildGoModule {
            pname = "snippets-ls";
            inherit version;
            src = ./.;

            # This hash locks the dependencies of this package. It is
            # necessary because of how Go requires network access to resolve
            # VCS.  See https://www.tweag.io/blog/2021-03-04-gomod2nix/ for
            # details. Normally one can build with a fake sha256 and rely on native Go
            # mechanisms to tell you what the hash should be or determine what
            # it should be "out-of-band" with other tooling (eg. gomod2nix).
            # To begin with it is recommended to set this, but one must
            # remeber to bump this hash when your dependencies change.
            # buildGoModule expects vendorSha256 and doesn't support vendorHash yet
            vendorSha256 =
              "sha256-SbTtKuJxZw+2du+/nwA79ZufgEDS/1qqG2sqqn1x9tM=";

          };
        });

      # add dependencies that are only needed for development
      devShells = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [ go gopls gotools go-tools ];
          };
        });

      defaultPackage =
        forAllSystems (system: self.packages.${system}.snippets-ls);
    };
}
