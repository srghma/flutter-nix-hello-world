{
  description = "An example project using flutter";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          config.android_sdk.accept_license = true;
        };
      in {
        devShells.default =
          let android = pkgs.callPackage ./nix/android.nix { };
          jdk_myversion = pkgs.jdk21;
          in pkgs.mkShell {
            buildInputs = with pkgs; [
              # from pkgs
              flutter
              jdk_myversion
              #from ./nix/*
              android.platform-tools
            ];

            ANDROID_HOME = "${android.androidsdk}/libexec/android-sdk";
            # https://endoflife.date/oracle-jdk
            JAVA_HOME = jdk_myversion;
            ANDROID_AVD_HOME = (toString ./.) + "/.android/avd";
          };
      });
}
