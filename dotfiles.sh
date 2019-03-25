#!/bin/sh

##-------------------------------------
## THIS_DIR=$(cd $(dirname "$0") ; pwd)
dirname_c () {
    # dirname $(readlink -f $1)
    targetfile=$1
    cd $(dirname "$targetfile")
    targetfile=$(basename "$targetfile")

    while [ "$targetfile" != "" ] ; do
        targetfile=$(readlink "$targetfile")
        cd $(dirname "$targetfile")
        targetfile=$(basename "$targetfile")
    done
    targetdir=$(pwd -P)

    echo "$targetdir"
}
THIS_DIR=$(dirname_c "$0")

##-------------------------------------
## variables
DOTFILES_ROOT=$(cd "${DOTFILES_ROOT:-"${THIS_DIR}/rc"}" ; pwd -P)
DEFAULT_DOTFILES=${DEFAULT_DOTFILES:-"home"}
DOTFILES_TARGET=$(cd "${DOTFILES_TARGET:-$HOME}" ; pwd)

##-------------------------------------
## consts.
IGNORE_PATH='*/.git/*'
IGNORE_FILE='.git* README*'
FIND_OPT=$(echo \
    $(printf ' ! -path %s' $IGNORE_PATH) \
    $(printf ' ! -name %s' $IGNORE_FILE))

CMD_SYMLINK='ln -sfnv'
#CMD_SYMLINK='ln -sbv'

##-------------------------------------
## sub-commands
cmd_pathname () {
    dname="${DOTFILES_ROOT}/${1:-"$DEFAULT_DOTFILES"}"
    if [ -d "$dname" ] ; then
        dname="$(cd "$dname" ; pwd -P)"
    fi
    echo "$dname"
}

cmd_pathnames () {
    for sdir in "${@:-$DEFAULT_DOTFILES}" ; do
        cmd_pathname "$sdir"
    done
}

cmd_mklink1 () {
    targetdir="$DOTFILES_TARGET"
    sourcedir="$(cmd_pathname "$1")"
    for f in $(find "$sourcedir" -type f $FIND_OPT) ; do
        dname=$(dirname $(echo "$f" | sed "s:^${sourcedir}:${targetdir}:"))
        [ -d "$dname" ] || mkdir -p "$dname"
        $CMD_SYMLINK "$f" "${dname}/"
    done
}

cmd_mklink () {
    for sdir in "${@:-$DEFAULT_DOTFILES}" ; do
        cmd_mklink1 "$sdir"
    done
}

cmd_rmlink1 () {
    targetdir="$DOTFILES_TARGET"
    sourcedir="$(cmd_pathname "$1")"
    for f in $(find "$sourcedir" -type f $FIND_OPT) ; do
        fname=$(echo "$f" | sed "s:^${sourcedir}:${targetdir}:")
        rm "$fname" > /dev/null 2>&1
        if [ -e "$fname~" ] ; then
            mv "$fname~" "$fname"
        fi
    done
    # remove dirs if empty.
    for f in $(find "$sourcedir" -mindepth 1 -type d $FIND_OPT | sort -r) ; do
        dname=$(echo "$f" | sed "s:^${sourcedir}:${targetdir}:")
        [ "$dname" = "${targetdir}" ] || rmdir "$dname" > /dev/null 2>&1
    done
}

cmd_rmlink () {
    for sdir in "${@:-$DEFAULT_DOTFILES}" ; do
        cmd_rmlink1 "$sdir"
    done
}

cmd_lsdotfiles1 () {
    targetdir="$DOTFILES_TARGET"
    sourcedir="$(cmd_pathname "$1")"
    for f in $(find "$sourcedir" -type f $FIND_OPT) ; do
        fname=$(echo "$f" | sed "s:^${sourcedir}:${targetdir}:")
        fstat='?'
        if [ -f "$fname" ] ; then
            if [ "$(readlink "$fname")" = "$f" ] ; then
                # same
                fstat='='
            else
                # conflict
                fstat='!'
            fi
        else
            # new
            fstat='+'
        fi
        echo "$(printf '%s:%s:%s' "$fstat" "$fname" "$f")"
    done
}

cmd_lsdotfiles () {
    for sdir in "${@:-$DEFAULT_DOTFILES}" ; do
        cmd_lsdotfiles1 "$sdir"
    done
}

cmd_import () {
    sourcedir="$(cmd_pathname "$DEFAULT_DOTFILES")"
    mkdir -p "$sourcedir"
    targetdir="$DOTFILES_TARGET"
    for target in "$@" ; do
        if [ -f "$target" ] ; then
            dotfile=$(basename "$target")
            parent=$(cd $(dirname "$target") ; pwd)
            dname=$(echo "${parent}" | sed "s:$targetdir::")
            dotdir=$(cd "${sourcedir}/$dname" ; pwd)
            mkdir -p "${dotdir}"
            mv -uv "${target}" "${dotdir}/"
            $CMD_SYMLINK "${dotdir}/$dotfile" "$target"
        elif [ -d "$target" ] ; then
            dotdir=$(cd "$target" ; pwd)
            dotfile=$(basename "$dotdir")
            parent=$(cd $(dirname "$dotdir") ; pwd)
            dname=$(echo "${parent}" | sed "s:$targetdir::")
            mkdir -p "${sourcedir}/$dname"
            mv -uv "${target}/" "${sourcedir}/$dname/"
            DOTFILES_ROOT="${sourcedir}/$dname" \
            DOTFILES_TARGET="$target" cmd_mklink "$dotfile"
        fi
    done
}

cmd_find_deadlink () {
    targetdir="${1:-$DOTFILES_TARGET}"
    find -L "$targetdir" -type l
}

cmd_install () {
    files=$(cmd_lsdotfiles "$@" | grep -E '^!')
    if [ -n "$files" ] ; then
        echo "$files"
        echo -n "--> Some files already exist. Force to install? [y/N]: "
        read ans
        case "$ans" in
            "Y"|"y"|"yes")      ;;
            "B"|"b"|"backup")   CMD_SYMLINK='ln -sbv' ;;
            * )                 return ;;
        esac
    fi
    cmd_mklink "$@"
}

##-------------------------------------
## main
THIS_FILE=$(basename "$0")
COMMAND="$1"
shift

case "$COMMAND" in
    "path")             cmd_pathnames "$@" ;;
    "deploy"|"link")    cmd_mklink "$@" ;;
    "remove"|"clean")   cmd_rmlink "$@" ;;
    "ls"|"list")        cmd_lsdotfiles "$@" ;;
    "import")           cmd_import "$@" ;;
    "find-deadlink")    cmd_find_deadlink "$@" ;;
    "install"|"setup")  cmd_install "$@" ;;
    *)                  echo "unknown: $COMMAND $@" ;;
esac
exit 0
