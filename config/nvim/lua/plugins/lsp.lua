return {
	{
		"neovim/nvim-lspconfig",
		cmd = "LspInfo",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "j-hui/fidget.nvim", opts = {} },
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			require("mason").setup({})
			local mason_lspconfig = require("mason-lspconfig")

			vim.diagnostic.config({
				virtual_text = {
					source = false,
					prefix = "●", -- Could be '■', '▎', 'x'
					-- spacing = 4,
					-- severity_limit = "Warning",
				},
				signs = true,
				underline = true,
				update_in_insert = false,
				severity_sort = true,
				float = {
					focusable = false,
					style = "minimal",
					border = "rounded",
					source = false,
					header = "",
					prefix = "",
				},
			})

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "fish",
				callback = function()
					vim.lsp.start({
						name = "fish-lsp",
						cmd = { "fish-lsp", "start" },
						cmd_env = { fish_lsp_show_client_popups = true },
					})
				end,
			})

			mason_lspconfig.setup({
				ensure_installed = { "lua_ls", "ts_ls", "jsonls", "bashls", "marksman", "yamlls", "texlab", "tofu_ls" },
				automatic_enable = true,
			})

			vim.lsp.config["tofu_ls"] = {
				filetypes = { "terraform", "terraform-vars" },
			}
		end,
	},
	{
		"nvimdev/lspsaga.nvim",
		after = "nvim-lspconfig",
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				desc = "LSP actions",
				callback = function(event)
					local opts = { buffer = event.buf, noremap = true }
					vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<cr>", opts)
					vim.keymap.set("n", "gd", "<cmd>Lspsaga goto_definition<cr>", opts)
					vim.keymap.set("n", "gi", "<cmd>Lspsaga finder<cr>", opts)
					vim.keymap.set("n", "go", "<cmd>Lspsaga goto_type_definition<cr>", opts)
					vim.keymap.set("n", "gr", "<cmd>Lspsaga rename<cr>", opts)
					vim.keymap.set("n", "ca", "<cmd>Lspsaga code_action<cr>", opts)
				end,
			})

			require("lspsaga").setup({
				symbol_in_winbar = {
					enable = false,
				},
				lightbulb = {
					virtual_text = false,
				},
			})
		end,
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	},
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
}
