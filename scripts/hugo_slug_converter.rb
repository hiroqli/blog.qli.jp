#!/usr/bin/env ruby
require 'fileutils'
require 'yaml'
require 'date'

class HugoSlugConverter
  def initialize(content_dir = 'content/posts')
    @content_dir = content_dir
    @dry_run = false
    @force_convert = false
  end

  def convert_slugs(dry_run: false, force: false)
    @dry_run = dry_run
    @force_convert = force
    
    puts "#{@dry_run ? '[DRY RUN] ' : ''}Hugo Slug変換を開始します..."
    puts "対象ディレクトリ: #{@content_dir}"
    puts "強制変換モード: #{@force_convert ? 'ON' : 'OFF'}"
    
    # まず現在のディレクトリ構造を確認
    puts "\n現在のディレクトリ一覧:"
    Dir.glob("#{@content_dir}/*/index.md").each do |file_path|
      dir_path = File.dirname(file_path)
      current_dirname = File.basename(dir_path)
      puts "  #{current_dirname}"
    end
    puts ""
    
    Dir.glob("#{@content_dir}/*/index.md").each do |file_path|
      process_post(file_path)
    end
    
    puts "変換完了！"
  end

  private

  def process_post(file_path)
    dir_path = File.dirname(file_path)
    current_dirname = File.basename(dir_path)
    
    # 既に変換済みかチェック（強制変換モードでない場合のみ）
    puts "チェック中: #{current_dirname}"
    if !@force_convert && current_dirname.match?(/^\d{6}-/)
      puts "スキップ: #{current_dirname} (既に変換済み - 6桁数字で始まる)"
      puts "  強制変換するには --force オプションを使用してください"
      return
    elsif @force_convert && current_dirname.match?(/^\d{6}-/)
      puts "強制変換: #{current_dirname} (変換済みだが強制実行)"
    end
    
    # ファイル内容からdate情報を取得（必須）
    date = extract_date_from_file(file_path)
    
    if date.nil?
      puts "エラー: #{current_dirname} - 記事ファイル内にdate情報が見つかりません"
      return
    end
    
    # slugフィールドからUUIDを取得、なければディレクトリ名から抽出
    uuid = extract_slug_from_file(file_path)
    if uuid.nil?
      uuid_match = current_dirname.match(/([a-f0-9\-]{8,})$/i)
      uuid = uuid_match ? uuid_match[1] : generate_fallback_uuid
    end
    
    # 新しいディレクトリ名を生成（YYYYMM-UUID形式）
    new_dirname = "#{date.strftime('%Y%m')}-#{uuid}"
    new_dir_path = File.join(File.dirname(dir_path), new_dirname)
    
    if current_dirname == new_dirname
      # ディレクトリ名は正しいが、記事内のslugが一致しているかチェック
      current_slug = extract_slug_from_file(file_path)
      if current_slug != new_dirname
        puts "slug不一致検出: #{current_dirname}"
        puts "  ファイル内slug: #{current_slug}"
        puts "  期待するslug: #{new_dirname}"
        
        unless @dry_run
          update_slug_in_file(file_path, new_dirname)
          puts "  slug更新完了"
        else
          puts "  [DRY RUN] slug更新が必要"
        end
      else
        puts "変更なし: #{current_dirname} (ディレクトリ名とslugが一致)"
      end
      return
    end
    
    puts "#{@dry_run ? '[DRY RUN] ' : ''}変換: #{current_dirname} → #{new_dirname}"
    puts "  日付: #{date.strftime('%Y-%m-%d')}"
    puts "  UUID: #{uuid}"
    
    unless @dry_run
      if File.exist?(new_dir_path)
        puts "エラー: #{new_dirname} は既に存在します"
        return
      end
      
      # ディレクトリ名を変更
      FileUtils.mv(dir_path, new_dir_path)
      
      # 記事ファイル内のslugも更新
      new_index_file = File.join(new_dir_path, 'index.md')
      update_slug_in_file(new_index_file, new_dirname)
      
      puts "完了: #{new_dirname}"
    end
  end

  def extract_date_from_file(file_path)
    content = File.read(file_path)
    
    # Front matterからdateを抽出
    if content.match(/^---\s*\n(.*?)\n---\s*\n/m)
      front_matter = $1
      begin
        yaml_data = YAML.load(front_matter)
        date_value = yaml_data['date'] || yaml_data['Date']
        
        if date_value
          # ISO形式やその他の日付形式をパース
          return DateTime.parse(date_value.to_s).to_date
        end
      rescue => e
        puts "YAML解析エラー: #{file_path} - #{e.message}"
      end
    end
    
    nil
  end

  def extract_slug_from_file(file_path)
    content = File.read(file_path)
    
    # Front matterからslugを抽出
    if content.match(/^---\s*\n(.*?)\n---\s*\n/m)
      front_matter = $1
      begin
        yaml_data = YAML.load(front_matter)
        slug_value = yaml_data['slug'] || yaml_data['Slug']
        
        if slug_value && !slug_value.to_s.strip.empty?
          return slug_value.to_s.strip
        end
      rescue => e
        puts "YAML解析エラー: #{file_path} - #{e.message}"
      end
    end
    
    nil
  end



  def update_slug_in_file(file_path, new_slug)
    content = File.read(file_path)
    
    # Front matter内のslugを更新
    updated_content = content.gsub(/^(\s*slug:\s*["']?)([^"'\n]+)(["']?\s*)$/m) do |match|
      prefix = $1
      old_slug = $2
      suffix = $3
      puts "  slug更新: #{old_slug} → #{new_slug}"
      "#{prefix}#{new_slug}#{suffix}"
    end
    
    # ファイルに書き戻し
    File.write(file_path, updated_content)
  end

  def generate_fallback_uuid
    # 簡単なランダム文字列を生成
    SecureRandom.hex(16) rescue Random.hex(16) rescue Time.now.to_i.to_s(16)
  end
end

# スクリプトの実行部分
if __FILE__ == $0
  require 'optparse'
  
  options = {}
  OptionParser.new do |opts|
    opts.banner = "使用法: #{$0} [オプション]"
    
    opts.on("-d", "--dir DIR", "content/postsディレクトリのパス") do |dir|
      options[:dir] = dir
    end
    
    opts.on("--force", "既に変換済みのディレクトリも強制的に再変換") do
      options[:force] = true
    end
    
    opts.on("--dry-run", "実際の変更は行わず、プレビューのみ表示") do
      options[:dry_run] = true
    end
    
    opts.on("-h", "--help", "このヘルプを表示") do
      puts opts
      exit
    end
  end.parse!
  
  content_dir = options[:dir] || 'content/posts'
  converter = HugoSlugConverter.new(content_dir)
  converter.convert_slugs(dry_run: options[:dry_run], force: options[:force])
end