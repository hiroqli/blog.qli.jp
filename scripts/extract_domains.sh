#!/bin/bash

# 記事内のリンクドメインを抽出するスクリプト
# 使用法: ./extract_domains.sh [検索ディレクトリ]

# デフォルトの検索ディレクトリ
SEARCH_DIR="${1:-content/posts}"

# 色付け用の定数
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ヘルプ表示
show_help() {
    echo "記事内のリンクドメインを抽出します"
    echo ""
    echo "使用法:"
    echo "  $0 [検索ディレクトリ]"
    echo ""
    echo "オプション:"
    echo "  -h, --help      このヘルプを表示"
    echo "  -s, --sort      ドメインをアルファベット順にソート"
    echo "  -c, --count     各ドメインの出現回数を表示"
    echo "  -u, --unique    重複を除いてユニークなドメインのみ"
    echo "  -f, --files     どのファイルに含まれるかも表示"
    echo "  -e, --exclude   除外するドメインを指定（カンマ区切り）"
    echo ""
    echo "例:"
    echo "  $0                              # 基本的な抽出"
    echo "  $0 -s -c                        # ソート＋カウント"
    echo "  $0 -f content/blog              # ファイル情報付き"
    echo "  $0 -e \"localhost,127.0.0.1\"    # 除外ドメイン指定"
}

# オプション解析
SORT_OUTPUT=false
COUNT_DOMAINS=false
UNIQUE_ONLY=false
SHOW_FILES=false
EXCLUDE_DOMAINS=""
SEARCH_DIR_SET=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -s|--sort)
            SORT_OUTPUT=true
            shift
            ;;
        -c|--count)
            COUNT_DOMAINS=true
            shift
            ;;
        -u|--unique)
            UNIQUE_ONLY=true
            shift
            ;;
        -f|--files)
            SHOW_FILES=true
            shift
            ;;
        -e|--exclude)
            EXCLUDE_DOMAINS="$2"
            shift 2
            ;;
        -*)
            echo "未知のオプション: $1"
            show_help
            exit 1
            ;;
        *)
            if [ $SEARCH_DIR_SET = false ]; then
                SEARCH_DIR="$1"
                SEARCH_DIR_SET=true
            else
                echo "複数のディレクトリは指定できません: $1"
                exit 1
            fi
            shift
            ;;
    esac
done

# デフォルトディレクトリが変更されていない場合のみ設定
if [ $SEARCH_DIR_SET = false ]; then
    SEARCH_DIR="content/posts"
fi

# ディレクトリの存在確認
if [ ! -d "$SEARCH_DIR" ]; then
    echo -e "${RED}エラー: ディレクトリ '$SEARCH_DIR' が見つかりません${NC}"
    exit 1
fi

echo -e "${BLUE}記事内のリンクドメインを抽出中...${NC}"
echo -e "${YELLOW}検索ディレクトリ: $SEARCH_DIR${NC}"
echo ""

# 一時ファイル
temp_file=$(mktemp)
temp_domains=$(mktemp)
temp_results=$(mktemp)

# クリーンアップ関数
cleanup() {
    rm -f "$temp_file" "$temp_domains" "$temp_results"
}
trap cleanup EXIT

# ドメイン抽出処理
extract_domains() {
    local file="$1"
    
    # MarkdownリンクとHTMLリンクの両方を抽出
    # Markdownリンク: [text](url) または [text]: url
    # HTMLリンク: <a href="url"> または src="url"
    grep -oE '\[.*\]\(https?://[^)]+\)|\[.*\]: https?://[^ ]+|href="https?://[^"]+"|src="https?://[^"]+"|https?://[^ )<>"\`]+' "$file" 2>/dev/null | \
    # URLを抽出
    grep -oE 'https?://[^ )<>"\`]+' | \
    # ドメイン部分のみ抽出
    sed -E 's|^https?://([^/]+).*|\1|' | \
    # ポート番号削除
    sed -E 's|:[0-9]+$||' | \
    # wwwプレフィックス削除（オプション）
    sed -E 's|^www\.||' | \
    # 空行削除
    grep -v '^$' | \
    # 各行にファイル名を追加（必要な場合）
    if [ $SHOW_FILES = true ]; then
        sed "s|$| ($file)|"
    else
        cat
    fi
}

