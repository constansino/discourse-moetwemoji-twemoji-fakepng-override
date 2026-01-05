
![crab](https://github.com/user-attachments/assets/5d0f7862-db85-43f0-92ca-0547d0b852bf)
![disguised_face](https://github.com/user-attachments/assets/b2d5ceb7-2cd1-41de-867b-e9ad0ca2ff45)
![drooling_face](https://github.com/user-attachments/assets/804532fb-3111-4587-bc59-6f76dcf48915)
![globe_showing_americas](https://github.com/user-attachments/assets/7dece8c5-e497-4d28-87c5-5c02ff570677)
![PixPin_2026-01-04_22-04-17](https://github.com/user-attachments/assets/eaa65953-db93-4e82-a9cb-241cf65e62f5)


# Discourse Moetwemoji Twemoji FakePNG Override

This plugin overrides the default Twemoji set in Discourse with Moetwemoji.

## ⚠️ Important Note

**This is the Override Version.**
This plugin will **replace** the default system emojis with Moetwemoji.

> If you want to add Moetwemoji as an **additional** emoji pack without replacing the default set, please use the **[Discourse Moetwemoji Pack](https://github.com/constansino/discourse-moetwemoji-pack)** instead.

## Requirements

1. Your forum must be using the **Twemoji** emoji set (otherwise it won’t request `/images/emoji/twemoji/...`).
2. Your replacement filenames must match Discourse’s existing Twemoji filenames, e.g.

   * `yum.png`
   * `broken_heart.png`
   * `1st_place_medal.png`
3. You are running Discourse via Docker (`/var/discourse`) and can enter the container to run rake tasks.

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
          - git clone https://github.com/constansino/discourse-moetwemoji-twemoji-fakepng-override.git
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



# Manual Installation Guide (Override Version)

This guide explains how to **manually install and apply** the
`discourse-moetwemoji-twemoji-fakepng-override` plugin **inside a running Discourse container**, and clarifies why a full rebuild is **not strictly required** for the override version.

---

## 1. Enter the Discourse Container

On your server, go to the Discourse Docker directory (usually `/var/discourse`) and enter the running container:

```
cd /var/discourse
./launcher enter app

```

You should now be inside the container shell.

---

## 2. Clone the Override Plugin Manually

Navigate to the plugins directory and clone the repository:

```
cd /var/www/discourse/plugins
git clone https://github.com/constansino/discourse-moetwemoji-twemoji-fakepng-override.git

```

Verify that the directory exists:

```
ls discourse-moetwemoji-twemoji-fakepng-override

```

---

## 3. Apply the Emoji Override

Go back to the Discourse root directory:

```
su - discourse
cd /var/www/discourse

```

Check the current status (optional but recommended):

```
RAILS_ENV=production bundle exec rake moetwemoji_twemoji:status

```

Apply the override:

```
RAILS_ENV=production bundle exec rake moetwemoji_twemoji:apply

```

If the command finishes without errors, the Twemoji PNG files have been replaced by Moetwemoji.

---

## 4. Important Notes About Rebuilds (Persistence)

### ❗ No rebuild is required to make the override work

This **override version** works by directly replacing files in the running container.
Therefore:

* ✅ **You do NOT need to run `./launcher rebuild app`**

* ✅ Changes take effect immediately after running the rake task

### ⚠️ But the change is NOT persistent

Because this is done **inside the container filesystem**:

* Any future `./launcher rebuild app`

* Or container recreation / upgrade

will **wipe the changes**, and the emoji override will be lost.

👉 If you need **persistence across rebuilds**, you must install the plugin via `app.yml` hooks and rebuild properly.

---

## 5. Clear CDN and Browser Cache (Very Important)

After applying the override, emoji may still appear unchanged due to caching.

### 5.1 Clear CDN Cache (e.g. Cloudflare)

If you are using a CDN such as **Cloudflare**:

* Purge cache for:

  * `/images/emoji/*`

  * or perform a **full cache purge** if necessary

Otherwise, the old Twemoji PNG files may still be served.

### 5.2 Clear Browser Cache

On the client side:

* Hard refresh the page (`Ctrl + F5` / `Cmd + Shift + R`)

* Or clear browser cache

* Or test in an incognito/private window

Until both CDN and browser caches are cleared, emoji changes may not be visible.

---

## 6. Summary

* This override plugin can be **installed and applied without rebuilding**

* Manual installation is useful for:

  * Testing

  * Temporary usage

  * Debugging

* The downside is **lack of persistence**

* Always clear **CDN cache + browser cache** after applying emoji overrides

---
