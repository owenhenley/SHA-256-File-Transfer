# SHA-256-File-Transfer
RSync File Transfer with SHA-256 checksum

A script designed for securley ingesting video footage.

The script has a user friendly CLI and will verify with SHA-256 that all footage has been copied successfully.

It copies all files including their folder if they have one. i.e: Transferring `MEDIA/<footage>` will transfer the entire `MEDIA` folder. 
Checksums are written to both Source and Destination, but the checksum `.txt` file is not copied from the source. (As I type this I wonder if a card is read only, will the checksum fail?). This can be changes by adding a `/` to the path names on line `75` I beleive. That way, when you drag a folder, it only copies the contents.

To run the script, save it as a file and make it executable: `$ chmod +x rsync_with_sha256.command`
