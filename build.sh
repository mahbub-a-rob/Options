#!/usr/bin/env bash
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

DEFAULT_BUILD_TOOLS_REPO="aspnet/DnxTools"
DEFAULT_BUILD_TOOLS_BRANCH="anurse/aspnet-build"

BUILD_TOOLS_ROOT="$DIR/.build"
INSTALL_SCRIPT="$BUILD_TOOLS_ROOT/install-aspnet-build.sh"
BUILD_TOOLS_PATH="$DIR/.build/aspnet-build"

[ -z "$ASPNETBUILD_TOOLS_REPO" ] && ASPNETBUILD_TOOLS_REPO="$DEFAULT_BUILD_TOOLS_REPO"
[ -z "$ASPNETBUILD_TOOLS_BRANCH" ] && ASPNETBUILD_TOOLS_BRANCH="$DEFAULT_BUILD_TOOLS_BRANCH"
[ -z "$ASPNETBUILD_TOOLS_INSTALL_SCRIPT_URL" ] && ASPNETBUILD_TOOLS_INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/$ASPNETBUILD_TOOLS_REPO/$ASPNETBUILD_TOOLS_BRANCH/scripts/install/install-aspnet-build.sh"

INSTALL_SCRIPT="$DIR/.build/install-aspnet-build.sh"

if [ ! -e "$INSTALL_SCRIPT" ]; then
    INSTALL_DIR=$(dirname "$INSTALL_SCRIPT")
    if [ ! -e "$INSTALL_DIR" ]; then
        mkdir -p "$INSTALL_DIR"
    fi

    echo "$(tput setaf 2)Fetching install script from $ASPNETBUILD_TOOLS_INSTALL_SCRIPT_URL ...$(tput setaf 7)"
    curl -sSL -o "$INSTALL_SCRIPT" "$ASPNETBUILD_TOOLS_INSTALL_SCRIPT_URL"
    chmod a+x "$INSTALL_SCRIPT"
fi

TRAINFILE="$DIR/Trainfile"
REPOFILE="$DIR/Repofile"
if [ -e "$TRAINFILE" ]; then
    "$INSTALL_SCRIPT" --trainfile "$TRAINFILE"
    BUILD_TOOLS_PATH=$("$INSTALL_SCRIPT" --get-path --trainfile "$TRAINFILE")
elif [ -e "$REPOFILE" ]; then
    "$INSTALL_SCRIPT" --trainfile "$REPOFILE"
    BUILD_TOOLS_PATH=$("$INSTALL_SCRIPT" --get-path --trainfile "$REPOFILE")
else
    "$INSTALL_SCRIPT" --branch "$ASPNETBUILD_TOOLS_BRANCH"
    BUILD_TOOLS_PATH=$("$INSTALL_SCRIPT" --get-path --branch "$ASPNETBUILD_TOOLS_BRANCH")
fi

"$BUILD_TOOLS_PATH/bin/aspnet-build" "$@"