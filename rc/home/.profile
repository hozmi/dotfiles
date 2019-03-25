
# for WSL
if [ -n "$IS_WSL" ] || [ -n "$(uname -srv | grep -i "microsoft")" ] ; then
    [ -r "/etc/environment" ] && . "/etc/environment"
    umask 022
fi

# local settings
[ -f "${HOME}/.profile.local" ] && . "${HOME}/.profile.local"

# PATH
[ -d "${HOME}/.local/bin" ] && PATH="${HOME}/.local/bin:$PATH"
[ -d "${HOME}/bin" ] && PATH="${HOME}/bin:$PATH"

