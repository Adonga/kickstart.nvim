return {
  {
    'mfussenegger/nvim-dap',
    config = function()
      local dap = require 'dap'

      -- Paths for codelldb from Mason
      local codelldb_path = vim.fn.stdpath 'data' .. '/mason/packages/codelldb/extension/adapter/codelldb'

      local liblldb_path = vim.fn.stdpath 'data' .. '/mason/packages/codelldb/extension/lldb/lib/liblldb.so'

      dap.adapters.codelldb = {
        type = 'server',
        port = '${port}',
        executable = {
          command = codelldb_path,
          args = { '--port', '${port}' },
          env = { LLDB_LAUNCHER = liblldb_path },
        },
      }

      --------------------------------------------------------------------
      --  Auto-detect Rust binary name (crate name) and remove prompts
      --------------------------------------------------------------------
      local function get_rust_executable()
        -- find crate name from Cargo.toml
        local cargo_toml = vim.fn.getcwd() .. '/Cargo.toml'
        local crate = vim.fn.system("grep '^name' " .. cargo_toml .. " | head -1 | cut -d '\"' -f2"):gsub('\n', '')

        if crate == '' then
          crate = vim.fn.fnamemodify(vim.fn.getcwd(), ':t') -- fallback to folder name
        end

        return vim.fn.getcwd() .. '/target/debug/' .. crate
      end

      dap.configurations.rust = {
        {
          name = 'Debug Rust (auto)',
          type = 'codelldb',
          request = 'launch',
          program = function()
            -- build first
            vim.fn.jobstart 'cargo build'
            return get_rust_executable() -- no prompt!
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
        },
      }
    end,
  },
}
