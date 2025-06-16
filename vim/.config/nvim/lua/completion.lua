local cmp = require('cmp')
local luasnip = require('luasnip')

-- Load friendly-snippets
require("luasnip.loaders.from_vscode").lazy_load()

-- Setup nvim-cmp
cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
    }),
    sources = cmp.config.sources({
        { name = 'luasnip' },
        { name = 'buffer' },
        { name = 'path' },
    }),
    formatting = {
        format = function(entry, vim_item)
            -- Add icons to completion menu
            local icons = {
                Text = "📝",
                Method = "📋",
                Function = "📊",
                Constructor = "📌",
                Field = "📎",
                Variable = "📌",
                Class = "📚",
                Interface = "📑",
                Module = "📦",
                Property = "🔑",
                Unit = "📏",
                Value = "💎",
                Enum = "📋",
                Keyword = "🔑",
                Snippet = "📝",
                Color = "🎨",
                File = "📁",
                Reference = "📎",
                Folder = "📁",
                EnumMember = "📋",
                Constant = "🔒",
                Struct = "📋",
                Event = "📢",
                Operator = "🔧",
                TypeParameter = "📋",
            }
            vim_item.kind = string.format("%s %s", icons[vim_item.kind] or "", vim_item.kind)
            return vim_item
        end,
    },
}) 