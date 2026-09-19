{
  description = "CSVMusic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    csvmusic-url = {
      url = "github:angall1/CSVMusic";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, csvmusic-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        desktopItem = pkgs.makeDesktopItem {
          name = "csvmusic";
          exec = "csvmusic";
          icon = "audio-x-generic";
          desktopName = "CSVMusic";
          categories = [ "Audio" "Music" "Player" ];
        };

        csvmusicApp = pkgs.python3Packages.buildPythonApplication {
          pname = "csvmusic";
          version = "1.7.7";
          src = csvmusic-url;

          pyproject = true;
          build-system = [ pkgs.python3Packages.setuptools ];

          propagatedBuildInputs = with pkgs.python3Packages; [
            pyside6
            yt-dlp
            ytmusicapi
            mutagen
            requests
            pandas
          ];

          makeWrapperArgs = [
            "--prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.ffmpeg pkgs.deno ]}"
          ];

          postInstall = ''
            mkdir -p $out/share/applications
            cp ${desktopItem}/share/applications/* $out/share/applications/
          '';
        };
      in
      {
        packages.default = csvmusicApp;

        devShells.default = pkgs.mkShell {
          inputsFrom = [ csvmusicApp ];
          buildInputs = [ pkgs.deno pkgs.ffmpeg ];
        };
      });
}
