{ pkgs, ... }:

pkgs.dockerTools.buildImage {
    name = "toolbox";
    tag = "latest";

    fromImage = pkgs.dockerTools.pullImage {
        imageName = "quay.io/toolbx-images/archlinux-toolbox";
        imageDigest = "sha256:cf7dd147c2b05b80132d4eb96c1b5ab44b3941f106f11c4bcf93d293d891dc43";
        sha256 = "";
    };
}
