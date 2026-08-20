return {
	{
		"pojokcodeid/auto-conform.nvim",
		event = "VeryLazy",
		optional = true,
		opts = function(_, opts)
			vim.list_extend(opts.formatters, {
				["markdown-toc"] = {
					condition = function(_, ctx)
						for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
							if line:find("<!%-%- toc %-%->") then
								return true
							end
						end
					end,
				},
				["markdownlint-cli2"] = {
					condition = function(_, ctx)
						local diag = vim.tbl_filter(function(d)
							return d.source == "markdownlint"
						end, vim.diagnostic.get(ctx.buf))
						return #diag > 0
					end,
				},
			})
			vim.list_extend(opts.formatters_by_ft, {
				["markdown"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
				["markdown.mdx"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
			})
		end,
	},
	{
		"williamboman/mason.nvim",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, { "markdownlint-cli2", "markdown-toc" })
		end,
	},
	{
		"pojokcodeid/auto-lint.nvim",
		event = "VeryLazy",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, { "markdownlint-cli2" })
		end,
		config = function(_, opts)
			require("auto-lint").setup(opts)
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, { "marksman" })
		end,
	},
	-- Markdown preview
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = function()
			require("lazy").load({ plugins = { "markdown-preview.nvim" } })
			vim.fn["mkdp#util#install"]()
		end,
		init = function()
			-- Enable semua renderer: mermaid, katex, flowchart, sequence,
			-- graphviz (viz.js), mhchem, dll.
			vim.g.mkdp_preview_options = {
				mkit = {},
				katex = {},
				uml = {},
				maid = {}, -- mermaid diagram
				disable_sync_scroll = 0,
				sync_scroll_type = "middle",
				hide_yaml_meta = 1,
				sequence_diagrams = {},
				flowchart_diagrams = {},
				content_editable = false,
				disable_filename = 0,
				toc = {},
			}
			-- Buka otomatis di browser, tetap update walau pindah buffer
			vim.g.mkdp_auto_close = 0
			vim.g.mkdp_theme = "dark"
		end,
		keys = {
			{
				"<leader>Cp",
				ft = "markdown",
				"<cmd>MarkdownPreviewToggle<cr>",
				desc = "Markdown Preview",
			},
		},
		config = function()
			vim.cmd([[do FileType]])
		end,
	},

	{
		"MeanderingProgrammer/render-markdown.nvim",
		opts = {
			code = {
				sign = false,
				width = "block",
				right_pad = 1,
			},
			heading = {
				sign = false,
				icons = {},
			},
		},
		ft = { "markdown", "norg", "rmd", "org" },
		config = function(_, opts)
			require("render-markdown").setup(opts)
		end,
		keys = {
			{ "<leader>C", "", desc = "  Markdown" },
			{
				"<leader>Cr",
				"<cmd>RenderMarkdown<cr>",
				desc = "Render Markdown",
			},
		},
	},
}
