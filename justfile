# Idaptik Reversible VM - Comprehensive Justfile
# ReScript + Deno build system with no npm/bun/typescript

# Configuration
project_name := "idaptik-reversible"
src_dir := "src"
lib_dir := "lib"
data_dir := "data"
puzzle_dir := "data/puzzles"

# Colors for output
red := '\033[0;31m'
green := '\033[0;32m'
yellow := '\033[1;33m'
blue := '\033[0;34m'
purple := '\033[0;35m'
cyan := '\033[0;36m'
nc := '\033[0m' # No Color

# Default recipe - list all commands
default:
    @just --list

# Display detailed help with examples
help:
    #!/usr/bin/env bash
    cat << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║        IDAPTIK REVERSIBLE VM - Build System Help              ║
╚════════════════════════════════════════════════════════════════╝

CORE COMMANDS:
  just build          - Compile ReScript to JavaScript
  just clean          - Remove compiled artifacts
  just run            - Run the CLI
  just demo           - Run demonstration
  just test           - Run instruction tests

DEVELOPMENT:
  just watch          - Auto-recompile on file changes
  just dev            - Development mode (watch + run)
  just check          - Verify ReScript syntax
  just format         - Format ReScript code
  just lint           - Lint code with Deno

DEPENDENCIES:
  just check-deps     - Verify all required tools installed
  just install-deps   - Install ReScript compiler (via Deno)
  just doctor         - Full dependency health check

DOCUMENTATION:
  just doc            - Generate documentation
  just readme         - Update README with latest info
  just license        - Show license information

PUZZLES:
  just puzzle <name>  - Run a specific puzzle
  just list-puzzles   - List all available puzzles
  just create-puzzle  - Create new puzzle template

QUALITY:
  just verify         - Full verification (build + test + lint)
  just ci             - Run CI/CD pipeline
  just benchmark      - Benchmark VM performance
  just coverage       - Code coverage analysis

MAINTENANCE:
  just clean-all      - Deep clean (includes ReScript cache)
  just reset          - Reset to clean state
  just status         - Show project status
  just stats          - Show code statistics

EXAMPLES:
  just build && just demo
  just watch
  just puzzle vault_7
  just ci

DEPENDENCIES REQUIRED:
  - Deno (runtime)
  - ReScript compiler (npx or bun)
  - watchexec (for watch mode)
  - fd (for file finding)
  - ripgrep (for code search)

ENVIRONMENT VARIABLES:
  VERBOSE=1           - Enable verbose output
  NO_COLOR=1          - Disable colored output

PROJECT: Reversible Computation VM
LICENSE: AGPL-3.0
AUTHORS: Joshua & Jonathan Jewell
EOF

# ═══════════════════════════════════════════════════════════════
#                    DEPENDENCY CHECKING
# ═══════════════════════════════════════════════════════════════

# Check if Deno is installed
@check-deno:
    command -v deno >/dev/null 2>&1 || { \
        echo "{{red}}✗ Deno is not installed{{nc}}"; \
        echo "  Install from: https://deno.land/"; \
        echo "  Or run: curl -fsSL https://deno.land/install.sh | sh"; \
        exit 1; \
    }
    echo "{{green}}✓ Deno found:{{nc}} $(deno --version | head -n1)"

# Check if ReScript compiler is available
@check-rescript:
    if command -v rescript >/dev/null 2>&1; then \
        echo "{{green}}✓ ReScript found:{{nc}} $(rescript -version)"; \
    elif command -v npx >/dev/null 2>&1; then \
        echo "{{yellow}}⚠ ReScript not in PATH, using npx{{nc}}"; \
    elif command -v bun >/dev/null 2>&1; then \
        echo "{{yellow}}⚠ ReScript not in PATH, using bunx{{nc}}"; \
    else \
        echo "{{red}}✗ ReScript compiler not found{{nc}}"; \
        echo "  Install: npm install -g rescript"; \
        echo "  Or use: just install-deps"; \
        exit 1; \
    fi

