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
    -- [KEYBIND] mode=vl; key=t; tags=lsp_modal,move; action=タブで開く
    -- [KEYBIND] mode=vl; key=o; tags=lsp_modal,move; action=カレントバッファで開く
    -- [KEYBIND] mode=vl; key=s; tags=lsp_modal,move; action=横スプリットして開く
    -- [KEYBIND] mode=vl; key=i; tags=lsp_modal,move; action=縦スプリットして開く
    -- [KEYBIND] mode=vl; key=q; tags=lsp_modal,move; action=閉じる

    -- [KEYBIND] mode=vn; key=gj; tags=lsp,show; action=カーソル位置のワードの定義先、参照先へ移動します
    keymap("n", "gj", "<cmd>Lspsaga lsp_finder<CR>", { silent = true })
    -- [KEYBIND] mode=vn; key=gh; tags=lsp,show; action=カーソル位置のワードのドキュメントを表示します;
    keymap("n", "gh", "<cmd>Lspsaga hover_doc<CR>", { silent = true })

    -- [KEYBIND] mode=vn; key=go; tags=lsp,show; action=ファイルのアウトラインを表示します;
    keymap("n","go", "<cmd>LSoutlineToggle<CR>",{ silent = true })

    -- [KEYBIND] mode=vn; key=gr; tags=lsp,edit; action=カーソル位置のワードの名前を変更します
    keymap("n", "gr", "<cmd>Lspsaga rename<CR>", { silent = true })

    -- [KEYBIND] mode=vn; key=gn; tags=lsp,move; action=次のdiagnosticに移動します
    keymap("n", "gn", "<cmd>Lspsaga diagnostic_jump_next<CR>", { silent = true })
    -- [KEYBIND] mode=vn; key=gp; tags=lsp,move; action=前のdiagnosticに移動します
    keymap("n", "gp", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { silent = true })

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

    -- gitレポの場合のみformatを有効化する
    result = os.execute("git rev-parse")
    if result == 0 then
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
    end

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
            null_ls.builtins.formatting.shfmt.with {
                filetypes = { "sh", "zsh" },
            },
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
 -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
-- local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

require('lspconfig')['pyright'].setup{
    capabilities = capabilities,
    on_attach = on_attach,
    flags = lsp_flags,
    filetypes = { "python" },
}

require('lspconfig')['markdown_oxide'].setup{
    capabilities = capabilities,
    on_attach = on_attach,
    flags = lsp_flags,
    filetypes = {"markdown"},
}

