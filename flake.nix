{
  inputs = {
    nix.url = "github:nixos/nix/2.24.10";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { nixpkgs, nix, ... }@inputs:
    let
      joeSSHKey = ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOqfn5ZPMeSTAdBddCJltKIlfJUYob9BVG0iNOutgpT8'';
      rootSSHKey = ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH4DlsM/LAypieOM6s61cXTNDRWTx2sibrgEf4SFTB2E'';
      allSystems = [
        "x86_64-linux" # 64-bit Intel/AMD Linux
        "aarch64-linux" # 64-bit ARM Linux
        "x86_64-darwin" # 64-bit Intel macOS
        "aarch64-darwin" # 64-bit ARM macOS
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        inherit system;
        pkgs = import nixpkgs {
          inherit system;
        };
      });
      devTools = { system, pkgs }: [
        pkgs.minio-client
      ];
    in
    {
      devShells = forAllSystems ({ system, pkgs }: {
        default = pkgs.mkShell {
          buildInputs = (devTools { system = system; pkgs = pkgs; });
        };
      });
      nixosConfigurations = {
        builder-x86_64 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            joeSSHKey = joeSSHKey;
            rootSSHKey = rootSSHKey;
          };
          modules = [
            ./systems/utm/builder/config.nix
          ];
        };
        builder-aarch64 = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            joeSSHKey = joeSSHKey;
            rootSSHKey = rootSSHKey;
          };
          modules = [
            ./systems/utm/builder/config.nix
          ];
        };
      };
    };
}
