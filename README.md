# Neovim Configuration (2026.02)

## keymaps

### 共通

| Key         | Action                |
| :---------- | :-------------------- |
| `<Space>`   | Leader Key            |
| `<leader>e` | Oil (Floating) を開く |
| `-`         | Oil (Normal) を開く   |

### Oil.nvim 内 (explorer)

| Key         | Action                              |
| :---------- | :---------------------------------- |
| `<CR>`      | ファイルを開く / ディレクトリに入る |
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

## External Dependencies

```powershell
# Windows (PowerShell)
winget install BurntSushi.ripgrep.MSVC
```
