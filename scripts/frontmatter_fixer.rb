#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'

class FrontmatterFixer
  def fix_file(file_path)
    content = File.read(file_path, encoding: 'utf-8')
    
    # 壊れたパターンを修復
    # 例: ---\n---\ntitle: xxx を ---\ntitle: xxx に修正
    
    if content.match(/\A---\s*\n---\s*\n(.*?\n)---\s*\n(.*)$/m)
      # パターン1: ---\n---\ntitle:... の形
      frontmatter_content = $1
      body = $2
      
      fixed_content = "---\n#{frontmatter_content}---\n#{body}"
      
      File.write(file_path, fixed_content, encoding: 'utf-8')
      puts "✅ 修復: #{File.basename(file_path)}"
      return true
      
    elsif content.match(/\A---\s*\n(.*?\nslug: "[^"]*\.\.\."\s*)\n---\s*\n(.*)$/m)
      # パターン2: slug が切り詰められている場合
      frontmatter_content = $1
      body = $2
      
      # 切り詰められたslugを修正
      fixed_frontmatter = frontmatter_content.gsub(/slug: "([^"]*)\.\.\."/, 'slug: "\1"')
      
      fixed_content = "---\n#{fixed_frontmatter}\n---\n#{body}"
      
      File.write(file_path, fixed_content, encoding: 'utf-8')
      puts "✅ 修復: #{File.basename(file_path)} (slug切り詰め修正)"
      return true
    end
    
    false
  end

  def scan_and_fix(posts_dir)
    posts_path = Pathname.new(posts_dir)
    fixed_count = 0
    
    posts_path.glob("**/index.md").each do |file|
      if fix_file(file)
        fixed_count += 1
      end
    end
    
    puts "\n📊 修復完了: #{fixed_count} ファイル"
  end

  def run
    puts "🔧 フロントマター修復スクリプト"
    puts "=" * 40
    
    print "📁 postsディレクトリのパス [./content/posts]: "
    posts_dir = gets.chomp
    posts_dir = "./content/posts" if posts_dir.empty?
    
    scan_and_fix(posts_dir)
  end
end

if __FILE__ == $0
  fixer = FrontmatterFixer.new
  fixer.run
end