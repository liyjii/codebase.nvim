# Select your code snippets
## Setup
### setup in your telescope config
```lua
telescope.setup {
extensions = {
  codebase = {
    -- file will be find if it's in 2 depth of path
    path = vim.fn.stdpath "config" .. "/codebase",
  },
},
}

```
