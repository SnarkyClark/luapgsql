#!/bin/sh

# Copyright (c) 2013 Dag-Erling Smørgrav
# All rights reserved.

# Print an informational message
info() {
	echo "mkpkgng: $@"
}

# Print an error message and exit
error() {
	echo "mkpkgng: $@" 1>&2
	exit 1
}

#
# Determine pkgng version and ABI
#
pkgver=$(pkg -v)
[ -n "$pkgver" ] || error "Unable to determine pkgng version."
pkgabi=$(pkg config abi)
[ -n "$pkgabi" ] || error "Unable to determine package ABI."

package=$1
version=$2

#
# Create temporary directory
#
info "Creating the temporary directory."
tmproot=$(mktemp -d "${TMPDIR:-/tmp}/$package-$version.XXXXXX")
[ -n "$tmproot" -a -d "$tmproot" ] || \
    error "Unable to create the temporary directory."
trap "exit 1" INT
trap "info Deleting the temporary directory. ; rm -rf '$tmproot'" EXIT
set -e

#
# Create temporary directory
#
info "Creating the temporary directory."
tmproot=$(mktemp -d "${TMPDIR:-/tmp}/$package-$version.XXXXXX")
[ -n "$tmproot" -a -d "$tmproot" ] || \
    error "Unable to create the temporary directory."
trap "exit 1" INT
trap "info Deleting the temporary directory. ; rm -rf '$tmproot'" EXIT
set -e

#
# Generate stub manifest
#
info "Generating the stub manifest."
manifest="$tmproot/+MANIFEST"
cat >"$manifest" <<EOF
name: $package
version: $version
origin: local/$package
comment: BSD-licensed Lua extension
arch: $pkgabi
www: http://$package.agileanteater.com
maintainer: stefan@agileanteater.com
prefix: /usr/local
licenses: [MIT, BSD]
catagories: [local]
EOF
cp "README" "$tmproot/+DESC"

#
# Generate file list
#
info "Generating the file list."
(
	echo "files: {"
	find -s "$tmproot@prefix@" -type f -or -type l | while read file ; do
		case $file in
		*.la)
			continue
			;;
		esac
		mode=$(stat -f%p "$file" | cut -c 3-)
		file="${file#$tmproot}"
		echo "  $file: { uname: root, gname: wheel, perm: $mode }"
	done
	echo "}"
)>>"$manifest"

#
# Create the package
#
info "Creating the package."
pkg create -r "$tmproot" -m "$tmproot" -o "$builddir"

#
# Done
#
info "Package created for $package-$version."