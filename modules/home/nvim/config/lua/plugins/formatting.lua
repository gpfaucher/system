return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        javascriptreact = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        markdown = { "prettier" },
        python = { "ruff_organize_imports", "ruff_format" },
        nix = { "nixfmt" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        lua = { "stylua" },
        go = { "gofmt" },
        rust = { "rustfmt" },
        terraform = { "terraform_fmt" },
        tf = { "terraform_fmt" },
      },
      format_on_save = {
        timeout_ms = 3000,
        lsp_fallback = true,
      },
    },
  },
}
