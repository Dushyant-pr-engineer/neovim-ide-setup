return {
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-neotest/nvim-nio",
            "olimorris/neotest-phpunit",
        },
        config = function()
            local docker_wrapper = vim.fn.stdpath("config") .. "/scripts/docker-phpunit.sh"

            -- Looks for a project-local .nvim.lua (not committed — see cheatsheet/README)
            -- declaring `{ docker = { container = "...", container_root = "..." } }`
            -- for projects whose app/vendor only exist inside a docker container.
            local function find_project_config()
                local found = vim.fs.find(".nvim.lua", { upward = true, path = vim.fn.expand("%:p:h") })[1]
                if not found then
                    return nil
                end
                local ok, cfg = pcall(dofile, found)
                if not ok or type(cfg) ~= "table" then
                    return nil
                end
                cfg._root = vim.fn.fnamemodify(found, ":h")
                return cfg
            end

            require("neotest").setup({
                adapters = {
                    require("neotest-phpunit")({
                        phpunit_cmd = function()
                            local cfg = find_project_config()
                            if cfg and cfg.docker then
                                return { docker_wrapper }
                            end
                            return "vendor/bin/phpunit"
                        end,
                        env = function()
                            local cfg = find_project_config()
                            if cfg and cfg.docker then
                                return {
                                    NEOTEST_DOCKER_CONTAINER = cfg.docker.container,
                                    NEOTEST_DOCKER_HOST_ROOT = cfg.docker.host_root or cfg._root,
                                    NEOTEST_DOCKER_CONTAINER_ROOT = cfg.docker.container_root,
                                }
                            end
                            return {}
                        end,
                    }),
                },
            })
            local neotest = require("neotest")
            vim.keymap.set("n", "<leader>tt", function() neotest.run.run() end, { desc = "Run nearest test" })
            vim.keymap.set("n", "<leader>tf", function() neotest.run.run(vim.fn.expand("%")) end, { desc = "Run test file" })
            vim.keymap.set("n", "<leader>ts", function() neotest.summary.toggle() end, { desc = "Toggle test summary" })
            vim.keymap.set("n", "<leader>to", function() neotest.output.open({ enter = true }) end, { desc = "Open test output" })
            vim.keymap.set("n", "<leader>tO", function() neotest.output_panel.toggle() end, { desc = "Toggle test output panel" })
        end,
    },
}