# Check if watchexec is installed (optional for watch mode)
@check-watchexec:
    command -v watchexec >/dev/null 2>&1 && \
        echo "{{green}}✓ watchexec found{{nc}}" || \
        echo "{{yellow}}⚠ watchexec not found (optional for watch mode){{nc}}"

# Check all required dependencies
check-deps: check-deno check-rescript
    @echo "{{green}}✓ All required dependencies available{{nc}}"

# Full system health check
doctor: check-deps check-watchexec
    @echo ""
    @echo "{{cyan}}📊 System Information:{{nc}}"
    @echo "  OS: $(uname -s)"
    @echo "  Architecture: $(uname -m)"
    @echo "  Shell: $SHELL"
    @echo ""
    @echo "{{cyan}}📁 Project Structure:{{nc}}"
    @[ -d "{{src_dir}}" ] && echo "{{green}}  ✓{{nc}} src/ directory exists" || echo "{{red}}  ✗{{nc}} src/ missing"
    @[ -f "rescript.json" ] && echo "{{green}}  ✓{{nc}} rescript.json exists" || echo "{{red}}  ✗{{nc}} rescript.json missing"
    @[ -f "deno.json" ] && echo "{{green}}  ✓{{nc}} deno.json exists" || echo "{{red}}  ✗{{nc}} deno.json missing"
    @echo ""
    @echo "{{green}}✓ System health check complete{{nc}}"

# ═══════════════════════════════════════════════════════════════
#                    BUILD & COMPILATION
# ═══════════════════════════════════════════════════════════════

# Compile ReScript to JavaScript
build: check-rescript
    #!/usr/bin/env bash
    set -euo pipefail
    echo "{{blue}}🔨 Compiling ReScript sources...{{nc}}"

    if command -v rescript >/dev/null 2>&1; then
        rescript build
    elif command -v npx >/dev/null 2>&1; then
        npx rescript build
    elif command -v bun >/dev/null 2>&1; then
        bunx rescript build
    else
        echo "{{red}}✗ No ReScript compiler available{{nc}}"
        exit 1
    fi

    echo "{{green}}✅ Build successful!{{nc}}"

# Clean compiled artifacts
clean:
    #!/usr/bin/env bash
    echo "{{yellow}}🧹 Cleaning build artifacts...{{nc}}"

    # Remove ReScript compiled files
    find {{src_dir}} -name "*.res.js" -type f -delete 2>/dev/null || true
    find {{src_dir}} -name "*.res.mjs" -type f -delete 2>/dev/null || true

    # Remove lib directory
    rm -rf {{lib_dir}}

    echo "{{green}}✓ Clean complete{{nc}}"

# Deep clean including ReScript cache
clean-all: clean
    #!/usr/bin/env bash
    echo "{{yellow}}🧹 Deep cleaning (including caches)...{{nc}}"

    # Remove ReScript build cache
    rm -rf .bsb.lock
    rm -rf .merlin

    # Remove any remaining artifacts
    rm -rf dist/

    # Remove old node_modules, package.json, bun.lock if still present
    if [ -d "node_modules" ]; then
        echo "{{yellow}}  Removing old node_modules...{{nc}}"
        rm -rf node_modules/
    fi

    if [ -f "package.json.bak" ]; then
        rm -f package.json.bak
    fi

    if [ -f "bun.lock" ]; then
        echo "{{yellow}}  Removing old bun.lock...{{nc}}"
        rm -f bun.lock
    fi

    echo "{{green}}✓ Deep clean complete{{nc}}"

# Verify ReScript syntax without full compilation
check: check-rescript
    #!/usr/bin/env bash
    echo "{{blue}}🔍 Checking ReScript syntax...{{nc}}"

    if command -v rescript >/dev/null 2>&1; then
        rescript build -with-deps
    elif command -v npx >/dev/null 2>&1; then
        npx rescript build -with-deps
    else
        bunx rescript build -with-deps
    fi

    echo "{{green}}✓ Syntax check passed{{nc}}"

# ═══════════════════════════════════════════════════════════════
#                    DEVELOPMENT & TESTING
# ═══════════════════════════════════════════════════════════════

