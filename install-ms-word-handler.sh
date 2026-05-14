#!/bin/bash
set -e

echo "Installing ms-word: protocol handler for LibreOffice..."

# 1. Create the handler script (no cookies needed)
sudo tee /usr/local/bin/ms-word-handler.sh > /dev/null << 'HANDLER_EOF'
#!/bin/bash
LOGFILE="/tmp/ms-word-handler.log"
echo "$(date): === New request ===" >> "$LOGFILE"

# Decode the argument and extract the file URL
decoded=$(python3 -c "import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1]))" "$1")
file_url=$(echo "$decoded" | awk -F'|' '{print $NF}')
echo "$(date): File URL: $file_url" >> "$LOGFILE"

# Prepare local working copy
mkdir -p "$HOME/chargoon_edits"
filename=$(basename "$file_url")
workfile="$HOME/chargoon_edits/$filename"

# Download the document (no authentication needed)
curl -s -o "$workfile" "$file_url" 2>> "$LOGFILE"

if [ ! -s "$workfile" ]; then
    zenity --error --text="Download failed. Check your internet connection."
    echo "$(date): Download failed" >> "$LOGFILE"
    exit 1
fi

echo "$(date): Downloaded to $workfile" >> "$LOGFILE"

# Open in LibreOffice Writer and wait until closed
/usr/bin/libreoffice --writer "$workfile" >> "$LOGFILE" 2>&1
echo "$(date): LibreOffice closed" >> "$LOGFILE"

# Upload the modified file back to the server using PUT
echo "$(date): Uploading to $file_url" >> "$LOGFILE"
curl -s -X PUT --data-binary @"$workfile" \
  -H "Content-Type: application/vnd.openxmlformats-officedocument.wordprocessingml.document" \
  "$file_url" 2>> "$LOGFILE"

if [ $? -eq 0 ]; then
    zenity --info --text="File successfully saved to server."
    echo "$(date): Upload succeeded" >> "$LOGFILE"
else
    zenity --error --text="Upload failed. See /tmp/ms-word-handler.log"
    echo "$(date): Upload failed" >> "$LOGFILE"
fi
HANDLER_EOF

sudo chmod +x /usr/local/bin/ms-word-handler.sh
echo "✔ Handler script installed."

# 2. Create a desktop entry to register the protocol
sudo tee /usr/share/applications/libreoffice-writer-msword.desktop > /dev/null << 'DESKTOP_EOF'
[Desktop Entry]
Version=1.0
Terminal=false
Icon=libreoffice-writer
Type=Application
Categories=Office;WordProcessor;
Exec=/usr/local/bin/ms-word-handler.sh %U
MimeType=application/vnd.oasis.opendocument.text;application/vnd.openxmlformats-officedocument.wordprocessingml.document;text/plain;
Name=LibreOffice Writer (MS-Word handler)
GenericName=Word Processor
Comment=Open and edit ms-word:ofe|u| links with LibreOffice
StartupNotify=true
InitialPreference=5
StartupWMClass=libreoffice-writer
X-KDE-Protocols=file,http,webdav,webdavs
DESKTOP_EOF

echo "✔ Desktop entry created."

# 3. Register the protocol handler
xdg-mime default libreoffice-writer-msword.desktop x-scheme-handler/ms-word
echo "✔ Protocol ms-word: registered."

echo ""
echo "Installation complete."
echo "You can now click ms-word: links; they will open in LibreOffice."
echo "After editing, close LibreOffice Writer to upload changes back to the server."
