----------------------------------------------------------------------------------------------------
-- lsp関連の設定
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- lspsagaの設定
----------------------------------------------------------------------------------------------------
function init_lspsaga()
    local saga = require('lspsaga')

    local keymap = vim.keymap.set

    local colors = {
      fg = '#bbc2cf',
      red = '#e95678',
      orange = '#FF8700',
      yellow = '#f7bb3b',
      green = '#afd700',
      cyan = '#36d0e0',
      blue = '#61afef',
      violet = '#CBA6F7',
      teal = '#1abc9c',
    }

    local opts = {
        custom_kind = {
            File = {'file:', colors.fg },
            Module = {'module: ', colors.blue },
            Namespace ={'namespace:', colors.orange },
            Package ={'package:', colors.violet },
            Class ={'class:', colors.violet },
            Method ={'method:', colors.violet },
            Property ={'prop:', colors.cyan },
            Field ={'field:', colors.teal },
            Constructor ={'constructor:', colors.blue },
            Enum ={'enum:', colors.green },
            Interface ={'interface: ', colors.orange },
            Function ={'func:', colors.violet },
            Variable ={'var:', colors.blue },
            Constant ={'const:', colors.cyan },
            String ={'str:', colors.green },
            Number ={'num:', colors.green },
            Boolean ={'bool:', colors.orange },
            Array ={'array:', colors.blue },
            Object ={'obj:', colors.orange },
            Key ={'key:', colors.red },
            Null ={'null:', colors.red },
            EnumMember ={'enum:', colors.green },
            Struct ={'struct:', colors.violet },
            Event ={'event: ', colors.violet },
            Operator ={'operator:', colors.green },
            TypeParameter ={'type_pram:', colors.green },
            TypeAlias ={'type_alias:', colors.green },
            Parameter ={'param:', colors.blue },
            StaticMethod ={'method:', colors.orange },
            Macro ={'macto:', colors.red },
        },
    }

    saga.init_lsp_saga(opts)

    -- Lsp finder find the symbol definition implement reference
    -- when you use action in finder like open vsplit then you can
    -- use <C-t> to jump back
    keymap("n", "gh", "<cmd>Lspsaga lsp_finder<CR>", { silent = true })

    -- Code action
    keymap("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", { silent = true })
    keymap("v", "<leader>ca", "<cmd><C-U>Lspsaga range_code_action<CR>", { silent = true })

    -- Rename
    keymap("n", "gr", "<cmd>Lspsaga rename<CR>", { silent = true })

    -- Definition preview
    keymap("n", "gd", "<cmd>Lspsaga preview_definition<CR>", { silent = true })

    -- Show line diagnostics
    keymap("n", "<leader>cd", "<cmd>Lspsaga show_line_diagnostics<CR>", { silent = true })

    -- Show cursor diagnostic
    keymap("n", "<leader>cd", "<cmd>Lspsaga show_cursor_diagnostics<CR>", { silent = true })

    -- Diagnsotic jump can use `<c-o>` to jump back
    keymap("n", "[e", "<cmd>Lspsaga diagnostic_jump_next<CR>", { silent = true })
    keymap("n", "]e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { silent = true })

    -- Only jump to error
    keymap("n", "[E", function()
      require("lspsaga.diagnostic").goto_prev({ severity = vim.diagnostic.severity.ERROR })
    end, { silent = true })
    keymap("n", "]E", function()
      require("lspsaga.diagnostic").goto_next({ severity = vim.diagnostic.severity.ERROR })
    end, { silent = true })

    -- Outline
    keymap("n","<space>o", "<cmd>LSoutlineToggle<CR>",{ silent = true })

    -- Hover Doc
    keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>", { silent = true })

    local action = require("lspsaga.action")
    -- scroll in hover doc or  definition preview window
    vim.keymap.set("n", "<C-f>", function()
        action.smart_scroll_with_saga(1)
    end, { silent = true })
    -- scroll in hover doc or  definition preview window
    vim.keymap.set("n", "<C-b>", function()
        action.smart_scroll_with_saga(-1)
    end, { silent = true })
end



----------------------------------------------------------------------------------------------------
-- null-lsの設定
----------------------------------------------------------------------------------------------------
function init_null_ls()
    local null_ls = require "null-ls"
    local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
    local h = require("null-ls.helpers")
    null_ls.setup({
        debug = true,
        sources = {
            -- web
            null_ls.builtins.formatting.prettier,

            -- clang
            null_ls.builtins.formatting.clang_format.with {
                args = h.range_formatting_args_factory(
                { "--assume-filename", "$FILENAME", "--style", "google" },
                "--offset",
                "--length",
                { use_length = true }
                ),
            },

            -- python
            null_ls.builtins.formatting.black,
            null_ls.builtins.diagnostics.flake8,

            -- golang
            null_ls.builtins.formatting.goimports,
        },
        on_attach = function(client, bufnr)
            if client.supports_method("textDocument/formatting") then
                vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
                vim.api.nvim_create_autocmd("BufWritePre", {
                    group = augroup,
                    buffer = bufnr,
                    callback = function()
                        vim.lsp.buf.format({ bufnr = bufnr })
                    end,
                })
            end 
        end,
    })
end



-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local bufopts = { noremap=true, silent=true, buffer=bufnr }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', '<space>f', vim.lsp.buf.format, bufopts)


    -- lsp_signature
    -- https://github.com/ray-x/lsp_signature.nvim
    require "lsp_signature".on_attach(signature_setup, bufnr)


    init_null_ls()
    init_lspsaga()
end


-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)


local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}


 -- Setup lspconfig.
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

require('lspconfig')['pyright'].setup{
    capabilities = capabilities,
    on_attach = on_attach,
    flags = lsp_flags,
    filetypes = { "python" },
}

-- require('lspconfig')['tsserver'].setup{
--     capabilities = capabilities,
--     on_attach = on_attach,
--     flags = lsp_flags,
--     filetypes = {"javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
-- }

require('lspconfig')['tailwindcss'].setup{
    capabilities = capabilities,
    on_attach = on_attach,
    flags = lsp_flags,
    filetypes = { "aspnetcorerazor", "astro", "astro-markdown", "blade", "django-html", "htmldjango", "edge", "eelixir", "ejs", "erb", "eruby",
    "gohtml", "haml", "handlebars", "hbs", "html", "html-eex", "heex", "jade", "leaf", "liquid", "markdown", "mdx", "mustache", "njk", "nunjucks", "php", "razor", "slim", "twig", "css", "less", "postcss", "sass", "scss", "stylus", "sugarss", "javascript", "javascriptreact", "reason", "rescript", "typescript", "typescriptreact", "vue", "svelte" },
}

require('lspconfig')['clangd'].setup{
    capabilities = capabilities,
    on_attach = on_attach,
    flags = lsp_flags,
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
}

require('lspconfig')['gopls'].setup{
    capabilities = capabilities,
    on_attach = on_attach,
    flags = lsp_flags,
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
}



----------------------------------------------------------------------------------------------------
-- fidget
-- LSPのステータス表示用
----------------------------------------------------------------------------------------------------
require"fidget".setup{}
