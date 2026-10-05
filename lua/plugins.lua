return {
  --------------------------------------------------
  -- UI / 基本プラグイン (旧 dein.toml)
  --------------------------------------------------
  'airblade/vim-rooter',
  {
    'fuenor/qfixhowm',
    init = function()
      vim.g.QFix_Height = 6
      vim.g.QFix_PreviewHeight = 24
      vim.g.QFixHowm_Key = ','
      vim.g.QFixHowm_KeyB = 'h'
      vim.g.QFixHowm_CalendarWinCmd = 'vertical botright'
      -- ripgrepを使う（PATHは通してある前提）
      vim.g.mygrepprg = 'rg'
      -- 実行時のオプションをripgrep用に変更（GNU Grepと同じ出力になるように）
      vim.g.MyGrepcmd_useropt = '-nH --no-heading --color never'
      vim.g.MyGrepcmd_regexp = ''
      vim.g.MyGrepcmd_regexp_ignore = '-i'
      vim.g.MyGrepcmd_fix = '-F'
      vim.g.MyGrepcmd_fix_ignore = '-F -i'
      vim.g.MyGrepcmd_recursive = ''
      -- gipgrepにファイルパターンとして「*」「*.*」を渡したらエラーになったのでその対策
      vim.g.MyGrep_GrepFilePattern = '.'
    end,
  },
  'ryanoasis/vim-devicons',
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- アイコン表示用（任意）
    config = function()
      -- 相対ディレクトリを取得する Lua 関数
      local function show_relative_dir()
        local dir = vim.fn.expand("%:h")
        return dir ~= "" and dir or "[Empty Dir]"
      end

      require("lualine").setup({
        options = {
          theme = "sonokai", 
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          globalstatus = false,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { 
            "branch", 
            { "filename", file_status = true, path = 0 } -- 0: ファイル名のみ
          },
          lualine_c = { 
            show_relative_dir -- 関数をそのままコンポーネントとして渡せます
          },
          lualine_x = { "copilot", "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },
  { 'AndreM222/copilot-lualine' },
  {
    'sainnhe/sonokai',
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.sonokai_disable_italic_comment = 1
      vim.g.sonokai_enable_italic = 0
      vim.cmd.colorscheme('sonokai')

      vim.api.nvim_set_hl(0, "@attribute.negation", {
        fg = "#000000",
        bg = "#ffff00",
      })
    end,
  },
  'editorconfig/editorconfig-vim',
  'rhysd/neovim-component',
  {
    'jiangmiao/auto-pairs',
    init = function()
      -- 同じ行のペアのみジャンプしたい
      vim.g.AutoPairsMultilineClose = 0
    end,
  },
  'yuttie/comfortable-motion.vim',

  --------------------------------------------------
  -- 遅延読み込みプラグイン (旧 dein_lazy.toml)
  --------------------------------------------------

  -- Yazi (TUIファイルマネージャー連携)
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    keys = {
      -- カレントファイル
      {
        ",fd",
        function()
          require("yazi").yazi()
        end,
        desc = "Open yazi at the current file",
      },
      -- ワーキングディレクトリ
      {
        ",fw",
        function()
          require("yazi").yazi(nil, vim.fn.getcwd())
        end,
        desc = "Open yazi in working directory",
      },
    },
    opts = {
      open_for_directories = false,
      keymaps = {
        show_help = "<f1>",
      },
    },
  },
  -- メモ: プレビュー用のfile.exeのパスを環境変数に設定する
  -- [Environment]::SetEnvironmentVariable("YAZI_FILE_ONE", "$env:USERPROFILE\scoop\apps\git\current\usr\bin\file.exe", "User")

  -- fzf 関連
  {
    'junegunn/fzf',
    build = './install --bin',
  },
  {
    'junegunn/fzf.vim',
    dependencies = { 'fzf' },
    cmd = { 'Files', 'GFiles', 'Snippets', 'Buffers' },
    keys = {
      -- ファイル一覧(サブディレクトリも対象)
      { ',fr', ':<C-u>Files<CR>', silent = true },
      -- ファイル一覧(Git)
      { ',fg', ':<C-u>GFiles<CR>', silent = true },
      -- スニペット
      { ',sn', ':<C-u>Snippets<CR>', silent = true },
      -- バッファ一覧
      { ',bl', ':<C-u>Buffers<CR>', silent = true },
    },
    config = function()
      vim.g.fzf_layout = { window = '-tabnew' }
    end,
  },
  {
    'pbogut/fzf-mru.vim',
    dependencies = { 'fzf' },
    cmd = { 'FZFMru' },
    keys = {
      -- 最近使用したファイル一覧
      { ',fm', ':<C-u>FZFMru<CR>', silent = true },
    },
    config = function()
      vim.g.fzf_mru_relative = 0
    end,
  },

  -- Quickrun & Asyncrun
  {
    'skywind3000/asyncrun.vim',
    cmd = { 'AsyncRun' },
    keys = {
      { ',r', '[asyncrun]', remap = true },
    },
    init = function()
      vim.keymap.set('n', '[asyncrun]', ':AsyncRun ', { noremap = true })
      vim.cmd([[
        " Job終了時にquickfixを開く
        autocmd User AsyncRunStop call asyncrun#quickfix_toggle(8, 1)
      ]])
    end,
    config = function()
      vim.g.asyncrun_bell = 1
    end,
  },

  -- EasyMotion / EasyAlign
  {
    'easymotion/vim-easymotion',
    keys = {
      { 's', '<Plug>(easymotion-s2)', mode = 'n' },
    },
    config = function()
      -- デフォルトのキーマッピングを無効に
      vim.g.EasyMotion_do_mapping = 0
      -- 検索時、大文字小文字を区別しない
      vim.g.EasyMotion_smartcase = 1
    end,
  },
  {
    "echasnovski/mini.align",
    version = "*",
    config = function()
      require("mini.align").setup({
        mappings = {
          start = "",
          start_with_preview = "ga",
        },
      })
    end,
  },

  -- Git / Tools
  {
    'kyoh86/vim-ripgrep',
    cmd = { 'Rg' },
    config = function()
      vim.cmd('command! -nargs=+ -complete=file Rg :call ripgrep#search(<q-args>)')
    end,
  },
  { 'tpope/vim-fugitive', event = 'BufReadPost' },
  { 'buggo/gitv', cmd = { 'Gitv' } },
  { 'cohama/agit.vim', cmd = { 'Agit' } },
  {
    'vim-scripts/gtags.vim',
    event = 'BufReadPost',
    keys = {
      -- cscope_maps.vim like
      -- Show definetion of function cursor word on quickfix
      { '<C-\\>s', ":<C-u>exe('Gtags '.expand('<cword>'))<CR>", mode = 'n' },
      -- Show reference of cursor word on quickfix
      { '<C-\\>c', ":<C-u>exe('Gtags -r '.expand('<cword>'))<CR>", mode = 'n' },
      -- Show search on quickfix
      { '<C-\\>e', ':<C-u>Gtags -g ', mode = 'n' },
    },
    config = function()
      vim.g.Gtags_Auto_Map = 0
      vim.g.Gtags_OpenQuickfixWindow = 1
    end,
  },

  -- ALE / CoC
  {
    'w0rp/ale',
    ft = { 'javascript', 'php' },
    config = function()
      -- 保存時のみ実行する
      vim.g.ale_lint_on_text_changed = 0
      -- 表示に関する設定
      vim.g.ale_sign_column_always = 1
      vim.g.ale_sign_error = "\u{f06a}"
      vim.g.ale_sign_warning = "\u{f071}"
      vim.g.ale_echo_msg_format = '[%linter%]%code: %%s'
      vim.cmd([[
        highlight link ALEErrorSign Tag
        highlight link ALEWarningSign StorageClass
        " Ctrl + kで次の指摘へ、Ctrl + jで前の指摘へ移動
        nmap <silent> <C-k> <Plug>(ale_previous_wrap)
        nmap <silent> <C-j> <Plug>(ale_next_wrap)
      ]])
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    tag = "v0.9.2", -- 従来の configs / :TS* コマンドがそのまま使えるバージョンに固定
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { 
          "c", "cpp", "c_sharp", "javascript", "typescript", "java", "go", "rust", "python", "lua"
        },
        auto_install = true,
        highlight = {
          enable = true,
        },
      })
    end,
  },

  -- Utility
  'kana/vim-operator-user',
  {
    'rhysd/vim-clang-format',
    dependencies = { 'kana/vim-operator-user' },
    event = 'BufReadPost',
    config = function()
      vim.g['clang_format#detect_style_file'] = 1
      vim.g['clang_format#command'] = 'clang-format-6.0'
    end,
  },
  { 'dhruvasagar/vim-table-mode', cmd = { 'TableModeToggle' } },
  {
    'kana/vim-altr',
    cmd = { 'A' },
    config = function()
      -- ヘッダファイルとソースファイルを切り替える
      vim.cmd('command! A call altr#forward()')
      vim.cmd("call altr#define('inc/%.h', 'src/%.cpp')")
    end,
  },
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "DiffviewOpen" },
  },
  {
    "ZSaberLv0/ZFVimDirDiff",
    dependencies = {
      "ZSaberLv0/ZFVimJob",
    },
    cmd = { "ZFDirDiff" },
  },
  { 'vim-scripts/copypath.vim', cmd = { 'CopyFileName', 'CopyPath' } },
  { 'vim-scripts/BlockDiff', cmd = { 'BlockDiff1', 'BlockDiff2' } },

  --------------------------------------------------
  -- GitHub Copilot (copilot.lua) & NES (Next Edit Suggestion)
  --------------------------------------------------
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    dependencies = {
      -- NES機能のためにバックエンドとなるLSPを管理するプラグイン
      {
        "copilotlsp-nvim/copilot-lsp",
        init = function()
          -- デバウンス時間（ミリ秒）: 編集後にNESの提案を計算するまでの待機時間
          vim.g.copilot_nes_debounce = 500
        end,
      },
    },
    config = function()
      require("copilot").setup({
        -- 1. 通常のインラインコード補完（ゴーストテキスト形式）
        suggestion = {
          enabled = true,
          auto_trigger = true, -- 入力中に自動で候補を表示
          debounce = 75,
          keymap = {
            accept = "<C-y>",      -- Vim標準の補完確定と統一 (インサート移動 <C-l> との衝突回避)
            accept_word = "<C-f>", -- Forward 1 Word
            accept_line = "<C-j>", -- Down 1 Line
            next = "<M-]>",        -- 【Alt + ]】で次の候補へ
            prev = "<M-[>",        -- 【Alt + [】で前の候補へ
            dismiss = "<C-e>",     -- Vim標準の補完キャンセルと統一
          },
        },

        -- ポップアップパネルを無効化
        panel = {
          enabled = false,
        },

        -- 2. Next Edit Suggestion (NES: 次の編集提案) の設定
        nes = {
          enabled = true,
          keymap = {
            accept_and_goto = ",a", -- カンマ派生 (,a) でジャンプ＆適用
            accept = false,         -- 移動なしの適用は無効化
            dismiss = "<Esc><Esc>",
          },
        },

        -- 無効化したいファイルタイプを指定
        filetypes = {
          help = false,
          gitrebase = false,
          ["."] = false,
        },
      })
    end,
  },
}
