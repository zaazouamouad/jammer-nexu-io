#!/usr/bin/env python3
"""
NexuIO Pro – Advanced RF Communication System
Professional UI · Multi-band Support · Real-time Logging
Tested on Pydroid 3 (Android)
"""

import tkinter as tk
from tkinter import ttk, scrolledtext
import threading
import time
import random
from datetime import datetime

# ───────────────────────── COLOUR PALETTE ─────────────────────────
BG_DARK      = "#0a0e14"
BG_PANEL     = "#11161e"
BG_WIDGET    = "#1a1f2a"
ACCENT       = "#58a6ff"
ACCENT2      = "#3fb950"
ACCENT3      = "#f78166"
ACCENT4      = "#d2a679"
ACCENT5      = "#a371f7"
TEXT_MAIN    = "#e6edf3"
TEXT_DIM     = "#8b949e"
BORDER       = "#242c38"
HOVER_BG     = "#242c38"

# Cross-platform monospace font
FONT         = "TkFixedFont"
FONT_BOLD    = (FONT, 10, "bold")
FONT_NORMAL  = (FONT, 9)
FONT_SMALL   = (FONT, 8)
FONT_TITLE   = (FONT, 12, "bold")
FONT_STATS   = (FONT, 18, "bold")

CATEGORY_COLORS = {
    "Communications": ("#58a6ff", "#0d2137"),
    "Networks":       ("#3fb950", "#0d2a14"),
    "Navigation":     ("#d2a679", "#2a1f0d"),
    "Vehicles":       ("#a371f7", "#1a1037"),
    "Drones":         ("#39d0d8", "#0d2527"),
    "Security":       ("#f78166", "#2a110d"),
    "Industrial":     ("#ffa657", "#2a1a0d"),
    "Medical":        ("#56d364", "#0d2415"),
    "Entertainment":  ("#e3b341", "#2a220d"),
    "Broadcast":      ("#f47067", "#2a130d"),
}


