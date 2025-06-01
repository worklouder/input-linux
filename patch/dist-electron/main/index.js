// From Input-Linux Patch
import { app, BrowserWindow, ipcMain } from 'electron';
import path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';
import sudoPrompt from 'sudo-prompt';
import fs from 'fs';
import os from 'os';

if (process.env.APPIMAGE) {
  app.commandLine.appendSwitch('no-sandbox');
}

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Handle udev setup request
ipcMain.on('run-udev-setup', () => {
  const isAppImage = !!process.env.APPIMAGE;

  const sourceScript = isAppImage
    ? path.join(process.resourcesPath, 'app.asar.unpacked', 'dist-electron/scripts/install-udev-worklouder.sh')
    : path.join(__dirname, '../scripts/install-udev-worklouder.sh');
  const tempScript = path.join(os.tmpdir(), 'install-udev-worklouder.sh');

  try {
    // Only copy if source and temp are different
    if (sourceScript !== tempScript) {
      fs.copyFileSync(sourceScript, tempScript);
      fs.chmodSync(tempScript, 0o755);
    }
  } catch (err) {
    console.error('[udev setup] Failed to prepare script:', err);
    return;
  }

  const options = {
    name: 'Work Louder Configurator',
    prompt: 'The app needs to install udev rules so it can access your Work Louder device. Please enter your password to continue.'
  };

  console.log('Attempting to run sudoPrompt.');
  sudoPrompt.exec(`bash "${tempScript}"`, options, (error, stdout, stderr) => {
    if (error) {
      console.error('[udev setup] Failed with sudo:', error);
    } else {
      console.log('[udev setup] Completed with sudo:', stdout.trim());
    }
  });
});

// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^

