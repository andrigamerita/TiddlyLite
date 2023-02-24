#!/bin/sh
cd "$( dirname "$( realpath "$0" )" )"

# Needed in $PATH: find patch node uglifyjs # uglifycss
# DEVNOTE: To create a patch: diff --unified TiddlyWiki5/{UpstreamFile} TiddlyLite/{PatchedFile} > Patch.patch

ApplyPatchesFrom() {
	cd ../Patches/$1
	find . -type f -name "*" -exec patch --unified --no-backup-if-mismatch ../../Output/{} -i {} \;
	cd ../../Output
}

RemoveCryptoModule() {
	ApplyPatchesFrom NoBootCrypto
	rm \
		./boot/boot.css.tid \
		./boot/sjcl.js \
		./boot/sjcl.js.meta \
		./core/sjcl-license.tid \
		./core/modules/filters/crypto.js
}

All() {
	# Clean output folder, then copy original TiddlyWiki source in it
	rm -rf ./Output/* || true
	mkdir -p ./Output
	cp -r ./TiddlyWiki5/* ./Output/
	cp -r ./Output/editions/tw5.com ./Output/editions/TiddlyLite
	
	# Copy TiddlyLite sources in output folder, overwriting conflicts
	cp -r ./TiddlyLite/* ./Output/
	
	cd ./Output
	
	RemoveCryptoModule
	
	# Delete all palettes except for Vanilla (Light) and Spartan Night (Dark)
	mv ./core/palettes/Vanilla.tid ./core/palettes/Vanilla.tid.tmp
	mv ./core/palettes/SpartanNight.tid ./core/palettes/SpartanNight.tid.tmp
	rm ./core/palettes/*.tid
	mv ./core/palettes/Vanilla.tid.tmp ./core/palettes/Vanilla.tid
	mv ./core/palettes/SpartanNight.tid.tmp ./core/palettes/SpartanNight.tid
	
	# Delete assets that are now unneeded
	rm ./core/images/cancel-button.tid # We reuse close-button
	
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
