#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"
PAKS_DIR="$ROOT/paks"
TEMP_DIR="$ROOT/temp"
OUTPUT_DIR="$ROOT/output"
LANGUAGE=""
KEEP_TEMP=0

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()  { echo -e "${GREEN}[INFO]${NC}  $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

usage() {
    echo "PAK public 数据/资源一键导出"
    echo ""
    echo "用法:"
    echo "  ./run.sh <AES-KEY> [--ipa <path>] [--app <path>] [--output <path>] [--language <dir>]"
    echo "  ./run.sh --aes-file <path> [--ipa <path>] [--app <path>] [--output <path>]"
    echo ""
    echo "参数:"
    echo "  AES-KEY         64 位十六进制 AES 密钥；也可传 @/path/to/aes.txt"
    echo "  --aes-file      从文件读取 AES 密钥（文件里可有换行/空白）"
    echo "  --ipa           砸壳后的 .ipa 文件路径"
    echo "  --app           已安装 App 容器路径；也可用 APP_CONTAINER 设置默认值"
    echo "  -o, --output    输出目录"
    echo "                  默认: ./output"
    echo "  --language      本地化语言目录；不传时从 BinLocalize 实际目录自动选择"
    echo "  --keep-temp     保留 temp 中间产物，方便排查资源导出"
    echo ""
    echo "示例:"
    echo "  ./run.sh --aes-file path/to/aes_key.txt --ipa path/to/app.ipa --app path/to/app_container --output path/to/output"
}

expand_path() {
    local value="$1"
    case "$value" in
        "~") printf '%s\n' "$HOME" ;;
        "~/"*) printf '%s/%s\n' "$HOME" "${value#~/}" ;;
        /*) printf '%s\n' "$value" ;;
        *) printf '%s/%s\n' "$ROOT" "$value" ;;
    esac
}

have() {
    command -v "$1" >/dev/null 2>&1
}

read_aes_file() {
    local path
    path="$(expand_path "$1")"
    [[ -f "$path" ]] || error "AES key file not found: $path"
    tr -d '[:space:]' < "$path"
}

ensure_dotnet() {
    if have dotnet; then
        DOTNET_BIN="$(command -v dotnet)"
        info ".NET: $("$DOTNET_BIN" --version)"
        return
    fi

    warn ".NET SDK not found; trying local install into $ROOT/.tools/dotnet"
    have curl || error "curl not found. Install .NET SDK manually: https://dotnet.microsoft.com/download"

    mkdir -p "$ROOT/.tools/dotnet"
    local installer="$ROOT/.tools/dotnet-install.sh"
    curl -fsSL https://dot.net/v1/dotnet-install.sh -o "$installer" \
        || error "Failed to download dotnet-install.sh"
    bash "$installer" --channel 10.0 --install-dir "$ROOT/.tools/dotnet" --no-path \
        || error "Failed to install .NET SDK locally"

    DOTNET_BIN="$ROOT/.tools/dotnet/dotnet"
    export DOTNET_ROOT="$ROOT/.tools/dotnet"
    export PATH="$DOTNET_ROOT:$PATH"
    info ".NET installed: $("$DOTNET_BIN" --version)"
}

ensure_node() {
    if have node; then
        info "Node: $(node --version)"
        return
    fi
    if have brew; then
        warn "Node.js not found; installing with Homebrew"
        brew install node || error "Failed to install Node.js with Homebrew"
        info "Node: $(node --version)"
        return
    fi
    error "Node.js is required for pet split/index generation. Install with: brew install node"
}

ensure_python_runner() {
    if have uv; then
        export UV_CACHE_DIR="${UV_CACHE_DIR:-$ROOT/.uv-cache}"
        mkdir -p "$UV_CACHE_DIR"
        PY_RUN=(uv run python)
        info "Python runner: uv ($(uv --version), cache: $UV_CACHE_DIR)"
        return
    fi

    if ! have python3; then
        if have brew; then
            warn "Neither uv nor python3 found; installing Python with Homebrew"
            brew install python || error "Failed to install Python with Homebrew"
        else
            error "Neither uv nor python3 found. Install uv or Python 3 first."
        fi
    fi
    warn "uv not found; using local pip/venv environment at $ROOT/.venv"
    if [[ ! -x "$ROOT/.venv/bin/python" ]]; then
        python3 -m venv "$ROOT/.venv" || error "Failed to create Python venv"
    fi
    "$ROOT/.venv/bin/python" -m pip --version >/dev/null \
        || error "pip is not available in the local venv"
    PY_RUN=("$ROOT/.venv/bin/python")
    info "Python runner: ${PY_RUN[*]}"
}

AES_KEY=""
AES_FILE=""
IPA_PATH=""
APP_PATH="${APP_CONTAINER:-}"

if [[ $# -eq 0 || "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        --aes-file|--key-file)
            [[ $# -ge 2 ]] || error "$1 requires a path"
            AES_FILE="$(expand_path "$2")"
            shift 2
            ;;
        --ipa)
            [[ $# -ge 2 ]] || error "--ipa requires a path"
            IPA_PATH="$(expand_path "$2")"
            shift 2
            ;;
        --app)
            [[ $# -ge 2 ]] || error "--app requires a path"
            APP_PATH="$(expand_path "$2")"
            shift 2
            ;;
        -o|--output)
            [[ $# -ge 2 ]] || error "--output requires a path"
            OUTPUT_DIR="$(expand_path "$2")"
            shift 2
            ;;
        --language)
            [[ $# -ge 2 ]] || error "--language requires a value"
            LANGUAGE="$2"
            shift 2
            ;;
        --keep-temp)
            KEEP_TEMP=1
            shift
            ;;
        *)
            if [[ -z "$AES_KEY" && -z "$AES_FILE" ]]; then
                if [[ "$1" == @* ]]; then
                    AES_FILE="$(expand_path "${1#@}")"
                else
                    AES_KEY="$1"
                fi
            else
                error "Unknown argument: $1"
            fi
            shift
            ;;
    esac
done

if [[ -n "$AES_FILE" ]]; then
    AES_KEY="$(read_aes_file "$AES_FILE")"
elif [[ -n "$AES_KEY" && ! "$AES_KEY" =~ ^[0-9a-fA-F]{64}$ ]]; then
    maybe_file="$(expand_path "$AES_KEY")"
    if [[ -f "$maybe_file" ]]; then
        AES_FILE="$maybe_file"
        AES_KEY="$(read_aes_file "$AES_FILE")"
    fi
fi

[[ -n "$AES_KEY" ]] || error "AES key required. Use --help for usage."
if [[ ! "$AES_KEY" =~ ^[0-9a-fA-F]{64}$ ]]; then
    error "AES key must be exactly 64 hex characters, got ${#AES_KEY} chars"
fi

info "Root  : $ROOT"
info "Output: $OUTPUT_DIR"
if [[ -n "$AES_FILE" ]]; then
    info "AES file: $AES_FILE"
fi
info "AES key: ${AES_KEY:0:16}..."

echo ""
info "Step 0: Checking environment"
ensure_dotnet
ensure_python_runner
ensure_node
if [[ -n "$IPA_PATH" ]]; then
    have unzip || error "unzip not found; it is required for --ipa extraction"
fi

echo ""
info "Step 1: Collecting PAK files"
mkdir -p "$PAKS_DIR" "$TEMP_DIR"
if [[ -n "$IPA_PATH" || ( -n "$APP_PATH" && -d "$APP_PATH" ) ]]; then
    rm -f "$PAKS_DIR"/*.pak 2>/dev/null || true
else
    warn "No IPA/App source found; using existing local PAKs in $PAKS_DIR"
fi
total=0

if [[ -n "$IPA_PATH" ]]; then
    if [[ -f "$IPA_PATH" ]]; then
        info "Extracting IPA: $IPA_PATH"
        IPA_TMP="$TEMP_DIR/.ipa_extract"
        rm -rf "$IPA_TMP"
        mkdir -p "$IPA_TMP"
        unzip -qo "$IPA_PATH" -d "$IPA_TMP" || warn "IPA unzip had warnings (non-critical)"

        ipa_count=0
        while IFS= read -r -d '' pak; do
            cp "$pak" "$PAKS_DIR/"
            ipa_count=$((ipa_count + 1))
        done < <(find "$IPA_TMP" -name "*.pak" -print0)
        info "  IPA -> $ipa_count paks"
        total=$((total + ipa_count))
    else
        warn "IPA not found: $IPA_PATH"
    fi
else
    warn "No IPA provided (use --ipa)"
fi

if [[ -n "$APP_PATH" && -d "$APP_PATH" ]]; then
    info "Collecting from App: $APP_PATH"
    app_count=0

    PUFFER=""
    if [[ -n "${APP_PAK_SUBDIR:-}" && -d "$APP_PATH/$APP_PAK_SUBDIR" ]]; then
        PUFFER="$APP_PATH/$APP_PAK_SUBDIR"
    else
        while IFS= read -r -d '' candidate; do
            PUFFER="$candidate"
            break
        done < <(find "$APP_PATH/Data/Documents" -path "*/Saved/Puffer/Paks" -type d -print0 2>/dev/null || true)
    fi

    if [[ -d "$PUFFER" ]]; then
        while IFS= read -r -d '' pak; do
            cp "$pak" "$PAKS_DIR/"
            app_count=$((app_count + 1))
        done < <(find "$PUFFER" -maxdepth 1 -name "*.pak" -print0)
        info "  Puffer -> $app_count paks"
    else
        warn "No Puffer PAK directory found under App container"
    fi

    patch_count=0
    PATCH="$PUFFER/Patch"
    if [[ -d "$PATCH" ]]; then
        while IFS= read -r -d '' pak; do
            cp "$pak" "$PAKS_DIR/"
            patch_count=$((patch_count + 1))
        done < <(find "$PATCH" -maxdepth 1 -name "*.pak" -print0)
        info "  Patches -> $patch_count paks"
    fi

    cooked=0
    while IFS= read -r -d '' pak; do
        cp "$pak" "$PAKS_DIR/"
        cooked=$((cooked + 1))
    done < <(find "$APP_PATH" -ipath "*/cookeddata/*" -name "*.pak" -print0 2>/dev/null || true)
    if [[ $cooked -gt 0 ]]; then
        info "  CookedData -> $cooked paks"
    fi
    total=$((total + app_count + patch_count + cooked))
