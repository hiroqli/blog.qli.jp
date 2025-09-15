#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require 'yaml'
require 'uri'

class TitleSlugUpdater
  def initialize
    @processed_count = 0
    @error_count = 0
    @skip_count = 0
  end

  # タイトルからURLエンコードされたslugを生成
  def generate_url_encoded_slug(title)
    return nil if title.nil? || title.strip.empty?
    
    # 基本的なクリーンアップ
    cleaned_title = title.strip
                         .gsub(/[\/\\]/, '-')      # スラッシュをハイフンに
                         .gsub(/\s+/, ' ')         # 連続空白を1つに
    
    # URLエンコード（UTF-8）
    encoded = URI.encode_www_form_component(cleaned_title)
    
    # さらにクリーンアップ
    slug = encoded.gsub(/%20/, '-')               # %20（スペース）をハイフンに
                  .gsub(/\./, '%2E')              # ピリオドをエンコード
                  .gsub(/--+/, '-')               # 連続ハイフンを1つに
                  .gsub(/^-|-$/, '')              # 前後のハイフンを除去
    
    # 長すぎる場合は切り詰め（150文字制限）
    if slug.length > 150
      slug = slug[0, 147] + "..."
    end
    
    slug
  end

  # フロントマターを解析・更新
  def update_frontmatter(content, new_slug)
    # フロントマターを抽出
    if content.match(/\A---\s*\n(.*?)\n---\s*\n(.*)$/m)
      frontmatter_yaml = $1
      body = $2
      
      begin
        frontmatter = YAML.load(frontmatter_yaml)
        
        # 既存のslugと比較
        current_slug = frontmatter['slug']
        if current_slug == new_slug
          return { updated: false, content: content, reason: "同一slug" }
        end
        
        # slugを更新
        frontmatter['slug'] = new_slug
        
        # YAML形式で再構成（より安全な方法）
        frontmatter_lines = []
        frontmatter.each do |key, value|
          if value.is_a?(String) && (value.include?("\n") || value.length > 80)
            # 長い文字列や改行を含む場合は引用符で囲む
            escaped_value = value.gsub('"', '\"')
            frontmatter_lines << "#{key}: \"#{escaped_value}\""
          elsif value.is_a?(Array)
            if value.empty?
              frontmatter_lines << "#{key}: []"
            else
              frontmatter_lines << "#{key}:"
              value.each { |item| frontmatter_lines << "  - #{item}" }
            end
          else
            frontmatter_lines << "#{key}: #{value}"
          end
        end
        
        new_frontmatter = frontmatter_lines.join("\n")
        updated_content = "---\n#{new_frontmatter}\n---\n#{body}"
        
        return { 
          updated: true, 
          content: updated_content, 
          old_slug: current_slug,
          new_slug: new_slug
        }
        
      rescue => e
        return { updated: false, content: content, reason: "YAML解析エラー: #{e.message}" }
      end
    else
      return { updated: false, content: content, reason: "フロントマターなし" }
    end
  end

  # Page Bundle内の記事を処理
  def process_post(bundle_dir)
    index_file = bundle_dir / "index.md"
    
    unless index_file.exist?
      return { success: false, reason: "index.mdなし" }
    end
    
    content = File.read(index_file, encoding: 'utf-8')
    
    # フロントマターからタイトルを抽出
    if content.match(/\A---\s*\n(.*?)\n---\s*\n/m)
      begin
        frontmatter = YAML.load($1)
        title = frontmatter['title']
        
        if title.nil? || title.strip.empty?
          return { success: false, reason: "タイトルなし" }
        end
        
        # URLエンコードされたslugを生成
        new_slug = generate_url_encoded_slug(title)
        
        if new_slug.nil? || new_slug.empty?
          return { success: false, reason: "slug生成失敗" }
        end
        
        # フロントマターを更新
        result = update_frontmatter(content, new_slug)
        
        if result[:updated]
          # ファイルに書き戻し
          File.write(index_file, result[:content], encoding: 'utf-8')
          
          return { 
            success: true, 
            title: title,
            old_slug: result[:old_slug],
            new_slug: result[:new_slug]
          }
        else
          return { success: false, reason: result[:reason] }
        end
        
      rescue => e
        return { success: false, reason: "処理エラー: #{e.message}" }
      end
    else
      return { success: false, reason: "フロントマター解析失敗" }
    end
  end

  # postsディレクトリ全体を処理
  def process_posts(posts_dir, options = {})
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
    
    results = []
    
    bundle_dirs.each_with_index do |bundle_dir, index|
      print "\r進捗: #{index + 1}/#{bundle_dirs.length} (#{((index + 1) * 100.0 / bundle_dirs.length).round(1)}%)"
      
      result = process_post(bundle_dir)
      result[:bundle_dir] = bundle_dir.basename.to_s
      results << result
      
      if result[:success]
        @processed_count += 1
      else
        if result[:reason] == "同一slug"
          @skip_count += 1
        else
          @error_count += 1
        end
      end
    end
    
    puts "\n"
    display_results(results, options)
  end

  # 結果を表示
  def display_results(results, options = {})
    puts "\n📊 処理結果"
    puts "=" * 60
    puts "処理済み: #{@processed_count} 件"
    puts "スキップ: #{@skip_count} 件"
    puts "エラー: #{@error_count} 件"
    
    # 成功した処理を表示
    successful = results.select { |r| r[:success] }
    
    if successful.any? && options[:show_details]
      puts "\n✅ 更新された記事:"
      puts "-" * 40
      
      successful.each_with_index do |result, index|
        puts "\n#{index + 1}. 📖 #{result[:title]}"
        puts "   📁 #{result[:bundle_dir]}"
        puts "   🔗 旧slug: #{result[:old_slug] || 'なし'}"
        puts "   🔗 新slug: #{result[:new_slug]}"
        
        if options[:show_urls]
          puts "   🌐 新URL: /posts/#{result[:new_slug]}/"
        end
      end
    end
    
    # エラーを表示
    failed = results.reject { |r| r[:success] || r[:reason] == "同一slug" }
    
    if failed.any?
      puts "\n❌ エラーが発生した記事:"
      puts "-" * 40
      
      failed.each do |result|
        puts "📁 #{result[:bundle_dir]} - #{result[:reason]}"
      end
    end
    
    # スキップされた記事
    skipped = results.select { |r| r[:reason] == "同一slug" }
    
    if skipped.any? && options[:show_skipped]
      puts "\n⏭️ スキップされた記事 (#{skipped.length} 件):"
      puts "-" * 40
      
      skipped.each do |result|
        puts "📁 #{result[:bundle_dir]} - 既に同じslug"
      end
    end
  end

  # メイン処理
  def run
    puts "🔗 Hugo Slug URLエンコード更新スクリプト"
    puts "=" * 50
    
    print "📁 postsディレクトリのパス [./content/posts]: "
    posts_dir = gets.chomp
    posts_dir = "./content/posts" if posts_dir.empty?
    
    print "📋 詳細表示しますか？ [Y/n]: "
    show_details = !gets.chomp.downcase.start_with?('n')
    
    show_urls = false
    show_skipped = false
    
    if show_details
      print "🌐 新URLも表示しますか？ [y/N]: "
      show_urls = gets.chomp.downcase.start_with?('y')
      
      print "⏭️ スキップした記事も表示しますか？ [y/N]: "
      show_skipped = gets.chomp.downcase.start_with?('y')
    end
    
    puts "\n📋 設定確認:"
    puts "   Posts: #{posts_dir}"
    puts "   詳細表示: #{show_details ? 'あり' : 'なし'}"
    
    print "\n実行しますか？ [Y/n]: "
    confirm = gets.chomp.downcase
    
    unless confirm.empty? || confirm.start_with?('y')
      puts "❌ キャンセルしました"
      return
    end
    
    # 処理実行
    begin
      puts "\n🔄 処理を開始します..."
      process_posts(posts_dir, {
        show_details: show_details,
        show_urls: show_urls,
        show_skipped: show_skipped
      })
      
      puts "\n🎉 処理が完了しました！"
      
      if @processed_count > 0
        puts "\n💡 次のステップ:"
        puts "1. hugo server で動作確認"
        puts "2. 必要に応じてリダイレクト設定"
        puts "3. 検索エンジンに新URLを通知"
      end
      
    rescue => e
      puts "❌ エラーが発生しました: #{e.message}"
      puts e.backtrace.first(5).join("\n")
    end
  end
end

if __FILE__ == $0
  updater = TitleSlugUpdater.new
  updater.run
end