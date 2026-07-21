return {
    {
        "saghen/blink.cmp",
        dependencies = { "rafamadriz/friendly-snippets" },
        version = "1.*",
        opts = {
            keymap = {
                preset = "super-tab", -- Tab accepts the selected item (VS Code-like)
                ["<CR>"] = { "accept", "fallback" }, -- Enter accepts when menu open, else newline
            },
            appearance = { nerd_font_variant = "mono" },
            completion = { documentation = { auto_show = true } },
            sources = { default = { "lsp", "path", "snippets", "buffer" } },
            fuzzy = { implementation = "prefer_rust_with_warning" },
        },
        opts_extend = { "sources.default" },
    },
}
