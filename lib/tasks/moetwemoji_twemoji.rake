# frozen_string_literal: true

require "fileutils"
require "digest"

namespace :moetwemoji_twemoji do
  def ensure_enabled!
    unless SiteSetting.respond_to?(:moetwemoji_twemoji_override_enabled) && SiteSetting.moetwemoji_twemoji_override_enabled
      puts "Plugin disabled: moetwemoji_twemoji_override_enabled = false"
      exit 1
    end
  end

  def plugin_root
    File.expand_path("../../..", __FILE__)
  end

  def source_dir
    subdir = if SiteSetting.respond_to?(:moetwemoji_twemoji_source_subdir)
      SiteSetting.moetwemoji_twemoji_source_subdir.to_s
    else
      "twemoji"
    end
    File.join(plugin_root, subdir)
  end

  def target_dir
    File.join(Rails.root, "public", "images", "emoji", "twemoji")
  end

  def backup_dir
    File.join(Rails.root, "public", "images", "emoji", "twemoji.__moetwemoji_backup")
  end

  def make_backup?
    return true unless SiteSetting.respond_to?(:moetwemoji_twemoji_make_backup)
    SiteSetting.moetwemoji_twemoji_make_backup
  end

  def png_files(dir)
    Dir.glob(File.join(dir, "*.png")).sort
  end

  desc "Show counts for source/target/backup"
  task status: :environment do
    ensure_enabled!

    s = source_dir
    t = target_dir
    b = backup_dir

    puts "Source: #{s} (exists=#{File.directory?(s)})"
    puts "Target: #{t} (exists=#{File.directory?(t)})"
    puts "Backup: #{b} (exists=#{File.directory?(b)})"
    puts ""

    if File.directory?(s)
      puts "Source PNG files: #{png_files(s).length}"
    end
    if File.directory?(t)
      puts "Target PNG files: #{png_files(t).length}"
    end
    if File.directory?(b)
      puts "Backup PNG files: #{png_files(b).length}"
    end
    puts ""
    puts "Tip: this override only affects the built-in Twemoji set (files in /images/emoji/twemoji/...)."
  end

  desc "Apply override: copy plugin twemoji/*.png into public/images/emoji/twemoji (optionally making a backup first)"
  task apply: :environment do
    ensure_enabled!

    s = source_dir
    t = target_dir
    b = backup_dir

    unless File.directory?(s)
      raise "Source directory not found: #{s} (put your replacement *.png files there)"
    end

    FileUtils.mkdir_p(t)

    files = png_files(s)
    if files.empty?
      raise "No .png files found in source: #{s}"
    end

    if make_backup?
      FileUtils.mkdir_p(b)
      # one-time backup: only back up target files that exist and aren't backed up yet
      files.each do |src|
        name = File.basename(src)
        dst = File.join(t, name)
        next unless File.exist?(dst)
        bak = File.join(b, name)
        next if File.exist?(bak)
        FileUtils.cp(dst, bak)
      end
      puts "Backup done (one-time per file) into: #{b}"
    else
      puts "Backup skipped (moetwemoji_twemoji_make_backup=false)"
    end

    replaced = 0
    created  = 0

    files.each do |src|
      name = File.basename(src)
      dst = File.join(t, name)

      if File.exist?(dst)
        replaced += 1
      else
        created += 1
      end

      # Preserve mtime to reduce churn; but content changes are intended.
      FileUtils.cp(src, dst, preserve: true)
    end

    puts "Applied override to: #{t}"
    puts "  source files: #{files.length}"
    puts "  replaced:     #{replaced}"
    puts "  created:      #{created}"
    puts ""
    puts "IMPORTANT: browsers/CDNs may cache /images/emoji/twemoji/*.png heavily."
    puts "After applying, test with a hard refresh (Ctrl+F5) or clear CDN cache if you use one."
  end

  desc "Restore from backup: copy twemoji.__moetwemoji_backup/*.png back into public/images/emoji/twemoji"
  task restore: :environment do
    ensure_enabled!

    t = target_dir
    b = backup_dir

    unless File.directory?(b)
      raise "Backup directory not found: #{b} (did you run rake moetwemoji_twemoji:apply with backup enabled?)"
    end

    FileUtils.mkdir_p(t)
    files = png_files(b)
    if files.empty?
      raise "No .png files found in backup: #{b}"
    end

    files.each do |src|
      name = File.basename(src)
      dst = File.join(t, name)
      FileUtils.cp(src, dst, preserve: true)
    end

    puts "Restored #{files.length} files from backup to: #{t}"
    puts "Again, you may need a hard refresh (Ctrl+F5) due to caching."
  end
end
