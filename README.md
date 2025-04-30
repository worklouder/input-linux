# Input - Linux Version

## ⚠️ Disclaimer

This project is an **unofficial community-developed** port of the Input application, intended for use on Linux systems.

While this project has been acknowledged and welcomed by Work Louder Inc., it is **not officially supported** or maintained by them. As such, functionality and stability are not guaranteed.

### Important Notes

- This software is provided **"as is"**, without any warranties, express or implied.
- Use at your own risk.
- **Work Louder does not guarantee the safety, integrity, or reliability of any files downloaded from this repository or related sources.** Users are responsible for reviewing and validating the software before installation.
- Work Louder cannot be held liable for any damages or legal claims resulting from the use or distribution of this software.

By using, copying, modifying, or distributing this software, **you agree to these terms**.

---

## Requirements

Before running the setup script, ensure the following tools are installed and accessible in your `$PATH`:

| Tool             | Purpose                                         | Ubuntu/Debian Install Command               |
|------------------|--------------------------------------------------|---------------------------------------------|
| `curl`           | Download files over HTTP(S)                      | `sudo apt install curl`                     |
| `7z`             | Extract `.exe` and `.7z` archives (`p7zip-full`) | `sudo apt install p7zip-full`               |
| `node`           | JavaScript runtime                               | `sudo apt install nodejs`                   |
| `npm`            | Node.js package manager                          | `sudo apt install npm`                      |
| `asar`           | Extract and repack `.asar` Electron archives     | `sudo npm install -g asar`                  |
| `build-essential`| Required for compiling native modules            | `sudo apt install build-essential`          |
| `python3`        | Required by some Node.js modules during build    | `sudo apt install python3`                  |
| `git`            | Used to clone the repository (optional)          | `sudo apt install git`                      |

You can install most of them in one step:

```bash
sudo apt update
sudo apt install curl p7zip-full nodejs npm build-essential python3 git
sudo npm install -g asar
```

---

## Usage

### Quick Install (One Command)

```bash
git clone https://github.com/BeekrBonkr/input-linux.git && cd input-linux && chmod +x input4linux-0.8.0-rc2.sh && ./input4linux-0.8.0-rc2.sh
```

### Manual Install

#### Step 1: Run the Setup Script

Make the script executable and run it:

```bash
chmod +x setup.sh
./setup.sh
```

The script defaults to **TEST_MODE**, allowing it to continue past non-critical errors. To run in strict mode:

```bash
TEST_MODE=false ./setup.sh
```

#### Step 2: Run the App

Once setup is complete, launch the application with:

```bash
./input-app/start.sh
```

---

## Troubleshooting

- If you encounter permission issues with `npm`, consider using [`nvm`](https://github.com/nvm-sh/nvm) to manage Node.js in your user space.
- If `node-hid` fails to build, confirm that `build-essential` and `python3` are installed and that the Electron version matches compatibility requirements.

---

## Contributions

Pull requests are welcome. This project is maintained on a best-effort basis by the community.

---

## License

This project does not claim ownership of Input. Input is a product of Work Louder Inc. This port is provided under an unofficial and permissive approach intended to help Linux users make use of their devices. Refer to the individual license files, if applicable.
