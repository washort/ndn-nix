{ stdenv, pkgconfig, fetchFromGitHub, autoreconfHook, ndn-cxx, perl,
  nfd, nlsr, libpcap, openvswitch, openssl, help2man,
libcgroup, python, pythonPackages, socat, psmisc, iperf, iproute, ethtool}:

let
  openflow = stdenv.mkDerivation {
  name = "openflow-9f587fc";
  src = fetchFromGitHub {
    owner = "mininet";
    repo = "openflow";
    rev = "9f587fc8e657a248d46b4763cc7e72efaccf8e00";
    sha256 = "0xrxkf0dmc4ydkzd5jggg8yzr99d1qfhfpp66bl4in5avh9fxgva";
  };
  patches = [ ./mininet-controller.patch ];
  postUnpack = ''
    touch $sourceRoot/debian/automake.mk
  '';
  nativeBuildInputs = [ autoreconfHook perl pkgconfig ];
  buildInputs = [ openssl ];
};
mininet = stdenv.mkDerivation {
  name = "mininet-2.2.2";
  src = fetchFromGitHub {
    owner = "mininet";
    repo = "mininet";
    rev = "2.2.2";
    sha256 = "18w9vfszhnx4j3b8dd1rvrg8xnfk6rgh066hfpzspzqngd5qzakg";
  };
  buildInputs = [ openflow openvswitch python pythonPackages.setuptools help2man ethtool iproute socat psmisc iperf libcgroup ];
  buildPhase = ''
    make mnexec
    make mn.1 mnexec.1
    ${python.interpreter} setup.py build
  '';
  installPhase = ''
    mkdir -p $out/share/man/man1
    mkdir -p $out/bin
    install mnexec $out/bin
    install mn.1 $out/share/man/man1
    install mnexec.1 $out/share/man/man1
    target=$out/lib/python2.7/site-packages/
    export PYTHONPATH=$PYTHONPATH:$target
    mkdir -p $target
    ${python.interpreter} setup.py install --prefix=$out --single-version-externally-managed --record egg-ynfo
  '';
};
in
pythonPackages.buildPythonApplication {
  name = "mini-ndn-0.3.0";
  src = fetchFromGitHub {
    owner = "named-data";
    repo = "mini-ndn";
    rev = "v0.3.0";
    sha256 = "1csnm8gx68mhbsdkcfjvs6sa4h7fnzhgkqz8iiyrvn1y7caaxp49";
  };
  buildInputs = [ mininet nlsr nfd ];
}
