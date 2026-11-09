#!/bin/bash

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "Usage: $0 [branch_name]"
    echo
    echo "Clones all ROS1 and ROS2 HDMapping benchmark repositories from MapsHD"
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

# =======================
# ROS1 repositories
# =======================
ROS1_REPOS=(
benchmark-Optimized-SC-F-LOAM-to-HDMapping
)

# =======================
# ROS2 repositories
# =======================
PYTHON_REPOS=(
"benchmark-PIN-SLAM-to-HDMapping"
)

clone_repo() {
  local repo_name="$1"  
  local branch_name="$2"    
  local url="https://github.com/marcinmatecki/${repo_name}.git"
  local dir_name=$(basename "$repo_name")

  if [ ! -d "$dir_name" ]; then
    echo "Cloning $dir_name..."
    git clone --recursive "$url"
  else
    echo "$dir_name already exists, skipping clone."
  fi

  cd "$dir_name" || return
  echo "Switching $dir_name to branch $branch_name..."
  git fetch
  git checkout "$branch_name"
  # Fast-forward an existing clone to the remote branch — fetch+checkout alone
  # leaves a stale local branch ("Your branch is behind ..."). --ff-only never
  # rewrites local commits; it only advances to what origin already has.
  git pull --ff-only origin "$branch_name" || \
    echo "WARNING: $dir_name could not be fast-forwarded (local changes?) — using local state"
  # Pulled commits may bump submodule pointers; materialize them.
  git submodule update --init --recursive
  cd ..
}

echo "=== Cloning ROS1 repositories ==="
for repo in "${ROS1_REPOS[@]}"; do
  clone_repo "$repo" "$BRANCH_NAME"
done                 

echo "=== Cloning PYTHON repositories ==="
for repo in "${PYTHON_REPOS[@]}"; do
  clone_repo "$repo" "$BRANCH_NAME"
done

echo "=== All repositories have been cloned and switched to branch '$BRANCH_NAME' ==="

ROS1_ALGOS=(
  "optimized-sc-f-loam"
)

PYTHON_ALGOS=(
  "pin-slam"
)

for i in "${!ROS1_ALGOS[@]}"; do
  algo="${ROS1_ALGOS[$i]}"
  dir="${ROS1_REPOS[$i]}"
  cd "$CLONE_DIR/$dir" || continue
  echo "Building Docker for $algo (ROS1 Noetic)..."
  docker build -t "${algo}_noetic" .
  cd "$CLONE_DIR" || exit
done

for i in "${!PYTHON_ALGOS[@]}"; do
  algo="${PYTHON_ALGOS[$i]}"
  dir="${PYTHON_REPOS[$i]}"
  cd "$CLONE_DIR/$dir" || continue
  echo "Building Docker for $algo (PYTHON)..."
  docker build -t "${algo}_cuda" .
  cd "$CLONE_DIR" || exit
done

echo "=== All Docker images built ==="