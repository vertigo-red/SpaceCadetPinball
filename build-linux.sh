#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
build_dir=$(realpath -m -- "${1:-$repo_dir/build-linux}")
architecture=$(uname -m)
build_id=$(git -C "$repo_dir" rev-parse --short=12 HEAD)
package_name="SpaceCadetPinball-linux-$architecture-$build_id"

cmake -S "$repo_dir" -B "$build_dir" -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_RUNTIME_OUTPUT_DIRECTORY="$build_dir/bin"
cmake --build "$build_dir" --parallel "${BUILD_JOBS:-$(nproc)}"

# Stage the normal Linux install for subsequent AppImage packaging.
rm -rf -- "$build_dir/AppDir"
DESTDIR="$build_dir/AppDir" cmake --install "$build_dir" --prefix /usr --strip

# The native archive contains an ordinary ELF executable and no bundled libraries.
package_dir="$build_dir/packages/$package_name"
rm -rf -- "$package_dir"
mkdir -p "$package_dir" "$build_dir/dist"
install -m 755 "$build_dir/AppDir/usr/bin/SpaceCadetPinball" "$package_dir/SpaceCadetPinball"
install -m 644 "$repo_dir/LICENSE" "$package_dir/LICENSE"
install -m 644 "$repo_dir/Platform/Linux/README.md" "$package_dir/README.md"
tar -czf "$build_dir/dist/$package_name.tar.gz" -C "$build_dir/packages" "$package_name"
printf 'Native archive: %s\n' "$build_dir/dist/$package_name.tar.gz"
