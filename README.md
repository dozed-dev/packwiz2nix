# packwiz2nix

packwiz2nix brings all of the benefits of Nix to [packwiz](https://packwiz.infra.link/), helping you create
[fixed-output derivations](https://nixos.org/manual/nix/stable/language/advanced-attributes.html#adv-attr-outputHash) from
your already existing packwiz modpack!

## Getting started

### For users

It is recommended to use [Infinidoge's](https://github.com/Infinidoge) [nix-minecraft](https://github.com/Infinidoge/nix-minecraft)
module as it allows you to symlink packages into a minecraft server's directory.

There is a convenience function called `mkModLinks` that can automate the creation of symlinks for a server like so:

```nix
{
  nix-minecraft,
  packwiz2nix,
  pkgs,
  yourModpack,
  ...
}: let
  inherit (packwiz2nix.lib) mkPackwizPackages mkModLinks;
  # replace "/checksums.json" with the path to the modpack's checksums file
  mods = mkPackwizPackages pkgs (yourModpack + "/checksums.json");
in {
  imports = [
    nix-minecraft.nixosModules.minecraft-servers
  ];

  nixpkgs.overlays = [nix-minecraft.overlay];

  services.minecraft-servers = {
    enable = true;
    eula = true;

    servers.my_server = {
      enable = true;
      package = pkgs.quiltServers.quilt-1_19_4-0_18_10;
      symlinks = mkModLinks mods;
    };
  };
}
```

### For modpack developers

packwiz2nix is quick to set up, all you have to do is add this to the `apps` attribute of a flake:

```nix
{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    packwiz2nix.url = "github:getchoo/packwiz2nix";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    packwiz2nix,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      apps = {
        # replace ./mods with the path to your .pw.toml files
        generate-checksums = packwiz2nix.lib.mkChecksumsApp pkgs ./mods;
      };
    });
}
```

An example of this can be found in my [personal modpack](https://github.com/getchoo/modpack/blob/main/flake.nix)

## Gotchas!

There are two main things you should keep in mind with this project currently:

- No Curseforge support

  - Packwiz does not keep the download URL to mods from Curseforge in it's TOML files,
    which is not acceptable in the current method used to generate checksums and create
    the final derivations for mods. This may be changed in the future

  - This is the biggest concern as it affects end users the most

- Checksums must be generated (**modpack developers, make sure you read this**)
  - Packwiz uses SHA1 to verify mod files, which fetchers in nix such as `builtins.fetchurl`
    and `pkgs.fetchurl` do not support. This prevents us from using them, and requires a separate
    checksum file (using SHA256) to be generated and updated along with the modpack. I don't see
    how this can be resolved in the foreseeable future unless SHA256 is adopted by Packwiz.

## Related Projects

- [Infinidoge/nix-minecraft](https://github.com/Infinidoge/nix-minecraft)
- [nix-community/mineflake](https://github.com/nix-community/mineflake)
