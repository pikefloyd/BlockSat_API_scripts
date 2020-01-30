# BlockSat_API_scripts
Bash scripts to send text or files to the Blockstream Satellite

More information about Blockstream Satellite here;

https://blockstream.com/satellite/

https://github.com/Blockstream/satellite

## sendtext.sh usage example, (requires qrencode and feh to be installed);

`./sendtext.sh any text goes here`

or simply

`./sendtext.sh`

Then folow the prompts in the script. A QR encoded lightning network invoice will pop-up, (using feh) and will be removed once paid.

## sendfile.sh usage example, (requires qrencode to be installed);

`./sendfile.sh file1.txt file2.jpg filen.doc`

The script will create new files in the same directory;

`file1-pay.png
file2-pay.png
filen-pay.png`

The png files are QR encoded lightning network invoces. Once paid the script will remove -pay.png files.

