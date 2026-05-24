{
  description = "voziv dotfiles managed by Nix flakes + home-manager (+ nix-darwin on macOS)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, ... }:
    let
      username = "voziv";

      mkPkgs = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      mkHome = { system, user ? username, modules }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs system;
          modules = [ ./home ] ++ modules;
          extraSpecialArgs = { username = user; inherit self; };
        };
    in {
      # Keyed by short hostname (`hostname -s`) so `home-manager switch --flake
      # .#$(hostname -s)` — and the `hms` alias — auto-select the right machine.
      homeConfigurations = {
        "voziv-pc"   = mkHome { system = "x86_64-linux";   modules = [ ./home/linux.nix ]; };
        "voziv-mac"  = mkHome { system = "aarch64-darwin"; modules = [ ./home/darwin.nix ]; };
        "lrobert-rh" = mkHome { system = "aarch64-darwin"; user = "lee.robert"; modules = [ ./home/darwin.nix ]; };
      };

      darwinConfigurations = {
        "voziv-mac" = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit username self; };
          modules = [
            ./darwin
            home-manager.darwinModules.home-manager
            {
              nixpkgs.config.allowUnfree = true;
              home-manager = {
                useGlobalPkgs   = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit username self; };
                users.${username} = {
                  imports = [ ./home ./home/darwin.nix ];
                };
              };
            }
          ];
        };
      };
    };
}
