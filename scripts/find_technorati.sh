#!/bin/bash

# Technorati Tags を含む記事を検索するスクリプト
# 使用法: ./find_technorati.sh [検索ディレクトリ]

# デフォルトの検索ディレクトリ
SEARCH_DIR="${1:-content/posts}"

# 色付け用の定数
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ヘルプ表示
show_help() {
    echo "Technorati Tags を含む記事を検索します"
    echo ""
    echo "使用法:"
    echo "  $0 [検索ディレクトリ]"
    echo ""
    echo "オプション:"
    echo "  -h, --help     このヘルプを表示"
    echo "  -v, --verbose  詳細出力モード"
    echo "  -c, --count    件数のみ表示"
    echo ""
    echo "例:"
    echo "  $0                    # content/posts で検索"
    echo "  $0 content/blog       # content/blog で検索"
    echo "  $0 -v content/posts   # 詳細出力"
    echo "  $0 -c                 # 件数のみ"
}

# オプション解析
VERBOSE=false
COUNT_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -c|--count)
            COUNT_ONLY=true
            shift
            ;;
        -*)
            echo "未知のオプション: $1"
            show_help
            exit 1
            ;;
        *)
            SEARCH_DIR="$1"
            shift
            ;;
    esac
done

# ディレクトリの存在確認
if [ ! -d "$SEARCH_DIR" ]; then
    echo -e "${RED}エラー: ディレクトリ '$SEARCH_DIR' が見つかりません${NC}"
    exit 1
fi

echo -e "${BLUE}Technorati Tags を含む記事を検索中...${NC}"
echo -e "${YELLOW}検索ディレクトリ: $SEARCH_DIR${NC}"
echo ""

# 検索実行
found_files=()
total_count=0

# Markdown ファイルを再帰的に検索
while IFS= read -r -d '' file; do
    if grep -l -i "technorati" "$file" >/dev/null 2>&1; then
        found_files+=("$file")
        ((total_count++))
    fi
done < <(find "$SEARCH_DIR" -name "*.md" -type f -print0 2>/dev/null)

# 結果表示
if [ $COUNT_ONLY = true ]; then
    echo "$total_count"
    exit 0
fi

if [ $total_count -eq 0 ]; then
    echo -e "${RED}Technorati Tags を含む記事は見つかりませんでした${NC}"
    exit 0
fi

echo -e "${GREEN}見つかった記事: $total_count 件${NC}"
echo ""

# ファイル一覧表示
for file in "${found_files[@]}"; do
    echo -e "${BLUE}📄 $file${NC}"
    
    if [ $VERBOSE = true ]; then
        # ファイルの詳細情報
        echo -e "   ${YELLOW}作成日時:${NC} $(stat -f "%SB" "$file" 2>/dev/null || stat -c "%y" "$file" 2>/dev/null || echo "不明")"
        echo -e "   ${YELLOW}サイズ:${NC}   $(du -h "$file" | cut -f1)"
        
        # Technorati関連行を抽出
        echo -e "   ${YELLOW}該当箇所:${NC}"
        grep -n -i "technorati" "$file" | head -3 | while read -r line; do
            line_num=$(echo "$line" | cut -d: -f1)
            content=$(echo "$line" | cut -d: -f2-)
            echo -e "     ${GREEN}L$line_num:${NC} $(echo "$content" | sed 's/^[[:space:]]*//' | cut -c1-80)..."
        done
        echo ""
    fi
done

echo ""
echo -e "${GREEN}検索完了: 合計 $total_count 件の記事が見つかりました${NC}"

# 詳細モードでない場合の追加情報
if [ $VERBOSE = false ] && [ $total_count -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}💡 詳細情報を見るには -v オプションを使用してください${NC}"
    echo -e "${YELLOW}   例: $0 -v $SEARCH_DIR${NC}"
fi