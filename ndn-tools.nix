{ stdenv, wafBuild, fetchFromGitHub, openssl, boost,
  pythonPackages, libpcap, git, ndn-cxx }:
let
  version = "0.4";
in wafBuild {
  name = "ndn-tools-${version}";

  src = fetchFromGitHub {
    owner = "named-data";
    repo = "ndn-tools";
    rev = "ndn-tools-${version}";
    sha256 = "19mrsbhv67ps3l2c8hds9d0gwjawpq1a3jnb917qqig0n6zs29vz";
  };

  buildInputs = [ libpcap openssl boost pythonPackages.sphinx git ndn-cxx ];
  wafConfigureFlags = [
      "--boost-includes='${boost.dev}/include'"
      "--boost-libs='${boost.out}/lib'"
      "--prefix='$out'"
  ];
  outputs = [ "out" "dev" "doc" ];
  meta = with stdenv.lib; {
    homepage = "http://named-data.net/";
    description = "Named Data Neworking (NDN) Essential Tools";
    license = licenses.gpl3;
    platforms = platforms.unix;
    maintainers = [ maintainers.MostAwesomeDude ];
  };
}
