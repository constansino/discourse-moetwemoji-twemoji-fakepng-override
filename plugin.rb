# frozen_string_literal: true

# name: discourse-moetwemoji-twemoji-fakepng-override
# about: Replaces Discourse's built-in /public/images/emoji/twemoji/*.png with your own (optionally animated) PNG files (commonly "fakepng" AVIF-in-PNG-extension).
# version: 0.1.0
# authors: your-name
# url: https://github.com/yourname/discourse-moetwemoji-twemoji-fakepng-override

enabled_site_setting :moetwemoji_twemoji_override_enabled

after_initialize do
  # Default behavior is SAFE: do nothing automatically.
  # Apply/restore is done via rake tasks:
  #   rake moetwemoji_twemoji:apply
  #   rake moetwemoji_twemoji:restore
end
