#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require 'fileutils'

class ExtensionFixer
  def initialize
    @posts_dir = Pathname.new('./content/posts')
    @fixed_files = []
    @updated_references = []
    @stats = {
      total_dirs: 0,
      files_without_extension: 0,
      files_fixed: 0,
      references_updated: 0
    }
  end

  # ファイルタイプを検出（マジックナンバーによる判定）
  def detect_file_type(file_path)
    return nil unless file_path.exist? && file_path.file?
    
    begin
      # ファイルの最初の数バイトを読み取り
      header = File.read(file_path, 20, mode: 'rb')
      
      case header
      when /^\xFF\xD8\xFF/n
        '.jpeg'
      when /^\x89PNG\r\n\x1a\n/n
        '.png'
      when /^GIF8[79]a/n
        '.gif'
      when /^RIFF....WEBP/n
        '.webp'
      when /^BM/n
        '.bmp'
      when /^\x00\x00\x01\x00/n, /^\x00\x00\x02\x00/n
        '.ico'
      when /^<svg/n, /^\s*<\?xml.*<svg/mn
        '.svg'
      when /^%PDF/n
        '.pdf'
      when /^PK\x03\x04/n
        '.zip'
      else
        # テキストファイルかどうかをチェック
        if text_file?(file_path)
          detect_text_type(file_path)
        else
          nil
        end
      end
    rescue => e
      puts "  ❌ ファイル読み込みエラー: #{file_path.basename} - #{e.message}"
      nil
    end
  end

  # テキストファイルかどうかの判定
  def text_file?(file_path)
    begin
      content = File.read(file_path, 1024, encoding: 'utf-8')
      # ASCII文字とUTF-8文字のみで構成されているかチェック
      content.valid_encoding? && content.match?(/\A[\x00-\x7F\u0080-\uFFFF]*\z/)
    rescue
      false
    end
  end

  # テキストファイルの種類を検出
  def detect_text_type(file_path)
    begin
      content = File.read(file_path, 512, encoding: 'utf-8')
      
      case content
      when /\A---\s*\n.*\n---\s*\n/m
        '.md'
      when /\A\s*{/
        '.json'
      when /\A\s*[\w-]+\s*:/
        '.yaml'
      when /\A\s*<\?xml/, /\A\s*<!DOCTYPE\s+html/, /\A\s*<html/
        '.xml'
      when /\A\s*\/\*/, /\.\w+\s*{/
        '.css'
      when /\A\s*(function|var|const|let|import|export)/
        '.js'
      else
        '.txt'
      end
    rescue
      '.txt'
    end
  end

  # 拡張子のないファイルを検索
  def find_files_without_extension
    puts "🔍 拡張子のないファイルを検索中..."
    
    files_without_ext = []
    all_files = []
    
    @posts_dir.glob('**/*').each do |file|
      next unless file.file?
      all_files << file
      
      filename = file.basename.to_s
      
      # 隠しファイルをスキップ
      next if filename.start_with?('.')
      
      # 一般的な拡張子なしファイル名をスキップ  
      skip_names = %w[README LICENSE Makefile Dockerfile index]
      next if skip_names.include?(filename.downcase)
      
      # 拡張子なしファイルの判定
      has_normal_extension = filename.match?(/\.[a-zA-Z0-9]{1,5}$/)
      
      # 特に問題のあるパターンを検出
      is_problematic = filename.end_with?('_') ||                    # アンダースコア終わり
                       filename.match?(/\.(jp|pn|gi|web|sv)$/i) ||   # 不完全拡張子
                       filename.match?(/[a-zA-Z0-9]+(jpeg|png|gif)$/i) || # ドット抜け
                       (file.size > 10240 && !has_normal_extension)  # 大きなファイルで拡張子なし
      
      if !has_normal_extension || is_problematic
        files_without_ext << file
      end
    end
    
    puts "📊 総ファイル数: #{all_files.length}"
    puts "📊 問題のあるファイル: #{files_without_ext.length} 個発見"
    
    # 発見されたファイルの例を表示
    if files_without_ext.any?
      puts "\n発見されたファイル例:"
      files_without_ext.first(10).each do |file|
        puts "  📄 #{file.relative_path_from(@posts_dir)} (#{format_size(file.size)})"
      end
      puts "  ..." if files_without_ext.length > 10
    end
    
    @stats[:files_without_extension] = files_without_ext.length
    files_without_ext
  end

  # ファイルの分析と修正
  def analyze_and_fix_files(dry_run: true)
    files_without_ext = find_files_without_extension
    
    return if files_without_ext.empty?
    
    puts "\n📋 ファイル分析中..."
    puts "=" * 50
    
    files_without_ext.each_with_index do |file, index|
      puts "\n#{index + 1}. 📁 #{file.parent.basename}/#{file.basename}"
      
      # ファイルサイズ表示
      size = format_size(file.size)
      puts "   💾 サイズ: #{size}"
      
      # ファイルタイプ検出
      detected_ext = detect_file_type(file)
      
      if detected_ext
        puts "   🔍 検出タイプ: #{detected_ext}"
        
        new_filename = "#{file.basename}#{detected_ext}"
        new_path = file.parent / new_filename
        
        if new_path.exist?
          puts "   ⚠️  同名ファイルが既に存在: #{new_filename}"
          next
        end
        
        if dry_run
          puts "   🔄 [DRY RUN] リネーム予定: #{file.basename} → #{new_filename}"
        else
          begin
            File.rename(file.to_s, new_path.to_s)
            puts "   ✅ リネーム完了: #{new_filename}"
            
            @fixed_files << {
              old_path: file,
              new_path: new_path,
              old_name: file.basename.to_s,
              new_name: new_filename
            }
            @stats[:files_fixed] += 1
          rescue => e
            puts "   ❌ リネーム失敗: #{e.message}"
          end
        end
      else
        puts "   ❓ ファイルタイプを検出できませんでした"
        
        # ファイルの先頭を表示（デバッグ用）
        begin
          preview = File.read(file, 50, mode: 'rb')
          hex_preview = preview.unpack('H*')[0][0, 40]
          puts "      Hex: #{hex_preview}"
          
          if text_file?(file)
            text_preview = File.read(file, 100, encoding: 'utf-8').strip
            puts "      Text: #{text_preview[0, 50]}..."
          end
        rescue
          puts "      ファイル読み込み不可"
        end
      end
    end
    
    unless dry_run
      update_references if @fixed_files.any?
    end
  end

  # 記事内の参照を更新
  def update_references
    return if @fixed_files.empty?
    
    puts "\n📝 記事内の参照を更新中..."
    puts "=" * 40
    
    @fixed_files.each do |fixed_file|
      update_references_for_file(fixed_file)
    end
    
    puts "📊 参照更新完了: #{@stats[:references_updated]} 箇所"
  end

  # 特定ファイルの参照を更新
  def update_references_for_file(fixed_file)
    bundle_dir = fixed_file[:old_path].parent
    index_md = bundle_dir / 'index.md'
    
    return unless index_md.exist?
    
    begin
      content = File.read(index_md, encoding: 'utf-8')
      original_content = content.dup
      
      old_name = fixed_file[:old_name]
      new_name = fixed_file[:new_name]
      
      # 様々なパターンで参照を検索・置換
      patterns = [
        # Markdown画像参照
        [/!\[([^\]]*)\]\(#{Regexp.escape(old_name)}\)/, "![\\1](#{new_name})"],
        
        # HTML img タグ
        [/<img([^>]*)\ssrc=["']#{Regexp.escape(old_name)}["']([^>]*)>/, "<img\\1 src=\"#{new_name}\"\\2>"],
        
        # 単純な文字列参照
        [/#{Regexp.escape(old_name)}/, new_name]
      ]
      
      updated = false
      patterns.each do |pattern, replacement|
        if content.gsub!(pattern, replacement)
          updated = true
        end
      end
      
      if updated
        File.write(index_md, content, encoding: 'utf-8')
        puts "   ✅ 更新: #{bundle_dir.basename}/index.md"
        
        @updated_references << {
          file: index_md,
          old_name: old_name,
          new_name: new_name
        }
        @stats[:references_updated] += 1
      end
      
    rescue => e
      puts "   ❌ 参照更新エラー: #{index_md.basename} - #{e.message}"
    end
  end

  # ファイルサイズのフォーマット
  def format_size(bytes)
    if bytes < 1024
      "#{bytes} bytes"
    elsif bytes < 1024 * 1024
      "#{(bytes / 1024.0).round(1)} KB"
    else
      "#{(bytes / (1024.0 * 1024)).round(1)} MB"
    end
  end

  # 結果サマリー表示
  def display_summary
    puts "\n📊 処理結果サマリー"
    puts "=" * 50
    puts "拡張子なしファイル: #{@stats[:files_without_extension]} 個"
    puts "修正されたファイル: #{@stats[:files_fixed]} 個"
    puts "削除された無効ファイル: #{@stats[:invalid_files_removed] || 0} 個"
    puts "更新された参照: #{@stats[:references_updated]} 箇所"
    puts "削除された参照: #{@stats[:references_removed] || 0} 箇所"
    
    if @fixed_files.any?
      puts "\n✅ 修正されたファイル:"
      @fixed_files.each do |file|
        puts "   📁 #{file[:old_path].parent.basename}/"
        puts "      #{file[:old_name]} → #{file[:new_name]}"
      end
    end
    
    if @invalid_files && @invalid_files.any?
      puts "\n🗑️ 削除された無効ファイル:"
      @invalid_files.each do |file|
        puts "   📁 #{file.parent.basename}/#{file.basename}"
      end
    end
  end

  # メイン処理
  def run
    puts "🔧 Hugo 拡張子復元・参照修正ツール"
    puts "=" * 60
    
    unless @posts_dir.exist?
      puts "❌ postsディレクトリが見つかりません: #{@posts_dir}"
      return
    end
    
    # 事前分析
    files_without_ext = find_files_without_extension
    
    if files_without_ext.empty?
      puts "🎉 拡張子のないファイルは見つかりませんでした！"
      return
    end
    
    puts "\n📋 実行オプション:"
    puts "1. ファイル分析のみ (ドライラン)"
    puts "2. 拡張子修正を実行"
    puts "3. 詳細プレビュー表示"
    puts "4. 終了"
    
    loop do
      print "\n選択してください [1-4]: "
      choice = gets.chomp
      
      case choice
      when '1'
        analyze_and_fix_files(dry_run: true)
      when '2'
        print "\n#{files_without_ext.length} 個のファイルを修正しますか？ [y/N]: "
        if gets.chomp.downcase.start_with?('y')
          analyze_and_fix_files(dry_run: false)
          display_summary
        else
          puts "キャンセルしました"
        end
      when '3'
        show_file_preview(files_without_ext.first(10))
      when '4'
        puts "終了します"
        break
      else
        puts "1-4を入力してください"
      end
    end
  end

  # ファイルプレビュー表示
  def show_file_preview(files)
    puts "\n🔍 ファイルプレビュー"
    puts "=" * 40
    
    files.each_with_index do |file, index|
      puts "\n#{index + 1}. #{file.parent.basename}/#{file.basename}"
      puts "   サイズ: #{format_size(file.size)}"
      
      detected_ext = detect_file_type(file)
      puts "   推定タイプ: #{detected_ext || '不明'}"
      
      # ファイル内容のプレビュー
      begin
        if text_file?(file)
          preview = File.read(file, 200, encoding: 'utf-8').strip
          puts "   内容: #{preview[0, 80]}#{'...' if preview.length > 80}"
        else
          header = File.read(file, 16, mode: 'rb')
          hex = header.unpack('H*')[0]
          puts "   Hex: #{hex}"
        end
      rescue => e
        puts "   プレビューエラー: #{e.message}"
      end
    end
  end
end

if __FILE__ == $0
  fixer = ExtensionFixer.new
  fixer.run
end