{
  description = "My shell tools";

  # Define the flake's outputs
  outputs =
    { self, nixpkgs }:
    let
      # Define the system we are building for
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      # Define packages provided by this flake
      packages.${system} = {
        # Package a script named 'tool-one'
        /*
          my-tool-one = pkgs.writeShellApplication {
            name = "my-tool-one";
            runtimeInputs = with pkgs; [ jq coreutils ]; # Specify dependencies
            text = ''
              #!/usr/bin/env bash
              echo "Hello from my first custom tool!"
              # Your script logic goes here
            '';
          };
        */

        # Package another script from a file named 'scripts/tool-two.sh'
        yn = pkgs.writeShellApplication {
          name = "yn";
          runtimeInputs = with pkgs; [ curl ];
          text = builtins.readFile ./util/yn;
        };
      };

      # A default package that installs all tools in this flake
      packages.${system}.default = pkgs.buildEnv {
        name = "shell-tools";
        paths = [
          self.packages.${system}.yn
        ];
      };
    };
}
