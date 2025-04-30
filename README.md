# Input - Linux Version

## Disclaimer ⚠️

This project is an **unofficial community-developed** port of Input, intended for use on Linux systems.

Although this project has been approved and welcomed by Work Louder Inc., it is not officially supported or maintained by our team, and we cannot guarantee its functionality or reliability.

### Important

- This software is provided “as is”, without warranty of any kind, express or implied.
- Use at your own risk.
- **Work Louder does not guarantee the integrity, security, or safety of any files downloaded from this repository or any related sources. Users are responsible for verifying the software they download and install.**
- In no event shall Work Louder be held liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.

**By using, copying, modifying, or distributing this software, you agree to these terms.**

---

## Requirements

Before running the setup script, you need to install the following dependencies:

### System Dependencies

Make sure the following tools are installed and available in your `$PATH`:

| Tool         | Purpose                                         | Install Command (Ubuntu/Debian)              |
|--------------|--------------------------------------------------|----------------------------------------------|
| `curl`       | Download files over HTTP(S)                      | `sudo apt install curl`                      |
| `7z`         | Extract `.exe` and `.7z` archives (`p7zip-full`) | `sudo apt install p7zip-full`                |
| `node`       | JavaScript runtime                               | `sudo apt install nodejs`                    |
| `npm`        | Node.js package manager                          | `sudo apt install npm`                       |
| `asar`       | Extract and repack `.asar` Electron archives     | `npm install -g asar`                        |
| `build-essential` | Tools for compiling native modules         | `sudo apt install build-essential`           |
| `python3`    | Required for compiling some native modules       | `sudo apt install python3`                   |
| `git`        | For cloning repositories (optional)              | `sudo apt install git`                       |

You can install most of them with:

```bash
sudo apt update
sudo apt install curl p7zip-full nodejs npm build-essential python3 git
sudo npm install -g asar
```

---

## Usage

### Use the one line rebuild script

```bash
git clone https://github.com/BeekrBonkr/input-linux.git && cd input-linux && chmod +x input4linux-0.8.0-rc2.sh && ./input4linux-0.8.0-rc2.sh```

### Step 1: Run the Setup Script

Make the script executable and run it:

```bash
chmod +x setup.sh
./setup.sh
```

By default, the script runs in **TEST_MODE**, which allows it to skip over non-critical errors. You can disable this mode by running:

```bash
TEST_MODE=false ./setup.sh
```

### Step 2: Run the App

After the setup completes successfully, you can run the app with:

```bash
npx electron ./input-app
```

---

## Notes

- If you run into permission issues with npm, consider using a Node version manager like `nvm` to install and manage Node.js in your user environment.
- If `node-hid` fails to build, double-check that all build dependencies are installed and compatible with your Electron version.
