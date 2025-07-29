{
  description = "Various tools for UNIX command-line usage";

  outputs = { self, nixpkgs }:
    let
      architectures = [ "x86_64-linux" "aarch64-linux" ];

      # Function to generate all outputs for a given system
      perSystem = (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          # --- Step 1: Define individual packages as local variables ---
          /*my-tool-one = pkgs.writeShellApplication {
            name = "my-tool-one";
            runtimeInputs = with pkgs; [ jq ];
            text = ''echo "Tool one reporting in!"'';
          };

          my-tool-two = pkgs.writeShellApplication {
            name = "my-tool-two";
            runtimeInputs = with pkgs; [ curl ];
            text = ''echo "Tool two here!"'';
            };

          my-tool-three = pkgs.writeShellApplication {
            name = "my-tool-one";
            runtimeInputs = with pkgs; [ jq coreutils ]; # Specify dependencies
            text = ''
              #!/usr/bin/env bash
              echo "Hello from my first custom tool!"
              # Your script logic goes here
            '';
          };

            */

        patmv = pkgs.writeShellApplication {
          name = "patmv";
          text = builtins.readFile ./util/patmv;
        };

        yn = pkgs.writeShellApplication {
          name = "yn";
          runtimeInputs = with pkgs; [ curl ];
          text = builtins.readFile ./util/yn;
        };

        in
        {
          # --- Step 2: Assemble the final packages set from local variables ---
          packages = {
            # Expose packages by their desired names
            #inherit my-tool-one my-tool-two;
            inherit patmv yn;

            # The default package now refers to the local variables, NOT `self`
            default = pkgs.buildEnv {
              name = "shell-tools";
              paths = [
                patmv
                yn
                #my-tool-two # Use the local variable
              ];
            };
          };
        });
    in
    {
      # This part remains the same, generating the final outputs
      packages = nixpkgs.lib.genAttrs architectures (system: (perSystem
      system).packages);
    };
}
