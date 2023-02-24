#!/bin/sh
cd "$( dirname "$( realpath "$0" )" )"

# Needed in $PATH: find patch node uglifyjs # uglifycss
# DEVNOTE: To create a patch: diff -u TiddlyLite/{FinalFile} TiddlyWiki5/{OriginalFile} > Patch.patch

alias patch="patch -u -R --no-backup-if-mismatch"

All() {
	# Clean output folder, then copy original TiddlyWiki source in it
	rm -rf ./Output/* || true
	mkdir -p ./Output
	cp -r ./TiddlyWiki5/* ./Output/
	cp -r ./Output/editions/tw5.com ./Output/editions/TiddlyLite
	
	# Copy TiddlyLite sources in output folder, overwriting conflicts
	cp -r ./TiddlyLite/* ./Output/
	
	cd ./Output
	
	# Remove crypto module
	patch ./boot/boot.js -i ../Patches/NoBootCrypto.patch
	rm \
		./boot/boot.css.tid \
		./boot/sjcl.js \
		./boot/sjcl.js.meta \
		./core/sjcl-license.tid \
		./core/modules/filters/crypto.js
	
	# Delete assets that are now unneeded
	rm ./core/images/cancel-button.tid
	
	# Apply patches to remaining files that need them
		# Minify files
		for Dir in boot core
		do
			cd ./$Dir
			find . -type f -name "*.js" -exec uglifyjs --verbose --comments all --keep-fargs --keep-fnames {} --output {} \;
			cd ..
		done
	
	# Build the TiddlyLite sites
	sh ./bin/BuildTiddlyLite.sh
}

set -x # Echo On
$1
