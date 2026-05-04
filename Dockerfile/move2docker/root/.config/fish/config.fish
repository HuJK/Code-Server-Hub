set -gx SHELL /usr/bin/fish
fish_add_path /opt/miniconda/bin

function conda
    functions -e conda
    eval /opt/miniconda/bin/conda "shell.fish" "hook" | source
    conda $argv
end

umask 002
