{pkgs ? import <nixpkgs> {}}:
let
  wafBuild = (args@{wafConfigureFlags ? "", wafBuildFlags ? "", buildInputs, ...}:
    pkgs.stdenv.mkDerivation (args // {
      buildInputs = buildInputs ++ [ pkgs.python2 pkgs.pkgconfig ];
      configurePhase = ''
        runHook preConfigure
        ${pkgs.python2.interpreter} waf configure ${builtins.toString wafConfigureFlags}  --prefix="$out"
      '';
      buildPhase = ''
        ${pkgs.python2.interpreter} waf ${builtins.toString wafBuildFlags}
      '';
      installPhase = ''
        ${pkgs.python2.interpreter} waf install
      '';
  }));
  ndnCxx = pkgs.callPackage ./ndn-cxx.nix { wafBuild = wafBuild; };
  load = (f: pkgs.callPackage f { ndn-cxx = ndnCxx; wafBuild = wafBuild; });

in
rec {
  ndn-cxx = ndnCxx;
  nfd = load ./nfd.nix;
  ndn-tools = load ./ndn-tools.nix;
  chronosync =  load ./chronosync.nix;
  repo-ng = load ./repo-ng.nix;
  nlsr = pkgs.callPackage ./nlsr.nix { inherit ndn-cxx chronosync wafBuild; };
  mini-ndn = pkgs.callPackage ./mini-ndn.nix { inherit nfd nlsr ndn-cxx; };
}
