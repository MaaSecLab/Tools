#!/bin/bash
FOUND_FLAGS=()

check_for_flag() {
    local input="$1"
    # Capture flags that start with the provided flag format and end at the next "}"
    while IFS= read -r flag; do
        FOUND_FLAGS+=("$flag")
    done < <(echo "$input" | grep -Eo "${FLAG_FORMAT}[^}]+}")
}

# Check if required arguments are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <file_to_analyze> <flag_format>"
    echo "Example: $0 challenge.zip 'picoCTF{'"
    exit 1
fi

FILE="$1"
FLAG_FORMAT="$2"
TEMP_DIR="temp_analysis_$(date +%s)"

# Check if file exists
if [ ! -f "$FILE" ]; then
    echo "Error: File '$FILE' not found!"
    exit 1
fi

# Function to print section headers
print_section() {
    echo -e "\n\033[1;34m=== $1 ===\033[0m"
}

# Function to analyze a single file
analyze_file() {
    local file_to_analyze="$1"
    local file_name="$(basename "$file_to_analyze")"
    
    print_section "ANALYZING: $file_name"
    
    print_section "FILE METADATA"
    file "$file_to_analyze"

    print_section "EXIFTOOL ANALYSIS"
    if command -v exiftool >/dev/null 2>&1; then
        exif_output=$(exiftool "$file_to_analyze")
        echo "$exif_output"
        check_for_flag "$exif_output" # append found flags to FOUND_FLAGS
    else
        echo "exiftool not installed. Install with: sudo apt-get install exiftool"
    fi

    # PDF analysis
    if file "$file_to_analyze" | grep -qi "pdf"; then
        print_section "PDF ANALYSIS"
        if command -v pdfinfo >/dev/null 2>&1; then
            pdf_output=$(pdfinfo "$file_to_analyze")
            echo "$pdf_output"
            check_for_flag "$pdf_output" # append found flags to FOUND_FLAGS
        else
            echo "pdfinfo not installed. Install with: sudo apt-get install poppler-utils"
        fi
    fi

    # String analysis
    print_section "STRINGS ANALYSIS"

    # Capture strings output once
    strings_output=$(strings "$file_to_analyze")

    # Helper function to search and record flags
    search_and_record() {
        local pattern="$1"
        local desc="$2"
        echo "Searching for $desc: $pattern"
        local result
        result=$(echo "$strings_output" | grep -i "$pattern")
        if [ -n "$result" ]; then
            echo "$result"
            check_for_flag "$result"  # Assumes check_for_flag is defined to append found flags
        else
            echo "No flags found matching pattern: $pattern"
        fi
        echo ""
    }

    search_and_record "$FLAG_FORMAT" "flag format"
    search_and_record "flag" "keyword 'flag'"

    # Look for base64 encoded content
    print_section "BASE64 CONTENT"
    strings "$file_to_analyze" | grep -Eo '[A-Za-z0-9+/]{20,}={0,2}' | while read -r line; do
        echo "Found base64 string: $line"
        decoded=$(echo "$line" | base64 -d 2>/dev/null)
        echo "Decoded: $decoded"
        check_for_flag "$decoded" # append found flags to FOUND_FLAGS
    done

    # Binwalk analysis
    print_section "BINWALK ANALYSIS"
    if command -v binwalk >/dev/null 2>&1; then
        binwalk "$file_to_analyze"
    else
        echo "binwalk not installed. Install with: sudo apt-get install binwalk"
    fi

    # Hexadecimal analysis
    print_section "HEXDUMP ANALYSIS"
    hexdump -C "$file_to_analyze" | head -n 10
    echo "... (showing first 10 lines only)"

    print_section "XXD ANALYSIS"
    xxd "$file_to_analyze" | head -n 10
    echo "... (showing first 10 lines only)"
}

# Create temporary directory for extraction
mkdir -p "$TEMP_DIR"

# Check if file is an archive and extract if necessary
if file "$FILE" | grep -qi "zip\|apk"; then
    print_section "EXTRACTING ARCHIVE"
    unzip -q "$FILE" -d "$TEMP_DIR"
    echo "Extracted contents to $TEMP_DIR"
    
    # First analyze the archive itself
    print_section "ANALYZING ARCHIVE FILE"
    analyze_file "$FILE"
    
    # Then analyze each extracted file
    print_section "ANALYZING EXTRACTED CONTENTS"
    find "$TEMP_DIR" -type f | while read -r extracted_file; do
        analyze_file "$extracted_file"
    done
else
    analyze_file "$FILE"
fi

# Cleanup
if [ -d "$TEMP_DIR" ]; then
    read -p "Analysis complete. Remove temporary files? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$TEMP_DIR"
        echo "Temporary files removed."
    else
        echo "Temporary files kept in: $TEMP_DIR"
    fi
fi

if [ ${#FOUND_FLAGS[@]} -gt 0 ]; then
    print_section "FLAG FOUND"
    for flag in "${FOUND_FLAGS[@]}"; do
        echo "FLAG FOUND: $flag"
    done
fi

if [ ${#FOUND_FLAGS[@]} -eq 0 ]; then
    print_section "NO FLAG FOUND"
fi

print_section "ANALYSIS COMPLETE"