elif [[ -n "$APP_PATH" ]]; then
    warn "App container not found: $APP_PATH"
else
    warn "No App container provided (use --app)"
fi

dedup=$(find "$PAKS_DIR" -maxdepth 1 -type f -name "*.pak" | wc -l | tr -d ' ')
if [[ $dedup -eq 0 ]]; then
    error "No PAK files found. Provide --ipa/--app or place .pak files in: $PAKS_DIR"
fi
info "Total PAK files: $dedup"

echo ""
info "Step 2: Decrypting, decompressing, exporting raw data and icon textures"
rm -rf "$TEMP_DIR"/.ipa_extract
find "$TEMP_DIR" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null || true
mkdir -p "$TEMP_DIR"

"$DOTNET_BIN" restore "$SCRIPT_DIR/extract_paks/ExtractPaks.csproj" /p:SkipNatives=true
"$DOTNET_BIN" run /p:SkipNatives=true --project "$SCRIPT_DIR/extract_paks/ExtractPaks.csproj" -- "$AES_KEY" "$PAKS_DIR" "$TEMP_DIR"
extracted=$(find "$TEMP_DIR" -type f | wc -l | tr -d ' ')
info "Files extracted: $extracted"

echo ""
info "Step 3: Generating frontend output"
mkdir -p "$OUTPUT_DIR"
rm -rf "$OUTPUT_DIR/data" "$OUTPUT_DIR/assets"

