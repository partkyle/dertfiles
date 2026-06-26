{
  lib,
  stdenvNoCC,
  fetchzip,
}:

let
  version = "1.1.2";
  variants = {
    bibata-rainbow-modern = {
      dirName = "Bibata-Rainbow-Modern";
      url = "https://github.com/ful1e5/Bibata_Cursor_Rainbow/releases/download/v${version}/Bibata-Rainbow-Modern.tar.gz";
      hash = "sha256-ycT4mkDzq489rESPRCtDmzvAWdAAu6WablpRoMpOyeI=";
    };
    bibata-rainbow-original = {
      dirName = "Bibata-Rainbow-Original";
      url = "https://github.com/ful1e5/Bibata_Cursor_Rainbow/releases/download/v${version}/Bibata-Rainbow-Original.tar.gz";
      hash = "sha256-I+RgkIVtDXuX6Tt8S4uQPniHOGbbhV2DeS43gsCwt78=";
    };
  };
in
lib.mapAttrs (_name: variant:
  stdenvNoCC.mkDerivation {
    pname = _name;
    inherit version;

    src = fetchzip {
      url = variant.url;
      hash = variant.hash;
      stripRoot = false;
    };

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/icons
      cp -r $src/${variant.dirName} $out/share/icons/
      runHook postInstall
    '';

    meta = {
      description = "Rainbow-color variant of Bibata cursors (${variant.dirName})";
      homepage = "https://github.com/ful1e5/Bibata_Cursor_Rainbow";
      license = lib.licenses.gpl3Only;
      platforms = lib.platforms.linux;
    };
  })
  variants
