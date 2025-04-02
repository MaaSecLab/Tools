#!/bin/bash

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
    echo -e "=== $1 ==="
}

# Function to analyze a single file
analyze_file() {
    local file_to_analyze="$1"
    local file_name
    file_name="$(basename "$file_to_analyze")"
    
    print_section "ANALYZING: $file_name"
    
    echo ""
    print_section "FILE METADATA"
    file "$file_to_analyze"

    echo ""
    print_section "EXIFTOOL ANALYSIS"
    if command -v exiftool >/dev/null 2>&1; then
        exif_output=$(exiftool "$file_to_analyze")
        echo "$exif_output"
    else
        echo "exiftool not installed. Install with: sudo apt-get install exiftool"
    fi

    # PDF analysis
    if file "$file_to_analyze" | grep -qi "pdf"; then
        print_section "PDF ANALYSIS"
        if command -v pdfinfo >/dev/null 2>&1; then
            pdf_output=$(pdfinfo "$file_to_analyze")
            echo "$pdf_output"
        else
            echo "pdfinfo not installed. Install with: sudo apt-get install poppler-utils"
        fi
    fi

    # String analysis
    echo ""
    print_section "STRINGS ANALYSIS"

    # Capture strings output once
    strings_output=$(strings -t x "$file_to_analyze")

    # Helper function to search and print results
    search_and_record() {
        local pattern="$1"
        local desc="$2"
        echo "Searching for $desc: $pattern"
        local result
        result=$(echo "$strings_output" | grep -i "$pattern")
        if [ -n "$result" ]; then
            echo "$result"
        else
            echo "No results found matching pattern: $pattern"
        fi
        echo ""
    }

    search_and_record "$FLAG_FORMAT" "flag format"
    search_and_record "flag" "keyword 'flag'"

    # Look for base64 encoded content
    echo ""
    print_section "BASE64 CONTENT"
    # Check metadata fields for base64 content using exiftool
    if command -v exiftool >/dev/null 2>&1; then
        while IFS=':' read -r field value; do
            # Trim whitespace
            value=$(echo "$value" | tr -d '[:space:]')
            if echo "$value" | grep -qE '^[A-Za-z0-9+/]{20,}={0,2}$'; then
                echo "Found base64 string in $field: $value"
                decoded=$(echo "$value" | base64 -d 2>/dev/null)
                if [ -n "$decoded" ]; then
                    echo "Decoded: $decoded"
                fi
            fi
        done < <(exiftool "$file_to_analyze")
    fi

    # Check file content for base64 strings
    mapfile -t base64_strings < <(strings "$file_to_analyze" | grep -Eo '[A-Za-z0-9+/]{20,}={0,2}')
    for line in "${base64_strings[@]}"; do
        echo "Found base64 string: $line"
        decoded=$(echo "$line" | base64 -d 2>/dev/null)
        if [ -n "$decoded" ]; then
            echo "Decoded: $decoded"
        fi
    done

    # Binwalk analysis
    echo ""
    print_section "BINWALK ANALYSIS"
    if command -v binwalk >/dev/null 2>&1; then
        binwalk "$file_to_analyze"
    else
        echo "binwalk not installed. Install with: sudo apt-get install binwalk"
    fi

    print_section "END OF ANALYSIS"
    echo ""
}

# Create temporary directory for extraction
mkdir -p "$TEMP_DIR"
LOGFILE="$TEMP_DIR/analysis.txt"

# Important: Use file descriptor to manage output
exec 3>&1                    # Save the place that stdout goes
exec > "$LOGFILE" 2>&1       # Redirect stdout and stderr to logfile

echo "Analysis in process, wait for it..." >&3  # Print to original stdout

# Check if file is an archive and extract if necessary
if file "$FILE" | grep -qi "zip\|apk"; then
    print_section "EXTRACTING ARCHIVE"
    unzip -q "$FILE" -d "$TEMP_DIR"
    echo "Extracted contents to $TEMP_DIR"
    find "$TEMP_DIR" -type f ! -name "analysis.txt" | while read -r extracted_file; do
        analyze_file "$extracted_file"
    done
else
    analyze_file "$FILE"
fi

# Print completion message to original stdout
echo -e "Analysis complete. Analysis saved to: $LOGFILE" >&3

# Restore stdout and stderr
exec 1>&3                    # Restore stdout
exec 2>&1                    # Restore stderr 
exec 3>&-                    # Close the temporary file descriptor