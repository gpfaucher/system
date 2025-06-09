#!/usr/bin/env fish

# Get script directory
set -l script_dir (dirname (status --current-filename))

# Export DEV_ENV
set -gx DEV_ENV (pwd)

# Find and run scripts
set -l script_dir (find $script_dir/scripts -mindepth 1 -maxdepth 1 -executable)

for s in $script_dir
    echo "running script: $s"
    $s
end
