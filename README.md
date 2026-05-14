# ms-word-handler
ms-word Protocol Handler for LibreOffice on Ubuntu
This script installs a custom protocol handler that allows ms-word:ofe|u|... links (commonly used by Microsoft Office Online / SharePoint) to be opened and edited directly in LibreOffice Writer. It downloads the document, opens it for editing, and automatically uploads the changes back to the server using HTTP PUT when Writer is closed. No Microsoft Office or browser plugins are required.


chmod +x install-ms-word-handler.sh
./install-ms-word-handler.sh
