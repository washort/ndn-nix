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
mininet-src = fetchFromGitHub {
    owner = "mininet";
    repo = "mininet";
    rev = "87e26ef931ee6063332ceba77db472140f832d3a";
    sha256 = "0rwlnd486zz6ivj7ywf1i43ig2yjl0aysh8nwf9wf6zdy8wjgp0i";
  };
mininet-internal = stdenv.mkDerivation {
  name = "mininet-internal-2.2.2";
  src = mininet-src;
  buildInputs = [ openflow openvswitch python help2man ethtool iproute socat psmisc iperf libcgroup ];
  buildPhase = ''
    make mnexec
    make mn.1 mnexec.1
  '';
  installPhase = ''
    mkdir -p $out/share/man/man1
    mkdir -p $out/bin
    install mnexec $out/bin
    install mn.1 $out/share/man/man1
    install mnexec.1 $out/share/man/man1
  '';
};
mininet = pythonPackages.buildPythonApplication {
  name = "mininet-2.2.2";
  src = mininet-src;
  buildInputs = [ openflow openvswitch ethtool iproute socat psmisc iperf ];
  propagatedBuildInputs = [ mininet-internal ];
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
  buildInputs = [ nlsr nfd pythonPackages.wrapPython mininet ];
  pythonPath = [ mininet ];
  postInstall = ''
    mkdir -p $out/etc/mini-ndn
    cp ndn_utils/topologies/* ndn_utils/client.conf.sample $out/etc/mini-ndn
  '';
  fixupPhase = ''
    sed -i "1i #!${python.interpreter}" $out/bin/minindn{,edit}
    substituteInPlace $out/bin/minindn --replace "/usr/local" "$out"
    chmod +x $out/bin/minindn{,edit}
    wrapPythonPrograms
  '';
}
