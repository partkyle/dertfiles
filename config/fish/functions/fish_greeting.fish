function fish_greeting
  if which fortune > /dev/null 2>&1
    fortune
  end
end
