# Discourse Moetwemoji Twemoji FakePNG Override

This repository is a file pack for overriding Discourse's built-in Twemoji PNG files with same-name replacements from `twemoji/`.

It is not a Ruby plugin and does not provide rake tasks.

## What It Contains

- `twemoji/*.png`: same-name replacement files
- `scripts/apply_to_discourse_twemoji_override.sh`: copies this pack into the current `discourse-emojis` gem directory
- `docker/run_hook.example.yml`: a `run` hook snippet for Discourse Docker so the override is re-applied after every rebuild/container start

Current file count:

- 412 override PNG files

## Apply To A Running Container Now

If you already have a running Discourse container and want the override to take effect immediately:

```bash
cd /var/discourse
./launcher enter app

/shared/emoji-overrides/discourse-moetwemoji-twemoji-fakepng-override/scripts/apply_to_discourse_twemoji_override.sh
```

The script:

- finds the active `discourse-emojis` gem path dynamically
- backs up each original file once into `twemoji.__moetwemoji_backup/`
- overwrites matching files from `twemoji/`

## Persistent Method For Future Rebuilds

The reliable method is:

1. Keep this repository under the persistent shared volume.
2. Run the apply script from a Discourse Docker `run` hook.

This works because `/shared` survives rebuilds, while the gem directory inside the container does not.

### 1. Put the repository under `/shared`

On the host:

```bash
mkdir -p /var/discourse/shared/standalone/emoji-overrides
cd /var/discourse/shared/standalone/emoji-overrides
git clone https://github.com/constansino/discourse-moetwemoji-twemoji-fakepng-override.git
```

Resulting path:

```text
/var/discourse/shared/standalone/emoji-overrides/discourse-moetwemoji-twemoji-fakepng-override
```

Inside the container this becomes:

```text
/shared/emoji-overrides/discourse-moetwemoji-twemoji-fakepng-override
```

### 2. Add a `run` hook in `/var/discourse/containers/app.yml`

Append this to the `run:` section, or merge it with your existing `run:` commands:

```yml
- exec: bash -lc 'script=/shared/emoji-overrides/discourse-moetwemoji-twemoji-fakepng-override/scripts/apply_to_discourse_twemoji_override.sh; if [ -x "$script" ]; then "$script"; else echo "Moetwemoji override script not found: $script"; fi'
```

You can also copy the ready-made snippet from `docker/run_hook.example.yml`.

### 3. Rebuild or restart normally

After future rebuilds, the container start process will run the script again and re-apply the overrides to the current gem path automatically.

## Why The Old "Persistent" Method Failed

Replacing files directly inside the running container is not persistent.

The target directory is typically something like:

```text
/var/www/discourse/vendor/bundle/ruby/<ruby-version>/gems/discourse-emojis-<version>/dist/emoji/twemoji
```

That path is recreated when Discourse is rebuilt or when the `discourse-emojis` gem version changes. A one-time manual replacement is therefore lost.

Using `/shared` + a `run` hook fixes that because:

- the source files live on the persistent volume
- the copy step runs again after each container recreation
- the script resolves the current gem path dynamically instead of assuming a fixed gem version

## Cache Notes

Emoji PNGs are usually cached by browsers and may also be cached by a CDN or reverse proxy.

If you do not see the new images immediately:

- hard refresh the browser
- purge CDN cache if applicable
- wait for cache expiry

## Rollback

The script stores one-time backups in:

```text
<target>.__moetwemoji_backup
```

On current Discourse builds this is usually:

```text
.../dist/emoji/twemoji.__moetwemoji_backup
```

To restore manually, copy files back from that backup directory into the active `twemoji/` directory.
