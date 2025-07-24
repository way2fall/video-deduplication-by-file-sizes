#!/bin/zsh

# Video deduplication script
# Removes duplicate video files based on file size (within 2 bytes tolerance)

# Function to check if two file sizes are considered duplicates (within 2 bytes)
is_duplicate() {
    local size1=$1
    local size2=$2
    local diff=$((size1 > size2 ? size1 - size2 : size2 - size1))
    # Return 0 (success/true) if difference is <= 2, otherwise return 1 (failure/false)
    [[ $diff -le 2 ]]
}

# Function to get video file extensions pattern
get_video_extensions() {
    echo "*.mp4|*.avi|*.mkv|*.mov|*.wmv|*.flv|*.webm|*.m4v|*.3gp|*.mpg|*.mpeg|*.m2v|*.ogv"
}

# Create video_sizes.txt if it doesn't exist
touch video_sizes.txt

echo "Starting video deduplication process..."

# Step 1: Get all video files and their sizes in current folder
echo "Step 1: Finding video files in current directory..."

# Array to store video files and their sizes
typeset -A video_files
typeset -a files_to_process
typeset -a surviving_files

# Find all video files in current directory
for ext in mp4 avi mkv mov wmv flv webm m4v 3gp mpg mpeg m2v ogv; do
    for file in *.$ext(N); do
        if [[ -f "$file" ]]; then
            size=$(stat -c %s "$file" 2>/dev/null || stat -f %z "$file" 2>/dev/null)
            if [[ -n "$size" ]]; then
                files_to_process+=("$file:$size")
            fi
        fi
    done
done

echo "Found ${#files_to_process[@]} video files"

# Step 1: Remove duplicates within current folder
echo "Step 1: Removing duplicates within current folder..."

for current_file in "${files_to_process[@]}"; do
    current_name="${current_file%:*}"
    current_size="${current_file##*:}"
    
    # Check if this file should be kept
    keep_file=true
    
    for existing_file in "${surviving_files[@]}"; do
        existing_name="${existing_file%:*}"
        existing_size="${existing_file##*:}"
        
        if is_duplicate "$current_size" "$existing_size"; then
            echo "  Duplicate found: $current_name (size: $current_size) ~ $existing_name (size: $existing_size)"
            echo "  Removing: $current_name"
            rm "$current_name"
            keep_file=false
            break
        fi
    done
    
    if $keep_file; then
        surviving_files+=("$current_file")
    fi
done

echo "After step 1: ${#surviving_files[@]} files remain"

# Step 2: Check against video_sizes.txt
echo "Step 2: Checking against existing sizes in video_sizes.txt..."

# Read existing sizes from video_sizes.txt
typeset -a existing_sizes
if [[ -s video_sizes.txt ]]; then
    while IFS= read -r line; do
        existing_sizes+=("$line")
    done < video_sizes.txt
fi

echo "Found ${#existing_sizes[@]} existing size records"

# Check surviving files against existing sizes
typeset -a final_surviving_files
for current_file in "${surviving_files[@]}"; do
    current_name="${current_file%:*}"
    current_size="${current_file##*:}"
    
    # Check if this size already exists in video_sizes.txt
    duplicate_found=false
    
    for existing_size in "${existing_sizes[@]}"; do
        if is_duplicate "$current_size" "$existing_size"; then
            echo "  Duplicate found against existing: $current_name (size: $current_size) ~ existing size: $existing_size"
            echo "  Removing: $current_name"
            rm "$current_name"
            duplicate_found=true
            break
        fi
    done
    
    if ! $duplicate_found; then
        final_surviving_files+=("$current_file")
    fi
done

echo "After step 2: ${#final_surviving_files[@]} files remain"

# Step 3: Append surviving files' sizes to video_sizes.txt
echo "Step 3: Appending surviving file sizes to video_sizes.txt..."

for final_file in "${final_surviving_files[@]}"; do
    file_name="${final_file%:*}"
    file_size="${final_file##*:}"
    echo "$file_size" >> video_sizes.txt
    echo "  Recorded: $file_name (size: $file_size)"
done

echo "Deduplication complete!"
echo "Final results:"
echo "  - Files processed: ${#files_to_process[@]}"
echo "  - Files remaining: ${#final_surviving_files[@]}"
echo "  - Files removed: $((${#files_to_process[@]} - ${#final_surviving_files[@]}))"

# Sort and remove any duplicate entries that might have been added to video_sizes.txt
echo "Cleaning up video_sizes.txt..."
sort -n video_sizes.txt | uniq > video_sizes.txt.tmp && mv video_sizes.txt.tmp video_sizes.txt

echo "Done!"