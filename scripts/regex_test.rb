#!/usr/bin/env ruby

# 正規表現のテスト
test_text = "![](1__qy7sAwjjNwYynxlG8P234Q.jpeg)"

patterns = [
  /!\[.*?\]\(([^)]+)\)/,                        # ![alt](path)
  /<img[^>]*src=["']([^"']+?)["'][^>]*>/i,      # <img src="path">
  /(?<!\!)\[.*?\]\(([^)]*\.(jpg|jpeg|png|gif|webp|svg)[^)]*)\)/i,  # [text](image.jpg) - ![を除外
  /https?:\/\/[^\s)]*\.(jpg|jpeg|png|gif|webp|svg)/i,  # 直接URL
  /https?:\/\/cdn-images-\d+\.medium\.com\/[^\s)"]*/i,  # Medium CDN
  /https?:\/\/miro\.medium\.com\/[^\s)"]*/i,             # Miro CDN
]

puts "テスト文字列: #{test_text}"
puts "=" * 50

patterns.each_with_index do |pattern, index|
  puts "\nパターン #{index + 1}: #{pattern.inspect}"
  
  matches = test_text.scan(pattern)
  puts "  マッチ結果: #{matches.inspect}"
  
  matches.each do |match|
    if match.is_a?(Array)
      result = match[0]
      puts "  → 抽出される値: '#{result}'"
    else
      result = match
      puts "  → 抽出される値: '#{result}'"
    end
  end
end