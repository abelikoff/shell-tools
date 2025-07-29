{
  description = "Various tools for UNIX command-line usage";

  outputs = { self, nixpkgs }:
    let
      architectures = [ "x86_64-linux" "aarch64-linux" ];

      # function to generate all outputs for a given system
      perSystem = (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          /*my-tool-three = pkgs.writeShellApplication {
            name = "my-tool-one";
            runtimeInputs = with pkgs; [ jq coreutils ]; # Specify dependencies
            text = ''
              #!/usr/bin/env bash
              echo "Hello from my first custom tool!"
            '';
          };

            */

        patmv = pkgs.writeShellApplication {
          name = "patmv";
          text = builtins.readFile ./util/patmv;
        };

        wpgallery = pkgs.writeShellApplication {
          name = "wpgallery.sh";
          text = builtins.readFile ./desktop/wpgallery.sh;
        };

        yn = pkgs.writeShellApplication {
          name = "yn";
          runtimeInputs = with pkgs; [ curl ];
          text = builtins.readFile ./util/yn;
        };

        in
        {
          packages = {
            inherit patmv wpgallery yn;

            # The default package
            default = pkgs.buildEnv {
              name = "shell-tools";
              paths = [
                patmv
                wpgallery
                yn
              ];
            };
          };
        });
    in
    {
      # generate the final outputs for all architectures
      packages = nixpkgs.lib.genAttrs architectures (system: (perSystem
      system).packages);
    };
}
