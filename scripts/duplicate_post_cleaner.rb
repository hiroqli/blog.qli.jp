#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require 'yaml'
require 'digest'
require 'fileutils'
require 'time'
require 'set'

class DuplicatePostCleaner
  def initialize
    @similarity_threshold = 0.85  # 85%以上の類似度で重複とみなす
    @min_content_length = 50      # 最小コンテンツ長（これより短いものは比較対象外）
    @log_file = nil
    @log_enabled = false
  end

  # ログ出力（コンソールとファイルの両方）
  def log(message, level = :info)
    timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    formatted_message = "[#{timestamp}] #{message}"
    
    # コンソールに出力
    puts message
    
    # ログファイルに出力
    if @log_enabled && @log_file
      begin
        @log_file.puts(formatted_message)
        @log_file.flush  # 即座にファイルに書き込み
      rescue => e
        puts "⚠️  ログ書き込みエラー: #{e.message}"
      end
    end
  end

  # ログファイルを初期化
  def initialize_log_file(log_path)
    begin
      @log_file = File.open(log_path, 'w', encoding: 'utf-8')
      @log_enabled = true
      
      # ヘッダー情報をログに記録
      @log_file.puts("=" * 80)
      @log_file.puts("Hugo重複記事検出・整理スクリプト ログ")
      @log_file.puts("開始時刻: #{Time.now}")
      @log_file.puts("=" * 80)
      @log_file.flush
      
      true
    rescue => e
      puts "❌ ログファイル作成エラー: #{e.message}"
      @log_enabled = false
      false
    end
  end

  # ログファイルを閉じる
  def close_log_file
    if @log_file && !@log_file.closed?
      @log_file.puts("\n" + "=" * 80)
      @log_file.puts("終了時刻: #{Time.now}")
      @log_file.puts("=" * 80)
      @log_file.close
    end
  end

  # 記事の基本情報を抽出
  def extract_post_info(bundle_dir)
    index_file = bundle_dir / "index.md"
    
    unless index_file.exist?
      return nil
    end
    
    content = File.read(index_file, encoding: 'utf-8')
    
    # Page Bundle内の画像ファイルを取得
    image_files = bundle_dir.children.select do |file|
      file.file? && %w[.jpg .jpeg .png .gif .webp .svg .bmp .tiff].include?(file.extname.downcase)
    end
    
    # フロントマターとボディを分離
    if content.match(/\A---\s*\n(.*?)\n---\s*\n(.*)$/m)
      frontmatter_yaml = $1
      body = $2.strip
      
      begin
        frontmatter = YAML.load(frontmatter_yaml)
        
        return {
          path: bundle_dir,
          title: frontmatter['title'] || bundle_dir.basename.to_s,
          date: frontmatter['date'],
          slug: frontmatter['slug'],
          description: frontmatter['description'],
          body: body,
          body_length: body.length,
          body_hash: Digest::MD5.hexdigest(body),
          word_count: body.split(/\s+/).length,
          frontmatter: frontmatter,
          file_size: index_file.size,
          images: image_files,
          image_count: image_files.length
        }
      rescue => e
        log "⚠️  YAML解析エラー: #{bundle_dir.basename} - #{e.message}"
        return nil
      end
    else
      return nil
    end
  end

  # テキストの類似度を計算（Jaccard係数）
  def calculate_similarity(text1, text2)
    return 1.0 if text1 == text2
    return 0.0 if text1.empty? || text2.empty?
    
    # 単語レベルでの比較
    words1 = text1.downcase.split(/\s+/).to_set
    words2 = text2.downcase.split(/\s+/).to_set
    
    intersection = words1 & words2
    union = words1 | words2
    
    return 0.0 if union.empty?
    intersection.size.to_f / union.size.to_f
  end

  # 文字レベルでの類似度（短い文章用）
  def calculate_char_similarity(text1, text2)
    return 1.0 if text1 == text2
    return 0.0 if text1.empty? || text2.empty?
    
    # 文字単位での比較
    chars1 = text1.chars.to_set
    chars2 = text2.chars.to_set
    
    intersection = chars1 & chars2
    union = chars1 | chars2
    
    return 0.0 if union.empty?
    intersection.size.to_f / union.size.to_f
  end

  # 重複グループを検出
  def find_duplicate_groups(posts)
    log "🔍 重複検出中..."
    
    duplicate_groups = []
    processed = Set.new
    
    posts.each_with_index do |post1, i|
      next if processed.include?(i)
      next if post1[:body_length] < @min_content_length
      
      group = [{ index: i, post: post1 }]
      
      posts.each_with_index do |post2, j|
        next if j <= i || processed.include?(j)
        next if post2[:body_length] < @min_content_length
        
        # まずハッシュで完全一致をチェック
        if post1[:body_hash] == post2[:body_hash]
          group << { index: j, post: post2 }
          processed.add(j)
          next
        end
        
        # タイトルの類似度をチェック
        title_similarity = calculate_similarity(post1[:title], post2[:title])
        
        # 本文の類似度をチェック
        if post1[:body_length] < 200 || post2[:body_length] < 200
          # 短い文章は文字レベルで比較
          content_similarity = calculate_char_similarity(post1[:body], post2[:body])
        else
          # 長い文章は単語レベルで比較
          content_similarity = calculate_similarity(post1[:body], post2[:body])
        end
        
        # 重複判定
        if content_similarity >= @similarity_threshold || 
           (title_similarity >= 0.9 && content_similarity >= 0.7)
          group << { index: j, post: post2 }
          processed.add(j)
        end
      end
      
      if group.length > 1
        duplicate_groups << group
        group.each { |item| processed.add(item[:index]) }
      end
    end
    
    duplicate_groups
  end

  # 重複グループ内で保持すべき記事を決定
  def choose_best_post(group)
    # 優先順位:
    # 1. より新しい日付
    # 2. より長いコンテンツ
    # 3. より詳細なメタデータ
    # 4. ファイルサイズ
    # 5. 画像数
    
    best = group.max_by do |item|
      post = item[:post]
      score = 0
      
      # 日付スコア（新しいほど高い）
      if post[:date]
        begin
          date = Date.parse(post[:date].to_s)
          score += date.year * 10000 + date.month * 100 + date.day
        rescue
          # 日付解析失敗時は0
        end
      end
      
      # コンテンツ長スコア
      score += post[:body_length] * 0.1
      
      # メタデータスコア
      score += 100 if post[:description] && !post[:description].empty?
      score += 50 if post[:slug] && !post[:slug].empty?
      
      # ファイルサイズスコア
      score += post[:file_size] * 0.01
      
      # 画像数スコア（画像が多いほど価値が高い）
      score += post[:image_count] * 50
      
      score
    end
    
    best[:post]
  end

  # 結果を表示
  def display_duplicates(duplicate_groups)
    return if duplicate_groups.empty?
    
    log "\n📊 重複検出結果"
    log "=" * 60
    log "重複グループ数: #{duplicate_groups.length}"
    
    total_duplicates = duplicate_groups.sum { |group| group.length - 1 }
    log "削除対象記事数: #{total_duplicates}"
    
    duplicate_groups.each_with_index do |group, group_index|
      log "\n📁 グループ #{group_index + 1} (#{group.length} 件)"
      log "-" * 40
      
      best_post = choose_best_post(group)
      
      group.each do |item|
        post = item[:post]
        is_best = post == best_post
        status = is_best ? "🟢 保持" : "🔴 削除"
        
        log "#{status} #{post[:title]}"
        log "   📁 #{post[:path].basename}"
        log "   📅 #{post[:date]}" if post[:date]
        log "   📝 #{post[:body_length]} 文字 (#{post[:word_count]} 語)"
        log "   🖼️  #{post[:image_count]} 画像"
        log "   💾 #{post[:file_size]} bytes"
        log ""
      end
    end
  end

  # 画像を安全にコピー
  def copy_images_safely(from_post, to_post)
    return [] if from_post[:images].empty?
    
    copied_images = []
    conflicts = []
    
    from_post[:images].each do |image_file|
      dest_file = to_post[:path] / image_file.basename
      
      if dest_file.exist?
        # ファイルが既に存在する場合の処理
        if image_file.size == dest_file.size
          # サイズが同じなら同一ファイルとみなしてスキップ
          next
        else
          # サイズが違う場合は別名でコピー
          base_name = image_file.basename(image_file.extname)
          ext = image_file.extname
          counter = 1
          
          loop do
            new_name = "#{base_name}_#{counter}#{ext}"
            dest_file = to_post[:path] / new_name
            break unless dest_file.exist?
            counter += 1
          end
          
          conflicts << {
            original: image_file.basename.to_s,
            renamed: dest_file.basename.to_s
          }
        end
      end
      
      begin
        FileUtils.cp(image_file.to_s, dest_file.to_s)
        copied_images << dest_file.basename.to_s
      rescue => e
        log "❌ 画像コピー失敗: #{image_file.basename} - #{e.message}"
      end
    end
    
    { copied: copied_images, conflicts: conflicts }
  end

  # 重複記事を削除
  def remove_duplicates(duplicate_groups, options = {})
    return if duplicate_groups.empty?
    
    removed_count = 0
    total_images_copied = 0
    
    duplicate_groups.each_with_index do |group, group_index|
      log "\n📁 グループ #{group_index + 1} 処理中..."
      
      best_post = choose_best_post(group)
      log "🟢 保持: #{best_post[:title]} (#{best_post[:path].basename})"
      
      # 削除対象の記事から画像をコピー
      group.each do |item|
        post = item[:post]
        next if post == best_post  # 最良の記事は保持
        
        # 画像があるかチェック
        if post[:image_count] > 0
          log "📷 画像処理: #{post[:path].basename} (#{post[:image_count]}個)"
          
          if options[:dry_run]
            log "   [DRY RUN] #{post[:image_count]}個の画像を #{best_post[:path].basename} にコピー"
            post[:images].each do |img|
              log "   📎 #{img.basename}"
            end
          else
            # 実際に画像をコピー
            result = copy_images_safely(post, best_post)
            
            if result[:copied].any?
              log "   ✅ コピー完了: #{result[:copied].join(', ')}"
              total_images_copied += result[:copied].length
            end
            
            if result[:conflicts].any?
              log "   ⚠️  名前変更:"
              result[:conflicts].each do |conflict|
                log "      #{conflict[:original]} → #{conflict[:renamed]}"
              end
            end
          end
        end
        
        # 記事を削除
        if options[:dry_run]
          log "🗑️  [DRY RUN] 削除対象: #{post[:path].basename}"
        else
          begin
            # Page Bundleディレクトリごと削除
            post[:path].rmtree
            log "🗑️  削除完了: #{post[:path].basename}"
            removed_count += 1
          rescue => e
            log "❌ 削除失敗: #{post[:path].basename} - #{e.message}"
          end
        end
      end
    end
    
    unless options[:dry_run]
      log "\n✅ 処理完了:"
      log "   削除した記事: #{removed_count} 件"
      log "   コピーした画像: #{total_images_copied} 個" if total_images_copied > 0
    end
  end

  # メイン処理
  def run
    puts "🔍 Hugo重複記事検出・整理スクリプト"
    puts "=" * 50
    
    print "📁 postsディレクトリのパス [./content/posts]: "
    posts_dir = gets.chomp
    posts_dir = "./content/posts" if posts_dir.empty?
    
    posts_path = Pathname.new(posts_dir)
    unless posts_path.exist?
      puts "❌ postsディレクトリが見つかりません: #{posts_dir}"
      return
    end
    
    # ログファイル設定
    print "📝 ログファイルを作成しますか？ [Y/n]: "
    create_log = !gets.chomp.downcase.start_with?('n')
    
    log_filename = nil
    if create_log
      timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
      log_filename = "duplicate_cleanup_#{timestamp}.log"
      
      print "📝 ログファイル名 [#{log_filename}]: "
      custom_log = gets.chomp
      log_filename = custom_log unless custom_log.empty?
      
      if initialize_log_file(log_filename)
        puts "📝 ログファイル作成: #{log_filename}"
      end
    end
    
    print "🎯 類似度閾値 [85%]: "
    threshold_input = gets.chomp
    @similarity_threshold = threshold_input.empty? ? 0.85 : threshold_input.to_f / 100.0
    
    log "設定:"
    log "  postsディレクトリ: #{posts_dir}"
    log "  類似度閾値: #{(@similarity_threshold * 100).round(1)}%"
    log "  ログファイル: #{@log_enabled ? 'あり' : 'なし'}"
    
    # 記事情報を収集
    log "\n📖 記事情報を収集中..."
    bundle_dirs = posts_path.children.select(&:directory?)
    posts = []
    
    bundle_dirs.each_with_index do |bundle_dir, index|
      print "\r進捗: #{index + 1}/#{bundle_dirs.length}"
      
      post_info = extract_post_info(bundle_dir)
      posts << post_info if post_info
    end
    
    log "\n📚 #{posts.length} 件の記事を読み込みました"
    
    # 重複検出
    duplicate_groups = find_duplicate_groups(posts)
    
    if duplicate_groups.empty?
      log "\n🎉 重複記事は見つかりませんでした！"
      close_log_file
      return
    end
    
    # 結果表示
    display_duplicates(duplicate_groups)
    
    # 削除確認
    print "\n削除を実行しますか？ [y/N]: "
    execute = gets.chomp.downcase.start_with?('y')
    
    if execute
      print "💡 まずドライランを実行しますか？ [Y/n]: "
      dry_run = !gets.chomp.downcase.start_with?('n')
      
      if dry_run
        log "\n🔍 ドライラン実行..."
        remove_duplicates(duplicate_groups, dry_run: true)
        
        print "\n本当に削除を実行しますか？ [y/N]: "
        final_confirm = gets.chomp.downcase.start_with?('y')
        
        if final_confirm
          log "\n🗑️  削除実行..."
          remove_duplicates(duplicate_groups)
        else
          log "❌ キャンセルしました"
        end
      else
        log "\n🗑️  削除実行..."
        remove_duplicates(duplicate_groups)
      end
    else
      log "❌ キャンセルしました"
    end
    
    log "\n💡 次のステップ:"
    log "1. hugo server で動作確認"
    log "2. 削除した記事にリンクがないかチェック"
    log "3. 必要に応じてリダイレクト設定"
    
    if @log_enabled && log_filename
      puts "\n📝 詳細ログ: #{File.expand_path(log_filename)}"
    end
    
    close_log_file
  end
end

if __FILE__ == $0
  cleaner = DuplicatePostCleaner.new
  cleaner.run
end