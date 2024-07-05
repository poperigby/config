-- Set leader key
-- Has to be done before Lazy loads, or it won't work
vim.g.mapleader = ";"

-- Define packages
require("lazy").setup("plugins")
