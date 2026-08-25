final: prev: {
    fishPlugins = prev.fishPlugins.overrideScope (
        final': prev': {
            done = prev'.done.overrideAttrs (old: {
                src = prev.applyPatches {
                    src = old.src;
                    patches = (old.patches or [ ]) ++ [
                        ./wezterm-notify-send.patch
                    ];
                };
            });
        }
    );
}
