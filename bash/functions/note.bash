note() {
  if [[ -z "$NOTE_LOCATION" ]]; then
    NOTE_LOCATION=~/Dropbox
  fi

  title=
  if [[ -n "$1" ]]; then
    title="-$1"
  fi

  subl -n "$NOTE_LOCATION" "$NOTE_LOCATION/`date +%Y-%m-%d`$title.md"
}

_note()
{
    local cur=${COMP_WORDS[COMP_CWORD]}
    LOOK_FOR="*.md"
    cd ${NOTE_LOCATION}
    PROJECTS=$(ls ${LOOK_FOR})
    COMPREPLY=( $(compgen -W "${PROJECTS}" -- $cur) )
}

complete -F _note -o filenames note
