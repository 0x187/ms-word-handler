# ms-word:// Protocol Handler for LibreOffice

Opens `ms-word:ofe|u|...` links (Microsoft Office Online / SharePoint) directly in **LibreOffice Writer** on Ubuntu.  
After editing, changes are uploaded back to the server automatically – no Microsoft Office required.

## How It Works

1. The `ms-word:ofe|u|...` link is passed to a custom handler script.
2. The script downloads the document via HTTP.
3. LibreOffice Writer opens the file for editing.
4. When you close Writer, the modified file is uploaded back to the server using an HTTP PUT request.

## Installation

Clone the repository and run the install script:

```bash
git clone https://github.com/0x187/ms-word-handler.git
cd ms-word-libreoffice-handler
chmod +x install-ms-word-handler.sh
./install-ms-word-handler.sh
