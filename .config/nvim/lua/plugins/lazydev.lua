-- lazydev.nvim — neovim Lua API type stubs for lua_ls and nvim-cmp.
-- Only active in lua ft. Provides vim.*, vim.api.*, etc. completions and type info.
-- Its cmp source is registered with group_index=0 so it beats LSP for neovim lua files.
return {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
        library = {
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
    },
}
