i()
{
  cd $1
  shift
  $@
}

compdef _cd i
