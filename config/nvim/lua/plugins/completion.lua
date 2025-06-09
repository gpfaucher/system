return {
  'saghen/blink.cmp',
  version = '*',
  dependencies = 'rafamadriz/friendly-snippets',
  ---
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = {
      preset = 'enter',

      ['<Tab>'] = {
        function(cmp)
          if cmp.snippet_active() then
            return cmp.snippet_forward()
          else
            return cmp.select_next()
          end
        end,
        'fallback'
      },
      ['<S-Tab>'] = {
        function(cmp)
          if cmp.snippet_active() then
            return cmp.snippet_backward()
          else
            return cmp.select_prev()
          end
        end,
        'select_prev'
      },
    },

    appearance = {
      use_nvim_cmp_as_default = true,
      -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono'
    },

    sources = {
      default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          score_offset = 100,
        },
      },
    },

    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 500 },
    }
  },
  opts_extend = { "sources.default" }
}
