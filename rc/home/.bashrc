# .bashrc

# -- interactive shell? --
case $- in
    *i*) ;;
      *) return ;;
esac

# -- system defaults --
[ -f "/etc/skel/.bashrc" ]  && . "/etc/skel/.bashrc"

# -- dircolors --
#if type dircolors > /dev/null 2>&1; then
#    [ -r "${HOME}/.dircolors" ] \
#      && eval "$(dircolors -b "${HOME}/.dircolors")" \
#      || eval "$(dircolors -b)"
#    alias ls='ls --color=auto'
#else
#    # *BSD?
#    alias ls='ls -G'
#fi

# -- aliases --
#[ -r "${HOME}/.bash_aliases" ] && . "${HOME}/.bash_aliases"


# -- tilix, or libvte-based terminals --
if [ $TILIX_ID ] || [ $VTE_VERSION ] ; then
    for vte in "/etc/profile.d/vte.sh" "/etc/profile.d/vte-2.91.sh" ; do
        if [ -r "$vte" ] ; then
            . "$vte"
            break
        fi
    done
fi

#EOF