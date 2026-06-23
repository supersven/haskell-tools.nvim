describe('LSP client API', function()
  local HtConfig = require('haskell-tools.config.internal')
  local ht = require('haskell-tools')
  local Types = require('haskell-tools.types.internal')
  local test_cwd = vim.fn.getcwd() .. '/spec'
  it('Can load haskell-language-server config', function()
    local settings = ht.lsp.load_hls_settings(test_cwd)
    assert.are_not_same(HtConfig.hls.default_settings, settings)
  end)
  it('Falls back to default haskell-language-server config if none is found', function()
    local settings = ht.lsp.load_hls_settings(test_cwd, { settings_file_pattern = 'bla.json' })
    assert.same(HtConfig.hls.default_settings, settings)
  end)
  local hls_bin = Types.evaluate(HtConfig.hls.cmd)[1]
  if vim.fn.executable(hls_bin) ~= 0 then
    it('Can spin up haskell-language-server for Cabal project.', function()
      --- TODO: Figure out how to add tests for this
      print('TODO')
    end)
  end
end)

describe('Buffer reload handler (_on_buf_reload)', function()
  local stub = require('luassert.stub')
  local ht = require('haskell-tools')
  local LspHelpers = require('haskell-tools.lsp.helpers')

  it('calls force_refresh when HLS clients are attached', function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    local get_active = stub(LspHelpers, 'get_active_hls_clients')
    get_active.returns({ { id = 1, name = 'haskell-tools.nvim' } })
    local force_refresh = stub(vim.lsp.semantic_tokens, 'force_refresh')
    local start = stub(ht.lsp, 'start')

    ht.lsp._on_buf_reload(bufnr)

    assert.stub(force_refresh).was_called_with(bufnr)
    assert.stub(start).was_not_called()

    get_active:revert()
    force_refresh:revert()
    start:revert()
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it('restarts HLS when no clients are attached after reload', function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    local get_active = stub(LspHelpers, 'get_active_hls_clients')
    get_active.returns({})
    local force_refresh = stub(vim.lsp.semantic_tokens, 'force_refresh')
    local start = stub(ht.lsp, 'start')

    ht.lsp._on_buf_reload(bufnr)

    assert.stub(start).was_called_with(bufnr)
    assert.stub(force_refresh).was_not_called()

    get_active:revert()
    force_refresh:revert()
    start:revert()
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)
end)
