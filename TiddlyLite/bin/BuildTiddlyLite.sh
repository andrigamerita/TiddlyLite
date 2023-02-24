#!/bin/bash

# Default to the current version number for building the plugin library

if [  -z "$TW5_BUILD_VERSION" ]; then
    TW5_BUILD_VERSION=v5.2.5
fi

echo "Using TW5_BUILD_VERSION as [$TW5_BUILD_VERSION]"

# Default to using TiddlyLite as the main edition

if [  -z "$TW5_BUILD_MAIN_EDITION" ]; then
    TW5_BUILD_MAIN_EDITION=./editions/TiddlyLite
fi

echo "Using TW5_BUILD_MAIN_EDITION as [$TW5_BUILD_MAIN_EDITION]"

# Default to the version of TiddlyWiki installed in this repo

if [  -z "$TW5_BUILD_TIDDLYWIKI" ]; then
    TW5_BUILD_TIDDLYWIKI=./tiddlywiki.js
fi

echo "Using TW5_BUILD_TIDDLYWIKI as [$TW5_BUILD_TIDDLYWIKI]"

# Set up the build details

if [  -z "$TW5_BUILD_DETAILS" ]; then
    TW5_BUILD_DETAILS="$(git symbolic-ref --short HEAD)-$(git rev-parse HEAD) from $(git remote get-url origin)"
fi

echo "Using TW5_BUILD_DETAILS as [$TW5_BUILD_DETAILS]"

if [  -z "$TW5_BUILD_COMMIT" ]; then
	TW5_BUILD_COMMIT="$(git rev-parse HEAD)"
fi

echo "Using TW5_BUILD_COMMIT as [$TW5_BUILD_COMMIT]"

# Set up the build output directory

if [  -z "$TW5_BUILD_OUTPUT" ]; then
    TW5_BUILD_OUTPUT=./output
fi

mkdir -p $TW5_BUILD_OUTPUT

if [  ! -d "$TW5_BUILD_OUTPUT" ]; then
    echo 'A valid TW5_BUILD_OUTPUT environment variable must be set'
    exit 1
fi

echo "Using TW5_BUILD_OUTPUT as [$TW5_BUILD_OUTPUT]"

echo "Build details: $TW5_BUILD_DETAILS"

# Put the build details into a .tid file so that it can be included in each build (deleted at the end of this script)

echo -e -n "title: $:/build\ncommit: $TW5_BUILD_COMMIT\n\n$TW5_BUILD_DETAILS\n" > $TW5_BUILD_OUTPUT/build.tid

######################################################
#
# Core distribution
#
######################################################

# /empty.html			Empty
node $TW5_BUILD_TIDDLYWIKI \
	$TW5_BUILD_MAIN_EDITION \
	--verbose \
	--output $TW5_BUILD_OUTPUT \
	--build empty \
	|| exit 1

# Delete the temporary build tiddler

rm $TW5_BUILD_OUTPUT/build.tid || exit 1
