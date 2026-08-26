{ lib, ... }:

{
    renderConfigUi =
        config:
        let
            renderValue = value: if builtins.isBool value then lib.boolToString value else toString value;

            flattenConfig =
                prefix: value:
                if builtins.isAttrs value then
                    lib.flatten (
                        lib.mapAttrsToList (
                            name: nestedValue: flattenConfig (if prefix == "" then name else "${prefix}.${name}") nestedValue
                        ) value
                    )
                else
                    [
                        {
                            key = prefix;
                            inherit value;
                        }
                    ];

            renderEntry =
                { key, value }:
                if builtins.isList value then
                    map (item: "${key} ${renderValue item}") value
                else
                    [ "${key} ${renderValue value}" ];
        in
        lib.concatStringsSep "\n" (lib.flatten (map renderEntry (flattenConfig "" config))) + "\n";
}
