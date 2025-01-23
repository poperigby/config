{ inputs, ... }:

final: prev: {
  vikunja = inputs.vikunja.legacyPackages.x86_64-linux.vikunja;
}
