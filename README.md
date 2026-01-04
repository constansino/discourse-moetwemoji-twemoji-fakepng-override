

```md
# discourse-moetwemoji-twemoji-fakepng-override

<details open>
<summary><b>中文（点这里收起/展开）</b></summary>

## 这是什么？

这个插件用于**直接覆盖** Discourse 内置的 Twemoji 图片文件目录：

- 目标目录（容器内）：`/var/www/discourse/public/images/emoji/twemoji/*.png`

它会把你插件仓库里 `twemoji/` 目录下的**同名** `*.png` 复制过去覆盖（你的 `.png` 可以是“fakepng”：**内容是动画 AVIF，但扩展名仍为 .png**）。

✅ 适用场景：你希望 URL 保持不变，例如：

- `/images/emoji/twemoji/yum.png?v=xx`

但实际返回你自己的动图。

> 重要：这是“替换静态文件”的方式。  
> 它**不是**新增 Emoji Set，也**不是**导入 Custom Emoji。

---

## 前提条件（必须满足）

1. 你的站点正在使用 **Twemoji**（否则不会请求 `/images/emoji/twemoji/...`）。
2. 你的替换文件名必须与 Discourse 当前 `public/images/emoji/twemoji/` 内置文件名一致，例如：
   - `yum.png`
   - `broken_heart.png`
   - `1st_place_medal.png`
3. 你能使用 Discourse Docker（`/var/discourse`）并有权限进入容器执行 rake 任务。

---

## 仓库结构

把你的替换资源放到：

```

twemoji/
yum.png
broken_heart.png
1st_place_medal.png
...

````

文件名不需要改，只要保证和目标目录同名即可。

---

## Windows：把 fakepng 复制进仓库（不改名）

仓库自带脚本：`scripts/prepare-fakepng.ps1`

示例：

```powershell
$src = "C:\Users\1\love\moetwemoji72x72fakepng(avif)"
.\scripts\prepare-fakepng.ps1 -Source $src
````

脚本会把 `$src` 里的 `*.png` 原样复制到仓库的 `twemoji/`。

---

## 安装（Discourse Docker）

编辑宿主机文件：

* `/var/discourse/containers/app.yml`

在 `hooks: after_code:` 增加：

```yml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/<YOU>/discourse-moetwemoji-twemoji-fakepng-override.git
```

然后重建：

```bash
cd /var/discourse
./launcher rebuild app
```

---

## 应用覆盖（必须手动执行一次）

进入容器后，用 `discourse` 用户执行：

```bash
cd /var/discourse
./launcher enter app

su - discourse
cd /var/www/discourse

RAILS_ENV=production bundle exec rake moetwemoji_twemoji:status
RAILS_ENV=production bundle exec rake moetwemoji_twemoji:apply
```

### apply 做了什么？

* 从插件目录读取：`plugins/<本插件>/twemoji/*.png`
* 覆盖写入：`public/images/emoji/twemoji/*.png`
* 默认会做“一次性备份”到：

  * `public/images/emoji/twemoji.__moetwemoji_backup/`
  * 每个文件只会备份一次（已有备份则不重复备份）

---

## 回滚恢复原版（从备份恢复）

```bash
cd /var/discourse
./launcher enter app

su - discourse
cd /var/www/discourse

RAILS_ENV=production bundle exec rake moetwemoji_twemoji:restore
```

---

## 缓存提醒（非常重要）

`/images/emoji/twemoji/*.png?v=xx` 往往会被：

* 浏览器缓存
* CDN / 反向代理缓存

所以你替换了服务器文件后，用户可能还会看到旧图。

排查建议：

* 浏览器硬刷新：`Ctrl + F5`
* 清理站点缓存/CDN 缓存（如有）
* 等待缓存过期（取决于你的缓存策略）

---

## 常见问题

### 1) 为什么替换后没有变化？

最常见就是缓存。请先硬刷新 + 清 CDN 缓存。

### 2) 为什么我替换了文件但页面仍然请求的不是 /twemoji/？

说明你站点没有使用 Twemoji（或主题/设置改了 emoji set）。请先确认 Emoji Set。

### 3) 我只想覆盖一部分表情可以吗？

可以。你放进 `twemoji/` 的文件会覆盖同名文件；没放的不会动。

### 4) 如何查看当前 source/target/backup 数量？

运行：

```bash
RAILS_ENV=production bundle exec rake moetwemoji_twemoji:status
```

---

## 卸载说明

* 先运行 `restore` 回滚：

  ```bash
  RAILS_ENV=production bundle exec rake moetwemoji_twemoji:restore
  ```
* 然后从 `/var/discourse/containers/app.yml` 删除插件 clone 行并 rebuild：

  ```bash
  cd /var/discourse
  ./launcher rebuild app
  ```

---

## 许可证与署名（务必补全）

如果你的替换资源来自 Noto Emoji / OpenMoji / Twemoji 等项目，请在 `NOTICE` / `LICENSE` 中保留上游许可证与署名，并注明你的转换/改动（例如：转码、合成、压缩等）。

</details>

---

<details>
<summary><b>English (click to expand/collapse)</b></summary>

## What is this?

This plugin **overwrites** Discourse’s built-in Twemoji image directory:

* Target (inside the container): `/var/www/discourse/public/images/emoji/twemoji/*.png`

It copies your repo’s `twemoji/*.png` files (same filenames) into that directory.
Your `.png` files may be “fakepng” (e.g. **animated AVIF content with a `.png` extension**).

✅ Use case: keep the URL unchanged, e.g.

* `/images/emoji/twemoji/yum.png?v=xx`

but serve your own animated emoji file.

> Important: this is a **static file override** approach.
> It is **NOT** a new Emoji Set plugin and **NOT** a Custom Emoji importer.

---

## Requirements

1. Your forum must be using the **Twemoji** emoji set (otherwise it won’t request `/images/emoji/twemoji/...`).
2. Your replacement filenames must match Discourse’s existing Twemoji filenames, e.g.

   * `yum.png`
   * `broken_heart.png`
   * `1st_place_medal.png`
3. You are running Discourse via Docker (`/var/discourse`) and can enter the container to run rake tasks.

---

## Repo layout

Put your replacement assets in:

```
twemoji/
  yum.png
  broken_heart.png
  1st_place_medal.png
  ...
```

No renaming is required — just keep filenames identical to the target directory.

---

## Windows: copy your fakepng assets into the repo (no rename)

This repo includes: `scripts/prepare-fakepng.ps1`

Example:

```powershell
$src = "C:\Users\1\love\moetwemoji72x72fakepng(avif)"
.\scripts\prepare-fakepng.ps1 -Source $src
```

It copies `*.png` as-is into the repo `twemoji/` folder.

---

## Install (Discourse Docker)

Edit on the host:

* `/var/discourse/containers/app.yml`

Add under `hooks: after_code:`:

```yml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/<YOU>/discourse-moetwemoji-twemoji-fakepng-override.git
```

Rebuild:

```bash
cd /var/discourse
./launcher rebuild app
```

---

## Apply override (must be run manually once)

Enter the container and run as `discourse`:

```bash
cd /var/discourse
./launcher enter app

su - discourse
cd /var/www/discourse

RAILS_ENV=production bundle exec rake moetwemoji_twemoji:status
RAILS_ENV=production bundle exec rake moetwemoji_twemoji:apply
```

### What does `apply` do?

* Reads from: `plugins/<this_plugin>/twemoji/*.png`
* Overwrites into: `public/images/emoji/twemoji/*.png`
* By default, it creates a one-time backup at:

  * `public/images/emoji/twemoji.__moetwemoji_backup/`
  * Each file is backed up only once (no repeated backup overwrites).

---

## Restore original (rollback from backup)

```bash
cd /var/discourse
./launcher enter app

su - discourse
cd /var/www/discourse

RAILS_ENV=production bundle exec rake moetwemoji_twemoji:restore
```

---

## Caching (very important)

`/images/emoji/twemoji/*.png?v=xx` is often heavily cached by:

* browsers
* CDN / reverse proxies

So after you overwrite files on the server, users may still see old images.

Tips:

* Hard refresh: `Ctrl + F5`
* Purge CDN cache (if any)
* Wait for cache expiry (depends on your caching policy)

---

## FAQ

### 1) Why do I see no change after applying?

Caching is the #1 reason. Try hard refresh and purge CDN cache.

### 2) Why isn’t my site requesting `/twemoji/` at all?

You’re likely not using Twemoji as your emoji set. Confirm your emoji set first.

### 3) Can I override only some emojis?

Yes. Only filenames you provide in `twemoji/` are overwritten.

### 4) How do I check counts for source/target/backup?

Run:

```bash
RAILS_ENV=production bundle exec rake moetwemoji_twemoji:status
```

---

## Uninstall

* Restore originals first:

  ```bash
  RAILS_ENV=production bundle exec rake moetwemoji_twemoji:restore
  ```
* Remove the plugin clone line from `app.yml` and rebuild:

  ```bash
  cd /var/discourse
  ./launcher rebuild app
  ```

---

## License & attribution

If your assets are derived from upstream emoji projects (Noto Emoji / OpenMoji / Twemoji, etc.), keep upstream license terms and attribution in `NOTICE`/`LICENSE`, and document your modifications (conversion, compression, etc.).

</details>
```
::contentReference[oaicite:0]{index=0}
