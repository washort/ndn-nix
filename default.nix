{pkgs ? import <nixpkgs> {}}:
let ndnCxx = pkgs.callPackage ./ndn-cxx.nix {};
in
{
  ndn-cxx = ndnCxx;
  nfd = pkgs.callPackage ./nfd.nix { ndn-cxx = ndnCxx; };
  ndn-tools = pkgs.callPackage ./ndn-tools.nix { ndn-cxx = ndnCxx; };
  repo-ng = pkgs.callPackage ./repo-ng.nix { ndn-cxx = ndnCxx; };
}
