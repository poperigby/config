{
  lib,
  fetchFromGitHub,
  jre,
  makeWrapper,
  maven,
}:

maven.buildMavenPackage {
  pname = "fallrim-tools";
  version = "unstable-2023-10-01";

  src = fetchFromGitHub {
    owner = "mdfairch";
    repo = "FallrimTools";
    rev = "61bb57d895f023617cb55045a4907849fd1ff566";
    hash = "sha256-1tVftWj3TdSiY80RTf3QdYbYFjMuQmuN8aRetVJ2eB8=";
  };

  mvnHash = "sha256-O98b0wNK9/gXw9xnPTOo5XeYXel7vBcShlaZctE5i+A=";

  nativeBuildInputs = [ makeWrapper ];

  doCheck = false;

  installPhase = ''
    runHook preInstall

    install -Dm644 target/ReSaver.jar $out/share/resaver/resaver.jar

    mkdir $out/share/java
    install -Dm644 target/lib/* $out/share/java/

    ls $out/share/java

    mkdir -p $out/bin
    makeWrapper ${jre}/bin/java $out/bin/resaver \
    --add-flags "
        --classpath '$out/share/java'
        -jar $out/share/resaver/resaver.jar
    "

    runHook postInstall
  '';

  meta = {
    description = "";
    homepage = "https://github.com/mdfairch/FallrimTools";
    license = lib.licenses.asl20;
    mainProgram = "resaver";
    platforms = lib.platforms.all;
  };
}
