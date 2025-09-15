#!/bin/bash

# 記事の最後に画像がある記事を検索するスクリプト
# 使用法: ./find_ending_images.sh [検索ディレクトリ]

# デフォルトの検索ディレクトリ
SEARCH_DIR="content/posts"

# 色付け用の定数
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# ヘルプ表示
show_help() {
    echo "記事の最後に画像がある記事を検索します"
    echo ""
    echo "使用法:"
    echo "  $0 [検索ディレクトリ]"
    echo ""
    echo "オプション:"
    echo "  -h, --help      このヘルプを表示"
    echo "  -v, --verbose   詳細出力（画像情報も表示）"
    echo "  -c, --count     件数のみ表示"
    echo "  -l, --lines N   記事末尾から検索する行数（デフォルト: 10）"
    echo "  -t, --types     検出する画像タイプを指定（デフォルト: all）"
    echo "  -s, --show      該当する画像行を表示"
    echo "  -o, --open      VS Codeで見つかったファイルを開く"
    echo ""
    echo "画像タイプ:"
    echo "  markdown        Markdown形式の画像 ![alt](url)"
    echo "  html            HTML形式の画像 <img src=\"url\">"
    echo "  all             すべての形式（デフォルト）"
    echo ""
    echo "例:"
    echo "  $0                           # 基本検索"
    echo "  $0 -v                        # 詳細表示"
    echo "  $0 -l 5                      # 末尾5行のみ検索"
    echo "  $0 -t markdown               # Markdown画像のみ"
    echo "  $0 -s content/blog           # 画像行も表示"
    echo "  $0 -o                        # VS Codeで開く"
    echo "  $0 -v -s -o                  # 詳細表示してVS Codeで開く"
}

# オプション解析
VERBOSE=false
COUNT_ONLY=false
TAIL_LINES=10
IMAGE_TYPES="all"
SHOW_IMAGES=false
OPEN_IN_VSCODE=false
SEARCH_DIR_SET=false

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
        -l|--lines)
            TAIL_LINES="$2"
            if ! [[ "$TAIL_LINES" =~ ^[0-9]+$ ]]; then
                echo -e "${RED}エラー: 行数は数値で指定してください${NC}"
                exit 1
            fi
            shift 2
            ;;
        -t|--types)
            IMAGE_TYPES="$2"
            if [[ ! "$IMAGE_TYPES" =~ ^(markdown|html|all)$ ]]; then
                echo -e "${RED}エラー: 画像タイプは markdown, html, all のいずれかです${NC}"
                exit 1
            fi
            shift 2
            ;;
        -s|--show)
            SHOW_IMAGES=true
            shift
            ;;
        -o|--open)
            OPEN_IN_VSCODE=true
            shift
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

# ディレクトリの存在確認
if [ ! -d "$SEARCH_DIR" ]; then
    echo -e "${RED}エラー: ディレクトリ '$SEARCH_DIR' が見つかりません${NC}"
    exit 1
fi

# 画像パターンの定義
get_image_pattern() {
    case $1 in
        "markdown")
            echo '!\[.*\]\([^)]+\)'
            ;;
        "html")
            echo '<img[^>]*src[[:space:]]*=[[:space:]]*['"'"'"][^'"'"'"]*['"'"'"][^>]*>'
            ;;
        "all")
            echo '!\[.*\]\([^)]+\)|<img[^>]*src[[:space:]]*=[[:space:]]*['"'"'"][^'"'"'"]*['"'"'"][^>]*>'
            ;;
    esac
}

# 画像検出関数
has_ending_image() {
    file="$1"
    pattern=$(get_image_pattern "$IMAGE_TYPES")
    
    # ファイルの末尾N行を取得し、空行とコメントを除外
    content=$(tail -n "$TAIL_LINES" "$file" | grep -v '^[[:space:]]*$' | grep -v '^[[:space:]]*<!--')
    
    # 内容が空の場合は false
    if [ -z "$content" ]; then
        return 1
    fi
    
    # 最後の非空行を取得
    last_line=$(echo "$content" | tail -n 1)
    
    # 画像パターンにマッチするかチェック
    if echo "$last_line" | grep -qE "$pattern"; then
        return 0
    else
        return 1
    fi
}

# 画像情報抽出関数
extract_image_info() {
    file="$1"
    pattern=$(get_image_pattern "$IMAGE_TYPES")
    
    # 末尾から画像行を抽出
    image_lines=$(tail -n "$TAIL_LINES" "$file" | grep -v '^[[:space:]]*$' | grep -v '^[[:space:]]*<!--' | grep -E "$pattern")
    
    echo "$image_lines"
}

echo -e "${BLUE}記事末尾の画像を検索中...${NC}"
echo -e "${YELLOW}検索ディレクトリ: $SEARCH_DIR${NC}"
echo -e "${YELLOW}検索範囲: 末尾 $TAIL_LINES 行${NC}"
echo -e "${YELLOW}画像タイプ: $IMAGE_TYPES${NC}"
echo ""

# 検索実行
found_files=()
total_count=0
total_files=0

