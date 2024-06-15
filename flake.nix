{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";

    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs =
    {
      self,
      nixpkgs,
      devenv,
      systems,
      ...
    }@inputs:
    let
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      packages = forEachSystem (system: {
        devenv-up = self.devShells.${system}.default.config.procfileScript;
      });

      devShells = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default =
            let
              inherit (inputs) android-nixpkgs;
              sdk = (import android-nixpkgs { }).sdk (
                sdkPkgs: with sdkPkgs; [
                  build-tools-30-0-3
                  build-tools-34-0-0
                  cmdline-tools-latest
                  platform-tools
                  platforms-android-34
                  platforms-android-33
                ]
              );
            in
            devenv.lib.mkShell {
              inherit inputs pkgs;
              modules = [
                (
                  { pkgs, config, ... }:
                  {
                    env.ANDROID_SDK_ROOT = "${sdk}/share/android-sdk";
                    env.ANDROID_HOME = config.env.ANDROID_SDK_ROOT;
                    env.GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${sdk}/share/android-sdk/build-tools/34.0.0/aapt2";

                    # https://devenv.sh/packages/
                    packages = [ ];

                    enterShell = ''
                      export PATH="${sdk}/bin:$PATH"
                    '';

                    # https://devenv.sh/languages/
                    languages.java = {
                      enable = true;
                      gradle.enable = false;
                      jdk.package = pkgs.jdk17;
                    };

                    # See full reference at https://devenv.sh/reference/options/
                  }
                )
              ];
            };
        }
      );
    };
}
