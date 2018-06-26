function edit
  pushd $argv >/dev/null 2>&1
	eval "$EDITOR ."
  popd >/dev/null 2>&1
end
