{
  packwiz-installer-bootstrap,
  zipBuilder,
}: {
  pname ? null,
  version ? "",
  src ? null,
  extraFiles ? {},
  instanceCfg,
  ...
} @ args:
  zipBuilder {
    inherit pname version src;
    files = {
      "instance.cfg" = instanceCfg;
      "packwiz-installer-bootstrap.jar" = packwiz-installer-bootstrap;
    } // extraFiles;
  }

