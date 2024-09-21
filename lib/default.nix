final: prev: {
  fetchPackwizModpack = final.callPackage ./fetchPackwizModpack.nix {};
  mkMultiMCPack = final.callPackage ./mkMultiMCPack.nix {};
  zipBuilder = final.callPackage ./zipBuilder.nix {};

  packwiz-installer-bootstrap = prev.callPackage ./packwiz-installer-bootstrap.nix {};
  packwiz-installer = prev.callPackage ./packwiz-installer.nix {};
}
