#!/usr/bin/env bash
repoFolder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $repoFolder

KOREBUILD_ARGS=()

show_help() {
    echo "Usage: $0 <arguments> [--] <arguments to msbuild>"
    echo ""
    echo "Arguments:"
    echo "      -s|--skip-update            Don't update KoreBuild"
    echo "      --korebuild-repo <REPO>     Clone KoreBuild from REPO"
    echo "      --korebuild-branch <BRANCH> Use BRANCH in KoreBuild repo"
    echo "      --korebuild-dest <DEST>     Clone KoreBuild to DEST"
    echo "      --                          Consider all remaining arguments arguments to MSBuild when building the repo"
}

while [[ $# > 0 ]]; do
    case $1 in
        -h|-\?|--help)
            show_help
            exit 0
            ;;
        -s|--skip-update)
            SKIP_UPDATE=1
            ;;
        --reclone-korebuild)
            RECLONE=1
            ;;
        --korebuild-repo)
            KOREBUILD_REPO=$2
            shift
            ;;
        --korebuild-branch)
            KOREBUILD_BRANCH=$2
            shift
            ;;
        --korebuild-dest)
            KOREBUILD_DEST=$3
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            break
            ;;
    esac
    shift
done

[ ! -z $KOREBUILD_BRANCH ] || KOREBUILD_BRANCH="anurse/msbuild" #TEMPORARY until this is merged to dev
[ ! -z $KOREBUILD_DEST ] || KOREBUILD_DEST="$repoFolder/.build"

if [[ $RECLONE == "1" ]] || [[ $SKIP_UPDATE != "1" ]]; then
    if [[ $RECLONE == "1" ]]; then
        rm -Rf $KOREBUILD_DEST
    fi

    if [ -d "$KOREBUILD_DEST/.git" ]; then
        echo -e "\033[1;32mUpdating KoreBuild...\033[0m"
        pushd $KOREBUILD_DEST >/dev/null
        git checkout $KOREBUILD_BRANCH
        git pull origin $KOREBUILD_BRANCH
        popd >/dev/null
    else
        if [ -d "$KOREBUILD_DEST" ]; then
            rm -Rf $KOREBUILD_DEST
        fi
        echo -e "\033[1;32mFetching KoreBuild...\033[0m"
        if [ -z "$KOREBUILD_REPO" ]; then
            # Use this repo's origin format to ensure we match the type (SSL/HTTPS)
            THIS_REPO=`git remote get-url origin`
            if [[ "$THIS_REPO" == http* ]]; then
                KOREBUILD_REPO="https://github.com/aspnet/KoreBuild"
            else
                KOREBUILD_REPO="git@github.com:aspnet/KoreBuild"
            fi
        fi
        git clone $KOREBUILD_REPO -b $KOREBUILD_BRANCH $KOREBUILD_DEST
    fi
fi

pushd $repoFolder >/dev/null
"$KOREBUILD_DEST/build/KoreBuild.sh" "$@"
popd >/dev/null
