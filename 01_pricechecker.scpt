#!/usr/bin/osascript
on run argv
  set BASEDIR to item 1 of argv as string
  set CLUSTER to item 2 of argv as string
  set APIKEY to item 3 of argv as string
  set APISECRET to item 4 of argv as string
  tell application "iTerm2"
    # open first terminal and produce
    tell current session of current tab of current window
        write text "cd " & BASEDIR
        write text "python3 confluentPriceScraper.py " & CLUSTER & " " & APIKEY & " " & APISECRET
    end tell
  end tell
end run