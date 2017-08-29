{ stdenv, wafBuild, fetchFromGitHub, boost, chronosync, ndn-cxx, log4cxx, openssl }:

wafBuild {
  name = "nlsr-20170824";
  src = fetchFromGitHub {
    owner = "named-data";
    repo = "NLSR";
    rev = "c0c6bcf7e29cf477659cbc31c67082e054f42742";
    sha256 = "0ksfmg02wv6f2ii4mcq1in1vy6sq9qg0h3x37k4qh7m9glmck9hb";
  };
  buildInputs = [ chronosync openssl ndn-cxx log4cxx ];
  wafConfigureFlags = [
      "--boost-includes='${boost.dev}/include'"
      "--boost-libs='${boost.out}/lib'"
  ];
}
