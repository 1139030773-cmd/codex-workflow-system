#!/usr/bin/env bash
# Version Consistency Validator (Linux/Mac)
# Checks CHANGELOG, plugin.json, README files, marketplace.json, and git tags
# for version number consistency.
set -e

ROOT="${1:-$PWD}"
OK=true

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

extract_first_version() { grep -oP "$1" "$2" 2>/dev/null | head -1; }

# 1. CHANGELOG.md latest version (first ## [X.Y.Z] entry)
CHANGELOG_VER=$(extract_first_version '## \[\K[\d.]+(?=\])' "$ROOT/CHANGELOG.md")
echo "CHANGELOG.md  : $CHANGELOG_VER"

# 2. plugin.json version
PLUGIN_VER=$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$ROOT/plugins/plugins/agent-workflow-system/.codex-plugin/plugin.json" 2>/dev/null | head -1 | sed 's/.*"\([^"]*\)".*/\1/')
echo "plugin.json   : $PLUGIN_VER"

# 3. Root README version table
ROOT_README_VER=$(extract_first_version '\| \*\*\K[\d.]+(?=\*\* \|)' "$ROOT/README.md")
echo "README.md     : $ROOT_README_VER"

# 4. Plugin README version table
PLUGIN_README_PATH="$ROOT/plugins/plugins/agent-workflow-system/README.md"
PLUGIN_README_VER=$(extract_first_version '\| \*\*\K[\d.]+(?=\*\* \|)' "$PLUGIN_README_PATH")
echo "Plugin README : $PLUGIN_README_VER"

# 5. Local README version table
LOCAL_README_PATH="$ROOT/agent-workflow-system-local/README.md"
LOCAL_README_VER=$(extract_first_version '\| \*\*\K[\d.]+(?=\*\* \|)' "$LOCAL_README_PATH" 2>/dev/null)
echo "Local README  : ${LOCAL_README_VER:-N/A}"

# 5b. Root README_CN
ROOT_READMECN_VER=$(extract_first_version '\| \*\*\K[\d.]+(?=\*\* \|)' "$ROOT/README_CN.md")
echo "README_CN.md  : $ROOT_READMECN_VER"

# 5c. Plugin README_CN
PLUGIN_READMECN_PATH="$ROOT/plugins/plugins/agent-workflow-system/README_CN.md"
PLUGIN_READMECN_VER=$(extract_first_version '\| \*\*\K[\d.]+(?=\*\* \|)' "$PLUGIN_READMECN_PATH")
echo "Plugin README_CN: $PLUGIN_READMECN_VER"

# 5d. Local README_CN
LOCAL_READMECN_PATH="$ROOT/agent-workflow-system-local/README_CN.md"
LOCAL_READMECN_VER=$(extract_first_version '\| \*\*\K[\d.]+(?=\*\* \|)' "$LOCAL_READMECN_PATH" 2>/dev/null)
echo "Local README_CN: ${LOCAL_READMECN_VER:-N/A}"

# 5e. Version range checks (vX.X ~ vY.Y tail version)
check_range() {
  local file=$1 label=$2
  [ ! -f "$file" ] && return
  local range_ver=$(grep -oP 'v[\d.]+ ~ v\K[\d.]+' "$file" 2>/dev/null | head -1)
  echo "Range $label : ${range_ver:-N/A}"
  [ -n "$range_ver" ] && [ "$range_ver" != "$PLUGIN_VER" ] && { echo -e "${RED}Range $label ($range_ver) != plugin.json ($PLUGIN_VER)${NC}"; OK=false; }
}
check_range "$ROOT/README.md" "README.md"
check_range "$ROOT/README_CN.md" "README_CN.md"
check_range "$PLUGIN_README_PATH" "Plugin README"
check_range "$PLUGIN_READMECN_PATH" "Plugin README_CN"
check_range "$LOCAL_README_PATH" "Local README"
check_range "$LOCAL_READMECN_PATH" "Local README_CN"

# 6. Local CHANGELOG
LOCAL_CHANGELOG_PATH="$ROOT/agent-workflow-system-local/CHANGELOG.md"
LOCAL_CHANGELOG_VER=$(extract_first_version '## \[\K[\d.]+(?=\])' "$LOCAL_CHANGELOG_PATH" 2>/dev/null)
echo "Local CHANGELOG: ${LOCAL_CHANGELOG_VER:-N/A}"

# 7. marketplace.json version
MARKETPLACE_PATH="$ROOT/agent-workflow-system-local/.github/plugin/marketplace.json"
MARKETPLACE_VER=""
if [ -f "$MARKETPLACE_PATH" ]; then
  MARKETPLACE_VER=$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$MARKETPLACE_PATH" 2>/dev/null | head -1 | sed 's/.*"\([^"]*\)".*/\1/')
fi
echo "marketplace   : ${MARKETPLACE_VER:-N/A}"

# 8. agent plugin.json
AGENT_PLUGIN_PATH="$ROOT/agent-workflow-system-local/plugins/agent-workflow-system/.codex-plugin/plugin.json"
AGENT_PLUGIN_VER=""
if [ -f "$AGENT_PLUGIN_PATH" ]; then
  AGENT_PLUGIN_VER=$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$AGENT_PLUGIN_PATH" 2>/dev/null | head -1 | sed 's/.*"\([^"]*\)".*/\1/')
fi
echo "agent plugin  : ${AGENT_PLUGIN_VER:-N/A}"

# 9. Git tag
LATEST_TAG=""
if [ -d "$ROOT/plugins/.git" ]; then
  LATEST_TAG=$(git -C "$ROOT/plugins" tag -l 'v*' --sort=-v:refname 2>/dev/null | head -1)
fi
echo "git tag       : ${LATEST_TAG:-N/A}"

# ============================================================
# Compare all
# ============================================================

check() {
  local val=$1 label=$2
  [ -z "$val" ] && return
  [ "$val" != "$PLUGIN_VER" ] && { echo -e "${RED}$label ($val) != plugin.json ($PLUGIN_VER)${NC}"; OK=false; }
}

check "$CHANGELOG_VER" "CHANGELOG.md"
check "$ROOT_README_VER" "README.md"
check "$ROOT_READMECN_VER" "README_CN.md"
check "$PLUGIN_README_VER" "Plugin README"
check "$PLUGIN_READMECN_VER" "Plugin README_CN"
check "$LOCAL_README_VER" "Local README"
check "$LOCAL_READMECN_VER" "Local README_CN"
check "$LOCAL_CHANGELOG_VER" "Local CHANGELOG"
check "$MARKETPLACE_VER" "marketplace.json"
check "$AGENT_PLUGIN_VER" "agent plugin.json"

[ -n "$LATEST_TAG" ] && [ "$LATEST_TAG" != "v$PLUGIN_VER" ] && { echo -e "${RED}git tag ($LATEST_TAG) != v$PLUGIN_VER${NC}"; OK=false; }

if $OK; then
  echo -e "${GREEN}All versions consistent: $PLUGIN_VER${NC}"
  exit 0
else
  echo -e "${RED}Fix version mismatches before pushing.${NC}"
  exit 1
fi
