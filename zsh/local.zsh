# source local files
if [ -d ~/.localrc.d ]; then
  for file in $(ls ~/.localrc.d); do
    source ~/.localrc.d/$file
  done
fi
