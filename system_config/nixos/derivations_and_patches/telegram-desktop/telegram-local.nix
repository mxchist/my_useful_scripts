{ pkgs ? import <nixpkgs> {} }:
with pkgs;

let
  withWebkit = true;

  telegramBin = stdenv.mkDerivation {
    pname = "telegram-bin";
    version = "6.8.2";
    src = ./6.8.2;
    dontUnpack = true;
    dontPatchELF = true;
    dontStrip = true;
    installPhase = ''
      mkdir -p $out/bin
      install -Dm755 $src/Telegram $out/bin/Telegram
    '';
  };

  fhs = buildFHSEnv {
    name = "Telegram";
    runScript = "${telegramBin}/bin/Telegram";

    targetPkgs = p: with p; with kdePackages; [
      # core libs
      stdenv.cc.cc.lib
      glibc
      glib
      zlib
      alsa-lib
      libGL
      libpulseaudio
      fontconfig
      freetype

      # X11
      xorg.libX11
      xorg.libxcb
      xcb-util-cursor
      xorg.libXext
      xorg.libXrandr
      xorg.libXi
      xorg.libXcursor
      xorg.libXdamage
      xorg.libXcomposite
      xorg.libXfixes
      xorg.libXtst
      libxkbcommon
      xkeyboard_config

      #Wayland
      wayland
      # system
      dbus
      nss
      nspr

      # Qt
      qtbase
      kimageformats
      qtwayland
      qtsvg
      qtdeclarative

      # GLib/GTK integration
      glib-networking
      dconf

      # gsettings / pixbuf
      gsettings-desktop-schemas
      gtk3
      gdk-pixbuf
      librsvg
    ] ++ lib.optionals withWebkit [
      geoclue2
      webkitgtk_4_1
    ];
  };

in fhs
