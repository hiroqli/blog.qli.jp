#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require 'yaml'

class ImageLinkFinder
  def initialize
    @image_patterns = [
      /!\[.*?\]\(([^)]+)\)/,                        # ![alt](path)
      /<img[^>]*src=["']([^"']+?)["'][^>]*>/i,      # <img src="path">
      /(?<!\!)\[.*?\]\(([^)]*\.(jpg|jpeg|png|gif|webp|svg)[^)]*)\)/i,  # [text](image.jpg) - ![を除外
      /https?:\/\/[^\s)]*\.(jpg|jpeg|png|gif|webp|svg)/i,  # 直接URL
      /https?:\/\/cdn-images-\d+\.medium\.com\/[^\s)"]*/i,  # Medium CDN
      /https?:\/\/miro\.medium\.com\/[^\s)"]*/i,             # Miro CDN
    ]
  end

  # 記事から画像リンクを抽出
  def extract_image_links(content)
    found_images = []
    
    @image_patterns.each do |pattern|
      content.scan(pattern) do |match|
        if match.is_a?(Array)
          # グループマッチの場合、最初の要素を使用
          image_ref = match[0]
        else
          # 直接マッチの場合
          image_ref = match
        end
        
        # 重複除去
        found_images << image_ref unless found_images.include?(image_ref)
      end
    end
    
    found_images
  end

  # 画像リンクの種類を分類
  def classify_image_link(link)
    case link
    when /^https?:\/\/cdn-images-\d+\.medium\.com/
      "Medium CDN"
    when /^https?:\/\/miro\.medium\.com/
      "Miro CDN"
    when /^https?:\/\//
      "外部URL"
    when /^\//
      "サイト相対パス"
    when /^[^\/]/
      "相対パス"
    else
      "その他"
    end
  end

  # 画像が実際に存在するかチェック（ローカルファイル用）
  def image_exists?(bundle_dir, image_path)
    return false if image_path.start_with?('http')
    
    # 相対パスの場合
    full_path = bundle_dir / image_path
    full_path.exist?
  end

  # Page Bundle内の記事を解析
  def analyze_post(bundle_dir)
    index_file = bundle_dir / "index.md"
    
    unless index_file.exist?
      return nil
    end
    
    content = File.read(index_file, encoding: 'utf-8')
    
    # フロントマターを解析
    title = "無題"
    date = nil
    
    if content.match(/\A---\s*\n(.*?)\n---\s*\n(.*)$/m)
      begin
        frontmatter = YAML.load($1)
        title = frontmatter['title'] || bundle_dir.basename.to_s
        date = frontmatter['date']
      rescue
        # YAML解析失敗時はディレクトリ名を使用
        title = bundle_dir.basename.to_s
      end
      body = $2
    else
      body = content
    end
    
    # 画像リンクを抽出
    image_links = extract_image_links(body)
    
    return nil if image_links.empty?
    
    # 画像情報を詳細解析
    image_details = image_links.map do |link|
      {
        link: link,
        type: classify_image_link(link),
        exists: image_exists?(bundle_dir, link),
        filename: Pathname.new(link).basename.to_s
      }
    end
    
    # Bundle内の実際の画像ファイルもチェック
    actual_images = bundle_dir.children.select do |file|
      %w[.jpg .jpeg .png .gif .webp .svg].include?(file.extname.downcase)
    end
    
    {
      title: title,
      date: date,
      bundle_dir: bundle_dir,
      image_links: image_details,
      actual_images: actual_images,
      total_links: image_links.length,
      external_links: image_details.count { |img| img[:type].include?("URL") || img[:type].include?("CDN") },
      missing_images: image_details.count { |img| !img[:exists] && !img[:link].start_with?('http') }
    }
  end

  # postsディレクトリ全体をスキャン
  def scan_posts(posts_dir)
    posts_path = Pathname.new(posts_dir)
    
    unless posts_path.exist?
      puts "❌ postsディレクトリが見つかりません: #{posts_dir}"
      return []
    end
    
    # Page Bundleディレクトリを取得
    bundle_dirs = posts_path.children.select(&:directory?)
    
    if bundle_dirs.empty?
      puts "❌ Page Bundleが見つかりません"
      return []
    end
    
    puts "🔍 #{bundle_dirs.length} 個のPage Bundleをスキャン中..."
    
    results = []
    
    bundle_dirs.each_with_index do |bundle_dir, index|
      print "\r進捗: #{index + 1}/#{bundle_dirs.length} (#{((index + 1) * 100.0 / bundle_dirs.length).round(1)}%)"
      
      result = analyze_post(bundle_dir)
      results << result if result
    end
    
    puts "\n"
    results
  end

  # 結果を表示
  def display_results(results, options = {})
    return if results.empty?
    
    puts "\n📊 スキャン結果"
    puts "=" * 60
    puts "画像リンクがある記事: #{results.length} 件"
    
    # 統計情報
    total_images = results.sum { |r| r[:total_links] }
    external_images = results.sum { |r| r[:external_links] }
    missing_images = results.sum { |r| r[:missing_images] }
    
    puts "\n📈 統計:"
    puts "  総画像リンク数: #{total_images}"
    puts "  外部画像: #{external_images}"
    puts "  見つからない画像: #{missing_images}"
    
    # 詳細表示
    if options[:detailed]
      puts "\n📝 記事詳細:"
      puts "-" * 60
      
      results.each_with_index do |result, index|
        puts "\n#{index + 1}. 📖 #{result[:title]}"
        puts "   📁 #{result[:bundle_dir].basename}"
        puts "   📅 #{result[:date]}" if result[:date]
        puts "   🖼️  画像リンク: #{result[:total_links]} 個"
        
        if options[:show_images]
          result[:image_links].each do |img|
            if img[:link].start_with?('http')
              status = "🌐"
            elsif img[:exists]
              status = "✅"
            else
              status = "❌"
            end
            puts "      #{status} [#{img[:type]}] #{img[:link]}"
            
            # デバッグ情報（存在しない場合）
            unless img[:exists] || img[:link].start_with?('http')
              puts "         💡 探している: #{img[:filename]}"
              
              # debug_found_filesがnilでないことを確認
              found_files = img[:debug_found_files] || []
              puts "         💡 見つかった: #{found_files.join(', ')}" if found_files.any?
              
              # フォルダ内の実際のファイル一覧も表示
              actual_images = result[:bundle_dir].children.select do |file|
                %w[.jpg .jpeg .png .gif .webp .svg].include?(file.extname.downcase)
              end
              puts "         📁 フォルダ内画像: #{actual_images.map(&:basename).join(', ')}"
            end
          end
        end
        
        if result[:actual_images].any?
          puts "   📎 実ファイル: #{result[:actual_images].map(&:basename).join(', ')}"
        end
      end
    end
    
    # 問題のある記事をハイライト
    problematic = results.select { |r| r[:external_links] > 0 || r[:missing_images] > 0 }
    
    if problematic.any?
      puts "\n⚠️  要注意記事 (#{problematic.length} 件):"
      puts "-" * 40
      
      problematic.each do |result|
        issues = []
        issues << "外部画像 #{result[:external_links]}個" if result[:external_links] > 0
        issues << "不明画像 #{result[:missing_images]}個" if result[:missing_images] > 0
        
        puts "📖 #{result[:title]}"
        puts "   📁 #{result[:bundle_dir].basename}"
        puts "   ⚠️  #{issues.join(', ')}"
      end
    end
  end

  # メイン処理
  def run
    puts "🔍 Hugo画像リンク検索スクリプト"
    puts "=" * 50
    
    print "📁 postsディレクトリのパス [./content/posts]: "
    posts_dir = gets.chomp
    posts_dir = "./content/posts" if posts_dir.empty?
    
    print "📋 詳細表示しますか？ [y/N]: "
    detailed = gets.chomp.downcase == 'y'
    
    show_images = false
    if detailed
      print "🖼️  画像リンクも表示しますか？ [y/N]: "
      show_images = gets.chomp.downcase == 'y'
    end
    
    print "🔧 デバッグモードを有効にしますか？ [y/N]: "
    $debug = gets.chomp.downcase == 'y'
    
    # スキャン実行
    results = scan_posts(posts_dir)
    
    # 結果表示
    display_results(results, detailed: detailed, show_images: show_images)
    
    if results.any?
      puts "\n💡 次のアクション:"
      puts "1. 外部画像をローカルにダウンロード"
      puts "2. 不明画像のパスを修正"
      puts "3. 不要な画像参照を削除"
    end
  end
end

if __FILE__ == $0
  finder = ImageLinkFinder.new
  finder.run
end