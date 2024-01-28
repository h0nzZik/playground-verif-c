{
  description = "A playground for learning Princeton VST";

  inputs = {
    nixpkgs.url = "github:NixOs/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
   };

  outputs = { self, nixpkgs, flake-utils }: (
    flake-utils.lib.eachDefaultSystem (system:
      let

        pkgs = nixpkgs.legacyPackages.${system};

        pgFun = { coqPackages }: (
          coqPackages.callPackage 
          ( { coq, stdenv }:
          stdenv.mkDerivation {
            name = "playground";
            src = ./playground;

            propagatedBuildInputs = [
              coq
              coqPackages.VST
              coqPackages.compcert
            ];
            enableParallelBuilding = true;
            installFlags = [ "COQLIB=$(out)/lib/coq/${coq.coq-version}/" ];

            passthru = { inherit coqPackages; };
          } ) { } 
        );

      in {

        packages.playground-coq_8_19 = pgFun { coqPackages = pkgs.coqPackages_8_19; } ;
        packages.playground-coq_8_18 = pgFun { coqPackages = pkgs.coqPackages_8_18; } ;
        packages.playground-coq_8_17 = pgFun { coqPackages = pkgs.coqPackages_8_17; } ;

        packages.playground = self.outputs.packages.${system}.playground-coq_8_17;

        devShells = {
          playground =
            let
              playground = self.outputs.packages.${system}.playground;
            in
              pkgs.mkShell {
                inputsFrom = [playground];
                packages = [playground.coqPackages.coq-lsp];
              };
        };
      }
    )
  );
}