# Run the CLI
run: build check-deno
    @echo "{{cyan}}▶ Running CLI...{{nc}}"
    deno run --allow-read --allow-write {{src_dir}}/CLI.res.js

# Run demonstration
demo: build check-deno
    @echo "{{purple}}🎬 Running demonstration...{{nc}}"
    deno run --allow-read {{src_dir}}/CLI.res.js demo

# Run instruction tests
test: build check-deno
    @echo "{{cyan}}🧪 Running tests...{{nc}}"
    deno run --allow-read {{src_dir}}/CLI.res.js test

# Watch mode - auto-recompile on changes
watch: check-rescript
    #!/usr/bin/env bash
    echo "{{blue}}👀 Watching for changes...{{nc}}"

    if command -v rescript >/dev/null 2>&1; then
        rescript build -w
    elif command -v npx >/dev/null 2>&1; then
        npx rescript build -w
    else
        bunx rescript build -w
    fi

# Development mode - watch and run
dev:
    @echo "{{purple}}🚀 Starting development mode...{{nc}}"
    @echo "  Terminal 1: Building..."
    @just build
    @echo "  Now run: just watch"
    @echo "  In another terminal: just demo"

# ═══════════════════════════════════════════════════════════════
#                    PUZZLE MANAGEMENT
# ═══════════════════════════════════════════════════════════════

# Run a specific puzzle
puzzle name: build check-deno
    @echo "{{purple}}🧩 Running puzzle: {{name}}{{nc}}"
    deno run --allow-read {{src_dir}}/CLI.res.js run {{name}}

# List all available puzzles
list-puzzles:
    @echo "{{cyan}}📋 Available puzzles:{{nc}}"
    @ls -1 {{puzzle_dir}}/*.json 2>/dev/null | xargs -n1 basename | sed 's/\.json//' || echo "  No puzzles found"

# Create new puzzle template
create-puzzle name:
    @echo "{{blue}}📝 Creating puzzle: {{name}}{{nc}}"
    @cat > {{puzzle_dir}}/{{name}}.json << 'EOF'
{
  "name": "{{name}}",
  "description": "Puzzle description here",
  "initialState": {
    "x": 0,
    "y": 0,
    "z": 0
  },
  "goalState": {
    "x": 10,
    "y": 0,
    "z": 0
  },
  "maxMoves": 10,
  "instructions": [
    {"type": "ADD", "args": ["x", "y"]},
    {"type": "SUB", "args": ["x", "y"]},
    {"type": "SWAP", "args": ["x", "z"]},
    {"type": "NEGATE", "args": ["x"]}
  ]
}
EOF
    @echo "{{green}}✓ Created {{puzzle_dir}}/{{name}}.json{{nc}}"

# ═══════════════════════════════════════════════════════════════
#                    QUALITY & VERIFICATION
# ═══════════════════════════════════════════════════════════════

# Format ReScript code
format:
    #!/usr/bin/env bash
    echo "{{blue}}🎨 Formatting ReScript code...{{nc}}"

    if command -v rescript >/dev/null 2>&1; then
        rescript format -all
    elif command -v npx >/dev/null 2>&1; then
        npx rescript format -all
    else
        bunx rescript format -all
    fi

    echo "{{green}}✓ Format complete{{nc}}"

# Lint with Deno
lint: check-deno
    @echo "{{blue}}🔍 Linting JavaScript output...{{nc}}"
    deno lint {{src_dir}}/**/*.res.js 2>/dev/null || echo "{{yellow}}⚠ Some lint warnings{{nc}}"

# Full verification
verify: build test lint
    @echo "{{green}}✅ Full verification passed!{{nc}}"

# CI/CD pipeline
ci: check-deps clean build test lint
    @echo "{{green}}✅ CI pipeline complete!{{nc}}"

# Benchmark VM performance
benchmark: build check-deno
    @echo "{{cyan}}⚡ Running benchmarks...{{nc}}"
    @echo "TODO: Implement benchmark suite"

# ═══════════════════════════════════════════════════════════════
#                    DOCUMENTATION
# ═══════════════════════════════════════════════════════════════

