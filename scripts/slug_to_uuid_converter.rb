#!/usr/bin/env ruby
require 'fileutils'
require 'yaml'
require 'date'

class SlugToUuidConverter
  def initialize(content_dir = 'content/posts')
    @content_dir = content_dir
    @dry_run = false
  end

  def convert_slugs(dry_run: false)
    @dry_run = dry_run
    
    puts "#{@dry_run ? '[DRY RUN] ' : ''}Slug → UUID変換を開始します..."
    puts "対象ディレクトリ: #{@content_dir}"
    
    # 現在のディレクトリ一覧を表示
    puts "\n現在のディレクトリ一覧:"
    Dir.glob("#{@content_dir}/*/index.md").each do |file_path|
      dir_path = File.dirname(file_path)
      current_dirname = File.basename(dir_path)
      puts "  #{current_dirname}"
    end
    puts ""
    
    processed_count = 0
    updated_count = 0
    
    Dir.glob("#{@content_dir}/*/index.md").each do |file_path|
      result = process_post(file_path)
      processed_count += 1
      updated_count += 1 if result
    end
    
    puts "\n処理結果:"
    puts "  処理対象: #{processed_count}"
    puts "  更新: #{updated_count}"
    puts "変換完了！"
  end

  private

  def process_post(file_path)
    dir_path = File.dirname(file_path)
    current_dirname = File.basename(dir_path)
    
    puts "処理中: #{current_dirname}"
    
    # 記事ファイル内容を読み込み
    content = File.read(file_path)
    
    # Front matterからslugを取得
    current_slug = extract_slug_from_file(content)
    
    if current_slug.nil?
      puts "  警告: slugフィールドが見つかりません"
      return false
    end
    
    # YYYYMM-UUID形式かチェック
    if current_slug.match?(/^\d{6}-(.+)$/)
      # UUIDの部分を抽出
      uuid_part = current_slug.match(/^\d{6}-(.+)$/)[1]
      
      puts "  現在のslug: #{current_slug}"
      puts "  新しいslug: #{uuid_part}"
      
      unless @dry_run
        # slugをUUIDのみに変更
        updated_content = update_slug_in_content(content, current_slug, uuid_part)
        File.write(file_path, updated_content)
        puts "  更新完了"
      else
        puts "  [DRY RUN] 更新が必要"
      end
      
      return true
      
    elsif current_slug.match?(/^[a-f0-9\-]{36}$/i)
      puts "  スキップ: 既にUUID形式 (#{current_slug})"
      return false
      
    else
      puts "  スキップ: 不明な形式 (#{current_slug})"
      return false
    end
  end

  def extract_slug_from_file(content)
    # Front matterからslugを抽出
    if content.match(/^---\s*\n(.*?)\n---\s*\n/m)
      front_matter = $1
      begin
        yaml_data = YAML.load(front_matter)
        slug_value = yaml_data['slug'] || yaml_data['Slug']
        
        if slug_value && !slug_value.to_s.strip.empty?
          return slug_value.to_s.strip.gsub(/^["']|["']$/, '') # クォート除去
        end
      rescue => e
        puts "    YAML解析エラー: #{e.message}"
      end
    end
    
    nil
  end

  def update_slug_in_content(content, old_slug, new_slug)
    # Front matter内のslugを更新（クォートありなし両方に対応）
    updated_content = content.gsub(/^(\s*slug:\s*)(["']?)#{Regexp.escape(old_slug)}\2(\s*)$/m) do
      prefix = $1
      quote = $2
      suffix = $3
      "#{prefix}#{quote}#{new_slug}#{quote}#{suffix}"
    end
    
    updated_content
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
    
    opts.on("--dry-run", "実際の変更は行わず、プレビューのみ表示") do
      options[:dry_run] = true
    end
    
    opts.on("-h", "--help", "このヘルプを表示") do
      puts opts
      exit
    end
  end.parse!
  
  content_dir = options[:dir] || 'content/posts'
  converter = SlugToUuidConverter.new(content_dir)
  converter.convert_slugs(dry_run: options[:dry_run])
end