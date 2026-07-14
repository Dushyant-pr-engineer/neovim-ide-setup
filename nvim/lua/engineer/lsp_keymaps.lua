-- Buffer-local keymaps applied whenever an LSP server attaches.
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(e)
        local function opts(desc)
            return { buffer = e.buf, desc = desc }
        end
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts("Go to definition"))
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts("Hover documentation"))
        vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts("Workspace symbol search"))
        vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts("Show line diagnostics"))
        vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts("Next diagnostic"))
        vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts("Previous diagnostic"))
        vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts("Code action"))
        vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts("Show references"))
        vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts("Rename symbol"))
    end,
})
