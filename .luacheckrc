local loveAPI = {
  'love',
 }

max_line_length = false

stds.love = {
   read_globals = loveAPI   -- these globals can only be accessed.
}

-- https://luacheck.readthedocs.io/en/stable/config.html
read_globals = {
  "table",
  "math",
  "trace",
  "colors",
}

globals = {
  'love'
}

std = "lua51+love"
