{
    pkgs,
    ...
}:

pkgs.writers.writePython3Bin "marine-jobs" {
    # Long keyword lists and output lines read better unwrapped; W503 is
    # flake8's off-by-default rule against leading binary operators.
    flakeIgnore = [
        "E501"
        "W503"
    ];
} (builtins.readFile ./marine_jobs.py)