# 除外ドメインのパターン作成
exclude_pattern=""
if [ -n "$EXCLUDE_DOMAINS" ]; then
    # カンマ区切りをパイプ区切りに変換
    exclude_pattern=$(echo "$EXCLUDE_DOMAINS" | sed 's/,/|/g')
fi

# 全ファイルを処理
total_files=0
total_domains=0

echo -e "${CYAN}処理中のファイル:${NC}"

while IFS= read -r -d '' file; do
    ((total_files++))
    echo -n "."
    
    # ドメイン抽出
    extract_domains "$file" >> "$temp_domains"
    
done < <(find "$SEARCH_DIR" -name "*.md" -type f -print0 2>/dev/null)

echo ""
echo ""

# 除外ドメインをフィルタリング
if [ -n "$exclude_pattern" ]; then
    if [ $SHOW_FILES = true ]; then
        # ファイル情報ありの場合
        grep -vE "^($exclude_pattern) " "$temp_domains" > "$temp_results"
    else
        # ファイル情報なしの場合
        grep -vE "^($exclude_pattern)$" "$temp_domains" > "$temp_results"
    fi
else
    cp "$temp_domains" "$temp_results"
fi

# 結果処理
if [ $UNIQUE_ONLY = true ]; then
    if [ $SHOW_FILES = true ]; then
        # ファイル情報付きでユニーク化（ドメイン部分のみでユニーク）
        sort "$temp_results" | awk '!seen[substr($0, 1, index($0, " ")-1)]++' > "$temp_file"
    else
        sort -u "$temp_results" > "$temp_file"
    fi
else
    cp "$temp_results" "$temp_file"
fi

# ソート処理
if [ $SORT_OUTPUT = true ]; then
    sort "$temp_file" > "$temp_results"
    cp "$temp_results" "$temp_file"
fi

# 結果表示
total_domains=$(wc -l < "$temp_file" | tr -d ' ')

if [ $total_domains -eq 0 ]; then
    echo -e "${RED}リンクドメインは見つかりませんでした${NC}"
    exit 0
fi

echo -e "${GREEN}見つかったドメイン: $total_domains 個（$total_files ファイルを処理）${NC}"

if [ -n "$exclude_pattern" ]; then
    echo -e "${YELLOW}除外パターン: $EXCLUDE_DOMAINS${NC}"
fi

echo ""

# カウント表示モード
if [ $COUNT_DOMAINS = true ]; then
    echo -e "${CYAN}== ドメイン別出現回数 ==${NC}"
    if [ $SHOW_FILES = true ]; then
        # ファイル情報ありの場合、ドメイン部分のみでカウント
        cut -d' ' -f1 "$temp_file" | sort | uniq -c | sort -nr | while read count domain; do
            printf "${GREEN}%3d${NC} %s\n" "$count" "$domain"
        done
    else
        sort "$temp_file" | uniq -c | sort -nr | while read count domain; do
            printf "${GREEN}%3d${NC} %s\n" "$count" "$domain"
        done
    fi
else
    # 通常の一覧表示
    echo -e "${CYAN}== ドメイン一覧 ==${NC}"
    while IFS= read -r line; do
        if [ $SHOW_FILES = true ]; then
            domain=$(echo "$line" | cut -d' ' -f1)
            file_info=$(echo "$line" | cut -d' ' -f2-)
            echo -e "${GREEN}${domain}${NC} ${YELLOW}${file_info}${NC}"
        else
            echo -e "${GREEN}${line}${NC}"
        fi
    done < "$temp_file"
fi

echo ""
echo -e "${BLUE}処理完了${NC}"

# 統計情報
unique_domains=$(if [ $SHOW_FILES = true ]; then cut -d' ' -f1 "$temp_file"; else cat "$temp_file"; fi | sort -u | wc -l | tr -d ' ')
echo -e "${YELLOW}統計: ユニークドメイン数 $unique_domains 個${NC}"