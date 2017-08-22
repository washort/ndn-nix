{ stdenv, fetchFromGitHub, openssl, doxygen, boost, sqlite, cryptopp, pkgconfig, python, pythonPackages }:
let
  version = "0.5.1";
in
stdenv.mkDerivation {
  name = "ndn-cxx-${version}";

  src = fetchFromGitHub {
    owner = "named-data";
    repo = "ndn-cxx";
    rev = "ndn-cxx-${version}";
    sha256 = "09yaqswmaafm9zcj8bskaplx6315xzhz3m5w8r2qvx1x8lq5hp73";
  };

  buildInputs = [ openssl doxygen boost sqlite cryptopp pkgconfig python pythonPackages.sphinx ];
  preConfigure = ''
    patchShebangs waf
    ./waf configure \
      --with-cryptopp="${cryptopp}" \
      --with-openssl="${openssl.dev}" \
      --boost-includes="${boost.dev}/include" \
      --boost-libs="${boost.out}/lib" \
      --prefix="$out"
  '';
  buildPhase = ''
    ./waf
  '';
  # To do battle with the tests, add --with-tests to the configure above. ~ C.
  doCheck = false;
  checkPhase = ''
    LD_LIBRARY_PATH=build/ build/unit-tests
  '';
  installPhase = ''
    ./waf install
  '';
  outputs = [ "dev" "out" "doc" ];
  meta = with stdenv.lib; {
    homepage = "http://named-data.net/";
    description = "A Named Data Neworking (NDN) or Content Centric Networking (CCN) abstraction";
    longDescription = ''
      ndn-cxx is a C++ library, implementing Named Data Networking (NDN)
      primitives that can be used to implement various NDN applications.
      NDN operates by addressing and delivering Content Objects directly
      by Name instead of merely addressing network end-points. In addition,
      the NDN security model explicitly secures individual Content Objects
      rather than securing the connection or “pipe”. Named and secured
      content resides in distributed caches automatically populated on
      demand or selectively pre-populated. When requested by name, NDN
      delivers named content to the user from the nearest cache, thereby
      traversing fewer network hops, eliminating redundant requests,
      and consuming less resources overall.
    '';
    license = licenses.lgpl3;
    platforms = stdenv.lib.platforms.unix;
    maintainers = with maintainers; [ sjmackenzie MostAwesomeDude ];
  };
}
