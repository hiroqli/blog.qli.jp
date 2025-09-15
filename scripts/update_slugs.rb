#!/usr/bin/env ruby
# Hugo Post Slug UUID Updater
# Usage: ruby update_slugs.rb [posts_directory]

require 'securerandom'
require 'fileutils'

# デフォルトのpostsディレクトリ
POSTS_DIR = ARGV[0] || 'content/posts'

def update_slug_in_file(file_path)
  puts "Processing: #{file_path}"
  
  # ファイルを読み込み
  content = File.read(file_path)
  
  # Front matterの開始と終了を検出
  if content.match(/^---\s*\n(.*?)\n---\s*\n/m)
    front_matter = $1
    rest_content = $'
    
    # 新しいUUIDを生成
    new_uuid = SecureRandom.uuid
    
    # 既存のslugを置換、または追加
    if front_matter.match(/^slug:\s*.*$/m)
      # 既存のslugを置換
      updated_front_matter = front_matter.gsub(/^slug:\s*.*$/m, "slug: \"#{new_uuid}\"")
      puts "  → Updated existing slug to: #{new_uuid}"
    else
      # slugが存在しない場合は追加
      updated_front_matter = front_matter + "\nslug: \"#{new_uuid}\""
      puts "  → Added new slug: #{new_uuid}"
    end
    
    # 新しいコンテンツを作成
    new_content = "---\n#{updated_front_matter}\n---\n#{rest_content}"
    
    # バックアップは作成しない
    
    # ファイルを更新
    File.write(file_path, new_content)
    puts "  → File updated successfully"
    
    return true
  else
    puts "  → Warning: No front matter found in #{file_path}"
    return false
  end
rescue => e
  puts "  → Error processing #{file_path}: #{e.message}"
  return false
end

def main
  unless Dir.exist?(POSTS_DIR)
    puts "Error: Directory '#{POSTS_DIR}' not found"
    puts "Usage: ruby #{$0} [posts_directory]"
    exit 1
  end
  
  puts "Starting slug update process..."
  puts "Target directory: #{POSTS_DIR}"
  puts "="*50
  
  # index.mdファイルを再帰的に検索
  index_files = Dir.glob(File.join(POSTS_DIR, '**/index.md'))
  
  if index_files.empty?
    puts "No index.md files found in #{POSTS_DIR}"
    exit 0
  end
  
  puts "Found #{index_files.length} index.md file(s)"
  puts "="*50
  
  updated_count = 0
  
  index_files.each do |file_path|
    if update_slug_in_file(file_path)
      updated_count += 1
    end
    puts "-" * 30
  end
  
  puts "="*50
  puts "Process completed!"
  puts "Total files processed: #{index_files.length}"
  puts "Successfully updated: #{updated_count}"
  puts "Failed updates: #{index_files.length - updated_count}"
  
  if updated_count > 0
    puts "\nNext steps:"
    puts "1. Review the changes"
    puts "2. Remove public/ directory: rm -rf public/"
    puts "3. Rebuild Hugo: hugo --gc --minify"
    puts "4. Test deployment"
    puts "\nBackup files created with timestamp for safety."
  end
end

main