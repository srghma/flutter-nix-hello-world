# # builtins.getFlake "git+file://${builtins.toString ./.}"
# nix --extra-experimental-features repl-flake repl nixpkgs
# :lf .#
# pkgs = inputs.nixpkgs.outputs.legacyPackages.x86_64-linux
#
# nix flake update --commit-lock-file --verbose && nix develop
# eval $(flutter bash-completion)

# [srghma@machine:~/projects/flutter-nix-hello-world]$ flutter -h
# Manage your Flutter app development.

# Common commands:

#   flutter create <output directory>
#     Create a new Flutter project in the specified directory.

#   flutter run [options]
#     Run your Flutter application on an attached device or in an emulator.

# Usage: flutter <command> [arguments]

# Global options:
# -h, --help                  Print this usage information.
# -v, --verbose               Noisy logging, including all shell commands executed.
#                             If used with "--help", shows hidden options. If used with "flutter doctor", shows additional diagnostic information. (Use "-vv" to force verbose logging in those cases.)
# -d, --device-id             Target device id or name (prefixes allowed).
#     --version               Reports the version of this tool.
#     --suppress-analytics    Suppress analytics reporting for the current CLI invocation.
#     --disable-telemetry     Disable telemetry reporting each time a flutter or dart command runs, until it is re-enabled.
#     --enable-telemetry      Enable telemetry reporting each time a flutter or dart command runs.

# Available commands:

# Flutter SDK
#   bash-completion   Output command line shell completion setup scripts.
#   channel           List or switch Flutter channels.
#   config            Configure Flutter settings.
#   doctor            Show information about the installed tooling.
#   downgrade         Downgrade Flutter to the last active version for the current channel.
#   precache          Populate the Flutter tool's cache of binary artifacts.
#   upgrade           Upgrade your copy of Flutter.

# Project
#   analyze           Analyze the project's Dart code.
#   assemble          Assemble and build Flutter resources.
#   build             Build an executable app or install bundle.
#   clean             Delete the build/ and .dart_tool/ directories.
#   create            Create a new Flutter project.
#   drive             Run integration tests for the project on an attached device or emulator.
#   gen-l10n          Generate localizations for the current project.
#   pub               Commands for managing Flutter packages.
#   run               Run your Flutter app on an attached device.
#   test              Run Flutter unit tests for the current project.

# Tools & Devices
#   attach            Attach to a running app.
#   custom-devices    List, reset, add and delete custom devices.
#   devices           List all connected devices.
#   emulators         List, launch and create emulators.
#   install           Install a Flutter app on an attached device.
#   logs              Show log output for running Flutter apps.
#   screenshot        Take a screenshot from a connected device.
#   symbolize         Symbolize a stack trace from an AOT-compiled Flutter app.

{
  description = "An example project using flutter";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # nixpkgs.url = "github:nixos/nixpkgs/master";
    # nixpkgs.url = "github:nixos/nixpkgs/ff67dad5711efe6daf0b1a0038b17093617ae502";
    # nixpkgs.url = "path:/home/srghma/projects/nixpkgs";
    nixpkgs.url = "git+file:/home/srghma/projects/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
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

            CHROME_EXECUTABLE = "google-chrome-beta"; # flutter doctor
          };
      });
}
