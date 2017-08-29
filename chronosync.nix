{ stdenv, wafBuild, fetchFromGitHub, ndn-cxx, boost, openssl }:
wafBuild {
  name = "ChronoSync-20170728";
  src = fetchFromGitHub {
    owner = "named-data";
    repo = "ChronoSync";
    rev = "097bb448f46b8bd9a5c1f431e824f8f6a169b650";
    sha256 = "0jay4367d3cvrqfwxcv0d8d4jhjnzwdpzzqwc10pxw72rg4i67ag";
  };
  buildInputs = [ ndn-cxx boost openssl ];
  wafConfigureFlags = [
      "--boost-includes='${boost.dev}/include'"
      "--boost-libs='${boost.out}/lib'"
      "--prefix='$out'"
    ];
}