cd "$ROOT"
export_args=("$SCRIPT_DIR/export_public.py" "$TEMP_DIR" "$OUTPUT_DIR")
if [[ -n "$LANGUAGE" ]]; then
    export_args+=(--language "$LANGUAGE")
fi
"${PY_RUN[@]}" "${export_args[@]}"

bin_count=$(find "$OUTPUT_DIR/data/BinData" -type f -name "*.json" 2>/dev/null | wc -l | tr -d ' ')
table_count=$(find "$OUTPUT_DIR/data/tables" -type f -name "*.json" 2>/dev/null | wc -l | tr -d ' ')
pet_count=$(find "$OUTPUT_DIR/data/pets" -type f -name "*.json" 2>/dev/null | wc -l | tr -d ' ')
asset_count=$(find "$OUTPUT_DIR/assets" -type f 2>/dev/null | wc -l | tr -d ' ')
asset_system_root="$OUTPUT_DIR/assets/webp/Game/NewRoco/Modules/System"
common_icon_count=$(find "$asset_system_root/Common/Icon" -type f -name "*.webp" 2>/dev/null | wc -l | tr -d ' ')
head_icon_count=$(find "$asset_system_root/Common/Icon/HeadIcon" -type f -name "*.webp" 2>/dev/null | wc -l | tr -d ' ')
big_head_icon_count=$(find "$asset_system_root/Common/Icon/BigHeadIcon256" -type f -name "*.webp" 2>/dev/null | wc -l | tr -d ' ')
pet1024_icon_count=$(find "$asset_system_root/Common/Icon/Pet1024" -type f -name "*.webp" 2>/dev/null | wc -l | tr -d ' ')
pet256_icon_count=$(find "$asset_system_root/Common/Icon/Pet256" -type f -name "*.webp" 2>/dev/null | wc -l | tr -d ' ')
bag_item_icon_count=$(find "$asset_system_root/Common/Icon/BagItem" -type f -name "*.webp" 2>/dev/null | wc -l | tr -d ' ')
battle_atlas_count=$(find "$asset_system_root/BattleUI/Raw/Atlas" -type f -name "*.webp" 2>/dev/null | wc -l | tr -d ' ')

