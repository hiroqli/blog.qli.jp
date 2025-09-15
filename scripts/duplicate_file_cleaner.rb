#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require 'fileutils'
require 'digest'

class DuplicateFileCleaner
  def initialize
    @posts_dir = Pathname.new('./content/posts')
    @duplicate_files = []
    @different_files = []
    @stats = {
      total_dirs: 0,
      dirs_with_duplicates: 0,
      identical_files: 0,
      different_files: 0,
      total_duplicate_files: 0
    }
  end

  # メイン処理
  def run
    puts "🔍 Hugo 重複ファイル調査・削除ツール (完全版)"
    puts "📝 index 2.md, image 2.jpeg など全ての ' 2' ファイル対応"
    puts "=" * 60

    # 事前チェック
    duplicate_files_found = Dir.glob("#{@posts_dir}/**/* 2.*")
    puts "🔍 ' 2' パターンファイル: #{duplicate_files_found.length} 個発見"
    
    if duplicate_files_found.empty?
      puts "❌ 重複ファイルが見つかりませんでした"
      return
    end

    puts "📄 発見例:"
    duplicate_files_found.first(5).each { |f| puts "  #{f}" }
    puts ""

    # 分析実行
    analyze_duplicates

    return if @stats[:dirs_with_duplicates] == 0

    # メニュー表示
    show_menu
  end

  # 重複ファイルの調査
  def analyze_duplicates
    puts "📂 ディレクトリ分析中..."
    
    bundle_dirs = @posts_dir.children.select(&:directory?)
    @stats[:total_dirs] = bundle_dirs.length

    bundle_dirs.each_with_index do |dir, index|
      print "\r進捗: #{index + 1}/#{bundle_dirs.length}" if index % 100 == 0
      analyze_directory(dir)
    end

    puts "\n"
    display_summary
  end

  # 各ディレクトリの分析
  def analyze_directory(dir)
    duplicate_pairs = find_duplicate_pairs(dir)
    return if duplicate_pairs.empty?

    @stats[:dirs_with_duplicates] += 1

    duplicate_pairs.each do |original, duplicate|
      analyze_file_pair(original, duplicate, dir)
    end
  end

  # 重複ペアを検出
  def find_duplicate_pairs(dir)
    pairs = []
    files = dir.children.select(&:file?)
    
    files.each do |file|
      filename = file.basename.to_s
      
      # " 2.extension" パターンをチェック
      if filename.match(/^(.+)\s2(\..+)$/)
        base_name = $1
        extension = $2
        original_name = "#{base_name}#{extension}"
        original_file = dir / original_name
        
        if original_file.exist?
          pairs << [original_file, file]
        end
      end
    end
    
    pairs
  end

  # ファイルペアの分析
  def analyze_file_pair(original, duplicate, dir)
    @stats[:total_duplicate_files] += 1

    if image_file?(original)
      compare_image_files(original, duplicate, dir)
    else
      compare_text_files(original, duplicate, dir)
    end
  end

  # 画像ファイル判定
  def image_file?(file)
    %w[.jpg .jpeg .png .gif .webp .svg .bmp .tiff].include?(file.extname.downcase)
  end

  # 画像ファイル比較
  def compare_image_files(original, duplicate, dir)
    hash1 = calculate_file_hash(original, binary: true)
    hash2 = calculate_file_hash(duplicate, binary: true)

    file_info = {
      dir: dir,
      original: original,
      duplicate: duplicate,
      type: 'image'
    }

    if hash1 == hash2
      @duplicate_files << file_info.merge(identical: true)
      @stats[:identical_files] += 1
    else
      @different_files << file_info.merge(identical: false)
      @stats[:different_files] += 1
    end
  end

  # テキストファイル比較
  def compare_text_files(original, duplicate, dir)
    hash1 = calculate_file_hash(original, binary: false)
    hash2 = calculate_file_hash(duplicate, binary: false)

    file_info = {
      dir: dir,
      original: original,
      duplicate: duplicate,
      type: 'text'
    }

    if hash1 == hash2
      @duplicate_files << file_info.merge(identical: true)
      @stats[:identical_files] += 1
    else
      @different_files << file_info.merge(identical: false)
      @stats[:different_files] += 1
    end
  end

  # ファイルハッシュ計算
  def calculate_file_hash(file_path, binary: false)
    if binary
      Digest::MD5.hexdigest(File.read(file_path, mode: 'rb'))
    else
      Digest::MD5.hexdigest(File.read(file_path, encoding: 'utf-8'))
    end
  rescue => e
    puts "❌ ハッシュ計算エラー: #{file_path.basename} - #{e.message}"
    nil
  end

  # サマリー表示
  def display_summary
    puts "📊 分析結果"
    puts "=" * 40
    puts "総ディレクトリ数: #{@stats[:total_dirs]}"
    puts "重複ファイルのあるディレクトリ: #{@stats[:dirs_with_duplicates]}"
    puts "重複ファイル総数: #{@stats[:total_duplicate_files]}"
    puts "同一内容: #{@stats[:identical_files]} 個"
    puts "異なる内容: #{@stats[:different_files]} 個"

    if @duplicate_files.any?
      puts "\n✅ 削除可能ファイル:"
      
      by_type = @duplicate_files.group_by { |f| f[:type] }
      by_type.each do |type, files|
        puts "  #{type.capitalize}: #{files.length} 個"
        files.first(3).each do |file|
          puts "    📁 #{file[:dir].basename}/#{file[:duplicate].basename}"
        end
        puts "    ..." if files.length > 3
      end
    end

    if @different_files.any?
      puts "\n⚠️  手動確認必要: #{@different_files.length} 個"
    end
  end

  # メニュー表示
  def show_menu
    puts "\n📋 選択してください:"
    puts "1. 同一ファイルの削除 (ドライラン)"
    puts "2. 同一ファイルの削除 (実行)"
    puts "3. 詳細表示"
    puts "4. 終了"

    loop do
      print "\n[1-4]: "
      choice = gets.chomp

      case choice
      when '1'
        remove_duplicates(dry_run: true)
      when '2'
        confirm_and_remove
      when '3'
        show_details
      when '4'
        puts "終了します"
        break
      else
        puts "1-4を入力してください"
      end
    end
  end

  # 削除実行
  def remove_duplicates(dry_run: true)
    return if @duplicate_files.empty?

    puts "\n🗑️  #{dry_run ? 'ドライラン' : '削除実行'}"
    puts "-" * 30

    removed_count = 0

    @duplicate_files.each do |file|
      duplicate_path = file[:duplicate]
      relative_path = "#{file[:dir].basename}/#{duplicate_path.basename}"
      
      if dry_run
        puts "🔍 [DRY] #{relative_path}"
      else
        begin
          FileUtils.rm(duplicate_path)
          puts "✅ #{relative_path}"
          removed_count += 1
        rescue => e
          puts "❌ #{relative_path} - #{e.message}"
        end
      end
    end

    puts "\n📊 #{dry_run ? '削除予定' : '削除完了'}: #{dry_run ? @duplicate_files.length : removed_count} 個"
  end

  # 削除確認
  def confirm_and_remove
    return if @duplicate_files.empty?

    puts "\n⚠️  #{@duplicate_files.length} 個のファイルを削除します"
    print "本当に実行しますか？ [y/N]: "
    
    if gets.chomp.downcase.start_with?('y')
      remove_duplicates(dry_run: false)
    else
      puts "キャンセルしました"
    end
  end

  # 詳細表示
  def show_details
    puts "\n📄 詳細情報"
    puts "-" * 30

    @duplicate_files.first(10).each_with_index do |file, index|
      puts "#{index + 1}. #{file[:dir].basename}"
      puts "   Original: #{file[:original].basename}"
      puts "   Duplicate: #{file[:duplicate].basename}"
      puts "   Type: #{file[:type]}"
      puts ""
    end

    puts "..." if @duplicate_files.length > 10
  end
end

if __FILE__ == $0
  cleaner = DuplicateFileCleaner.new
  cleaner.run
end