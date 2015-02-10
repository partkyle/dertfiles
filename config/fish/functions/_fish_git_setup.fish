function _fish_git_setup
  # Fish git prompt
  set -g __fish_git_prompt_color_branch yellow
  set -g __fish_git_prompt_color_upstream_ahead green
  set -g __fish_git_prompt_color_upstream_behind red

  # Status Chars
  set -g __fish_git_prompt_char_dirtystate '⚡'
  set -g __fish_git_prompt_char_stagedstate '→'
  set -g __fish_git_prompt_char_untrackedfiles '☡'
  set -g __fish_git_prompt_char_stashstate '↩'
  set -g __fish_git_prompt_char_upstream_ahead '+'
  set -g __fish_git_prompt_char_upstream_behind '-'
end
