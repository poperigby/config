{
    writeShellScriptBin,
    ...
}:

# TODO: Allow reading from STDIN and absolute paths

writeShellScriptBin "file-path" ''
# Check if the input argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <filename or full path>"
    exit 1
fi

# Check if the input argument is an absolute path
if [[ "$1" = /* ]] || [[ "$1" = ./* ]]; then
    # Absolute path provided
    filepath="$1"
else
    # Filename provided, look in the current directory
    filepath="./$1"
fi

# Check if the file exists
if [ -f "$filepath" ]; then
    fullpath=$(realpath "$filepath")
    echo "$fullpath"
else
    echo "$filepath"
    exit 1
fi
''
