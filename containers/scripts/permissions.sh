perm_base() {
    local path="${1}"
    local uid="${2}"
    local gid="${3}"
    local perms="${4}"
    IFS=' ' read -a options <<< "${5}"
    IFS=' ' read -a arguments <<< "${6}"

    echo "Enforcing permissions: ${path}"
    echo "${uid}:${gid} ${perms} ${@:5}"

    echo -ne '\033[31m'
    if [[ ${#options[@]} -gt 0 ]]; then
        find "${path}" ${options[@]:-} '(' -not -uid "${uid}" -or -not -gid "${gid}" ')' ${arguments[@]:-} -print -exec chown "${uid}:${gid}" '{}' '+'
        find "${path}" ${options[@]:-} '(' -not -perm "${perms}" ')' ${arguments[@]:-} -print -exec chmod "${perms}" '{}' '+'
    else
        find "${path}" '(' -not -uid "${uid}" -or -not -gid "${gid}" ')' ${arguments[@]:-} -print -exec chown "${uid}:${gid}" '{}' '+'
        find "${path}" '(' -not -perm "${perms}" ')' ${arguments[@]:-} -print -exec chmod "${perms}" '{}' '+'
    fi
    echo -ne '\033[0m'

    echo
}

perm_user_rw() {
    local path="${1}"
    local uid="${UGID}"
    local gid="${UGID}"
    local perms='u=rwX,g=,o='

    perm_base "${path}" "${uid}" "${gid}" "${perms}" "${2:-}" "${3:-}"
}
perm_user_ro() {
    local path="${1}"
    local uid="${UGID}"
    local gid="${UGID}"
    local perms='u=rX,g=,o='

    perm_base "${path}" "${uid}" "${gid}" "${perms}" "${2:-}" "${3:-}"
}

perm_group_rw() {
    local path="${1}"
    local uid='0'
    local gid="${UGID}"
    local perms='u=rwX,g=rwX,o='

    perm_base "${path}" "${uid}" "${gid}" "${perms}" "${2:-}" "${3:-}"
}
perm_group_ro() {
    local path="${1}"
    local uid='0'
    local gid="${UGID}"
    local perms='u=rwX,g=rX,o='

    perm_base "${path}" "${uid}" "${gid}" "${perms}" "${2:-}" "${3:-}"
}

perm_root_rw() {
    local path="${1}"
    local uid='0'
    local gid='0'
    local perms='u=rwX,g=,o='

    perm_base "${path}" "${uid}" "${gid}" "${perms}" "${2:-}" "${3:-}"
}
perm_root_ro() {
    local path="${1}"
    local uid='0'
    local gid='0'
    local perms='u=rX,g=,o='

    perm_base "${path}" "${uid}" "${gid}" "${perms}" "${2:-}" "${3:-}"
}

perm_ur_rw() {
    local path="${1}"
    local uid="${UGID}"
    local gid='0'
    local perms='u=rwX,g=rwX,o='

    perm_base "${path}" "${uid}" "${gid}" "${perms}" "${2:-}" "${3:-}"
}
perm_ur_rw_ro() {
    local path="${1}"
    local uid="${UGID}"
    local gid='0'
    local perms='u=rwX,g=rX,o='

    perm_base "${path}" "${uid}" "${gid}" "${perms}" "${2:-}" "${3:-}"
}
perm_ur_ro() {
    local path="${1}"
    local uid="${UGID}"
    local gid='0'
    local perms='u=rX,g=rX,o='

    perm_base "${path}" "${uid}" "${gid}" "${perms}" "${2:-}" "${3:-}"
}

perm_rg_ro() {
    local path="${1}"
    local uid='0'
    local gid="${UGID}"
    local perms='u=rX,g=rX,o='

    perm_base "${path}" "${uid}" "${gid}" "${perms}" "${2:-}" "${3:-}"
}

perm_custom() {
    local path="${1}"
    local uid="${2}"
    local gid="${3}"
    local perms="${4}"

    perm_base "${path}" "${uid}" "${gid}" "${perms}" "${5:-}" "${6:-}"
}
