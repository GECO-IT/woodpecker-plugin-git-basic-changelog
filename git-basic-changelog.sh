#!/usr/bin/env bash

set -e

# utf8 icons: https://www.utf8icons.com

INFO_TEXT="Plugin $(basename "${0%.*}")"

# =========================================================================================================
# functions()

say()
{
    if [ -n "$2" ]; then
        printf "🛈\e[32m ${INFO_TEXT}\e[0m\e[36m[⚒️ %s]\e[0m: %s \n" "$2" "$1"
    else
        printf "🛈\e[32m ${INFO_TEXT}\e[0m: %s \n" "$1"
    fi

return 0
}

sayE()
{
    if [ -n "$2" ]; then
        printf "✘\e[31m ${INFO_TEXT}\e[0m\e[36m[⚒️ %s]\e[0m: %s \n" "$2" "$1" 1>&2
    else
        printf "✘\e[31m ${INFO_TEXT}\e[0m: %s \n" "$1" 1>&2
    fi

exit 1
}

sayW()
{
    if [ -n "$2" ]; then
        printf "⚠\e[33m ${INFO_TEXT}\e[0m\e[36m[⚒️ %s]\e[0m: %s \n" "$2" "$1" 1>&2
    else
        printf "⚠\e[33m ${INFO_TEXT}\e[0m: %s \n" "$1" 1>&2
    fi

return 0
}

generate_changelog()
{
    if eval git describe --tags --abbrev=0 &> /dev/null; then
        # print commit log lines to CI_COMMIT_TAG
        if [ -n "${CI_COMMIT_TAG}" ]; then
            PREVIOUS_TAG="$(git describe --tags --abbrev=0 "${CI_COMMIT_TAG}^" 2> /dev/null || return 1)"

            # from previous tag
            if [ -n "${PREVIOUS_TAG}" ]; then
                ${PLUGIN_DEBUG:-false}&& say "Previous tag: ${PREVIOUS_TAG}"
                ${PLUGIN_DEBUG:-false}&& say "New tag: ${CI_COMMIT_TAG}"
                say "Generate changelog from '${PREVIOUS_TAG}' to '${CI_COMMIT_TAG}'..."
                git log "${PREVIOUS_TAG}..${CI_COMMIT_TAG}" --no-merges --pretty="- %s" | tee -a CHANGELOG.md &> /dev/null || return 1
                echo -e "\n_**Compare**_: [${PREVIOUS_TAG}...${CI_COMMIT_TAG}](${CI_REPO_URL}/compare/${PREVIOUS_TAG}...${CI_COMMIT_TAG})" >> CHANGELOG.md

            # for all commits
            else
                ${PLUGIN_DEBUG:-false}&& say "New tag: ${CI_COMMIT_TAG}"
                say "Generate changelog from first commit to '${CI_COMMIT_TAG}'..."
                git log --no-merges --pretty="- %s" | tee -a CHANGELOG.md &> /dev/null
            fi

        # print all commits log lines to last commit
        else
            LAST_TAG="$(git describe --tags --abbrev=0 2> /dev/null || return 1)"

            # from last tag
            if [ -n "${LAST_TAG}" ]; then
                say "Last tag: ${LAST_TAG}"
                say "Generate changelog from '${LAST_TAG}' to last commit..."
                git log "${LAST_TAG}"..HEAD --no-merges --pretty="- %s" | tee -a CHANGELOG.md &> /dev/null || return 1

            # for all commits
            else
                say "Found any tag in this repository... Generate full changelog..."
                git log --no-merges --pretty="- %s" | tee -a CHANGELOG.md &> /dev/null || return 1
            fi
        fi
    else
        # all commits log lines
        say "Found any tag in this repository... Generate full changelog..."
        git log --no-merges --pretty="- %s" | tee -a CHANGELOG.md &> /dev/null || return 1
    fi

return 0
}

# =========================================================================================================
# main()

# fix perm in Windows Container
uname -a | grep -q Windows && git config --global --add safe.directory "${CI_WORKSPACE}"

# changelog headers
echo -e "# What's Changed\n" > CHANGELOG.md

generate_changelog || sayE "Git changelog generated with error! 💣"

say "Git changelog successfully generated. ✅"

if ${PLUGIN_DEBUG:-false}; then
    sayW "Debug mode enable... Generated changelog:"
    cat CHANGELOG.md
fi

exit 0
