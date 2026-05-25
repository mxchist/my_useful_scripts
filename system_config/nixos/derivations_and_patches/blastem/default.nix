{ pkgs ? import <nixpkgs> {} }:
with pkgs;
stdenv.mkDerivation rec {
    pname = "blastem-dev";
    version = "884de5ef1263";

    src = ./.;

    #NIX_DEBUG = 7;
    DATA_PATH="/home/<username>/Downloads/blastem/x86_64/0.6.3/";
    DEBUG=1;
    nativeBuildInputs = [
        pkg-config
    	wrapGAppsHook3
    ];
    buildInputs = [
        SDL2
        clang
        glib
        glew
        gtk3
    ];
    #separateDebugInfo = true;
    dontStrip = true;
    enableParallelBuilding = true;
    makeFlags = [
        "DEBUG=1"
        "DATA_PATH=/home/<username>/Downloads/blastem/x86_64/0.6.3/"
    ];
    preBuild = ''
	export XDG_DATA_DIRS=$GSETTINGS_SCHEMAS_PATH
        make clean
    '';
    installPhase = ''
        runHook preInstall

        mkdir -p $out/bin
        install -Dm755 blastem $out/bin/blastem
        
        runHook postInstall
    '';
    postFixup = ''
        wrapProgram $out/bin/blastem \
        --prefix LD_LIBRARY_PATH : ${
            pkgs.lib.makeLibraryPath [
                pkgs.gtk3
            ]
        }
    '';
}
