# Native Linux builds

This is a native C++/SDL2 port. Wine and the original Windows executable are not required.

## Download from GitHub Actions

Open [Linux binaries](https://github.com/vertigo-red/SpaceCadetPinball/actions/workflows/LinuxBuild.yml),
select a successful run, and download the **SpaceCadetPinball-linux-x86_64** artifact.
GitHub requires signing in to download workflow artifacts. Artifacts are retained for 30 days.
Builds run on pushes to `master`, tags beginning with `v`, pull requests targeting `master`,
and manually through **Run workflow**.

The artifact contains:

- `SpaceCadetPinball-linux-x86_64-<commit>.tar.gz`: a native ELF executable, instructions and MIT license.
- `SpaceCadetPinball-linux-x86_64-<commit>.AppImage`: the same executable with SDL2, SDL2_mixer,
  their non-system dependencies and a MIDI SoundFont bundled.
- `SHA256SUMS`: checksums for both files; verify with `sha256sum --check SHA256SUMS`.

The builds target **x86_64** and use Ubuntu 22.04 as the **glibc 2.35** baseline.
They require a desktop session and are intended for glibc-based distributions at or above that baseline.
The AppImage still uses the host's graphics/audio drivers and core system libraries.

## Game data and launch

Copy the data files from your own Windows Space Cadet or Full Tilt installation.
The data is not included in the source repository or build artifacts.
For Windows Space Cadet, keep `PINBALL.DAT`, the `.WAV` sounds and the music files together;
copying the entire original game directory is the easiest way to preserve the layout.
File names and subdirectory case matter on Linux; preserve the original names.

The engine searches the current working directory, the executable directory,
`${XDG_DATA_HOME:-~/.local/share}/SpaceCadetPinball/`,
`/usr/local/share/SpaceCadetPinball/` and `/usr/share/SpaceCadetPinball/`.
Uppercase and lowercase `.DAT` names are accepted. In the AppImage build, game data
can also be placed beside the `.AppImage` file.

### AppImage

Extract the downloaded artifact, put the AppImage in the game data directory, and run:

```sh
chmod +x SpaceCadetPinball-linux-x86_64-*.AppImage
./SpaceCadetPinball-linux-x86_64-*.AppImage
```

If FUSE is unavailable, run it with extraction instead:

```sh
./SpaceCadetPinball-linux-x86_64-*.AppImage --appimage-extract-and-run
```

On **NixOS**, use the `appimage-run` wrapper:

```sh
nix shell nixpkgs#appimage-run --command appimage-run ./SpaceCadetPinball-linux-x86_64-<commit>.AppImage
```

The AppImage includes TimGM6mb for MIDI playback. To select a different SoundFont,
set `SDL_SOUNDFONTS=/absolute/path/to/your.sf2` before launching.

### ELF archive

Install the SDL runtime libraries. On Debian/Ubuntu:

```sh
sudo apt-get install libsdl2-2.0-0 libsdl2-mixer-2.0-0 timgm6mb-soundfont
tar -xzf SpaceCadetPinball-linux-x86_64-<commit>.tar.gz
```

Place the extracted `SpaceCadetPinball` executable beside the game data, or run
its absolute path while the current directory contains the game data.
The archive preserves its executable permission. On NixOS, use the AppImage via
`appimage-run` or build from source in a Nix development shell.

## Build locally

On Debian/Ubuntu:

```sh
sudo apt-get install build-essential cmake ninja-build libsdl2-dev libsdl2-mixer-dev
bash build-linux.sh
```

The executable is `build-linux/bin/SpaceCadetPinball`, and the archive is in `build-linux/dist/`.
An optional first argument chooses another build directory. `BUILD_JOBS=2` limits parallel compilation.
To install the executable, desktop entry and icons system-wide:

```sh
sudo cmake --install build-linux --prefix /usr/local
```

On NixOS:

```sh
nix-shell -p cmake ninja pkg-config SDL2 SDL2_mixer --run 'bash build-linux.sh'
```

AppImage packaging is an additional step. Install `desktop-file-utils`, `patchelf`
and `timgm6mb-soundfont`, download and verify the linuxdeploy version pinned in
`.github/workflows/LinuxBuild.yml`, then run:

```sh
LINUXDEPLOY=/absolute/path/to/linuxdeploy-x86_64.AppImage bash Platform/Linux/package-appimage.sh
```

## Validation limits

CI builds in Release mode, tests the executable extracted from the archive and
tests the extracted AppImage without FUSE. Both tests use SDL's dummy display/audio
drivers and require a working software renderer followed by the expected missing-data
error. They check startup and packaging, but cannot verify gameplay, graphics
drivers, sound or music without the original game resources.
