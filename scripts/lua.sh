#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()  { echo -e "${GREEN}[INFO]${NC}  $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

usage() {
    echo "Lua 源码导出"
    echo ""
    echo "用法:"
    echo "  ./lua.sh <AES-KEY> [--paks path/to/paks] [--output path/to/output] --decompiler path/to/unluac-cli"
    echo "  ./lua.sh --aes-file path/to/aes_key.txt [--paks path/to/paks] [--output path/to/output] --decompiler path/to/unluac-cli"
    echo ""
    echo "默认:"
    echo "  --paks     ./paks"
    echo "  --output   ./output/scripts"
    echo "  默认导出完整 Lua 源码，luac 只作为临时中间文件"
    echo ""
    echo "输出:"
    echo "  lua/             反编译还原的 Lua 源码，按 Common/Core/Data/NewRoco 等目录分类"
    echo ""
    echo "选项:"
    echo "  --decompiler     指定 unluac-cli 或 unluac.jar"
    echo "  --unluac-lib     指定 FModel native unluac 库"
    echo "  --jobs           并发反编译数量，默认 CPU 核数"
}

have() {
    command -v "$1" >/dev/null 2>&1
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

if [[ $# -eq 0 || "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

ensure_dotnet

"$DOTNET_BIN" restore "$SCRIPT_DIR/extract_paks/ExtractPaks.csproj" /p:SkipNatives=true
"$DOTNET_BIN" run /p:SkipNatives=true --project "$SCRIPT_DIR/extract_paks/ExtractPaks.csproj" -- --extract-lua "$@"