# プログレス表示
echo -e "${CYAN}処理中:${NC}"

while IFS= read -r -d '' file; do
    ((total_files++))
    echo -n "."
    
    if has_ending_image "$file"; then
        found_files+=("$file")
        ((total_count++))
    fi
    
    # 50ファイルごとに改行
    if (( total_files % 50 == 0 )); then
        echo " ($total_files)"
    fi
done < <(find "$SEARCH_DIR" -name "*.md" -type f -print0 2>/dev/null)

echo ""
echo ""

# 結果表示
if [ $COUNT_ONLY = true ]; then
    echo "$total_count"
    exit 0
fi

if [ $total_count -eq 0 ]; then
    echo -e "${RED}記事末尾に画像がある記事は見つかりませんでした${NC}"
    echo -e "${YELLOW}💡 検索範囲を広げる場合は -l オプションで行数を増やしてください${NC}"
    exit 0
fi

echo -e "${GREEN}見つかった記事: $total_count 件（$total_files ファイル中）${NC}"
echo ""

# ファイル一覧表示
for file in "${found_files[@]}"; do
    echo -e "${BLUE}📄 $file${NC}"
    
    if [ $VERBOSE = true ]; then
        # ファイルの詳細情報
        echo -e "   ${YELLOW}作成日時:${NC} $(stat -f "%SB" "$file" 2>/dev/null || stat -c "%y" "$file" 2>/dev/null || echo "不明")"
        echo -e "   ${YELLOW}サイズ:${NC}   $(du -h "$file" | cut -f1)"
        
        # 記事タイトル抽出（front matterから）
        title=$(grep -m1 '^title:' "$file" 2>/dev/null | cut -d: -f2- | sed 's/^[[:space:]]*//' | sed 's/^["\x27]//' | sed 's/["\x27]$//')
        if [ -n "$title" ]; then
            echo -e "   ${YELLOW}タイトル:${NC} $title"
        fi
    fi
    
    if [ $SHOW_IMAGES = true ]; then
        # 画像情報表示
        image_info=$(extract_image_info "$file")
        if [ -n "$image_info" ]; then
            echo -e "   ${MAGENTA}末尾画像:${NC}"
            echo "$image_info" | while IFS= read -r line; do
                # 行を80文字で切り詰め
                truncated=$(echo "$line" | cut -c1-80)
                if [ ${#line} -gt 80 ]; then
                    truncated="${truncated}..."
                fi
                echo -e "     ${GREEN}${truncated}${NC}"
            done
        fi
    fi
    
    if [ $VERBOSE = true ] || [ $SHOW_IMAGES = true ]; then
        echo ""
    fi
done

echo ""
echo -e "${GREEN}検索完了: 合計 $total_count 件の記事で末尾に画像が見つかりました${NC}"

# VS Codeで開く
if [ $OPEN_IN_VSCODE = true ] && [ $total_count -gt 0 ]; then
    echo ""
    echo -e "${CYAN}VS Codeで開いています...${NC}"
    echo "DEBUG: OPEN_IN_VSCODE = $OPEN_IN_VSCODE"
    echo "DEBUG: total_count = $total_count"
    echo "DEBUG: found_files = ${found_files[@]}"
    
    # codeコマンドの存在確認
    if command -v code >/dev/null 2>&1; then
        echo "DEBUG: codeコマンドが見つかりました"
        # 見つかったファイルをすべてVS Codeで開く
        for file in "${found_files[@]}"; do
            echo -e "  ${BLUE}開いています: $file${NC}"
            echo "DEBUG: 実行中 - code \"$file\""
            code "$file"
            sleep 1  # 少し待機
        done
        echo -e "${GREEN}✅ $total_count 件のファイルをVS Codeで開きました${NC}"
    else
        echo -e "${RED}❌ VS Codeのcodeコマンドが見つかりません${NC}"
        echo -e "${YELLOW}💡 VS Code拡張機能を有効にするか、PATHにcodeコマンドを追加してください${NC}"
        echo -e "${YELLOW}   macOS: Command Palette > Shell Command: Install 'code' command in PATH${NC}"
        echo -e "${YELLOW}   または手動でファイルを開いてください:${NC}"
        for file in "${found_files[@]}"; do
            echo -e "     code \"$file\""
        done
    fi
else
    echo "DEBUG: VS Code条件チェック - OPEN_IN_VSCODE=$OPEN_IN_VSCODE, total_count=$total_count"
fi

# 統計情報
percentage=$(( (total_count * 100) / total_files ))
echo -e "${YELLOW}統計: $percentage% の記事が末尾に画像を含んでいます${NC}"

# 追加のヒント
if [ $VERBOSE = false ] && [ $SHOW_IMAGES = false ] && [ $total_count -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}💡 詳細情報を見るには:${NC}"
    echo -e "${YELLOW}   -v: ファイル詳細情報${NC}"
    echo -e "${YELLOW}   -s: 画像内容を表示${NC}"
    echo -e "${YELLOW}   -o: VS Codeで開く${NC}"
    echo -e "${YELLOW}   例: $0 -v -s -o${NC}"
fi