var J = Object.defineProperty;
var Z = (s, e, t) => e in s ? J(s, e, { enumerable: !0, configurable: !0, writable: !0, value: t }) : s[e] = t;
var d = (s, e, t) => Z(s, typeof e != "symbol" ? e + "" : e, t);
import { ipcMain as p, BrowserWindow as T, app as v, Menu as E, shell as $ } from "electron";
import { release as K } from "node:os";
import { dirname as Q, join as P } from "node:path";
import { fileURLToPath as X } from "node:url";
import i from "electron-log";
import Y from "electron-updater";
import { devices as _, HIDAsync as H } from "node-hid";
import { SerialPort as B, DelimiterParser as ee } from "serialport";
import { download as ne, CancelError as te } from "electron-dl";
import * as g from "fs";
import { join as y } from "path";
import { exec as re } from "child_process";
var L = /* @__PURE__ */ ((s) => (s.checkUpdates = "check-updates", s.installUpdate = "install-update", s.onUpdateDonwloaded = "on-update-downloaded", s))(L || {});
function se() {
  const { autoUpdater: s } = Y;
  return s;
}
class ie {
  constructor() {
    d(this, "updater");
    i.transports.file.level = "info";
    const e = se();
    e.logger = i, this.updater = e;
  }
  setUpListeners(e) {
    this.updater.on("checking-for-update", () => {
      i.info("Checking for updates event received");
    }), this.updater.on("update-available", () => {
      i.info("Update available event received");
    }), this.updater.on("update-not-available", () => {
      i.info("Update not available event received");
    }), this.updater.on("update-downloaded", (t) => {
      i.info("Update downloaded"), e.webContents.send(L.onUpdateDonwloaded, "true");
    }), this.updater.on("error", () => {
      i.info("Error event received");
    }), this.updater.on("download-progress", () => {
      i.info("Download progress event received");
    }), i.info("Checking for updates"), this.registedManualListeners();
  }
  registedManualListeners() {
    p.handle(L.checkUpdates, async (e) => {
      i.info("Calling updater"), T.getAllWindows().length > 0 && this.checkForUpdates();
    }), p.handle(L.installUpdate, async (e) => {
      this.installUpdate();
    });
  }
  checkForUpdates() {
    this.updater.checkForUpdatesAndNotify();
  }
  installUpdate() {
    this.updater.quitAndInstall();
  }
}
const q = [
  {
    label: "input",
    submenu: [
      { role: "about" },
      { type: "separator" },
      { role: "quit", registerAccelerator: !1, accelerator: "" }
    ]
  },
  // {
  //     label: 'File',
  //     submenu: [process.platform === 'darwin' ? { role: 'close' } : { role: 'quit' }],
  // },
  // {
  //     label: 'Edit',
  //     submenu: [
  //         { role: 'undo' },
  //         { role: 'redo' },
  //         { type: 'separator' },
  //         { role: 'cut' },
  //         { role: 'copy' },
  //         { role: 'paste' },
  //         ...(process.platform === 'darwin'
  //             ? [
  //                 { role: 'pasteAndMatchStyle' },
  //                 { role: 'delete' },
  //                 { role: 'selectAll' },
  //                 { type: 'separator' },
  //                 {
  //                     label: 'Speech',
  //                     submenu: [{ role: 'startSpeaking' }, { role: 'stopSpeaking' }],
  //                 },
  //             ]
  //             : [{ role: 'delete' }, { type: 'separator' }, { role: 'selectAll' }]),
  //     ],
  // },
  {
    label: "View",
    submenu: [
      { role: "resetZoom", enabled: !0, accelerator: "", registerAccelerator: !1 },
      { role: "zoomIn", enabled: !0, accelerator: "", registerAccelerator: !1 },
      { role: "zoomOut", enabled: !0, accelerator: "", registerAccelerator: !1 },
      { type: "separator", accelerator: "", registerAccelerator: !1 },
      { role: "togglefullscreen", accelerator: "", registerAccelerator: !1 }
    ]
  }
  // {
  //     label: 'Window',
  //     role: 'window',
  //     submenu: [
  //         { role: 'minimize' },
  //         { role: 'zoom' },
  //         ...(process.platform === 'darwin'
  //             ? [{ type: 'separator' }, { role: 'front' }, { type: 'separator' }, { role: 'window' }]
  //             : [{ role: 'close' }]),
  //     ],
  // },
  // {
  //     label: 'Help',
  //     role: 'help',
  //     submenu: [
  //         {
  //             label: 'Learn More',
  //             click: async () => {
  //                 const { shell } = require('electron');
  //                 await shell.openExternal('https://electronjs.org');
  //             },
  //         },
  //     ],
  // },
], C = [
  {
    label: "input",
    submenu: [
      { role: "about" },
      { type: "separator" },
      { role: "quit" }
    ]
  },
  // {
  //     label: 'File',
  //     submenu: [process.platform === 'darwin' ? { role: 'close' } : { role: 'quit' }],
  // },
  {
    label: "Edit",
    submenu: [
      { role: "undo" },
      { role: "redo" },
      { type: "separator" },
      { role: "cut" },
      { role: "copy" },
      { role: "paste" }
    ]
  },
  //         ...(process.platform === 'darwin'
  //             ? [
  //                 { role: 'pasteAndMatchStyle' },
  //                 { role: 'delete' },
  //                 { role: 'selectAll' },
  //                 { type: 'separator' },
  //                 {
  //                     label: 'Speech',
  //                     submenu: [{ role: 'startSpeaking' }, { role: 'stopSpeaking' }],
  //                 },
  //             ]
  //             : [{ role: 'delete' }, { type: 'separator' }, { role: 'selectAll' }]),
  //     ],
  // },
  {
    label: "View",
    submenu: [
      { role: "resetZoom" },
      { role: "zoomIn" },
      { role: "zoomOut" },
      { type: "separator" },
      { role: "togglefullscreen" }
    ]
  }
  // {
  //     label: 'Window',
  //     role: 'window',
  //     submenu: [
  //         { role: 'minimize' },
  //         { role: 'zoom' },
  //         ...(process.platform === 'darwin'
  //             ? [{ type: 'separator' }, { role: 'front' }, { type: 'separator' }, { role: 'window' }]
  //             : [{ role: 'close' }]),
  //     ],
  // },
  // {
  //     label: 'Help',
  //     role: 'help',
  //     submenu: [
  //         {
  //             label: 'Learn More',
  //             click: async () => {
  //                 const { shell } = require('electron');
  //                 await shell.openExternal('https://electronjs.org');
  //             },
  //         },
  //     ],
  // },
];
var m = /* @__PURE__ */ ((s) => (s[s.serial = 0] = "serial", s[s.hid = 1] = "hid", s))(m || {});
class W {
  constructor(e, t, r, a, o, l) {
    d(this, "portPath");
    d(this, "devicePid");
    d(this, "connectionType");
    d(this, "deviceType");
    d(this, "layoutType");
    d(this, "isUsbConnection");
    this.portPath = e, this.devicePid = t, this.connectionType = r, this.deviceType = a, this.layoutType = o, this.isUsbConnection = l;
  }
}
var I = /* @__PURE__ */ ((s) => (s.NomadE = "nomad_e", s.Knob = "knob", s))(I || {}), D = /* @__PURE__ */ ((s) => (s.unknown = "unknown", s.ansi = "ansi", s.iso = "iso", s))(D || {}), A = /* @__PURE__ */ ((s) => (s.searchDevices = "searchDevices", s.searchForDeviceInBootloader = "searchForDeviceInBootloader", s))(A || {});
const f = class f {
  constructor() {
    d(this, "win", null);
    this.createHandlers();
  }
  createHandlers() {
    i.info("Adding listeners for devices manager channel"), p.handle(A.searchDevices, this.searchDevices), p.handle(A.searchForDeviceInBootloader, this.searchForDeviceInBootloader);
  }
  async searchForDeviceInBootloader() {
    const e = process.platform === "win32";
    try {
      const t = await B.list();
      let r = [];
      return t.forEach((a) => {
        var c;
        if (parseInt(a.vendorId ?? "", 16) !== f.vid)
          return;
        const l = f.getDeviceFromSerialPort(a);
        l !== void 0 && (e && ((c = a.serialNumber) != null && c.endsWith("0000")) || a.manufacturer === "Espressif") && r.push(l);
      }), r;
    } catch (t) {
      return i.error(t), [];
    }
  }
  async searchDevices() {
    let e = await _(), t = e.filter(
      (o) => o.manufacturer !== void 0 && f.manufacturers.some(
        (l) => o.manufacturer.includes(l)
      ) && o.vendorId === f.vid
    );
    if (t.length === 0 && (t = e.filter(
      (o) => o.vendorId === f.vid
    )), t.length === 0)
      return [];
    let r = [];
    return t.find((o) => o.productId === f.legacyNomadPid) !== void 0 && (t = t.filter((c) => c.productId !== f.legacyNomadPid), (await B.list()).filter((c) => parseInt(c.productId ?? "", 16) === f.legacyNomadPid).forEach((c) => {
      const u = f.getDeviceFromSerialPort(c);
      u !== void 0 && r.find((N) => u.portPath === N.portPath) === void 0 && r.push(u);
    })), t.forEach((o) => {
      const l = f.getDeviceFromHIDDevice(o);
      if (t === void 0 || o.usagePage !== 65280)
        return;
      const c = r.find((u) => l.devicePid === u.devicePid);
      if (c !== void 0 && !(l != null && l.isUsbConnection) && (c != null && c.isUsbConnection)) {
        const u = r.indexOf(c);
        if (u === -1)
          return;
        r[u] = l;
        return;
      }
      c === void 0 && r.push(l);
    }), r;
  }
  static getDeviceFromHIDDevice(e) {
    if (e.productId === void 0)
      return;
    const t = (e.release & 3) === 0, r = f.nomadPids.get(e.productId);
    if (r !== void 0 && e.path !== void 0)
      return new W(e.path, e.productId.toString(), m.hid, I.NomadE, r, t);
    const a = f.knobPids.get(e.productId);
    if (a !== void 0 && e.path !== void 0)
      return new W(e.path, e.productId.toString(), m.hid, I.Knob, a, t);
  }
  static getDeviceFromSerialPort(e) {
    if (e.productId === void 0)
      return;
    const t = parseInt(e.productId, 16), r = f.nomadPids.get(t);
    if (r !== void 0 && e.path !== void 0)
      return new W(e.path, t.toString(), m.serial, I.NomadE, r, !0);
    const a = f.knobPids.get(t);
    if (a !== void 0 && e.path !== void 0)
      return new W(e.path, t.toString(), m.serial, I.Knob, a, !0);
  }
  setWindow(e) {
    this.win = e;
  }
};
d(f, "legacyNomadPid", 4097), d(f, "nomadPids", /* @__PURE__ */ new Map([[4097, D.unknown], [33428, D.ansi], [33429, D.iso]])), d(f, "knobPids", /* @__PURE__ */ new Map([[21845, D.unknown]])), d(f, "vid", 12346), d(f, "manufacturers", ["Work Louder", "Work_Louder"]);
let x = f;
var w = /* @__PURE__ */ ((s) => (s.isConnected = "isConnected", s.connect = "connect", s.disconnect = "disconnect", s.getConnectedDevice = "getConnectedDevice", s.sendLegacyRpcCall = "sendLegacyRpcCall", s.sendJsonRpcCall = "sendJsonRpcCall", s.onCloseEvent = "onCloseEvent", s.onErrorEvent = "onErrorEvent", s))(w || {});
const n = class n {
  // Private constructor prevents direct instantiation
  constructor() {
    d(this, "connectedDevice", null);
    d(this, "port", null);
    d(this, "_responseResolvers", {});
    d(this, "_rpcResolver", {});
    d(this, "rpcResponse", "");
    d(this, "win", null);
    d(this, "connectionType");
    d(this, "serialDevice", null);
    d(this, "queue", []);
    d(this, "pending", !1);
    d(this, "buffers", {
      [n.CHANNEL_DEBUG]: "",
      [n.CHANNEL_RPC]: ""
    });
    this.createHandlers();
  }
  enqueue(e) {
    return new Promise((t, r) => {
      n.instance.queue.push({ fn: e, resolve: t, reject: r }), i.info("Added call to queue, new queue lenght: " + n.instance.queue.length), n.instance.process();
    });
  }
  async process() {
    if (n.instance.pending) return;
    const e = n.instance.queue.shift();
    if (e) {
      n.instance.pending = !0;
      try {
        const t = await e.fn();
        e.resolve(t);
      } catch (t) {
        e.reject(t);
      } finally {
        n.instance.pending = !1, n.instance.process();
      }
    }
  }
  setWindow(e) {
    n.instance.win = e;
  }
  // Public method to get the single instance
  static getInstance() {
    return n.instance || (n.instance = new n()), n.instance;
  }
  createHandlers() {
    i.info("Adding listeners for devices manager channel"), p.handle(w.connect, (e, t) => n.instance.connect(t)), p.handle(w.disconnect, (e) => n.instance.disconnect()), p.handle(w.isConnected, (e) => n.instance.isConnected()), p.handle(w.sendLegacyRpcCall, (e, t, r) => n.instance.enqueue(() => n.instance.sendLegacyRpcRequest(t, r))), p.handle(w.sendJsonRpcCall, (e, t, r) => n.instance.enqueue(() => n.instance.sendJsonRpcRequest(t, r))), p.handle(w.getConnectedDevice, (e) => n.instance.getConnectedDevice());
  }
  async getConnectedDevice() {
    var t;
    if (n.instance.connectionType === m.serial)
      return Promise.resolve(n.instance.serialDevice ?? void 0);
    const e = await ((t = n.instance.connectedDevice) == null ? void 0 : t.getDeviceInfo());
    return Promise.resolve(e !== void 0 ? x.getDeviceFromHIDDevice(e) : void 0);
  }
  isConnected() {
    if (n.instance.connectionType == m.hid) {
      if (n.instance.connectedDevice !== void 0 && n.instance.connectedDevice != null && n.instance.connectedDevice !== null)
        return Promise.resolve(!0);
    } else if (n.instance.connectionType == m.serial && n.instance.port !== void 0 && n.instance.port !== null)
      return Promise.resolve(!0);
    return Promise.resolve(!1);
  }
  async connect(e) {
    return e.connectionType === m.serial ? (i.info("Connecting with serial"), n.instance.connectWithSerial(e)) : (i.info("Connecting with hid"), i.info("Connected with usb: " + e.isUsbConnection), n.instance.connectWithHID(e));
  }
  async disconnect() {
    var e, t;
    if (n.instance.connectionType === m.hid) {
      i.info("Disconnecting hid device"), await ((e = n.instance.connectedDevice) == null ? void 0 : e.close()), n.instance.queue = [], n.instance.connectionType = void 0, n.instance.connectedDevice = null;
      return;
    }
    i.info("Disconnecting serial device"), (t = n.instance.port) == null || t.close(), n.instance.queue = [], n.instance.connectionType = void 0, n.instance.port = null, n.instance.serialDevice = null;
  }
  async connectWithSerial(e) {
    if (n.instance.port !== null)
      return i.info("A device is already connected "), Promise.reject("A device is already connected");
    let t = null, r = new Promise((c, u) => {
      t = c;
    }), a = 115200;
    i.info(e.portPath);
    const o = new B({ path: e.portPath, baudRate: a, autoOpen: !1 });
    return o.on("open", () => {
      i.info("Connection opened");
    }), o.on("close", () => {
      var c;
      n.instance.queue = [], n.instance.connectionType = void 0, n.instance.port = null, n.instance.serialDevice = null, i.info("Connection closed"), (c = n.instance.win) == null || c.webContents.send(w.onCloseEvent, "CLOSED");
    }), o.on("error", (c) => {
      var u;
      i.error(c), n.instance.queue = [], n.instance.connectionType = void 0, n.instance.serialDevice = null, (u = n.instance.win) == null || u.webContents.send(w.onErrorEvent, c.message);
    }), o.open((c) => {
      c ? (i.error("errore here"), n.instance.queue = [], n.instance.connectionType = void 0, n.instance.port = null, n.instance.serialDevice = null, i.error(c), t(!1)) : (n.instance.serialDevice = e, t(!0));
    }), o.on("data", n.instance.parseSerialRpcData.bind(n.instance)), o.pipe(new ee({ delimiter: `
` })).on("data", n.instance.parseSerialData.bind(n.instance)), n.instance.connectionType = m.serial, n.instance.port = o, r;
  }
  async connectWithHID(e) {
    if (n.instance.connectedDevice !== null)
      return i.info("A device is already connected "), Promise.reject("A device is already connected");
    try {
      let t = process.platform === "darwin" ? await H.open(e.portPath, { nonExclusive: !0 }) : await H.open(e.portPath);
      return t.on("close", () => {
        var r;
        n.instance.queue = [], n.instance.connectionType = void 0, n.instance.connectedDevice = null, i.info("Connection closed"), (r = n.instance.win) == null || r.webContents.send(w.onCloseEvent, "CLOSED");
      }), t.on("error", (r) => {
        var a;
        i.error(r), n.instance.queue = [], n.instance.connectionType = void 0, n.instance.connectedDevice = null, (a = n.instance.win) == null || a.webContents.send(w.onErrorEvent, r.message);
      }), t.on("data", n.instance.parseHIDdata.bind(n.instance)), n.instance.connectionType = m.hid, n.instance.connectedDevice = t, !0;
    } catch (t) {
      throw n.instance.queue = [], i.error(t), t;
    }
  }
  async sendLegacyRpcRequest(e, t = null) {
    return t == null || t === "" ? n.instance.sendData(`#${e}#\r
`) : n.instance.sendData(`#${e}#${t}#\r
`), new Promise((r, a) => {
      let o = setTimeout(() => {
        n.instance._responseResolvers[e] && (a("Timeout"), n.instance._responseResolvers[e] = null);
      }, 2e3);
      n.instance._responseResolvers[e] = (l) => {
        clearTimeout(o), r(l);
      };
    });
  }
  sendJsonRpcRequest(e, t) {
    return n.instance.sendData(e), n.instance.rpcResponse = "", new Promise((r, a) => {
      let o = setTimeout(() => {
        n.instance._rpcResolver[t] && (a("Timeout"), n.instance._rpcResolver[t] = null);
      }, 5e3);
      n.instance._rpcResolver[t] = (l) => {
        clearTimeout(o), r(l);
      };
    });
  }
  async sendData(e) {
    return n.instance.connectionType === m.serial ? n.instance.sendDataSerial(e) : n.instance.sendDataHID(e);
  }
  sendDataSerial(e) {
    var t, r;
    (t = n.instance.port) == null || t.write(e), (r = n.instance.port) == null || r.drain();
  }
  async sendDataHID(e) {
    var a, o;
    const r = Date.now();
    try {
      if (e.length > 61) {
        const l = Buffer.from(e);
        let c = 0, u = 1;
        for (; c < e.length; ) {
          const F = Math.min(61, e.length - c);
          console.log(`Sending packet ${u} with ${F} bytes, offset: ${c}`);
          const k = Buffer.alloc(64);
          k[0] = 6, k[1] = n.CHANNEL_RPC, k[2] = F, l.copy(k, 3, c, c + F);
          const ue = await ((a = n.instance.connectedDevice) == null ? void 0 : a.write(k));
          c += F, u++, c < e.length;
        }
        const N = (Date.now() - r) / 1e3;
        return i.info(`Send complete: ${u - 1} packets, ${e.length} bytes in ${N.toFixed(3)} seconds`), !0;
      } else {
        const l = Buffer.alloc(64);
        l[0] = 6, l[1] = n.CHANNEL_RPC, l[2] = e.length, Buffer.from(e).copy(l, 3, 0, e.length);
        const c = await ((o = n.instance.connectedDevice) == null ? void 0 : o.write(l)), u = (Date.now() - r) / 1e3;
        return i.info(`Sent ${c} bytes in ${u.toFixed(3)} seconds`), !0;
      }
    } catch (l) {
      return i.error(`Error sending message: ${l.message}`), i.error(l.stack), !1;
    }
  }
  parseHIDReport(e) {
    const t = e[1], r = e[2], a = e.slice(3, 3 + r);
    return {
      channel: t,
      length: r,
      payload: Buffer.from(a).toString("utf8")
    };
  }
  parseHIDdata(e) {
    try {
      const t = n.instance.parseHIDReport(e), r = t.channel, a = t.payload;
      n.instance.buffers[r] === void 0 && (n.instance.buffers[r] = "");
      const o = (n.instance.buffers[r] + a).split(/\r?\n/);
      if (o.length > 1 || a.endsWith(`
`) || a.endsWith("\r")) {
        for (let l = 0; l < o.length - 1; l++) {
          const c = o[l].trim();
          if (c) {
            const u = r === n.CHANNEL_DEBUG ? "[LOG]" : "[RPC]";
            i.info(`${u} ${c}`), r === n.CHANNEL_DEBUG ? i.info(`${u} ${c}`) : r === n.CHANNEL_RPC && (n.instance.parseData(c), n.instance.parseRpcData(c));
          }
        }
        if (n.instance.buffers[r] = o[o.length - 1], a.endsWith(`
`) || a.endsWith("\r")) {
          const l = n.instance.buffers[r].trim();
          if (l) {
            const c = r === n.CHANNEL_DEBUG ? "[LOG]" : "[RPC]";
            i.info(`${c} ${l}`), r === n.CHANNEL_DEBUG ? i.info(`${c} ${l}`) : r === n.CHANNEL_RPC && (n.instance.parseData(l), n.instance.parseRpcData(l));
          }
          n.instance.buffers[r] = "";
        }
      } else
        n.instance.buffers[r] = o[0];
    } catch (t) {
      i.error(`[ERROR] Failed to parse packet: ${t.message}`);
    }
  }
  parseSerialRpcData(e) {
    const t = new TextDecoder().decode(e);
    n.instance.parseRpcData(t);
  }
  parseRpcData(e) {
    const t = e;
    if (n.instance.rpcResponse.length === 0) {
      const r = t.indexOf("{");
      if (r === -1)
        return;
      n.instance.rpcResponse = t.slice(r);
    } else
      n.instance.rpcResponse += t;
    for (; n.instance.rpcResponse.length > 0; )
      try {
        const r = JSON.parse(n.instance.rpcResponse);
        n.instance._rpcResolver[r.id](n.instance.rpcResponse), n.instance._rpcResolver[r.id] = null;
        const a = JSON.stringify(r).length;
        if (n.instance.rpcResponse = n.instance.rpcResponse.slice(a).trim(), n.instance.rpcResponse.length === 0) break;
        if (!n.instance.rpcResponse.startsWith("{")) {
          n.instance.rpcResponse = "";
          break;
        }
      } catch {
        break;
      }
  }
  parseSerialData(e) {
    const t = new TextDecoder().decode(e);
    n.instance.parseData(t);
  }
  parseData(e) {
    let t = e.replace(/[\r\n]+$/, "");
    try {
      if (n.instance.checkMessage(t, "version")) {
        let r = n.instance.extractResponse(t);
        n.instance._responseResolvers.version(r), n.instance._responseResolvers.version = null;
      } else n.instance.checkMessage(t, "dfu") ? (n.instance.extractResponse(t) === "ok" && n.instance._responseResolvers.dfu(!0), n.instance._responseResolvers.dfu = null) : n.instance.checkMessage(t, "selftest") ? (n.instance.extractResponse(t) === "ok" && n.instance._responseResolvers.selftest(!0), n.instance._responseResolvers.selftest = null) : n.instance.checkMessage(t, "bootloader") && (n.instance.extractResponse(t) === "ok" && n.instance._responseResolvers.bootloader(!0), n.instance._responseResolvers.bootloader = null);
    } catch (r) {
      i.error(r);
    }
  }
  checkMessage(e, t) {
    let r = new RegExp(String.raw`\#${t}#.*#$`, "g");
    return e.search(r) !== -1;
  }
  extractResponse(e) {
    let r = new RegExp(String.raw`\#.*?\#(.*?)\#$`, "g").exec(e);
    return r && r[1] ? r[1] : "";
  }
  // We need to escape unicodes because the keyboard cannot handle them
  escapeUnicode(e) {
    return e.replace(/[^\x00-\x7F]/gu, (t) => {
      const r = t.codePointAt(0);
      if (r !== void 0 && r > 65535) {
        const a = r - 65536 >> 10 | 55296, o = r - 65536 & 1023 | 56320;
        return `\\u${a.toString(16).padStart(4, "0")}\\u${o.toString(16).padStart(4, "0")}`;
      }
      return `\\u${r == null ? void 0 : r.toString(16).padStart(4, "0")}`;
    });
  }
  // This methods are not needed but we need to implement it to comply with the interface 
  onCloseEvent(e) {
  }
  onErrorEvent(e) {
  }
};
d(n, "nomadPids", /* @__PURE__ */ new Map([[4097, D.unknown], [33428, D.ansi], [33429, D.iso]])), d(n, "knobPids", /* @__PURE__ */ new Map([[21845, D.unknown]])), d(n, "CHANNEL_DEBUG", 1), d(n, "CHANNEL_RPC", 2), d(n, "instance");
let U = n;
var b = /* @__PURE__ */ ((s) => (s.downloadFile = "downloadFile", s.deleteFile = "deleteFile", s.saveBackupFile = "saveBackupFile", s.getBackupFiles = "getBackupFiles", s.deleteBackupFiles = "deleteBackupFiles", s.getWallpaperImage = "getWallpaperImage", s.saveWallpaperImage = "saveWallpaperImage", s.deleteWallpaperImage = "deleteWallpaperImage", s.readFile = "readFile", s))(b || {});
class ae {
  constructor(e, t) {
    d(this, "filename");
    d(this, "data");
    this.filename = e, this.data = t;
  }
}
class oe {
  constructor(e) {
    d(this, "win");
    this.win = e, this.createListeners();
  }
  createListeners() {
    p.handle(b.downloadFile, (e, t) => this.downloadFile(t)), p.handle(b.deleteFile, (e, t) => this.deleteFile(t)), p.handle(b.saveBackupFile, (e, t, r) => this.saveBackupFile(t, r)), p.handle(b.getBackupFiles, (e) => this.getBackupFiles()), p.handle(b.deleteBackupFiles, (e) => this.deleteBackupFiles()), p.handle(b.getWallpaperImage, (e) => this.getWallpaperImage()), p.handle(b.deleteWallpaperImage, (e) => this.deleteWallpaperImage()), p.handle(b.saveWallpaperImage, (e, t) => this.saveWallpaperImage(t)), p.handle(b.readFile, (e, t) => this.readBinaryFile(t));
  }
  async downloadFile(e) {
    if (this.win === null)
      return i.error("Browser window is null"), Promise.reject("Cannot find window");
    const t = v.getPath("temp");
    let r = "";
    try {
      r = (await ne(this.win, e, { directory: t })).savePath;
    } catch (a) {
      a instanceof te ? i.info("item.cancel() was called") : i.error(a);
    }
    return r;
  }
  async deleteFile(e) {
    try {
      return await g.promises.unlink(e), !0;
    } catch (t) {
      return i.error("Error while deleting file", t), !1;
    }
  }
  async saveBackupFile(e, t) {
    const r = y(v.getPath("temp"), "backup"), a = y(r, e);
    try {
      return g.existsSync(r) || g.mkdirSync(r), g.writeFileSync(a, t), !0;
    } catch (o) {
      return i.error(o), !1;
    }
  }
  async getBackupFiles() {
    const e = y(v.getPath("temp"), "backup");
    try {
      var t = [];
      if (g.existsSync(e)) {
        const r = g.readdirSync(e);
        i.info(r), t = r.map((a) => {
          const o = g.readFileSync(y(e, a));
          return new ae(a, o);
        });
      }
      return t;
    } catch (r) {
      return i.error(r), [];
    }
  }
  async deleteBackupFiles() {
    const e = y(v.getPath("temp"), "backup");
    try {
      return g.existsSync(e) && (i.info("Deleting backup files"), g.rmSync(e, { recursive: !0, force: !0 })), !0;
    } catch (t) {
      return i.error(t), !1;
    }
  }
  async getWallpaperImage() {
    const e = y(v.getPath("userData"), "wallpaper_bg.png");
    try {
      return g.existsSync(e) ? `data:image/png;base64,${g.readFileSync(e).toString("base64")}` : void 0;
    } catch (t) {
      i.error(t);
      return;
    }
  }
  async saveWallpaperImage(e) {
    const t = y(v.getPath("userData"), "wallpaper_bg.png");
    try {
      return g.writeFileSync(t, e), !0;
    } catch (r) {
      return i.error(r), !1;
    }
  }
  async deleteWallpaperImage() {
    const e = y(v.getPath("userData"), "wallpaper_bg.png");
    try {
      return g.existsSync(e) && g.unlinkSync(e), !0;
    } catch (t) {
      return i.error(t), !1;
    }
  }
  async readBinaryFile(e) {
    try {
      return (await g.promises.readFile(e)).toString("binary");
    } catch (t) {
      throw i.error(t), t;
    }
  }
}
var R = /* @__PURE__ */ ((s) => (s.appVersion = "app-version", s.mainLog = "main-log", s.openDevTools = "open-dev-tools", s.enableMenuShortcuts = "enable-menu-shortcuts", s.disableMenuShortcuts = "disable-menu-shortcuts", s.openMacSettings = "open-mac-settings", s.openExternalTab = "open-external-tab", s))(R || {});
class ce {
  constructor() {
    d(this, "platform");
    d(this, "win");
    this.platform = process.platform, this.createWindowlessHandlers();
  }
  createWindowlessHandlers() {
    i.info("Adding listeners for devices manager channel"), p.handle(R.appVersion, (e) => this.appVersion()), p.handle(R.openMacSettings, this.openMacSettings);
  }
  setWindow(e) {
    this.win = e, this.createWindowDependantHandlers();
  }
  createWindowDependantHandlers() {
    p.handle(R.openDevTools, (e) => this.openDevTools()), p.handle(R.enableMenuShortcuts, (e) => this.enableMenuShortcuts()), p.handle(R.disableMenuShortcuts, (e) => this.disableMenuShortcuts()), p.handle(R.openExternalTab, (e, t) => this.openExternalTab(t));
  }
  async appVersion() {
    try {
      return i.info("Getting app version"), v.getVersion();
    } catch (e) {
      return i.error("Error while getting app version", e), "";
    }
  }
  async openDevTools() {
    var e;
    i.info("Opening dev tools"), (e = this.win) == null || e.webContents.openDevTools();
  }
  enableMenuShortcuts() {
    var t;
    const e = E.buildFromTemplate(C);
    return E.setApplicationMenu(e), (t = this.win) == null || t.setMenu(e), Promise.resolve();
  }
  disableMenuShortcuts() {
    var t;
    i.info("Disabling menu shortcuts");
    const e = E.buildFromTemplate(q);
    return E.setApplicationMenu(e), (t = this.win) == null || t.setMenu(e), Promise.resolve();
  }
  openMacSettings() {
    return i.info("Opening mac settings"), re('open "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent"'), Promise.resolve();
  }
  openExternalTab(e) {
    return i.info("Opening external tab at url: ", e), $.openExternal(e), Promise.resolve();
  }
  onMainLog(e) {
  }
}
globalThis.__filename = X(import.meta.url);
globalThis.__dirname = Q(__filename);
process.env.DIST_ELECTRON = P(__dirname, "../");
process.env.DIST = P(process.env.DIST_ELECTRON, "../dist");
process.env.VITE_PUBLIC = process.env.VITE_DEV_SERVER_URL ? P(process.env.DIST_ELECTRON, "../public") : process.env.DIST;
process.env.VERSION = v.getVersion();
K().startsWith("6.1") && v.disableHardwareAcceleration();
process.platform === "win32" && v.setAppUserModelId(v.getName());
v.requestSingleInstanceLock() || (v.quit(), process.exit(0));
let h = null;
const O = P(__dirname, "../preload/preload.mjs"), S = process.env.VITE_DEV_SERVER_URL, V = P(process.env.DIST, "index.html"), le = new ie(), de = new x(), pe = new ce(), j = U.getInstance();
E.buildFromTemplate(q);
const M = E.buildFromTemplate(C);
S || E.setApplicationMenu(M);
async function z() {
  i.initialize(), i.transports.console.format = "{h}:{i}:{s} {text}", i.transports.ipc.level = "silly";
  const s = Object.assign(
    (e) => {
      const t = T.getAllWindows();
      t.length > 0 && t[0].webContents.send(R.mainLog, e.data.toString());
    },
    {
      level: "info",
      transforms: []
    }
  );
  return i.transports.ipc = s, i.info("Creating window"), h = new T({
    title: "Work Louder - Input",
    icon: P(process.env.VITE_PUBLIC, "./assets/icon.ico"),
    webPreferences: {
      preload: O
    },
    width: 1266,
    height: 793,
    minWidth: 1266,
    minHeight: 793
  }), S || h.setMenu(M), h.webContents.session.on("select-serial-port", (e, t, r, a) => {
    i.info("GOT TO PORT SELECTION"), e.preventDefault();
    let o = t.find((l) => l.vendorId == "12346" && l.productId == "4097");
    a(o ? o.portId : "");
  }), S ? (h.loadURL(S), h.webContents.openDevTools()) : h.loadFile(V), h.webContents.on("did-finish-load", () => {
    h == null || h.webContents.send("main-process-message", (/* @__PURE__ */ new Date()).toLocaleString());
  }), h.webContents.setWindowOpenHandler(({ url: e }) => (e.startsWith("https:") && $.openExternal(e), { action: "deny" })), le.setUpListeners(h), h;
}
v.whenReady().then(() => {
  i.info("Application ready"), z().then(G);
});
v.on("window-all-closed", () => {
  h = null, j.disconnect(), process.platform !== "darwin" && v.quit();
});
v.on("second-instance", () => {
  i.info("second istance"), h && (h.isMinimized() && h.restore(), h.focus());
});
v.on("activate", () => {
  const s = T.getAllWindows();
  i.info("activate"), s.length ? s[0].focus() : z().then(G);
});
v.on("before-quit", () => {
  j.disconnect();
});
p.handle("open-win", (s, e) => {
  i.info("New win");
  const t = new T({
    webPreferences: {
      preload: O,
      nodeIntegration: !1,
      contextIsolation: !0
    }
  });
  process.env.VITE_DEV_SERVER_URL ? t.loadURL(`${S}#${e}`) : t.loadFile(V, { hash: e });
});
function G(s) {
  de.setWindow(s), pe.setWindow(s), new oe(s);
}