# noinspection PyAttributeOutsideInit
class NexuIOPro:
    """Main application controller."""

    def __init__(self, root: tk.Tk):
        self.root = root
        self.root.title("NexuIO Pro – Advanced RF System")
        self.root.geometry("800x600")          # tablet-friendly default
        self.root.configure(bg=BG_DARK)
        self.root.resizable(True, True)

        # Transmission state
        self.is_transmitting = False
        self.current_frequency = "433.92 MHz"
        self.current_device = ""

        # UI elements that need cross access
        self.status_var: tk.StringVar = None
        self.status_pill: tk.Label = None
        self.freq_var: tk.StringVar = None
        self.power_var: tk.IntVar = None
        self.modulation_var: tk.StringVar = None
        self.start_btn: ttk.Button = None
        self.stop_btn: ttk.Button = None
        self.log_text: scrolledtext.ScrolledText = None
        self.device_label: tk.Label = None

        self._apply_ttk_theme()
        self._build_ui()

    # ───────────────── THEME ─────────────────
    def _apply_ttk_theme(self):
        style = ttk.Style()
        style.theme_use("clam")

        style.configure(".", background=BG_DARK, foreground=TEXT_MAIN,
                        fieldbackground=BG_WIDGET, bordercolor=BORDER,
                        troughcolor=BG_WIDGET, selectbackground=ACCENT,
                        selectforeground=BG_DARK, font=FONT_NORMAL)

        style.configure("TNotebook", background=BG_DARK, borderwidth=0)
        style.configure("TNotebook.Tab", background=BG_PANEL,
                        foreground=TEXT_DIM, padding=[12, 6], font=FONT_BOLD)
        style.map("TNotebook.Tab",
                  background=[("selected", BG_WIDGET)],
                  foreground=[("selected", ACCENT)])

        style.configure("Card.TFrame", background=BG_PANEL, relief="flat")
        style.configure("TLabel", background=BG_DARK, foreground=TEXT_MAIN)
        style.configure("TEntry", fieldbackground=BG_WIDGET, foreground=TEXT_MAIN,
                        insertcolor=ACCENT)
        style.configure("TCombobox", fieldbackground=BG_WIDGET, foreground=TEXT_MAIN,
                        arrowcolor=ACCENT)
        style.configure("TLabelframe", background=BG_PANEL, foreground=ACCENT,
                        bordercolor=BORDER, relief="flat")
        style.configure("TLabelframe.Label", background=BG_PANEL,
                        foreground=ACCENT, font=FONT_BOLD)

        # Generic button
        style.configure("TButton", background=BG_WIDGET, foreground=TEXT_MAIN,
                        bordercolor=BORDER, relief="flat", padding=[8, 4])
        style.map("TButton",
                  background=[("active", HOVER_BG), ("disabled", BG_PANEL)],
                  foreground=[("disabled", TEXT_DIM)])

        # Coloured buttons
        for name, color in [("Accent", ACCENT), ("Success", ACCENT2),
                            ("Danger", ACCENT3), ("Warning", ACCENT4),
                            ("Purple", ACCENT5)]:
            style.configure(f"{name}.TButton", background=color,
                            foreground=BG_DARK, bordercolor=color,
                            font=FONT_BOLD)
            style.map(f"{name}.TButton",
                      background=[("active", color), ("disabled", BG_PANEL)],
                      foreground=[("disabled", TEXT_DIM)])

        style.configure("Horizontal.TScale", background=BG_PANEL,
                        troughcolor=BG_WIDGET, sliderlength=16, sliderrelief="flat")

    # ───────────────── UI STRUCTURE ─────────────────
    def _build_ui(self):
        # Top bar
        topbar = tk.Frame(self.root, bg=BG_PANEL, height=42)
        topbar.pack(fill="x", side="top")
        topbar.pack_propagate(False)
        tk.Label(topbar, text="◈ NEXUIO PRO", bg=BG_PANEL,
                 fg=ACCENT, font=FONT_TITLE).pack(side="left", padx=14, pady=8)
        tk.Label(topbar, text="Professional RF Platform",
                 bg=BG_PANEL, fg=TEXT_DIM, font=FONT_SMALL).pack(side="left", padx=4)
        self.status_var = tk.StringVar(value="● READY")
        self.status_pill = tk.Label(topbar, textvariable=self.status_var,
                                    bg=BG_PANEL, fg=ACCENT2, font=FONT_BOLD)
        self.status_pill.pack(side="right", padx=14)

        tk.Frame(self.root, bg=BORDER, height=1).pack(fill="x")

        # Notebook
        self.notebook = ttk.Notebook(self.root)
        self.notebook.pack(fill="both", expand=True)

        self._tab_dashboard()
        self._tab_category("Communications", [
            "Smartphones", "2G Phones", "3G Phones", "4G Phones", "5G Phones",
            "Sat Phones", "Walkie-Talkies", "Police VHF", "Ambulance UHF",
            "Military Comms", "Marine Comms", "CB Radio", "PMR", "TETRA"
        ])
        self._tab_category("Networks", [
            "Wi-Fi Routers", "Wi-Fi APs", "Wi-Fi Extenders", "4G Modem",
            "5G Modem", "Bluetooth", "BLE Devices", "NFC", "RFID",
            "ZigBee", "Z-Wave", "LoRa", "IoT Devices"
        ])
        self._tab_category("Navigation", [
            "GPS Receivers", "Car GPS", "Aircraft GPS", "Vehicle Trackers",
            "Animal Trackers", "Child Trackers", "Luggage Trackers"
        ])
        self._tab_category("Vehicles", [
            "Keyless Entry", "SmartKey", "Remote Lock", "Car Alarms",
            "TPMS Sensors", "RF Engine Control", "Smart Parking"
        ])
        self._tab_category("Drones", [
            "Consumer Drones", "Pro Drones", "FPV Transmission",
            "Telemetry Links", "Drone GPS", "RTH Systems"
        ])
        self._tab_category("Security", [
            "Wi-Fi Cameras", "Smart Locks", "Smart Doorbells",
            "RF Motion Sensors", "Door Sensors", "Wireless Fire Sensors"
        ])
        self._tab_category("Industrial", [
            "Crane Remotes", "Industrial Telemetry", "Smart Meters",
            "LoRa Sensors", "Industrial RFID"
        ])
        self._tab_category("Medical", [
            "BT Blood Pressure", "BT Glucose Meter", "BT ECG",
            "Health Wearables", "Wireless EMS"
        ])
        self._tab_category("Entertainment", [
            "RF Remotes", "Wi-Fi Speakers", "PlayStation Controller",
            "Xbox Controller", "RC Cars", "Wireless Microphones"
        ])
        self._tab_category("Broadcast", [
            "FM Radio", "AM Radio", "Shortwave", "Analog TV",
            "Ham Radio", "PMR446", "FM Transmitters"
        ])
        self._tab_advanced()

    # ───────────────── DASHBOARD TAB ─────────────────
    def _tab_dashboard(self):
        frame = ttk.Frame(self.notebook)
        self.notebook.add(frame, text=" Dashboard ")

        left = tk.Frame(frame, bg=BG_DARK)
        left.pack(side="left", fill="both", expand=True, padx=(14, 7), pady=14)
        right = tk.Frame(frame, bg=BG_DARK)
        right.pack(side="right", fill="both", expand=True, padx=(7, 14), pady=14)

        # ── Stat cards ──
        stats = [
            ("700+", "Devices", ACCENT),
            ("15+", "Bands", ACCENT2),
            ("24 GHz", "mmWave", ACCENT5),
            ("10", "Categories", "#39d0d8"),
        ]
        grid = tk.Frame(left, bg=BG_DARK)
        grid.pack(fill="x")
        for idx, (val, lbl, clr) in enumerate(stats):
            card = tk.Frame(grid, bg=BG_PANEL, padx=12, pady=8,
                            highlightthickness=1, highlightbackground=BORDER)
            card.grid(row=idx // 2, column=idx % 2, padx=4, pady=4, sticky="nsew")
            tk.Label(card, text=val, bg=BG_PANEL, fg=clr,
                     font=FONT_STATS).pack(anchor="w")
            tk.Label(card, text=lbl, bg=BG_PANEL, fg=TEXT_DIM,
                     font=FONT_SMALL).pack(anchor="w")
        grid.columnconfigure(0, weight=1)
        grid.columnconfigure(1, weight=1)

        # ── Protocol tags ──
        proto_frame = tk.LabelFrame(left, text=" Supported Protocols",
                                    bg=BG_PANEL, fg=ACCENT, font=FONT_NORMAL,
                                    relief="flat", highlightthickness=1,
                                    highlightbackground=BORDER)
        proto_frame.pack(fill="x", pady=(12, 0))
        tags = ["RF 433", "RF 868", "2.4 GHz", "5.8 GHz", "Wi-Fi",
                "Bluetooth", "Zigbee", "LoRa", "NFC", "RFID", "GPS", "TETRA"]
        tag_grid = tk.Frame(proto_frame, bg=BG_PANEL)
        tag_grid.pack(padx=8, pady=6)
        colors = [ACCENT, ACCENT2, ACCENT4, ACCENT5, "#39d0d8", "#f78166"]
        for i, tag in enumerate(tags):
            clr = colors[i % len(colors)]
            lbl = tk.Label(tag_grid, text=f" {tag} ", bg=clr, fg=BG_DARK,
                           font=FONT_SMALL, padx=3, pady=1)
            lbl.grid(row=i // 4, column=i % 4, padx=2, pady=2, sticky="w")

        # ── Quick actions ──
        actions_frame = tk.LabelFrame(right, text=" Quick Actions",
                                      bg=BG_PANEL, fg=ACCENT, font=FONT_NORMAL,
                                      relief="flat", highlightthickness=1,
                                      highlightbackground=BORDER)
        actions_frame.pack(fill="x")
        for txt, style, cmd in [
            ("⊕ Scan Devices", "Accent", self.scan_devices),
            ("≋ Spectrum Analysis", "Warning", self.spectrum_analysis),
            ("⚙ Advanced Settings", "Purple", self.advanced_settings),
        ]:
            ttk.Button(actions_frame, text=txt, style=f"{style}.TButton",
                       command=cmd).pack(fill="x", padx=10, pady=4)

        # ── System log ──
        log_frame = tk.LabelFrame(right, text=" System Log",
                                  bg=BG_PANEL, fg=ACCENT, font=FONT_NORMAL,
                                  relief="flat", highlightthickness=1,
                                  highlightbackground=BORDER)
        log_frame.pack(fill="both", expand=True, pady=(12, 0))
        self.log_text = scrolledtext.ScrolledText(
            log_frame, bg=BG_DARK, fg=ACCENT2, insertbackground=ACCENT,
            font=FONT_SMALL, relief="flat", bd=0,
            selectbackground=ACCENT, wrap="word"
        )
        self.log_text.pack(fill="both", expand=True, padx=6, pady=6)
        self._log("System initialised — NexuIO Pro v3.0 ready.")

    # ───────────────── CATEGORY TAB ─────────────────
    def _tab_category(self, name: str, devices: list):
        accent, bg_tint = CATEGORY_COLORS.get(name, (ACCENT, BG_PANEL))

        outer = tk.Frame(self.notebook, bg=BG_DARK)
        self.notebook.add(outer, text=f" {name} ")

        # Header
        header = tk.Frame(outer, bg=bg_tint, pady=10,
                          highlightthickness=1, highlightbackground=accent)
        header.pack(fill="x")
        tk.Label(header, text=f"◈ {name}", bg=bg_tint, fg=accent,
                 font=FONT_TITLE).pack(side="left", padx=14)
        tk.Label(header, text=f"{len(devices)} devices", bg=bg_tint,
                 fg=TEXT_DIM, font=FONT_SMALL).pack(side="right", padx=14)

        # Scrollable grid
        canvas = tk.Canvas(outer, bg=BG_DARK, highlightthickness=0)
        scrollbar = ttk.Scrollbar(outer, orient="vertical", command=canvas.yview)
        canvas.configure(yscrollcommand=scrollbar.set)
        scrollbar.pack(side="right", fill="y")
        canvas.pack(side="left", fill="both", expand=True)

        inner = tk.Frame(canvas, bg=BG_DARK)
        inner_id = canvas.create_window((0, 0), window=inner, anchor="nw")

        def _configure_inner(event):
            canvas.configure(scrollregion=canvas.bbox("all"))
        def _configure_canvas(event):
            canvas.itemconfig(inner_id, width=event.width)

        inner.bind("<Configure>", _configure_inner)
        canvas.bind("<Configure>", _configure_canvas)

        cols = 4
        for i, device in enumerate(devices):
            row, col = divmod(i, cols)
            self._make_device_btn(inner, device, accent, row, col)

        for c in range(cols):
            inner.columnconfigure(c, weight=1)

    def _make_device_btn(self, parent: tk.Frame, device: str,
                         accent: str, row: int, col: int):
        cell = tk.Frame(parent, bg=BG_PANEL,
                        highlightthickness=1, highlightbackground=BORDER,
                        padx=4, pady=4)
        cell.grid(row=row, column=col, padx=6, pady=6, sticky="nsew")

        tk.Label(cell, text="●", bg=BG_PANEL, fg=accent,
                 font=FONT_SMALL).pack(side="left", padx=(2, 4))
        tk.Label(cell, text=device, bg=BG_PANEL, fg=TEXT_MAIN,
                 font=FONT_NORMAL, anchor="w", wraplength=120).pack(
            side="left", fill="x", expand=True)

        btn = tk.Button(cell, text="▶", bg=BG_PANEL, fg=accent,
                        activebackground=accent, activeforeground=BG_DARK,
                        relief="flat", font=FONT_BOLD, cursor="hand2",
                        command=lambda d=device: self._device_selected(d))
        btn.pack(side="right", padx=2)

        def _enter(e): cell.config(highlightbackground=accent)
        def _leave(e): cell.config(highlightbackground=BORDER)
        cell.bind("<Enter>", _enter)
        cell.bind("<Leave>", _leave)

    # ───────────────── ADVANCED TAB ─────────────────
    def _tab_advanced(self):
        frame = ttk.Frame(self.notebook)
        self.notebook.add(frame, text=" Advanced ")

        left = tk.Frame(frame, bg=BG_DARK)
        left.pack(side="left", fill="both", padx=(14, 7), pady=14, expand=True)
        right = tk.Frame(frame, bg=BG_DARK)
        right.pack(side="right", fill="both", padx=(7, 14), pady=14, expand=True)

        # ── Signal Control card ──
        ctrl = tk.LabelFrame(left, text=" Signal Control",
                             bg=BG_PANEL, fg=ACCENT, font=FONT_NORMAL,
                             relief="flat", highlightthickness=1,
                             highlightbackground=BORDER)
        ctrl.pack(fill="x")
        ctrl.columnconfigure(1, weight=1)
        pad = {"padx": 10, "pady": 4, "sticky": "w"}

        # Frequency
        tk.Label(ctrl, text="Freq. (MHz):", bg=BG_PANEL, fg=TEXT_DIM,
                 font=FONT_NORMAL).grid(row=0, column=0, **pad)
        self.freq_var = tk.StringVar(value="433.92")
        freq_entry = tk.Entry(ctrl, textvariable=self.freq_var,
                              bg=BG_WIDGET, fg=TEXT_MAIN, insertbackground=ACCENT,
                              relief="flat", font=FONT_NORMAL,
                              highlightthickness=1, highlightbackground=BORDER,
                              width=16)
        freq_entry.grid(row=0, column=1, **pad)

        # Power
        tk.Label(ctrl, text="TX Power (%):", bg=BG_PANEL, fg=TEXT_DIM,
                 font=FONT_NORMAL).grid(row=1, column=0, **pad)
        self.power_var = tk.IntVar(value=50)
        power_scale = tk.Scale(ctrl, from_=0, to=100, variable=self.power_var,
                               orient="horizontal", bg=BG_PANEL, fg=ACCENT,
                               troughcolor=BG_WIDGET, activebackground=ACCENT,
                               highlightthickness=0, bd=0,
                               sliderrelief="flat", length=140,
                               font=FONT_SMALL)
        power_scale.grid(row=1, column=1, sticky="w", padx=8)

        # Modulation
        tk.Label(ctrl, text="Modulation:", bg=BG_PANEL, fg=TEXT_DIM,
                 font=FONT_NORMAL).grid(row=2, column=0, **pad)
        self.modulation_var = tk.StringVar(value="OOK")
        mod_combo = ttk.Combobox(ctrl, textvariable=self.modulation_var,
                                 values=["OOK", "FSK", "ASK", "PSK", "QAM",
                                         "GFSK", "OFDM"],
                                 width=14, state="readonly")
        mod_combo.grid(row=2, column=1, **pad)

        # Buttons
        btn_frame = tk.Frame(ctrl, bg=BG_PANEL)
        btn_frame.grid(row=3, column=1, pady=(10, 12), sticky="ew")
        btn_frame.columnconfigure((0, 1, 2), weight=1)

        self.start_btn = ttk.Button(btn_frame, text="▶ Start TX",
                                    style="Success.TButton",
                                    command=self._start_transmission)
        self.start_btn.grid(row=0, column=0, padx=2, sticky="ew")
        self.stop_btn = ttk.Button(btn_frame, text="■ Stop TX",
                                   style="Danger.TButton",
                                   command=self._stop_transmission,
                                   state="disabled")
        self.stop_btn.grid(row=0, column=1, padx=2, sticky="ew")
        ttk.Button(btn_frame, text="≡ Sweep",
                   style="Purple.TButton",
                   command=self._sweep_band).grid(row=0, column=2, padx=2, sticky="ew")

        # ── Active Device info ──
        info = tk.LabelFrame(left, text=" Active Device",
                             bg=BG_PANEL, fg=ACCENT, font=FONT_NORMAL,
                             relief="flat", highlightthickness=1,
                             highlightbackground=BORDER)
        info.pack(fill="x", pady=(12, 0))
        self.device_label = tk.Label(info, text="No device selected",
                                     bg=BG_PANEL, fg=TEXT_DIM,
                                     font=FONT_NORMAL, anchor="w")
        self.device_label.pack(fill="x", padx=10, pady=8)

        # ── Log viewer ──
        log_lf = tk.LabelFrame(right, text=" System Log",
                               bg=BG_PANEL, fg=ACCENT, font=FONT_NORMAL,
                               relief="flat", highlightthickness=1,
                               highlightbackground=BORDER)
        log_lf.pack(fill="both", expand=True)
        adv_log = scrolledtext.ScrolledText(
            log_lf, bg=BG_DARK, fg=ACCENT2, insertbackground=ACCENT,
            font=FONT_SMALL, relief="flat", bd=0,
            selectbackground=ACCENT, wrap="word"
        )
        adv_log.pack(fill="both", expand=True, padx=6, pady=6)
        self.log_text_adv = adv_log

        ttk.Button(right, text="⊘ Clear Log",
                   style="TButton",
                   command=lambda: adv_log.delete("1.0", "end")).pack(
            anchor="e", pady=(6, 0))

    # ───────────────── HELPERS ─────────────────
    def _log(self, message: str):
        ts = datetime.now().strftime("%H:%M:%S")
        line = f"[{ts}]  {message}\n"
        for box in [self.log_text, getattr(self, "log_text_adv", None)]:
            if box:
                box.insert("end", line)
                box.see("end")

    def _set_status(self, text: str, color: str = ACCENT2):
        self.status_var.set(text)
        self.status_pill.config(fg=color)

    def _device_selected(self, device_name: str):
        self.current_device = device_name
        if self.device_label:
            self.device_label.config(text=f"● {device_name}", fg=ACCENT)
        self._log(f"Device selected: {device_name}")
        self._show_device_control(device_name)

    def _show_device_control(self, device_name: str):
        win = tk.Toplevel(self.root)
        win.title(f"Control – {device_name}")
        win.geometry("360x320")
        win.configure(bg=BG_DARK)
        win.resizable(False, False)

        hdr = tk.Frame(win, bg=BG_PANEL, pady=10)
        hdr.pack(fill="x")
        tk.Label(hdr, text=f"◈ {device_name}", bg=BG_PANEL,
                 fg=ACCENT, font=FONT_TITLE).pack(padx=14, anchor="w")

        body = tk.Frame(win, bg=BG_DARK, padx=14, pady=12)
        body.pack(fill="both", expand=True)

        # Frequency
        row1 = tk.Frame(body, bg=BG_DARK)
        row1.pack(fill="x", pady=4)
        tk.Label(row1, text="Frequency (MHz):", bg=BG_DARK, fg=TEXT_DIM,
                 font=FONT_NORMAL).pack(side="left")
        freq_entry = tk.Entry(row1, width=14, bg=BG_WIDGET, fg=TEXT_MAIN,
                              insertbackground=ACCENT, relief="flat",
                              font=FONT_NORMAL, highlightthickness=1,
                              highlightbackground=BORDER)
        freq_entry.pack(side="left", padx=8)
        freq_entry.insert(0, self._default_freq(device_name))

        sep = tk.Frame(body, bg=BORDER, height=1)
        sep.pack(fill="x", pady=8)

        btn_frame = tk.Frame(body, bg=BG_DARK)
        btn_frame.pack(fill="x")
        for txt, style, cmd in [
            ("▶ Transmit", "Success", lambda: self._start_device_tx(device_name, freq_entry.get())),
            ("◎ Receive", "Accent", lambda: self._start_device_rx(device_name, freq_entry.get())),
            ("≋ Analyse", "Warning", lambda: self._analyse(device_name, freq_entry.get())),
        ]:
            ttk.Button(btn_frame, text=txt, style=f"{style}.TButton",
                       command=cmd).pack(fill="x", pady=3)

    @staticmethod
    def _default_freq(device: str) -> str:
        mapping = {
            "Smartphones": "2400", "Wi-Fi Routers": "2412",
            "Bluetooth Devices": "2402", "GPS Receivers": "1575.42",
            "Keyless Entry": "433.92", "RF Remotes": "315.00",
            "FM Radio": "98.00", "Walkie-Talkies": "446.00",
        }
        return mapping.get(device, "433.92")

    # ───────────────── TRANSMISSION LOGIC ─────────────────
    def _start_device_tx(self, device, freq):
        self.current_device = device
        self.current_frequency = freq
        self.freq_var.set(freq)
        self._start_transmission()

    def _start_device_rx(self, device, freq):
        self.current_frequency = freq
        self._log(f"RECEPTION START · {device} @ {freq} MHz")
        self._set_status("● RECEIVING", ACCENT)
        threading.Thread(target=self._sim_reception, daemon=True).start()

    def _analyse(self, device, freq):
        self._log(f"ANALYSIS · {device} @ {freq} MHz")
        threading.Thread(target=self._sim_analysis, args=(device, freq),
                         daemon=True).start()

    def _start_transmission(self):
        if not self.is_transmitting:
            self.is_transmitting = True
            self.start_btn.config(state="disabled")
            self.stop_btn.config(state="normal")
            self._set_status("● TRANSMITTING", ACCENT3)
            power = self.power_var.get()
            mod = self.modulation_var.get()
            freq = self.freq_var.get()
            self._log(f"TX START · {freq} MHz · {mod} · {power}%")
            threading.Thread(target=self._sim_tx, daemon=True).start()

    def _stop_transmission(self):
        if self.is_transmitting:
            self.is_transmitting = False
            self.start_btn.config(state="normal")
            self.stop_btn.config(state="disabled")
            self._set_status("● READY", ACCENT2)
            self._log("TX STOPPED")

    def _sim_tx(self):
        for i in range(1000):
            if not self.is_transmitting:
                break
            if i % 10 == 0:
                self._log(f"  pkt #{i:04d}  data=TX_{random.randint(1000,9999)}")
            time.sleep(0.1)

    def _sim_reception(self):
        for _ in range(15):
            if random.random() > 0.7:
                self._log(f"  RX · sig={random.randint(20,95)}% "
                          f"data=RX_{random.randint(1000,9999)} "
                          f"proto={random.choice(['OOK','FSK','ASK'])}")
            time.sleep(0.4)
        self._set_status("● READY", ACCENT2)

    def _sim_analysis(self, device, freq):
        fields = {
            "Signal Strength": f"{random.randint(30,98)} %",
            "Noise Floor": f"{random.randint(-120,-80)} dBm",
            "Bandwidth": random.choice(["1 MHz", "5 MHz", "20 MHz"]),
            "Modulation": random.choice(["OOK", "FSK", "ASK", "PSK"]),
        }
        self._log(f"── Analysis: {device} ──")
        for k, v in fields.items():
            self._log(f"   {k:<18} {v}")

    # ───────────────── QUICK ACTIONS ─────────────────
    def scan_devices(self):
        self._log("Scanning for nearby devices…")
        threading.Thread(target=self._sim_scan, daemon=True).start()

    def _sim_scan(self):
        sample = ["Smartphone · Galaxy", "Wi-Fi Router · TP-Link",
                  "Bluetooth Speaker", "Keyless Entry · Toyota",
                  "GPS Tracker", "Smart Lock", "Drone · Mavic"]
        random.shuffle(sample)
        for dev in sample[:random.randint(3, 6)]:
            sig = random.randint(20, 95)
            freq = random.choice(["433.92", "868", "2400", "5800"])
            self._log(f"  ◈ {dev} · {sig}% · {freq} MHz")
            time.sleep(0.35)
        self._log("Scan complete.")

    def spectrum_analysis(self):
        self._log("Spectrum sweep…")
        for freq in ["433", "868", "2400", "5800", "24200", "60500"]:
            pwr = random.randint(-90, -20)
            bar = "█" * max(1, (pwr + 90) // 8)
            self._log(f"  {freq:>6} MHz  {pwr:>4} dBm  {bar}")
            time.sleep(0.06)

    def _sweep_band(self):
        freq = self.freq_var.get()
        self._log(f"Sweeping around {freq} MHz…")
        threading.Thread(target=self._sim_sweep, args=(freq,), daemon=True).start()

    def _sim_sweep(self, center: str):
        try:
            cf = float(center)
        except ValueError:
            cf = 2400
        for offset in range(-80, 81, 20):
            f = cf + offset
            rssi = random.randint(-90, -20)
            bar = "█" * max(1, (rssi + 90) // 5)
            self._log(f"  {f:>8.1f} MHz  {rssi} dBm  {bar}")
            time.sleep(0.08)

    def advanced_settings(self):
        self._log("Advanced settings panel accessed.")


# ──────────────────────── ENTRY POINT ────────────────────────
if __name__ == "__main__":
    root = tk.Tk()
    app = NexuIOPro(root)
    root.mainloop()
