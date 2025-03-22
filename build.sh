#!/bin/bash

BUILDDIR="$PWD/build/"
OUTDIR="$PWD/out/"

mkdir -p "$BUILDDIR"
mkdir -p "$OUTDIR"

CMAKE_FLAGS=(
	"-GNinja"
	"-DCMAKE_BUILD_TYPE=Release"
	"-DCMAKE_INSTALL_PREFIX=/"
)

get_tar_archive() {
	# $1: folder to extract to, $2: URL
	local filename="${2##*/}"

	wget -nc -c "$2" -O "$filename"
	mkdir -p "$1"
	tar -xaf "$filename" -C "$1" --strip-components=1
	cd "$1"
}

build() {
	echo "Building $1 ver. $2..."

	pushd "$BUILDDIR" || exit

	"dep_$1" "$2"

	popd || exit
}

dep_SDL2() {
	get_tar_archive SDL2 "https://github.com/libsdl-org/SDL/releases/download/release-$1/SDL2-$1.tar.gz"

	mkdir -p build; cd build
	cmake .. "${CMAKE_FLAGS[@]}" \
		-DSDL_INSTALL_CMAKEDIR=usr/lib/cmake/SDL2 \
		-DSDL_RENDER=OFF \
		-DSDL_VULKAN=OFF \
		-DSDL_TEST=OFF \
		-DSDL_STATIC=OFF
	ninja

	strip -s *.so

	DESTDIR="$OUTDIR" ninja install
}

build SDL2 "2.32.2"
