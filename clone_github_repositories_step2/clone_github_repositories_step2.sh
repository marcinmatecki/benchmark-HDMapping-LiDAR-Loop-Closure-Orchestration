#!/bin/bash
set -e

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "Usage: $0 [branch_name]"
    echo
    echo "Clones all HDMapping loop closure benchmark repositories from marcinmatecki"
    echo "and switches them to the specified branch."
    echo
    exit 0
fi

CLONE_DIR="$HOME/hdmapping-benchmark-loop-closure"

if [ ! -d "$CLONE_DIR" ]; then
    echo "Creating directory $CLONE_DIR..."
    mkdir -p "$CLONE_DIR"
else
    echo "Directory $CLONE_DIR already exists, skipping creation."
fi

cd "$CLONE_DIR" || exit

if [ -n "$1" ]; then
    BRANCH_NAME="$1"
    echo "Using branch from CLI: $BRANCH_NAME"
else
    read -p "Enter the branch name to checkout for all repositories: " BRANCH_NAME
fi

LOOP_CLOSURE_REPOS=(
    "BEV-LIO-LC-to-HDMAPPING"
    "KISS-MATCHER-to-HDMAPPING"
    "Open3D-to-HDMAPPING"
)

LOOP_CLOSURE_URLS=(
    "https://github.com/MapsHD/BEV-LIO-LC-to-HDMAPPING.git"
    "https://github.com/MapsHD/KISS-MATCHER-to-HDMAPPING.git"
    "https://github.com/MapsHD/Open3D-to-HDMAPPING.git"
)

clone_repo() {

    local repo_name="$1"
    local branch_name="$2"
    local url="$3"

    local dir_name="$repo_name"

    if [ ! -d "$dir_name" ]; then
        echo "Cloning $dir_name..."
        git clone --recursive "$url" "$dir_name"
    else
        echo "$dir_name already exists, skipping clone."
    fi

    cd "$dir_name" || return

    echo "Switching $dir_name to branch $branch_name..."

    git fetch

    git checkout "$branch_name"

    git pull --ff-only origin "$branch_name" || \
        echo "WARNING: $dir_name could not be fast-forwarded (local changes?) — using local state"

    git submodule update --init --recursive

    cd ..
}

echo "=== Cloning Loop Closure repositories ==="

for i in "${!LOOP_CLOSURE_REPOS[@]}"; do
    clone_repo \
        "${LOOP_CLOSURE_REPOS[$i]}" \
        "$BRANCH_NAME" \
        "${LOOP_CLOSURE_URLS[$i]}"
done

echo "=== All repositories have been cloned and switched to branch '$BRANCH_NAME' ==="

LOOP_CLOSURE_ALGOS=(
    "bev-lio-lc"
    "kiss-matcher"
    "open3d_docker"
)

for i in "${!LOOP_CLOSURE_ALGOS[@]}"; do

    algo="${LOOP_CLOSURE_ALGOS[$i]}"
    dir="${LOOP_CLOSURE_REPOS[$i]}"

    cd "$CLONE_DIR/$dir" || continue

    echo "Building Docker for $algo..."

    docker build -t "${algo}" .

    cd "$CLONE_DIR" || exit

done

echo "=== All Docker images built ==="