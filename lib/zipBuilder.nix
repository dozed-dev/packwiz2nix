{
  lib,
  stdenvNoCC,
  zip,
  strip-nondeterminism,
}: {
  pname ? null,
  version ? "",
  src ? null,
  files ? {},
  ...
} @ args:
  stdenvNoCC.mkDerivation (finalAttrs:
    {
      pname = src.pname or pname;
      version = src.version or version;

      dontUnpack = true;
      dontConfig = true;
      dontBuild = true;

      nativeBuildInputs = [zip];

      installPhase = let
      in
        ''
          runHook preInstall

          mkdir -p $out
          tmp="$(mktemp -d)"
        ''
        + (lib.concatLines (
          lib.mapAttrsToList
          (name: file: ''
            mkdir -p "$tmp"/"$(dirname ${name})"
            cp -as ${file} "$tmp"/${name}
          '')
          files
        ))
        + ''
				  cd "$tmp"
          zip -r "$out/${finalAttrs.pname}-${finalAttrs.version}.zip" * .*

          "${lib.getExe strip-nondeterminism}" "$out/${finalAttrs.pname}-${finalAttrs.version}.zip"
        '';
    }
    // args)
