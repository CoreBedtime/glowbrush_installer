#!/bin/bash

# Function to check if the script is running as root
check_root() {
  if [ "$(id -u)" != "0" ]; then
    echo "This script requires root privileges. Please run it with sudo."
    exit 1
  fi
}

# Function to download the file from Google Drive
download_file() {
  file_id=$1
  destination=$2

  confirm=$(curl -sc /dev/null "https://drive.google.com/uc?export=download&id=${file_id}" | \
            awk '/confirm=/{print $NF}')

  curl -Lb "confirm=${confirm}&id=${file_id}" \
       -o "${destination}" \
       "https://drive.google.com/uc?export=download&id=${file_id}"
}

# Function to extract the 7z file
extract_file() {
  file_path=$1
  output_dir=$2

  7z x "${file_path}" -o"${output_dir}"
}

# Google Drive file ID extracted from the sharing link
file_id="1BpUU9IGGrMEDWEoSEXKgCXGsDZ9fNQ0H"

# Destination for downloaded file
download_destination="downloaded_file.7z"

# Output directory for extracted files
extracted_dir="extracted_files"

# Check for root privileges
check_root

# Install p7zip if not already installed
if ! command -v 7z &> /dev/null; then
  echo "Installing p7zip..."
  sudo brew install p7zip
fi

# Download the file
download_file "${file_id}" "${download_destination}"
extract_file "${download_destination}" "${extracted_dir}"

rm -rf /Library/mocha 
mv ./${extracted_dir}/mocha /Library/

wget https://raw.githubusercontent.com/CoreBedtime/mocha/master/com.mocha.loader.plist
mv com.mocha.loader.plist /Library/LaunchDaemons/
sudo launchctl load -w /Library/LaunchDaemons/com.mocha.loader.plist