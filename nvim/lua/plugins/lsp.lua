return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      -- Ensure bicep-lsp is configured
      bicep = {},
    },
  },
}
