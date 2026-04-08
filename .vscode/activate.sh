#!/bin/bash
# Source default bash configuration
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# Add uv-managed venv to PATH
export PATH="$PWD/.venv/bin:$PATH"
export VIRTUAL_ENV="$PWD/.venv"
echo "✓ uv environment ready (.venv)"
