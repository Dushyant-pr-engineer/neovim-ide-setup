return {
    {
        -- Renders .md in the default browser, updates live as you edit.
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        ft = { "markdown" },
        build = function() vim.fn["mkdp#util#install"]() end,
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        keys = {
            { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", ft = "markdown", desc = "Markdown preview (browser)" },
        },
    },
}
