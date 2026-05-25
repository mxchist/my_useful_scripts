{
  pkgs ? import <nixpkgs> { },
}:
with pkgs;
stdenv.mkDerivation rec {
  pname = "sonic3_air";
  version = "26.03.28.0";

  src = ./.;

  nativeBuildInputs = [
    pkgs.autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    pkgs.curl
    pkgs.SDL2

    pkgs.zenity
    pkgs.alsa-lib
    pkgs.alsa-utils
    pkgs.libpulseaudio
  ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin/
    cp -r bonus config.json  data  doc  libdiscord_game_sdk.so sonic3air_linux $out/bin/

    runHook postInstall
  '';
  postFixup = ''
    wrapProgram $out/bin/sonic3air_linux \
    --prefix LD_LIBRARY_PATH : ${
      pkgs.lib.makeLibraryPath [
        pkgs.alsa-lib
        pkgs.libpulseaudio
      ]
    } \
    --prefix PATH : ${
      pkgs.lib.makeBinPath [
        pkgs.zenity
      ]
    }
  '';
}
