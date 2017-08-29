{ stdenv, wafBuild, fetchFromGitHub, doxygen, boost, pkgconfig, python, pythonPackages,
  libpcap, openssl, ndn-cxx,
  websocketSupport ? true, websocketpp ? null}:
let
  version = "0.5.1";
  opt = stdenv.lib.optional;
in
wafBuild {
  name = "nfd-${version}";
  src = fetchFromGitHub {
    owner = "named-data";
    repo = "NFD";
    rev = "NFD-${version}";
    sha256 = "1qd02xr7iic0d9mca1m2ps1cxb7z3hj7llmyvxx0fc1jl8djvy9z";
  };
  buildInputs = [ libpcap doxygen boost pythonPackages.sphinx
    openssl ndn-cxx ] ++ opt websocketSupport websocketpp;

  preConfigure = opt websocketSupport
                 "ln -s ${websocketpp}/include/* websocketpp/websocketpp";
  wafConfigureFlags = [
      "--boost-includes='${boost.dev}/include'"
      "--boost-libs='${boost.out}/lib'"
      ] ++ opt (! websocketSupport) "--without-websocket";

  # Even though there are binaries, they don't get put in "bin" by default, so
  # this ordering seems to be a better one. ~ C.
  outputs = [ "out" "dev" "doc" ];
  meta = with stdenv.lib; {
    homepage = "http://named-data.net/";
    description = "Named Data Neworking (NDN) Forwarding Daemon";
    license = licenses.gpl3;
    platforms = stdenv.lib.platforms.unix;
    maintainers = [ maintainers.MostAwesomeDude ];
  };
}