require('lspconfig')['ts_ls'].setup{
    capabilities = capabilities,
    on_attach = on_attach,
    flags = lsp_flags,
    filetypes = {"javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
}

require('lspconfig')['tailwindcss'].setup{
    capabilities = capabilities,
    on_attach = on_attach,
    flags = lsp_flags,
    filetypes = { "aspnetcorerazor", "astro", "blade", "django-html", "htmldjango", "edge", "eelixir", "ejs", "erb", "eruby",
    "gohtml", "haml", "handlebars", "hbs", "html", "html-eex", "heex", "jade", "leaf", "liquid", "mdx", "mustache", "njk", "nunjucks", "php", "razor", "slim", "twig", "css", "less", "postcss", "sass", "scss", "stylus", "sugarss", "javascript", "javascriptreact", "reason", "rescript", "typescript", "typescriptreact", "vue", "svelte" },
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
    filetypes = { "sh", "zsh" },
}

---
require("holon").setup({
  -- Path to notes directory (required)
  notes_path = vim.fn.expand("~/mynotes"),

  -- Subdirectory structure (relative to notes_path)
  -- Note types are derived from these keys (excluding "journal").
  directories = {
    permanent  = "notes/permanent",
    fleeting   = "notes/fleeting",
    literature = "notes/literature",
    project    = "notes/project",
    index      = "notes/permanent",
    structure  = "notes/permanent",
    journal    = "journal",
  },

  -- Template directory (relative to notes_path)
  templates_path = "templates",

  -- Archive directory (relative to notes_path)
  archives_path = "archives",

  -- File extension
  extension = ".md",

  -- Filename style: "uuid" (auto-generated UUID) or "manual" (user-specified)
  filename_style = "time",

  -- Link format: "wiki" for [[target|title]], "markdown" for [title](target.md)
  default_link_format = "wiki",

  -- Nerd Font icons per note type
  icons = {
    permanent  = { icon = "󰆼", hl = "HolonPermanent" },
    fleeting   = { icon = "󱞁", hl = "HolonFleeting" },
    literature = { icon = "󰂺", hl = "HolonLiterature" },
    project    = { icon = "󰳏", hl = "HolonProject" },
    index      = { icon = "󰉋", hl = "HolonIndex" },
    structure  = { icon = "󰙅", hl = "HolonStructure" },
    default    = { icon = "󰈙", hl = "HolonDefault" },
  },

  -- Picker display settings
  picker = {
    show_icons = true,
    show_tags = true,
    initial_mode = "insert",
    layout_config = {
      width = 0.9,
      height = 0.8,
      horizontal = {
        preview_width = 0.5,
      },
    },
    -- Common keybindings shared by all pickers (defaults shown below)
    keymaps = {
      prompt = {
        i = {
          ["<CR>"] = "focus_results",
          ["<Down>"] = "move_down",
          ["<Up>"] = "move_up",
          ["<Tab>"] = "toggle_mark",
        },
        n = {
          ["<CR>"] = "focus_results",
          ["q"] = "close",
          ["<Esc>"] = "close",
        },
      },
      results = {
        n = {
          ["j"] = "move_down",
          ["k"] = "move_up",
          ["<CR>"] = "select",
          ["q"] = "close",
          ["<Esc>"] = "close",
          ["i"] = "focus_prompt",
          ["I"] = "focus_prompt",
          ["a"] = "focus_prompt",
          ["A"] = "focus_prompt",
          ["/"] = "focus_prompt",
          ["<Tab>"] = "toggle_mark",
          ["<C-d>"] = "page_down",
          ["<C-u>"] = "page_up",
        },
      },
    },
  },

  -- Keybindings inside the notes picker
  -- Available actions: "create_note", "show_backlinks", "show_forward_links",
  --                    "insert_link", "filter_by_type", "filter_by_tag"
  mappings = {
    i = {
      ["<C-n>"] = "create_note",
      ["<C-b>"] = "show_backlinks",
      ["<C-f>"] = "show_forward_links",
      ["<C-l>"] = "insert_link",
      ["<C-t>"] = "filter_by_type",
      ["<C-g>"] = "filter_by_tag",
    },
    n = {
      ["n"] = "create_note",
      ["b"] = "show_backlinks",
      ["f"] = "show_forward_links",
      ["l"] = "insert_link",
      ["t"] = "filter_by_type",
      ["g"] = "filter_by_tag",
    },
  },

  -- GTD board settings
  gtd = {
    statuses = { "inbox", "todo", "inprogress", "waiting", "delegate", "done" },

    -- Icons shown in the board for each status
    status_icons = {
      inbox      = { icon = "󰁔", hl = "HolonGtdInbox" },
      todo       = { icon = "󰝖", hl = "HolonGtdTodo" },
      inprogress = { icon = "󱓻", hl = "HolonGtdProgress" },
      waiting    = { icon = "󰏤", hl = "HolonGtdWaiting" },
      delegate   = { icon = "󰜵", hl = "HolonGtdDelegate" },
      done       = { icon = "󰄲", hl = "HolonGtdDone" },
    },

    -- Blocked indicator
    blocked_icon = "🔒",

    -- Board layout
    layout = {
      width = 0.9,
      height = 0.8,
      timeline_min_width = 30,
      preview_ratio = 0.45,
    },
  },

})
