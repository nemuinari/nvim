# Neovim Configuration (2026.02)

## keymaps

### 共通

| Key          | Action                |
| :----------- | :-------------------- |
| `<Space>`    | Leader Key            |
| `<leader>e`  | Oil (Floating) を開く |
| `<Esc><Esc>` | 検索ハイライトを消す  |

### Oil.nvim 内 (explorer)

| Key         | Action                              |
| :---------- | :---------------------------------- |
| `<CR>`      | ファイルを開く / ディレクトリに入る |
| `<C-p>`     | プレビュー                          |
| `<C-c>`     | 閉じる                              |
| `<C-l>`     | リフレッシュ                        |
| `-`         | 親ディレクトリへ移動                |
| `_`         | カレントディレクトリ (CWD) を開く   |
| `g.`        | 隠しファイルの表示/非表示           |
| `<leader>g` | このディレクトリ内を Grep 検索      |

### Telescope (History/Buffer/Help)

| Key          | Action                      |
| :----------- | :-------------------------- |
| `<leader>fr` | 最近開いたファイル (Recent) |
| `<leader>fb` | バッファ一覧                |
| `<leader>fh` | ヘルプ検索                  |

### Dashboard

| Key | Action         |
| :-- | :------------- |
| `n` | New file       |
| `f` | Oil (Floating) |
| `r` | Recent files   |
| `l` | Lazy Manager   |
| `q` | Quit           |

### パスコピー

| Key          | Action                  |
| :----------- | :---------------------- |
| `<leader>cr` | 相対パスをコピー        |
| `<leader>ca` | 絶対パスをコピー        |
| `<leader>cw` | Windows形式パスをコピー |

### LSP

| Key         | Action       |
| :---------- | :----------- |
| `gd`        | 定義へ移動   |
| `K`         | Hover 表示   |
| `<space>f`  | フォーマット |
| `<space>rn` | リネーム     |

### Terminal Mode

| Key     | Action              |
| :------ | :------------------ |
| `<Esc>` | Normal モードへ戻る |
| `<C-h>` | 左ウィンドウへ移動  |
| `<C-j>` | 下ウィンドウへ移動  |
| `<C-k>` | 上ウィンドウへ移動  |
| `<C-l>` | 右ウィンドウへ移動  |

---

## Commands

| Command | Action                       |
| :------ | :--------------------------- |
| `:Q`    | 未保存バッファを整理して終了 |

---

## LSP / Tools

- LSP servers: clangd, pyright, rust-analyzer, lua_ls
- Mason tools: stylua, prettier, black, isort, rustfmt, clang-format, shfmt, taplo
- Inlay hints: Neovim 0.10+ で自動有効

---

## External Dependencies

```powershell
# Windows (PowerShell)
winget install BurntSushi.ripgrep.MSVC
```
