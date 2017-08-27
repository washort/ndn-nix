{ stdenv, ndn-cxx, boost, sqlite, fetchFromGitHub, python, pkgconfig, openssl }:

stdenv.mkDerivation {
  name = "repo-ng-20170722";
  src = fetchFromGitHub {
    owner = "named-data";
    repo = "repo-ng";
    rev = "e1801314be82d1212193b7b77f3c422d4e7f3553";
    sha256 = "0lh97y3j7kzxqlvszsda2yi71araj81vmaxhh1cfjgkvrxr9drxn";
  };
  buildInputs = [ boost ndn-cxx sqlite python pkgconfig openssl ];
  preConfigure = ''
        patchShebangs waf
    ./waf configure \
      --boost-includes="${boost.dev}/include" \
      --boost-libs="${boost.out}/lib" \
      --prefix="$out"
    '';
  buildPhase = ''
    ./waf --with-tests
  '';
  installPhase = ''
    ./waf install
  '';
}
