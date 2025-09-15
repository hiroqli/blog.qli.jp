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
      different_files: 0
    }
  end

  # 重複ファイルの調査
  def analyze_duplicates
    puts "🔍 index 2.md ファイルの調査を開始..."
    puts "対象ディレクトリ: #{@posts_dir}"
    puts "=" * 60

    unless @posts_dir.exist?
      puts "❌ postsディレクトリが見つかりません: #{@posts_dir}"
      return
    end

    bundle_dirs = @posts_dir.children.select(&:directory?)
    @stats[:total_dirs] = bundle_dirs.length

    puts "📂 #{bundle_dirs.length} 個のディレクトリをチェック中...\n"

    bundle_dirs.each do |dir|
      analyze_directory(dir)
    end

    display_summary
  end

  # 各ディレクトリの分析
  def analyze_directory(dir)
    index_md = dir / 'index.md'
    index2_md = dir / 'index 2.md'

    return unless index_md.exist? && index2_md.exist?

    @stats[:dirs_with_duplicates] += 1
    dir_name = dir.basename.to_s

    puts "📁 #{dir_name}"

    # ファイルサイズ確認
    size1 = index_md.size
    size2 = index2_md.size

    puts "   📄 index.md: #{size1} bytes"
    puts "   📄 index 2.md: #{size2} bytes"

    # ハッシュ値で内容比較
    hash1 = calculate_file_hash(index_md)
    hash2 = calculate_file_hash(index2_md)

    if hash1 == hash2
      puts "   ✅ 内容が同一 - 削除可能"
      @duplicate_files << {
        dir: dir,
        dir_name: dir_name,
        size: size1
      }
      @stats[:identical_files] += 1
    else
      puts "   ⚠️  内容が異なる - 手動確認が必要"
      
      # 簡単な差分チェック
      check_difference(index_md, index2_md, dir_name)
      
      @different_files << {
        dir: dir,
        dir_name: dir_name,
        size1: size1,
        size2: size2
      }
      @stats[:different_files] += 1
    end

    puts ""
  end

  # ファイルハッシュ計算
  def calculate_file_hash(file_path)
    Digest::MD5.hexdigest(File.read(file_path, encoding: 'utf-8'))
  rescue => e
    puts "   ❌ ハッシュ計算エラー: #{e.message}"
    nil
  end

  # 差分の簡単チェック
  def check_difference(file1, file2, dir_name)
    begin
      content1 = File.read(file1, encoding: 'utf-8')
      content2 = File.read(file2, encoding: 'utf-8')

      lines1 = content1.lines.length
      lines2 = content2.lines.length

      puts "      index.md: #{lines1} 行"
      puts "      index 2.md: #{lines2} 行"

      # 簡単な差分分析
      if content1.include?('---') && content2.include?('---')
        puts "      💡 両方ともフロントマターあり"
      elsif content1.include?('---') || content2.include?('---')
        puts "      💡 片方のみフロントマターあり"
      end

    rescue => e
      puts "      ❌ 差分チェックエラー: #{e.message}"
    end
  end

  # サマリー表示
  def display_summary
    puts "📊 調査結果サマリー"
    puts "=" * 60
    puts "総ディレクトリ数: #{@stats[:total_dirs]}"
    puts "重複ファイルのあるディレクトリ: #{@stats[:dirs_with_duplicates]}"
    puts "同一内容ファイル: #{@stats[:identical_files]} 個"
    puts "異なる内容ファイル: #{@stats[:different_files]} 個"

    if @duplicate_files.any?
      puts "\n✅ 削除可能な同一ファイル:"
      puts "-" * 40
      @duplicate_files.each do |file|
        puts "   📁 #{file[:dir_name]} (#{file[:size]} bytes)"
      end
    end

    if @different_files.any?
      puts "\n⚠️  手動確認が必要なファイル:"
      puts "-" * 40
      @different_files.each do |file|
        puts "   📁 #{file[:dir_name]} (#{file[:size1]} vs #{file[:size2]} bytes)"
      end
    end
  end

  # 同一ファイルの削除
  def remove_duplicate_files(dry_run: true)
    return if @duplicate_files.empty?

    puts "\n🗑️  重複ファイル削除#{dry_run ? ' (ドライラン)' : ''}"
    puts "=" * 60

    removed_count = 0

    @duplicate_files.each do |file|
      index2_path = file[:dir] / 'index 2.md'
      
      if dry_run
        puts "🔍 [DRY RUN] 削除予定: #{file[:dir_name]}/index 2.md"
      else
        begin
          FileUtils.rm(index2_path)
          puts "✅ 削除完了: #{file[:dir_name]}/index 2.md"
          removed_count += 1
        rescue => e
          puts "❌ 削除失敗: #{file[:dir_name]}/index 2.md - #{e.message}"
        end
      end
    end

    unless dry_run
      puts "\n📊 削除完了: #{removed_count}/#{@duplicate_files.length} ファイル"
    end
  end

  # 異なる内容のファイルの詳細確認
  def show_differences
    return if @different_files.empty?

    puts "\n🔍 内容が異なるファイルの詳細"
    puts "=" * 60

    @different_files.each_with_index do |file, index|
      puts "\n#{index + 1}. 📁 #{file[:dir_name]}"
      puts "-" * 40

      index_md = file[:dir] / 'index.md'
      index2_md = file[:dir] / 'index 2.md'

      begin
        content1 = File.read(index_md, encoding: 'utf-8')
        content2 = File.read(index2_md, encoding: 'utf-8')

        puts "📄 index.md (#{content1.lines.length} 行, #{content1.bytesize} bytes)"
        puts content1.lines.first(3).join.strip
        puts "..." if content1.lines.length > 3

        puts "\n📄 index 2.md (#{content2.lines.length} 行, #{content2.bytesize} bytes)"  
        puts content2.lines.first(3).join.strip
        puts "..." if content2.lines.length > 3

        # 先頭10行の比較
        lines1 = content1.lines.first(10)
        lines2 = content2.lines.first(10)

        if lines1 != lines2
          puts "\n💡 先頭部分で差分を検出"
        end

      rescue => e
        puts "❌ ファイル読み込みエラー: #{e.message}"
      end
    end
  end

  # メイン処理
  def run
    puts "🔍 Hugo index 2.md 重複ファイル調査・削除ツール"
    puts "=" * 60

    # 分析実行
    analyze_duplicates

    return if @stats[:dirs_with_duplicates] == 0

    puts "\n📋 実行可能なアクション:"
    puts "1. 同一ファイルの削除 (ドライラン)"
    puts "2. 同一ファイルの削除 (実行)"
    puts "3. 異なるファイルの詳細表示"
    puts "4. 終了"

    loop do
      print "\n選択してください [1-4]: "
      choice = gets.chomp

      case choice
      when '1'
        remove_duplicate_files(dry_run: true)
      when '2'
        if @duplicate_files.any?
          print "\n本当に #{@duplicate_files.length} 個のファイルを削除しますか？ [y/N]: "
          confirm = gets.chomp.downcase
          
          if confirm.start_with?('y')
            remove_duplicate_files(dry_run: false)
          else
            puts "キャンセルしました"
          end
        else
          puts "削除対象のファイルがありません"
        end
      when '3'
        show_differences
      when '4'
        puts "終了します"
        break
      else
        puts "無効な選択です。1-4を入力してください。"
      end
    end
  end
end

if __FILE__ == $0
  cleaner = DuplicateFileCleaner.new
  cleaner.run
end