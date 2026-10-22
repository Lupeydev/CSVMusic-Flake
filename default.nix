{ pkgs, lib, stdenv, copyDesktopItems, makeDesktopItem, autoPatchelfHook, ... }:
let
  pname = "csvmusic";
  version = "1.7.9";
  src = pkgs.fetchurl {
    url = "https://github.com/angall1/CSVMusic/releases/download/v${version}/CSVMusic-linux.zip";
    hash = "sha256-XzS8gq15T6kv7c9gDtrhTf+6H6bpAJYTzPuKkqjgl7Y=";
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    pkgs.unzip
    copyDesktopItems
    autoPatchelfHook
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libxcb-icccm.so.4"
    "libxcb-keysyms.so.1"
  ];

  buildInputs = with pkgs; [
    stdenv.cc.cc.lib
    libglvnd
    wayland
    libxkbcommon
    fontconfig
    glib
    libpulseaudio 
    libdrm         
    libX11
    libxcb
    libXext
    libXrender
    libice
    libsm
    xkeyboard_config
  ];

  sourceRoot = ".";

  installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      mkdir -p $out/lib/${pname}

      if [ -d "CSVMusic" ]; then
        cp -r CSVMusic/* $out/lib/${pname}/
      else
        cp -r ./* $out/lib/${pname}/
      fi

      if [ -f "$out/lib/${pname}/csvmusic" ]; then
        MAIN_BIN="$out/lib/${pname}/csvmusic"
      elif [ -f "$out/lib/${pname}/CSVMusic" ]; then
        MAIN_BIN="$out/lib/${pname}/CSVMusic"
      else
        MAIN_BIN=$(find $out/lib/${pname} -maxdepth 1 -type f -executable ! -name "yt-dlp" | head -n 1)
      fi

      chmod +x "$MAIN_BIN"
      BINARY_NAME=$(basename "$MAIN_BIN")

      cat << EOF > $out/bin/${pname}
      #!/bin/sh
      export XKB_CONFIG_ROOT="${pkgs.xkeyboard_config}/share/X11/xkb"
      exec $out/lib/${pname}/$BINARY_NAME "\$@"
      EOF
      chmod +x $out/bin/${pname}

      runHook postInstall
    '';

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      desktopName = pname;
      exec = "${pname} %u";
      icon = "csvmusic";
      type = "Application";
      terminal = false;
      comment = "CSV Music";
      categories = [ "Audio" "Music" "Utility" ];
    })
  ];

  meta = with lib; {
    description = "CSVMusic";
    homepage = "https://github.com/Lupeydev/CSVMusic-Flake";
    platforms = [ "x86_64-linux" ];
    license = licenses.gpl3;
  };
}