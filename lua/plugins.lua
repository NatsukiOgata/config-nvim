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
    'itchyny/lightline.vim',
    init = function()
      vim.o.laststatus = 2
      vim.g.lightline = {
        colorscheme = 'wombat',
        active = {
          left = {
            { 'mode', 'paste' },
            { 'gitbranch', 'readonly', 'filename', 'modified', 'relativedir' },
          },
        },
        component_function = {
          gitbranch = 'FugitiveHead',
          absolutedir = 'ShowAbsoluteDir',
          relativedir = 'ShowRelativeDir',
        },
        separator = { left = "", right = "" },
        subseparator = { left = "", right = "" },
      }
      vim.cmd([[
        function! ShowAbsoluteDir()
          let l:dir = expand('%:p:h')
          return '' != l:dir ? l:dir : '[Empty Dir]'
        endfunction
        function! ShowRelativeDir()
          let l:dir = expand('%:h')
          return '' != l:dir ? l:dir : '[Empty Dir]'
        endfunction
      ]])
    end,
  },
  'sheerun/vim-wombat-scheme',
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

  -- Fern (ファイルエクスプローラー) & NerdFont設定
  {
    'lambdalisue/fern.vim',
    cmd = { 'Fern' },
    dependencies = {
      'lambdalisue/nerdfont.vim',
      'lambdalisue/fern-renderer-nerdfont.vim',
      'lambdalisue/fern-bookmark.vim',
      'antoinemadec/FixCursorHold.nvim',
    },
    keys = {
      { ',f', '[fern]', remap = true },
      -- バッファディレクトリ
      { '[fern]d', ':<C-u>Fern . -reveal=%<CR>', silent = true },
      -- カレントディレクトリ
      { '[fern]c', ':<C-u>Fern .<CR>', silent = true },
      -- bookmark
      { ',bj', ':<C-u>Fern bookmark:///<CR>', silent = true },
    },
    init = function()
      vim.keymap.set('n', '[fern]', ':Fern', { noremap = true })
      -- Fern 起動前にレンダラーを nerdfont に指定しておく
      vim.g['fern#renderer'] = 'nerdfont'
    end,
  },

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
    'junegunn/vim-easy-align',
    keys = {
      { 'ga', '<Plug>(EasyAlign)', mode = { 'n', 'x' } },
    },
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

  -- AI補助プラグイン
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
            accept = "<Tab>",   -- 【Tab】で提案をすべて受け入れる
            accept_word = "<M-w>", -- 【Alt + w】で1語だけ受け入れる
            accept_line = "<M-l>", -- 【Alt + l】で1行だけ受け入れる
            next = "<M-]>",     -- 【Alt + ]】で次の候補へ
            prev = "<M-[>",     -- 【Alt + [】で前の候補へ
            dismiss = "<C-]>",  -- 【Ctrl + ]】で提案を閉じる
          },
        },
        panel = { enabled = false }, -- ポップアップパネルは不要なため無効化

        -- 2. Next Edit Suggestion (NES: 次の編集提案) の設定
        nes = {
          enabled = true,
          keymap = {
            -- 提案がある場合、このキーで「提案を受け入れて該当箇所にジャンプ」します
            -- 例: <leader>cp (Space + c + p など)
            accept_and_goto = "<leader>cp", 
          },
        },
      })
    end,
  },
}
