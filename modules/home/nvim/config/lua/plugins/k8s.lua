return {
  -- ============================================================================
  -- Kubernetes Treesitter grammar (syntax highlighting for manifests)
  -- ============================================================================
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      local langList = opts.ensure_installed
      -- Add Kubernetes manifest grammar
      if not vim.tbl_contains(langList, "kubernetes") then
        table.insert(langList, "kubernetes")
      end
      -- Add Helm template grammar ({{ .Values... }})
      if not vim.tbl_contains(langList, "helm") then
        table.insert(langList, "helm")
      end
      -- Add Kustomize grammar
      if not vim.tbl_contains(langList, "kustomize") then
        table.insert(langList, "kustomize")
      end
    end,
  },

  -- ============================================================================
  -- Kubectl integration (run kubectl from Neovim)
  -- ============================================================================
  {
    "kellrby/kubectl.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    keys = {
      { "<leader>k", "<cmd>Kubectl<cr>", desc = "Kubectl menu" },
      { "<leader>kg", "<cmd>Kubectl get pods<cr>", desc = "Get pods" },
      { "<leader>ks", "<cmd>Kubectl get svc<cr>", desc = "Get services" },
      { "<leader>ki", "<cmd>Kubectl get ingress<cr>", desc = "Get ingresses" },
      { "<leader>kd", "<cmd>Kubectl get deploy<cr>", desc = "Get deployments" },
      { "<leader>kn", "<cmd>Kubectl get ns<cr>", desc = "Get namespaces" },
      { "<leader>kl", "<cmd>Kubectl logs -f<cr>", desc = "Tail logs" },
      { "<leader>ke", "<cmd>Kubectl exec -it<cr>", desc = "Exec into pod" },
      { "<leader>kf", "<cmd>Kubectl port-forward<cr>", desc = "Port forward" },
      { "<leader>kk", "<cmd>Kubectl config get-contexts<cr>", desc = "Get contexts" },
    },
    config = function()
      require("kubectl").setup({})
    end,
  },

  -- ============================================================================
  -- Helm LSP (helm-ls) — syntax-aware completion for Helm templates
  -- ============================================================================
  {
    "psliwinski/vim-helm",  -- Helm syntax for Vim
    ft = { "yaml", "helm" },
  },

  {
    "psliwinski/helm-ls",
    ft = { "yaml", "helm" },
    build = "make install",
    config = function()
      local lspconfig = require("lspconfig")
      -- Setup helm-ls LSP
      lspconfig.helm_ls.setup({
        filetypes = { "helm" },
        on_attach = function(client, bufnr)
          local map = vim.keymap.set
          map("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "Go to definition" })
          map("n", "gr", vim.lsp.buf.references, { buffer = bufnr, desc = "Go to references" })
          map("n", "gD", vim.lsp.buf.declaration, { buffer = bufnr, desc = "Go to declaration" })
          map("n", "gy", vim.lsp.buf.type_definition, { buffer = bufnr, desc = "Go to type" })
          map("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = "Hover" })
          map("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, desc = "Code action" })
          map("n", "<leader>r", vim.lsp.buf.rename, { buffer = bufnr, desc = "Rename" })
        end,
      })
    end,
  },

  -- ============================================================================
  -- Kubernetes LSP (redhat-developer/kubernetes-lsp)
  -- Syntax-aware completion and validation for K8s manifests
  -- ============================================================================
  {
    "redhat-developer/kubernetes-lsp",
    ft = { "yaml" },
    build = "npm install -g kubernetes-lsp-server",
    config = function()
      local lspconfig = require("lspconfig")
      lspconfig.kubernetes_lsp.setup({
        on_attach = function(client, bufnr)
          local map = vim.keymap.set
          map("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "Go to definition" })
          map("n", "gr", vim.lsp.buf.references, { buffer = bufnr, desc = "Go to references" })
          map("n", "gD", vim.lsp.buf.declaration, { buffer = bufnr, desc = "Go to declaration" })
          map("n", "gy", vim.lsp.buf.type_definition, { buffer = bufnr, desc = "Go to type" })
          map("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = "Hover" })
          map("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, desc = "Code action" })
          map("n", "<leader>r", vim.lsp.buf.rename, { buffer = bufnr, desc = "Rename" })
        end,
      })
    end,
  },

  -- ============================================================================
  -- Kubeval/Kubeconform as linter (manifest validation)
  -- ============================================================================
  {
    "mrcjkb/vim-kubeval",
    ft = { "yaml" },
    config = function()
      -- Use kubeconform as the linter (faster than kubeval)
      -- Add to your LSP config or use as a separate lint check
      vim.api.nvim_create_user_command("Kubeconform", function()
        local bufnr = vim.api.nvim_get_current_buf()
        local fname = vim.api.nvim_buf_get_name(bufnr)
        if vim.fn.filereadable(fname) and fname:match("%.ya?ml$") then
          local result = vim.fn.system({ "kubeconform", "-strict", "-verbose", fname })
          print(result)
        else
          print("Not a Kubernetes manifest file")
        end
      end, { nargs = 0 })
    end,
  },
}
