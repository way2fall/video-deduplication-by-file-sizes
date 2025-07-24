# FB Video Processing Optimized

A zsh-based video deduplication tool designed to efficiently remove duplicate video files based on file size comparison.

## Overview

This project provides an intelligent video deduplication system that identifies and removes duplicate video files by comparing their file sizes with a tolerance of 2 bytes. It's particularly useful for managing large collections of video files where duplicates may exist.

## Features

- **Smart Deduplication**: Removes duplicate videos based on file size (within 2-byte tolerance)
- **Multi-format Support**: Handles various video formats including MP4, AVI, MKV, MOV, WMV, FLV, WebM, M4V, 3GP, MPG, MPEG, M2V, and OGV
- **Two-stage Processing**: 
  1. Removes duplicates within the current directory
  2. Checks against previously processed files stored in `video_sizes.txt`
- **Persistent Memory**: Maintains a record of processed file sizes to prevent re-processing duplicates
- **Safe Operation**: Uses conservative file size comparison to minimize false positives

## Files

- `deduplicate_videos.zsh` - Main deduplication script
- `video_sizes.txt` - Database of processed video file sizes
- `.gitignore` - Excludes video files and temporary data from version control

## Usage

### Prerequisites

- zsh shell
- `stat` command (available on most Unix-like systems)

### Running the Script

1. Navigate to the directory containing your video files:
   ```bash
   cd /path/to/your/video/directory
   ```

2. Copy the script to your video directory or run it from the project directory:
   ```bash
   ./deduplicate_videos.zsh
   ```

### How It Works

The script operates in three stages:

1. **Discovery**: Scans the current directory for video files and records their sizes
2. **Local Deduplication**: Removes duplicates within the current directory
3. **Global Deduplication**: Checks remaining files against the `video_sizes.txt` database
4. **Record Keeping**: Appends new unique file sizes to the database

### Output

The script provides detailed output showing:
- Number of files found and processed
- Duplicate files identified and removed
- Final count of remaining files
- Summary statistics

Example output:
```
Starting video deduplication process...
Step 1: Finding video files in current directory...
Found 25 video files
Step 1: Removing duplicates within current folder...
  Duplicate found: video2.mp4 (size: 1241520) ~ video1.mp4 (size: 1241522)
  Removing: video2.mp4
After step 1: 24 files remain
...
Deduplication complete!
Final results:
  - Files processed: 25
  - Files remaining: 20
  - Files removed: 5
```

## Safety Features

- **Conservative Matching**: Only files within 2 bytes of each other are considered duplicates
- **Detailed Logging**: Shows exactly which files are being compared and removed
- **Size Database**: Maintains sorted, unique list of processed file sizes

## Supported Video Formats

- MP4, AVI, MKV, MOV
- WMV, FLV, WebM, M4V
- 3GP, MPG, MPEG, M2V, OGV

## Notes

- The script only processes files in the current directory (not recursive)
- File size comparison uses a 2-byte tolerance to account for minor encoding differences
- The `video_sizes.txt` file should be preserved between runs to maintain deduplication history
- Deleted files cannot be recovered - ensure you have backups if needed

## License

This project is provided as-is for video file management purposes.