if [[ "$asset_count" -eq 0 ]]; then
    error "No assets generated. Re-run with --keep-temp and check $TEMP_DIR/assets; C# texture export likely matched no icon textures or failed decoding."
fi

temp_status="$TEMP_DIR ($extracted files)"
if [[ "$KEEP_TEMP" -eq 0 ]]; then
    echo ""
    info "Step 4: Cleaning temp files"
    find "$TEMP_DIR" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null || true
    temp_status="$TEMP_DIR (cleaned)"
fi

echo ""
echo "========================================="
echo -e "  ${GREEN}Export complete${NC}"
echo "========================================="
echo "  Output : $OUTPUT_DIR"
echo "  Data   : $OUTPUT_DIR/data"
echo "    BinData        : $bin_count json"
echo "    tables         : $table_count json"
echo "    pets           : $pet_count json"
echo "    Pets.json      : $([[ -f "$OUTPUT_DIR/data/Pets.json" ]] && echo yes || echo no)"
echo "    moves.json     : $([[ -f "$OUTPUT_DIR/data/moves.json" ]] && echo yes || echo no)"
echo "    magic_items.json: $([[ -f "$OUTPUT_DIR/data/magic_items.json" ]] && echo yes || echo no)"
echo "  Assets : $OUTPUT_DIR/assets ($asset_count files)"
echo "    Common/Icon    : $common_icon_count webp"
echo "      HeadIcon     : $head_icon_count webp"
echo "      BigHeadIcon256: $big_head_icon_count webp"
echo "      Pet1024      : $pet1024_icon_count webp"
echo "      Pet256       : $pet256_icon_count webp"
echo "      BagItem      : $bag_item_icon_count webp"
echo "    BattleUI Atlas : $battle_atlas_count webp"
echo "  Temp   : $temp_status"
echo "  Paks   : $PAKS_DIR ($dedup files)"
echo "========================================="
