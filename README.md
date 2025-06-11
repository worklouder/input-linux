# Input - Linux

##  Disclaimer

This project is an **unofficial community-developed** port of the Input application, intended for use on Linux systems.

While this project has been acknowledged and welcomed by Work Louder Inc., it is **not officially supported** or maintained by them. As such, functionality and stability are not guaranteed.

### Important Notes

- This software is provided **"as is"**, without any warranties, express or implied.
- Use at your own risk.
- **Work Louder does not guarantee the safety, integrity, or reliability of any files downloaded from this repository or related sources.** Users are responsible for reviewing and validating the software before installation.
- Work Louder cannot be held liable for any damages or legal claims resulting from the use or distribution of this software.

By using, copying, modifying, or distributing this software, **you agree to these terms**.

---

## Usage

You have two options for using Input on Linux:

### Option 1: Prebuilt AppImage

The easiest way to get started is by visiting the [Releases Page](https://github.com/worklouder/input-linux/releases) and downloading the latest `.AppImage`.

Make the AppImage executable and run it:

We recommend using a tool like [Gear Lever](https://flathub.org/apps/it.mijorus.gearlever)

You may need FUSE in order for the AppImage to run.

```bash
sudo apt install libfuse2
chmod +x Input-*.AppImage
./Input-*.AppImage
```

---

### Option 2: Build from Source

This option is for users who want to rebuild the application from the official Windows installer.


### Dependencies

Install all required tools in one go:

```bash
sudo apt update
sudo apt install curl p7zip-full nodejs npm build-essential python3.11 python3.11-venv git
sudo npm install -g asar
```

These packages are needed to unpack, patch, and run the Input application. You can also install them manually if you prefer.
------------------|--------------------------------------------------|--------------------------------------------------------|
| `curl`           | Download files over HTTP(S)                      | `sudo apt install curl`                               |
| `7z`             | Extract `.exe` and `.7z` archives (`p7zip-full`) | `sudo apt install p7zip-full`                         |
| `node`           | JavaScript runtime                               | `sudo apt install nodejs`                             |
| `npm`            | Node.js package manager                          | `sudo apt install npm`                                |
| `asar`           | Extract and repack `.asar` Electron archives     | `sudo npm install -g asar`                            |
| `build-essential`| Required for compiling native modules            | `sudo apt install build-essential`                    |
| `python3.11`     | Compatible Python version with venv support      | `sudo apt install python3.11 python3.11-venv`         |
| `git`            | Used to clone the repository (optional)          | `sudo apt install git`                                |

Install them all in one step:

```bash
sudo apt update
sudo apt install curl p7zip-full nodejs npm build-essential python3.11 python3.11-venv git
sudo npm install -g asar
```

---

###  Build Process

The setup script now:

- Creates a virtualenv with Python 3.11+ to ensure a compatible `distutils` environment
- Installs `setuptools` and a shim for `distutils` to work with modern Python
- Rebuilds native modules like `node-hid` using the patched environment
- Applies community patches into `./input-app/`
- Launches the app with Electron

Run it:

```bash
git clone https://github.com/worklouder/input-linux.git
cd input-linux
bash input4linux-0.8.1.sh
```

Launch the app:

```bash
./input-app/start.sh
```

---

## Optional: Udev Rule Setup

Install the necessary udev rules to allow access to your Work Louder device:

Input *should* automatically create these for you.

```bash
curl -sSL https://raw.githubusercontent.com/worklouder/input-linux/main/patch/dist-electron/scripts/install-udev-worklouder.sh | sudo bash
```

Afterward, **unplug and replug your keyboard** before launching the app.

---

## Troubleshooting

- If `node-hid` fails to build and youre using Python 3.12 or newer, ensure the build script properly activates its virtualenv.
- Use Python 3.11+ for best compatibility with `node-gyp`.
- If the app launches but doesnt detect your device, ensure udev rules are installed (see above).
- The build script defaults to `TEST_MODE=true`, which skips over non-critical errors. You can run it in strict mode like this:

```bash
TEST_MODE=false ./input4linux-0.8.1.sh
```

- If you were previously using `npm config set python`, thats no longer needed. The build script uses `export PYTHON=...` automatically now.

---

## Contributions

Pull requests are welcome. This project is maintained on a best-effort basis by the community.

---

## License

This project does not claim ownership of Input. Input is a product of Work Louder Inc. This port is provided under an unofficial and permissive approach intended to help Linux users make use of their devices. Refer to the individual license files, if applicable.
