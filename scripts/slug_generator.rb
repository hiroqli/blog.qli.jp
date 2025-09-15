#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require 'yaml'

class SlugGenerator
  def initialize
    @slug_counter = {}
  end

  # タイトルからslugを生成
  def generate_slug(title, date = nil)
    # 基本的なslug生成
    slug = title.downcase
                .gsub(/[^\w\s-]/, '')  # 特殊文字除去
                .gsub(/\s+/, '-')      # スペースをハイフンに
                .gsub(/-+/, '-')       # 連続ハイフンを1つに
                .strip.chomp('-')      # 前後の空白・ハイフン除去
    
    # 空の場合は日付から生成
    if slug.empty? && date
      slug = date.strftime('%Y-%m-%d')
    end
    
    # 重複チェック
    original_slug = slug
    counter = 1
    while @slug_counter[slug]
      slug = "#{original_slug}-#{counter}"
      counter += 1
    end
    
    @slug_counter[slug] = true
    slug
  end

  # フロントマターを解析・更新
  def update_frontmatter(content, slug)
    # フロントマターを抽出
    if content.match(/\A---\s*\n(.*?)\n---\s*\n(.*)$/m)
      frontmatter_yaml = $1
      body = $2
      
      begin
        frontmatter = YAML.load(frontmatter_yaml)
        
        # slugが既にある場合はスキップ
        return content if frontmatter['slug']
        
        # slugを追加
        frontmatter['slug'] = slug
        
        # YAML形式で再構成
        new_frontmatter = YAML.dump(frontmatter)
        return "---\n#{new_frontmatter}---\n#{body}"
        
      rescue => e
        puts "  ⚠️  YAML解析エラー: #{e.message}"
        return content
      end
    else
      puts "  ⚠️  フロントマターが見つかりません"
      return content
    end
  end

  # ディレクトリ名を短縮
  def shorten_directory_name(dir_path, slug)
    parent_dir = dir_path.parent
    current_name = dir_path.basename.to_s
    
    # 既に短い場合はそのまま
    return dir_path if current_name.length <= 50
    
    # 日付部分を抽出（あれば）
    match = current_name.match(/^(\d{4}-\d{2}-\d{2})/)
    date_part = match ? match[1] : nil
    
    # 新しいディレクトリ名を生成
    if date_part
      new_name = "#{date_part}_#{slug}"
    else
      new_name = slug
    end
    
    # 長すぎる場合は切り詰め
    if new_name.length > 50
      new_name = new_name[0, 47] + "..."
    end
    
    new_path = parent_dir / new_name
    
    # 重複回避
    counter = 1
    while new_path.exist? && new_path != dir_path
      test_name = "#{new_name}-#{counter}"
      new_path = parent_dir / test_name
      counter += 1
    end
    
    new_path
  end

  # メイン処理
  def process_posts(posts_dir)
    posts_path = Pathname.new(posts_dir)
    
    unless posts_path.exist?
      puts "❌ postsディレクトリが見つかりません: #{posts_dir}"
      return
    end
    
    # Page Bundleディレクトリを取得
    bundle_dirs = posts_path.children.select(&:directory?)
    
    if bundle_dirs.empty?
      puts "❌ Page Bundleが見つかりません"
      return
    end
    
    puts "📝 #{bundle_dirs.length} 個のPage Bundleを処理します..."
    
    bundle_dirs.each do |bundle_dir|
      index_file = bundle_dir / "index.md"
      
      unless index_file.exist?
        puts "⚠️  スキップ: #{bundle_dir.basename} (index.mdなし)"
        next
      end
      
      puts "\n📁 処理中: #{bundle_dir.basename}"
      
      # index.mdを読み込み
      content = File.read(index_file, encoding: 'utf-8')
      
      # フロントマターからタイトルと日付を抽出
      if content.match(/\A---\s*\n(.*?)\n---\s*\n/m)
        begin
          frontmatter = YAML.load($1)
          title = frontmatter['title'] || bundle_dir.basename.to_s
          date_str = frontmatter['date']
          date = date_str ? Date.parse(date_str.to_s) : nil
          
          # slugを生成
          slug = generate_slug(title, date)
          puts "  🏷️  生成されたslug: #{slug}"
          
          # フロントマターを更新
          updated_content = update_frontmatter(content, slug)
          
          # ファイルを更新
          if updated_content != content
            File.write(index_file, updated_content, encoding: 'utf-8')
            puts "  ✅ slug追加完了"
          else
            puts "  ⏭️  slug既存またはスキップ"
          end
          
          # ディレクトリ名を短縮（必要な場合）
          new_dir_path = shorten_directory_name(bundle_dir, slug)
          if new_dir_path != bundle_dir
            puts "  📂 ディレクトリ名変更: #{bundle_dir.basename} → #{new_dir_path.basename}"
            File.rename(bundle_dir.to_s, new_dir_path.to_s)
          end
          
        rescue => e
          puts "  ❌ エラー: #{e.message}"
        end
      end
    end
    
    puts "\n🎉 処理完了！"
    puts "\n💡 次のステップ:"
    puts "1. hugo.yaml に permalinks 設定を追加"
    puts "2. hugo server で確認"
  end

  def run
    puts "🚀 Hugo Slug生成スクリプト"
    puts "=" * 40
    
    print "📁 postsディレクトリのパス [./content/posts]: "
    posts_dir = gets.chomp
    posts_dir = "./content/posts" if posts_dir.empty?
    
    puts "\n処理を開始しますか？ [Y/n]: "
    confirm = gets.chomp.downcase
    
    unless confirm.empty? || %w[y yes].include?(confirm)
      puts "❌ キャンセルしました"
      return
    end
    
    process_posts(posts_dir)
  end
end

if __FILE__ == $0
  generator = SlugGenerator.new
  generator.run
end