#!/usr/bin/env bash
set -e  # stop on error

# === CONFIG ===
BASE_DIR="$(pwd)"
SRC_DIR="$BASE_DIR/src"
OUT_DIR="$BASE_DIR/out"
MAIN_BASENAME="main"
BFC_FILE="$OUT_DIR/main.bcf"

echo "=== FULL RENEW BUILD ==="
echo "Working directory: $BASE_DIR"
echo

# === STEP 1: Clear output folder ===
if [ -d "$OUT_DIR" ]; then
  echo "🧹 Clearing everything in $OUT_DIR ..."
  rm -rf "$OUT_DIR"/*
else
  echo "📁 Creating output directory: $OUT_DIR"
  mkdir -p "$OUT_DIR"
fi
echo "✅ Output directory ready."
echo

# === STEP 2: Run biber in OUT_DIR ===
echo "📚 Running bibliography (biber) in $OUT_DIR ..."
export BIBINPUTS="$SRC_DIR"
export BSTINPUT="$SRC_DIR"
echo "📌 Set BIBINPUTS=$BIBINPUTS"
echo "📌 Set BSTINPUT=$BSTINPUT"
echo

# If main.bcf doesn't exist yet, we need a first LaTeX run to generate it
if [ ! -f "$BFC_FILE" ]; then
  echo "⚠️ main.bcf not found — running initial LaTeX build to generate it ..."
  bash "$BASE_DIR/buildLatexDocument.sh"
  echo "✅ Initial LaTeX build completed."
  echo
fi

# Run biber inside OUT_DIR
(
  cd "$OUT_DIR"
  biber --quiet "$MAIN_BASENAME"
)
echo "✅ Biber run completed."
echo

# === STEP 3: Run final LaTeX build ===
echo "🏗️ Running final LaTeX build ..."
bash "$BASE_DIR/buildLatexDocument.sh"
echo

echo "✅ FULL RENEW BUILD COMPLETED!"
