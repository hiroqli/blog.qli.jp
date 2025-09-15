#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require 'set'

# Medium記事をHugo Page Bundleに変換するスクリプト（Ruby版）
class PageBundleConverter
  def initialize
    @image_extensions = %w[.jpg .jpeg .png .gif .webp .svg]
  end

  # posts ディレクトリ内の .md ファイルを Page Bundle 形式に変換
  def convert_to_page_bundles(posts_dir, img_dir = nil)
    posts_path = Pathname.new(posts_dir)
    
    unless posts_path.exist?
      puts "❌ エラー: #{posts_dir} が見つかりません"
      return
    end
    
    # .mdファイルを取得
    md_files = posts_path.glob("*.md")
    
    if md_files.empty?
      puts "変換対象の .md ファイルが見つかりません"
      return
    end
    
    puts "#{md_files.length} 件の記事を変換します..."
    
    md_files.each do |md_file|
      # ファイル名から拡張子を除いたものをディレクトリ名に
      dir_name = md_file.basename('.md').to_s
      bundle_dir = posts_path / dir_name
      
      # ディレクトリを作成
      bundle_dir.mkpath
      
      # index.md として移動
      new_file_path = bundle_dir / "index.md"
      
      if new_file_path.exist?
        puts "スキップ: #{dir_name} (既に存在)"
        next
      end
      
      FileUtils.mv(md_file.to_s, new_file_path.to_s)
      puts "✅ 変換完了: #{md_file.basename} → #{dir_name}/index.md"
      
      # 画像の処理（自動実行）
      process_images(new_file_path, img_dir, bundle_dir) if img_dir
    end
  end

  # Markdownファイル内の画像参照を処理し、関連画像をコピー
  def process_images(md_file_path, img_dir, bundle_dir)
    img_path = Pathname.new(img_dir)
    
    unless img_path.exist?
      puts "画像ディレクトリが見つかりません: #{img_dir}"
      return
    end
    
    # Markdownファイルの内容を読み取り
    content = File.read(md_file_path, encoding: 'utf-8')
    
    # 画像参照パターンを検索（より包括的に）
    img_patterns = [
      /!\[.*?\]\((.*?)\)/,  # ![alt](path)
      /<img.*?src=["']([^"']*?)["']/,  # <img src="path">
      /src="([^"]*\.(?:jpg|jpeg|png|gif|webp|svg))"/i,  # src属性内の画像
      /src='([^']*\.(?:jpg|jpeg|png|gif|webp|svg))'/i   # シングルクォート版
    ]
    
    modified = false
    found_images = Set.new
    
    # パターンマッチングで画像参照を探す
    img_patterns.each do |pattern|
      content.scan(pattern) do |match|
        img_ref = match[0]
        
        # URLの場合はスキップ
        next if img_ref.match?(/^https?:\/\//) || img_ref.start_with?('//')
        
        # 画像ファイル名を抽出（URLパラメータなどを除去）
        img_filename = Pathname.new(img_ref.split('?')[0]).basename.to_s
        
        found_images.add([img_ref, img_filename]) unless img_filename.empty?
      end
    end
    
    # 見つかった画像を処理
    found_images.each do |img_ref, img_filename|
      # imgディレクトリ内で同名ファイルを検索
      matching_imgs = find_matching_images(img_path, img_filename)
      
      if matching_imgs.any?
        # 最初にマッチした画像をコピー
        src_img = matching_imgs.first
        dst_img = bundle_dir / img_filename
        
        unless dst_img.exist?
          FileUtils.cp(src_img.to_s, dst_img.to_s)
          puts "  📷 画像コピー: #{img_filename}"
        end
        
        # Markdown内のパスを相対パスに更新
        content.gsub!(img_ref, img_filename)
        modified = true
      else
        puts "  ⚠️  画像が見つかりません: #{img_filename}"
      end
    end
    
    # medium-2-mdの特殊なパターンも処理
    # cdn-images-1.medium.com などのパターン
    medium_pattern = /https:\/\/cdn-images-\d+\.medium\.com\/[^\s\)"']+/
    
    content.scan(medium_pattern) do |medium_url|
      # URLから画像ID（最後の部分）を取得
      url_parts = medium_url.split('/')
      img_id = url_parts.last
      
      next unless img_id
      
      # imgディレクトリ内で類似ファイルを検索
      possible_files = find_files_by_pattern(img_path, img_id)
      
      if possible_files.any?
        src_img = possible_files.first
        # より適切なファイル名を生成
        file_ext = src_img.extname.empty? ? '.jpg' : src_img.extname
        new_filename = "medium-#{img_id[0, 12]}#{file_ext}"
        dst_img = bundle_dir / new_filename
        
        unless dst_img.exist?
          FileUtils.cp(src_img.to_s, dst_img.to_s)
          puts "  📷 Medium画像コピー: #{new_filename}"
        end
        
        # パスを更新
        content.gsub!(medium_url, new_filename)
        modified = true
      end
    end
    
    # 変更があった場合はファイルを更新
    if modified
      File.write(md_file_path, content, encoding: 'utf-8')
      puts "  ✅ 画像パスを更新しました"
    end
  end

  # imgディレクトリを自動検出
  def auto_find_img_directory(posts_dir)
    posts_path = Pathname.new(posts_dir)
    parent_dir = posts_path.parent
    
    # よくあるパターンを検索
    possible_img_dirs = [
      parent_dir / "img",
      parent_dir / "images", 
      posts_path / "img",
      posts_path / "images"
    ]
    
    # md_で始まるディレクトリ内のimgも検索
    parent_dir.glob("md_*").each do |md_dir|
      possible_img_dirs << md_dir / "img"
      possible_img_dirs << md_dir / "images"
    end
    
    possible_img_dirs.each do |img_dir|
      next unless img_dir.exist? && img_dir.directory?
      
      # 実際に画像ファイルがあるかチェック
      has_images = @image_extensions.any? do |ext|
        img_dir.glob("*#{ext}").any?
      end
      
      return img_dir.to_s if has_images
    end
    
    nil
  end

  # メイン処理
  def run
    puts "🚀 Hugo Page Bundle変換スクリプト（Ruby版）"
    puts "=" * 50
    
    # posts ディレクトリのパスを入力
    print "📁 postsディレクトリのパスを入力してください [./content/posts]: "
    posts_dir = gets.chomp
    posts_dir = "./content/posts" if posts_dir.empty?
    
    # 画像ディレクトリを自動検出
    auto_img_dir = auto_find_img_directory(posts_dir)
    
    if auto_img_dir
      puts "\n🔍 画像ディレクトリを自動検出: #{auto_img_dir}"
      print "この画像ディレクトリを使用しますか？ [Y/n]: "
      use_auto = gets.chomp.downcase
      
      if use_auto.empty? || %w[y yes].include?(use_auto)
        img_dir = auto_img_dir
      else
        print "📷 画像ディレクトリのパスを手動入力: "
        img_dir = gets.chomp
      end
    else
      puts "\n📷 画像ディレクトリが自動検出できませんでした"
      print "画像ディレクトリのパス（オプション、Enterでスキップ）: "
      img_dir = gets.chomp
    end
    
    if img_dir.empty?
      img_dir = nil
      puts "⚠️  画像処理をスキップします"
    end
    
    puts "\n📋 設定確認:"
    puts "   Posts: #{posts_dir}"
    puts "   Images: #{img_dir || 'なし'}"
    
    print "\n実行しますか？ [Y/n]: "
    confirm = gets.chomp.downcase
    
    unless confirm.empty? || %w[y yes].include?(confirm)
      puts "❌ キャンセルしました"
      return
    end
    
    # 変換実行
    begin
      puts "\n🔄 変換を開始します..."
      convert_to_page_bundles(posts_dir, img_dir)
      
      puts "\n🎉 変換が完了しました！"
      
      # 結果確認
      posts_path = Pathname.new(posts_dir)
      bundle_dirs = posts_path.children.select(&:directory?)
      puts "\n📊 結果:"
      puts "   作成されたPage Bundle: #{bundle_dirs.length} 個"
      
      bundle_dirs.first(5).each do |bundle_dir|
        files = bundle_dir.children
        img_count = files.count { |f| @image_extensions.include?(f.extname.downcase) }
        puts "   📁 #{bundle_dir.basename}/ (#{files.length} ファイル, 📷#{img_count} 画像)"
      end
      
      if bundle_dirs.length > 5
        puts "   ... 他 #{bundle_dirs.length - 5} 個"
      end
      
      puts "\n💡 次のステップ:"
      puts "   1. hugo server で確認"
      puts "   2. 必要に応じて画像パスを手動調整"
      puts "   3. フロントマターの確認・調整"
      
    rescue => e
      puts "❌ エラーが発生しました: #{e.message}"
      puts e.backtrace.first(5).join("\n")
    end
  end

  private

  # 画像ファイルを検索
  def find_matching_images(img_path, filename)
    # 完全一致検索
    exact_matches = img_path.glob("**/#{filename}")
    return exact_matches unless exact_matches.empty?
    
    # 部分一致検索
    base_name = Pathname.new(filename).basename('.*').to_s
    img_path.glob("**/*#{base_name}*").select do |file|
      @image_extensions.include?(file.extname.downcase)
    end
  end

  # パターンでファイルを検索
  def find_files_by_pattern(img_path, pattern)
    # 完全一致
    exact_matches = img_path.glob("**/*#{pattern}*")
    return exact_matches unless exact_matches.empty?
    
    # 部分一致（最初の10文字）
    pattern_part = pattern[0, 10]
    img_path.glob("**/*#{pattern_part}*").select do |file|
      @image_extensions.include?(file.extname.downcase)
    end
  end
end

# スクリプト実行
if __FILE__ == $0
  converter = PageBundleConverter.new
  converter.run
end