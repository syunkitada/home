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
    -- [KEYBIND] mode=vn; key=gh; tags=show; action=カーソル位置のワードの定義元、参照先の一覧を表示します;
    -- [KEYBIND] mode=vl; key=t; tags=move; action=タブで開く
    -- [KEYBIND] mode=vl; key=o; tags=move; action=カレントバッファで開く
    -- [KEYBIND] mode=vl; key=s; tags=move; action=横スプリットして開く
    -- [KEYBIND] mode=vl; key=i; tags=move; action=縦スプリットして開く
    -- [KEYBIND] mode=vl; key=q; tags=move; action=閉じる
    keymap("n", "gh", "<cmd>Lspsaga lsp_finder<CR>", { silent = true })

    -- [KEYBIND] mode=vn; key=gr; tags=edit; action=LSPで名前を変更します
    keymap("n", "gr", "<cmd>Lspsaga rename<CR>", { silent = true })

    -- [KEYBIND] mode=vn; key=gn; tags=move; action=次のdiagnosticに移動します
    keymap("n", "gn", "<cmd>Lspsaga diagnostic_jump_next<CR>", { silent = true })
    -- [KEYBIND] mode=vn; key=gp; tags=move; action=前のdiagnosticに移動します
    keymap("n", "gp", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { silent = true })

    -- [KEYBIND] mode=vn; key=_f; tags=show; action=ファイルのアウトラインを表示します;
    keymap("n","<space>o", "<cmd>LSoutlineToggle<CR>",{ silent = true })
    -- [KEYBIND] mode=vn; key=K; tags=show; action=カーソル位置のワードのドキュメントを表示します;
    keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>", { silent = true })

end



----------------------------------------------------------------------------------------------------
-- null-lsの設定
----------------------------------------------------------------------------------------------------
function init_null_ls(client)
    local null_ls = require "null-ls"
    local h = require("null-ls.helpers")
    local vim_version = vim.version()

    -- フォーマットはnulllsで行うため、lspのフォーマットは無効化する
    if vim_version.major == 0 and vim_version.minor < 8 then
        client.resolved_capabilities.document_formatting = false
        client.resolved_capabilities.document_range_formatting = false
    else
        client.server_capabilities.document_formatting = false
        client.server_capabilities.document_range_formatting = false
    end

    -- ファイル保存時にformatする
    -- MEMO: 以下のwikiにいあるやり方だと、ファイル開いてからしばらくは動くがいつのまにかフォーマットが動かなくなった
    --       https://github.com/jose-elias-alvarez/null-ls.nvim/wiki/Formatting-on-save
    local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
    vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        callback = function()
            if vim_version.major == 0 and vim_version.minor < 8 then
                vim.lsp.buf.formatting_sync()
            else
                vim.lsp.buf.format()
            end
        end,
    })

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
            null_ls.builtins.formatting.isort,
            null_ls.builtins.diagnostics.flake8,

            -- golang
            null_ls.builtins.formatting.goimports,

            -- shell
            null_ls.builtins.formatting.shfmt,
        },
    })
end



-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    -- lsp_signature
    -- https://github.com/ray-x/lsp_signature.nvim
    require "lsp_signature".on_attach(signature_setup, bufnr)

    init_null_ls(client)
    init_lspsaga()

end


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

require('lspconfig')['bashls'].setup{
    capabilities = capabilities,
    on_attach = on_attach,
    flags = lsp_flags,
    filetypes = { "sh" },
}