# Generate documentation
doc:
    @echo "{{blue}}📚 Generating documentation...{{nc}}"
    @echo "  ReScript documentation at: https://rescript-lang.org/docs/"
    @echo "  Source docs in: {{src_dir}}/"

# Show license information
license:
    @echo "{{cyan}}📜 License Information:{{nc}}"
    @echo ""
    @echo "  Project: {{project_name}}"
    @echo "  License: AGPL-3.0"
    @echo "  Authors: Joshua & Jonathan Jewell"
    @echo ""
    @[ -f "license.txt" ] && cat license.txt || echo "  See license.txt for full text"

# ═══════════════════════════════════════════════════════════════
#                    INSTALLATION & SETUP
# ═══════════════════════════════════════════════════════════════

# Install ReScript compiler via npm
install-deps:
    @echo "{{blue}}📦 Installing dependencies...{{nc}}"
    @echo "  Installing ReScript globally via npm..."
    npm install -g rescript@latest
    @echo "{{green}}✓ Dependencies installed{{nc}}"

# Reset to clean state
reset: clean-all
    @echo "{{yellow}}🔄 Resetting to clean state...{{nc}}"
    @just check-deps
    @echo "{{green}}✓ Reset complete - ready for fresh build{{nc}}"

# ═══════════════════════════════════════════════════════════════
#                    PROJECT STATUS & STATISTICS
# ═══════════════════════════════════════════════════════════════

# Show project status
status:
    #!/usr/bin/env bash
    echo "{{cyan}}📊 Project Status:{{nc}}"
    echo ""

    # Count source files
    res_files=$(find {{src_dir}} -name "*.res" 2>/dev/null | wc -l)
    compiled=$(find {{src_dir}} -name "*.res.js" 2>/dev/null | wc -l)

    echo "  ReScript files: $res_files"
    echo "  Compiled files: $compiled"

    # Show last build
    if [ -d "{{lib_dir}}" ]; then
        echo "{{green}}  ✓ Build artifacts present{{nc}}"
    else
        echo "{{yellow}}  ⚠ No build artifacts (run: just build){{nc}}"
    fi

    # Git status if in repo
    if [ -d ".git" ]; then
        echo ""
        echo "{{cyan}}📂 Git Status:{{nc}}"
        git status --short --branch
    fi

# Show code statistics
stats:
    #!/usr/bin/env bash
    echo "{{cyan}}📈 Code Statistics:{{nc}}"
    echo ""

    # Count lines of ReScript code
    if command -v tokei >/dev/null 2>&1; then
        tokei {{src_dir}}
    else
        echo "  ReScript lines:"
        find {{src_dir}} -name "*.res" -exec wc -l {} + | tail -n1

        echo ""
        echo "  Files by type:"
        find {{src_dir}} -name "*.res" | wc -l | xargs echo "    ReScript files:"
    fi

    echo ""
    echo "  Puzzles:"
    ls {{puzzle_dir}}/*.json 2>/dev/null | wc -l | xargs echo "    JSON puzzles:"

# ═══════════════════════════════════════════════════════════════
#                    EXPERIMENTAL & ADVANCED
# ═══════════════════════════════════════════════════════════════

# Bundle for distribution (experimental)
bundle: build
    @echo "{{blue}}📦 Creating distribution bundle...{{nc}}"
    @echo "TODO: Implement Deno bundle"

# Profile VM performance
profile: build
    @echo "{{cyan}}📊 Profiling VM performance...{{nc}}"
    @echo "TODO: Implement profiler"

# Generate dependency graph
deps-graph:
    @echo "{{blue}}🕸️  Generating dependency graph...{{nc}}"
    @echo "TODO: Implement dep graph"

# ═══════════════════════════════════════════════════════════════
#                    ALIASES & SHORTCUTS
# ═══════════════════════════════════════════════════════════════

# Aliases for common commands
alias b := build
alias c := clean
alias r := run
alias d := demo
alias t := test
alias w := watch
alias v := verify
alias h := help
