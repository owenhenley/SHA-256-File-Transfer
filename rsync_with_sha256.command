#!/bin/bash

# Formatting
bold=$(tput bold)
normal=$(tput sgr0)
green="\033[0;32m"
red="\033[0;31m"
reset="\033[0m"

############################### HELPERS ###############################

request_source() {
    while true; do
        printf "\n${bold}Enter the source directory:${normal}\n"
        read source_dir

        if [ ! -d "$source_dir" ]; then
            printf "${red}${bold}Source directory does not exist. Enter a valid source directory.${normal}${reset}"
            continue
        fi

        if [ -z "$(find "$source_dir" -type f)" ]; then
            printf "\n${red}${bold}Source directory is empty. Enter a valid source directory.${normal}${reset}\n"
            continue
        fi
        break
    done
}

request_destination() {
    while true; do
        printf "\n${bold}Enter the destination directory:${normal}\n"
        read dest_dir

        if [ ! -d "$dest_dir" ]; then
            printf "\n${red}${bold}Destination directory does not exist. Enter a valid destination directory.${normal}${reset}\n"
            continue
        fi
        break
    done
}

# Calculate checksum for each individual file in the directory
calculate_file_checksums() {
    local dir="$1"

    # Start the progress bar in the background
    while true; do
        echo -n "."
        sleep 1
    done &
    progress_pid=$!  # Capture the process ID of the background job

    # Calculate checksums, excluding .DS_Store and the checksum file itself
    find "$dir" -type f ! -name ".DS_Store" ! -name "sha2_checksums.txt" -exec sha256sum {} \; | awk '{print $1}' > "$dir/sha2_checksums.txt"
    
    kill "$progress_pid" 2>/dev/null  # Stop the progress dots after checksum calculation completes
    wait "$progress_pid" 2>/dev/null  # Wait for the process to finish before moving to a new line
    echo ""  # Move to a new line after the progress dots
}

############################### START ###############################

printf "\n${bold}Welcome to the rsync with SHA-256 checksum verification!\n\n${normal}Each file in the source and destination directories will be compared using SHA-256 checksums. You can manually check this yourself.\n\nLet's get started.\n\n"

# User Input
request_source
request_destination

# Automated steps
printf "\n${bold}Generating checksums for source directory:${normal}\n"
calculate_file_checksums "$source_dir"

printf "\n${bold}Starting transfer from Source to Destination:${normal}\n"
rsync -av --info=progress2 --exclude=".DS_Store" --exclude="sha2_checksums.txt" "$source_dir" "$dest_dir"

printf "\n${bold}Generating checksums for destination directory:${normal}\n"
calculate_file_checksums "$dest_dir"

printf "\n${bold}Comparing checksums file by file:${normal}\n"
if diff <(sort "$source_dir/sha2_checksums.txt") <(sort "$dest_dir/sha2_checksums.txt"); then
    # To clean up checksum files after comparison:
    # rm "$source_dir/sha2_checksums.txt" "$dest_dir/sha2_checksums.txt"
    printf "\n${green}${bold}Transfer completed successfully and checksums match!${normal}${reset}\n"
else
    printf "\n${red}${bold}Warning: Checksums do not match. There may have been an error in the transfer.${normal}${reset}\n"
fi

printf "\n${bold}Press any key to exit${normal}\n"
read -n 1 -s

# Close the terminal window
osascript -e 'tell application "Terminal" to quit'
exit

############################### END ###############################

# To run the script, save it to a file (e.g: rsync_with_sha256.sh), make it executable, and double click to run it: 
# chmod +x rsync_with_sha256.command

#  Note:  The checksum files are not deleted after comparison. You can uncomment line 81 if you want to clean up after comparison. 
#  Note:  The script excludes .DS_Store files from the checksum calculation and transfer.