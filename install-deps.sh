#!/usr/bin/env bash
# Install everything needed to build src/main.tex on Fedora
# (pdflatex + biber, driven by latexmk).
#
# The package list was derived from the files a full build actually reads
# (pdflatex -recorder), mapped to their owning RPMs, so it is the minimal set
# on top of a plain Fedora install; no TeX Live scheme is required.
#
# Usage:
#   ./install-deps.sh           install missing packages (asks for sudo)
#   ./install-deps.sh --check   only report which packages are missing
#   ./install-deps.sh --build   install, then do a test build of src/main.tex

set -euo pipefail

# Build tools
TOOLS=(
    latexmk
    biber
    texlive-pdftex
    texlive-kpathsea
    texlive-latex
    texlive-latexconfig
)

# Packages loaded directly by main.tex / vub.sty
DIRECT=(
    texlive-babel texlive-babel-dutch texlive-babel-english
    texlive-hyphen-dutch texlive-hyphen-english
    texlive-biblatex texlive-biblatex-ieee
    texlive-caption
    texlive-cleveref
    texlive-csquotes
    texlive-emptypage
    texlive-float
    texlive-geometry
    texlive-graphics texlive-graphics-cfg texlive-graphics-def
    texlive-hyperref
    texlive-listings
    texlive-tools
    texlive-xcolor
    texlive-wrapfig2 texlive-curve2e texlive-pict2e
    texlive-pgf
    texlive-adjustbox
)

# Indirect dependencies, fonts and support packages. Several of these are not
# declared as RPM dependencies (e.g. wrapfig2 -> curve2e), hence listed here.
SUPPORT=(
    texlive-amsfonts texlive-cm texlive-cm-super texlive-ec texlive-tex-gyre
    texlive-fontname
    texlive-atbegshi texlive-atveryend texlive-auxhook texlive-bigintcalc
    texlive-bitset texlive-collectbox texlive-epstopdf-pkg texlive-etexcmds
    texlive-etoolbox texlive-gettitlestring texlive-hycolor texlive-ifoddpage
    texlive-iftex texlive-infwarerr texlive-intcalc texlive-kvdefinekeys
    texlive-kvoptions texlive-kvsetkeys texlive-l3backend texlive-l3kernel
    texlive-l3packages texlive-letltxmacro texlive-logreq texlive-ltxcmds
    texlive-mptopdf texlive-pdfescape texlive-pdftexcmds texlive-refcount
    texlive-rerunfilecheck texlive-uniquecounter texlive-url texlive-varwidth
    texlive-xkeyval
)

PACKAGES=("${TOOLS[@]}" "${DIRECT[@]}" "${SUPPORT[@]}")

if [[ ! -r /etc/fedora-release ]]; then
    echo "This script only supports Fedora." >&2
    exit 1
fi

missing=()
for pkg in "${PACKAGES[@]}"; do
    rpm -q --quiet "$pkg" || missing+=("$pkg")
done

if [[ "${1:-}" == "--check" ]]; then
    if ((${#missing[@]} == 0)); then
        echo "All ${#PACKAGES[@]} packages are installed."
    else
        echo "Missing ${#missing[@]} of ${#PACKAGES[@]} packages:"
        printf '  %s\n' "${missing[@]}"
        exit 1
    fi
    exit 0
fi

if ((${#missing[@]} == 0)); then
    echo "All ${#PACKAGES[@]} packages are already installed."
else
    echo "Installing ${#missing[@]} missing package(s):"
    printf '  %s\n' "${missing[@]}"
    sudo dnf install "${missing[@]}"
fi

if [[ "${1:-}" == "--build" ]]; then
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    cd "$(dirname "$0")/src"
    latexmk -pdf -interaction=nonstopmode -halt-on-error -outdir="$tmp" main.tex >/dev/null \
        && echo "Test build succeeded." \
        || { echo "Test build failed; see $tmp/main.log" >&2; trap - EXIT; exit 1; }
fi
