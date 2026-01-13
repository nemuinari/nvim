# Neovim 設定概要

---

## 構成

- **エントリポイント**: `init.lua` → `lua/config/bootstrap.lua`

  - `lazy.nvim` の自動ブートストラップ
  - `options`/`keybinds` は `VimEnter` で遅延初期化し高速起動
  - 言語設定は LSP セットアップ時に適用（`lua/plugins/mason.lua`）

- **OS/プラットフォーム対応**: `lua/config/platform.lua`

  - クリップボード・シェル・clang-format スタイルの自動検出（キャッシュ化）

- **エディタ設定**: `lua/config/options.lua`

  - 基本オプション。クリップボード/シェルは `platform` 依存

- **キーマップ**: `lua/config/keybinds.lua`

  - リーダーキーは `lua/config/leader.lua`
  - ターミナル操作やパスコピー等の汎用マップ
  - Telescope キーマップはプラグイン側で遅延定義

- **言語別設定**: `lua/config/languages.lua`

  - 1 つの `FileType` autocmd でインデント等を一括管理
  - C/C++系は保存時に `clang-format` 適用

- **プラグイン管理**: `lua/plugins/init.lua`

  - `lazy.nvim` 用プラグイン一覧

- **LSP/フォーマット**: `lua/plugins/mason.lua`
  - LSP サーバは `BufReadPre` で初期化
  - インレイヒントはノーマル時表示・挿入時非表示（`<leader>ih` で切替）

---

## パフォーマンス最適化

- `lua/config/lazy.lua` で `performance.cache.enabled = true` など高速化
- 一部ランタイムプラグイン無効化（`gzip`, `matchit` など）
- autocmd 集約・プラグイン遅延ロード
- プラットフォーム検出はキャッシュ利用

---

## 主なプラグイン

- **Telescope**: `lua/plugins/telescope.lua` で設定。キーマップは遅延ロード
- **Copilot**: インライン補完。`nvim-cmp` 非使用
- **ToggleTerm**: キー押下時のみロード（`<C-t>` など）
- **Netrw**: 標準ファイラ無効（`:Lex`/`:Lexplore`）

---

## 起動時間計測

```bash
nvim --startuptime /tmp/nvim-startup.txt +qall
sed -n '1,120p' /tmp/nvim-startup.txt
```

---

## Windows/WSL Tips

- `clang-format` が PATH に無い場合は `vim.g.clang_format_cmd` で絶対パス指定
- クリップボード: WSL では `win32yank`、シェルは `pwsh`/`powershell` 優先
- 今後、WezTerm に移行予定

---

## キーマップ早見表

- **リーダーキー**: `<Space>`
- **Telescope**: `<leader>ff` (ファイル), `<leader>fg` (grep), `<leader>fb` (バッファ), `<leader>fh` (ヘルプ)
- **パスコピー**: `<leader>cr` (相対), `<leader>ca` (絶対), `<leader>cw` (Win 形式)
- **ターミナル**: `<C-t>` で開閉、端末内で `<Esc>`/`<C-hjkl>`
- **LSP**: `gd` (定義), `K` (ホバー), `<space>f` (フォーマット), `<space>rn` (リネーム), `<leader>ih` (インレイヒント切替)
- **Copilot CLI**: `<leader>cc` (タブ表示), `<leader>cx` (セッション終了)
- **Netrw**: `:Lex` / `:Lexplore`

---

## 終了

- `:q` で終了。失敗時は自動で `:quit!` にフォールバック

---
