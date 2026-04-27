#!/usr/bin/env python3
"""
NexuIO Pro – Advanced RF Communication System (CLI Edition)
Professional multi-band support · Real-time logging
Runs in any terminal, no GUI dependencies.

Color scheme:
  - Menu numbers: CYAN (bright, consistent)
  - Category headers: their own colour (see CATEGORY_COLORS)
  - Device names: match the parent category colour
  - Log levels: ERROR (red), SUCCESS (green), WARNING (yellow)
"""

import threading
import time
import random
from datetime import datetime

# ------------------------------------------------------------------
#  ANSI colour & style constants
# ------------------------------------------------------------------
RESET   = "\033[0m"
BOLD    = "\033[1m"
DIM     = "\033[2m"

RED     = "\033[91m"
GREEN   = "\033[92m"
YELLOW  = "\033[93m"
BLUE    = "\033[94m"
MAGENTA = "\033[95m"
CYAN    = "\033[96m"
WHITE   = "\033[97m"
ORANGE  = "\033[38;5;214m"

# Each category gets its own colour for visual grouping
CATEGORY_COLORS: dict[str, str] = {
    "Communications": BLUE,
    "Networks":       GREEN,
    "Navigation":     YELLOW,
    "Vehicles":       MAGENTA,
    "Drones":         CYAN,
    "Security":       RED,
    "Industrial":     YELLOW,
    "Medical":        GREEN,
    "Entertainment":  CYAN,
    "Broadcast":      RED,
}

# Colour used for all menu option numbers (to make them stand out)
NUMBER_COLOR = CYAN


# ------------------------------------------------------------------
#  Banner
# ------------------------------------------------------------------
def show() -> None:
    """Display the NexuIO Pro banner (logo, bat, developer credit)."""
    # Jammer-style logo
    print(f"{ORANGE}{BOLD}")
    print("      ██╗ █████╗ ███╗   ███╗███╗   ███╗███████╗██████╗ ")
    print("      ██║██╔══██╗████╗ ████║████╗ ████║██╔════╝██╔══██╗")
    print("      ██║███████║██╔████╔██║██╔████╔██║█████╗  ██████╔╝")
    print(" ██   ██║██╔══██║██║╚██╔╝██║██║╚██╔╝██║██╔══╝  ██╔══██╗")
    print(" ╚█████╔╝██║  ██║██║ ╚═╝ ██║██║ ╚═╝ ██║███████╗██║  ██║")
    print("  ╚════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝")
    print(RESET)

    # Bat
    print(f"{GREEN}{BOLD}")
    print(r"   /\                 /\ ")
    print(r"  / \'._   (\_/)   _.'/ \ ")
    print(r"  |.''._'--(o.o)--'_.''.|")
    print(r"   \_ / `;=/ " "\\" r" \=;` \ _/")
    print(r"     `\__| \___/ |__/`")
    print(r"          \(_|_)/")
    print(RESET)

    # Developer credit
    print(f"{YELLOW}{BOLD}")
    print("     Developed by: zaazouamouad")
    print(RESET)


# ------------------------------------------------------------------
#  Core application class
# ------------------------------------------------------------------
class NexuIOCLI:
    """Professional RF communication system simulator (CLI)."""

    def __init__(self) -> None:
        self.is_transmitting:   bool = False
        self.current_frequency: str  = "433.92"
        self.current_device:    str  = ""
        self.transmit_power:    int  = 50
        self.modulation:        str  = "OOK"
        self.running:           bool = True

    # ------------------------------------------------------------------
    #  Logging & UI helpers
    # ------------------------------------------------------------------
    def _log(self, message: str, level: str = "INFO") -> None:
        """Print a timestamped log message with appropriate colour."""
        ts = datetime.now().strftime("%H:%M:%S")
        if level == "ERROR":
            prefix = f"{RED}[{ts}] ERROR{RESET}"
        elif level == "SUCCESS":
            prefix = f"{GREEN}[{ts}] {BOLD}✓{RESET}"
        elif level == "WARNING":
            prefix = f"{YELLOW}[{ts}] ⚠{RESET}"
        else:
            prefix = f"{DIM}[{ts}]{RESET}"
        print(f"{prefix} {message}")

    def _print_header(self, title: str) -> None:
        """Print a stylised section header."""
        print(f"\n{BOLD}{BLUE}─── {title} ───{RESET}")

    def _input_int(self, prompt: str, min_val: int, max_val: int) -> int:
        """Safely read an integer within a given range."""
        while True:
            try:
                val = int(input(prompt))
                if min_val <= val <= max_val:
                    return val
                print(f"{RED}Please enter a number between {min_val} and {max_val}.{RESET}")
            except ValueError:
                print(f"{RED}Invalid number.{RESET}")

    def _input_choice(self, prompt: str, choices: list) -> str:
        """Force the user to pick one of the provided choices."""
        while True:
            inp = input(prompt).strip()
            if inp in choices:
                return inp
            print(f"{RED}Invalid choice. Options: {', '.join(choices)}{RESET}")

    # ------------------------------------------------------------------
    #  Core RF simulation
    # ------------------------------------------------------------------
    def _start_transmission(self) -> None:
        """Begin transmitting in a background thread."""
        if self.is_transmitting:
            self._log("Already transmitting.", "WARNING")
            return
        self.is_transmitting = True
        self._log(
            f"TX START · {self.current_frequency} MHz · {self.modulation} · {self.transmit_power}%",
            "SUCCESS",
        )
        threading.Thread(target=self._sim_tx, daemon=True).start()

    def _stop_transmission(self) -> None:
        """Stop the current transmission."""
        if not self.is_transmitting:
            self._log("No active transmission.", "WARNING")
            return
        self.is_transmitting = False
        self._log("TX STOPPED", "SUCCESS")

    def _sim_tx(self) -> None:
        """Simulate ongoing packet transmission."""
        pkt = 0
        while self.is_transmitting:
            if pkt % 10 == 0:
                self._log(f"  pkt #{pkt:04d}  data=TX_{random.randint(1000, 9999)}")
            pkt += 1
            time.sleep(0.1)

    def _sim_reception(self, device: str, freq: str) -> None:
        """Simulate receiving data from a device."""
        self._log(f"RECEPTION START · {device} @ {freq} MHz", "SUCCESS")
        for _ in range(15):
            if random.random() > 0.7:
                self._log(
                    f"  RX · sig={random.randint(20, 95)}% "
                    f"data=RX_{random.randint(1000, 9999)} "
                    f"proto={random.choice(['OOK', 'FSK', 'ASK'])}"
                )
            time.sleep(0.4)
        self._log("Reception finished.")

    def _sim_analysis(self, device: str, freq: str) -> None:
        """Perform spectrum analysis simulation."""
        self._log(f"─── Analysis: {device} @ {freq} MHz ───", "INFO")
        fields = {
            "Signal Strength": f"{random.randint(30, 98)} %",
            "Noise Floor":     f"{random.randint(-120, -80)} dBm",
            "Bandwidth":       random.choice(["1 MHz", "5 MHz", "20 MHz"]),
            "Modulation":      random.choice(["OOK", "FSK", "ASK", "PSK"]),
        }
        for k, v in fields.items():
            self._log(f"   {k:<18} {v}")

    # ------------------------------------------------------------------
    #  Device management & category menus
    # ------------------------------------------------------------------
    @staticmethod
    def _get_categories() -> dict[str, list[str]]:
        """Return available categories and their devices."""
        return {
            "Communications": [
                "Smartphones", "2G Phones", "3G Phones", "4G Phones", "5G Phones",
                "Sat Phones", "Walkie-Talkies", "Police VHF", "Ambulance UHF",
                "Military Comms", "Marine Comms", "CB Radio", "PMR", "TETRA",
            ],
            "Networks": [
                "Wi-Fi Routers", "Wi-Fi APs", "Wi-Fi Extenders", "4G Modem",
                "5G Modem", "Bluetooth", "BLE Devices", "NFC", "RFID",
                "ZigBee", "Z-Wave", "LoRa", "IoT Devices",
            ],
            "Navigation": [
                "GPS Receivers", "Car GPS", "Aircraft GPS", "Vehicle Trackers",
                "Animal Trackers", "Child Trackers", "Luggage Trackers",
            ],
            "Vehicles": [
                "Keyless Entry", "SmartKey", "Remote Lock", "Car Alarms",
                "TPMS Sensors", "RF Engine Control", "Smart Parking",
            ],
            "Drones": [
                "Consumer Drones", "Pro Drones", "FPV Transmission",
                "Telemetry Links", "Drone GPS", "RTH Systems",
            ],
            "Security": [
                "Wi-Fi Cameras", "Smart Locks", "Smart Doorbells",
                "RF Motion Sensors", "Door Sensors", "Wireless Fire Sensors",
            ],
            "Industrial": [
                "Crane Remotes", "Industrial Telemetry", "Smart Meters",
                "LoRa Sensors", "Industrial RFID",
            ],
            "Medical": [
                "BT Blood Pressure", "BT Glucose Meter", "BT ECG",
                "Health Wearables", "Wireless EMS",
            ],
            "Entertainment": [
                "RF Remotes", "Wi-Fi Speakers", "PlayStation Controller",
                "Xbox Controller", "RC Cars", "Wireless Microphones",
            ],
            "Broadcast": [
                "FM Radio", "AM Radio", "Shortwave", "Analog TV",
                "Ham Radio", "PMR446", "FM Transmitters",
            ],
        }

    @staticmethod
    def _default_freq(device: str) -> str:
        """Return a typical frequency for a device (or fallback)."""
        mapping = {
            "Smartphones":    "2400",
            "Wi-Fi Routers":  "2412",
            "Bluetooth":      "2402",
            "GPS Receivers":  "1575.42",
            "Keyless Entry":  "433.92",
            "RF Remotes":     "315.00",
            "FM Radio":       "98.00",
            "Walkie-Talkies": "446.00",
        }
        return mapping.get(device, "433.92")

    def _select_device(self) -> str | None:
        """Interactive device selection by category. Returns device name or None."""
        categories = self._get_categories()
        cat_names  = list(categories.keys())

        # Category list
        print()
        for idx, cat in enumerate(cat_names, 1):
            print(f"  {NUMBER_COLOR}{idx}{RESET}. {cat}")
        print(f"  {NUMBER_COLOR}0{RESET}. Back to main menu")

        cat_choice = self._input_int("\nSelect category: ", 0, len(cat_names))
        if cat_choice == 0:
            return None

        category = cat_names[cat_choice - 1]
        devices  = categories[category]
        cat_color = CATEGORY_COLORS.get(category, WHITE)

        # Device list – each device name takes the category's colour
        print(f"\n{BOLD}{cat_color}Devices in {category}:{RESET}")
        for idx, dev in enumerate(devices, 1):
            print(f"  {NUMBER_COLOR}{idx}{RESET}. {cat_color}{dev}{RESET}")
        print(f"  {NUMBER_COLOR}0{RESET}. Back")

        dev_choice = self._input_int("\nSelect device: ", 0, len(devices))
        if dev_choice == 0:
            return None

        device = devices[dev_choice - 1]
        self.current_device = device
        self.current_frequency = self._default_freq(device)
        self._log(f"Device selected: {device}", "SUCCESS")
        return device

    def _device_control_menu(self, device: str) -> None:
        """Control menu for a specific device."""
        while True:
            self._print_header(f"Control – {device}")
            print(f"  Current frequency: {self.current_frequency} MHz")
            print(f"  TX Power:          {self.transmit_power}%")
            print(f"  Modulation:        {self.modulation}")
            print()

            menu_items = [
                "Transmit",
                "Receive",
                "Analyse",
                "Set frequency",
                "Set TX power",
                "Set modulation",
            ]
            for idx, item in enumerate(menu_items, 1):
                print(f"  {NUMBER_COLOR}{idx}{RESET}. {item}")
            print(f"  {NUMBER_COLOR}0{RESET}. Back")

            choice = input("\nChoice: ").strip()

            if choice == "1":
                self._start_transmission()
            elif choice == "2":
                freq = input(f"Frequency (MHz) [{self.current_frequency}]: ").strip()
                if freq:
                    self.current_frequency = freq
                threading.Thread(
                    target=self._sim_reception,
                    args=(device, self.current_frequency),
                    daemon=True,
                ).start()
            elif choice == "3":
                freq = input(f"Frequency (MHz) [{self.current_frequency}]: ").strip()
                if freq:
                    self.current_frequency = freq
                threading.Thread(
                    target=self._sim_analysis,
                    args=(device, self.current_frequency),
                    daemon=True,
                ).start()
            elif choice == "4":
                new_freq = input(f"New frequency (MHz) [{self.current_frequency}]: ").strip()
                if new_freq:
                    self.current_frequency = new_freq
                    self._log(f"Frequency set to {self.current_frequency} MHz")
            elif choice == "5":
                self.transmit_power = self._input_int("TX Power (0-100): ", 0, 100)
                self._log(f"TX power set to {self.transmit_power}%")
            elif choice == "6":
                mods = ["OOK", "FSK", "ASK", "PSK", "QAM", "GFSK", "OFDM"]
                print("Modulation types:", ", ".join(mods))
                new_mod = input(f"Select modulation [{self.modulation}]: ").strip().upper()
                if new_mod in mods:
                    self.modulation = new_mod
                    self._log(f"Modulation set to {self.modulation}")
                elif new_mod:
                    print(f"{RED}Invalid modulation.{RESET}")
            elif choice == "0":
                break
            else:
                print(f"{RED}Invalid choice.{RESET}")

    # ------------------------------------------------------------------
    #  Quick actions
    # ------------------------------------------------------------------
    def _scan_devices(self) -> None:
        """Simulate a scan for nearby devices."""
        self._log("Scanning for nearby devices...")
        sample = [
            "Smartphone · Galaxy",
            "Wi-Fi Router · TP-Link",
            "Bluetooth Speaker",
            "Keyless Entry · Toyota",
            "GPS Tracker",
            "Smart Lock",
            "Drone · Mavic",
        ]
        random.shuffle(sample)
        for dev in sample[:random.randint(3, 6)]:
            sig  = random.randint(20, 95)
            freq = random.choice(["433.92", "868", "2400", "5800"])
            self._log(f"  ◈ {dev} · {sig}% · {freq} MHz")
            time.sleep(0.35)
        self._log("Scan complete.", "SUCCESS")

    def _spectrum_analysis(self) -> None:
        """Simulate a spectrum sweep over common bands."""
        self._log("Spectrum sweep...")
        for freq in ["433", "868", "2400", "5800", "24200", "60500"]:
            pwr = random.randint(-90, -20)
            bar = "█" * max(1, (pwr + 90) // 8)
            self._log(f"  {freq:>6} MHz  {pwr:>4} dBm  {bar}")
            time.sleep(0.06)
        self._log("Sweep done.", "SUCCESS")

    def _sweep_band(self) -> None:
        """Sweep around the current centre frequency."""
        try:
            cf = float(self.current_frequency)
        except ValueError:
            cf = 2400.0
        self._log(f"Sweeping around {cf} MHz...")
        for offset in range(-80, 81, 20):
            f    = cf + offset
            rssi = random.randint(-90, -20)
            bar  = "█" * max(1, (rssi + 90) // 5)
            self._log(f"  {f:>8.1f} MHz  {rssi} dBm  {bar}")
            time.sleep(0.08)
        self._log("Sweep complete.", "SUCCESS")

    # ------------------------------------------------------------------
    #  Main menu & program loop
    # ------------------------------------------------------------------
    def run(self) -> None:
        """Launch the interactive CLI."""
        show()
        print(f"\n{BOLD}{CYAN}◈◈◈ NEXUIO PRO – Advanced RF System ◈◈◈{RESET}")
        print("CLI Edition – No GUI required")

        while self.running:
            self._print_header("Main Menu")
            menu_options = [
                "Select device (by category)",
                "Quick scan for devices",
                "Spectrum analysis",
                "Frequency sweep",
                "Transmission control (start/stop)",
                "Settings (power/modulation)",
            ]
            for idx, option in enumerate(menu_options, 1):
                print(f"  {NUMBER_COLOR}{idx}{RESET}. {option}")
            print(f"  {NUMBER_COLOR}0{RESET}. Exit")

            choice = input("\nChoice: ").strip()

            if choice == "1":
                dev = self._select_device()
                if dev:
                    self._device_control_menu(dev)
            elif choice == "2":
                self._scan_devices()
            elif choice == "3":
                self._spectrum_analysis()
            elif choice == "4":
                self._sweep_band()
            elif choice == "5":
                sub = input("(s) start transmission / (t) stop / (b) back: ").strip().lower()
                if sub == "s":
                    self._start_transmission()
                elif sub == "t":
                    self._stop_transmission()
            elif choice == "6":
                print(f"\nCurrent TX Power: {self.transmit_power}%")
                new_power = input("New TX Power (0-100, enter to skip): ").strip()
                if new_power:
                    try:
                        p = int(new_power)
                        if 0 <= p <= 100:
                            self.transmit_power = p
                            self._log(f"TX power set to {p}%")
                        else:
                            print(f"{RED}Must be 0-100{RESET}")
                    except ValueError:
                        print(f"{RED}Invalid number{RESET}")

                print(f"Current Modulation: {self.modulation}")
                mods = ["OOK", "FSK", "ASK", "PSK", "QAM", "GFSK", "OFDM"]
                print("Available modulations:", ", ".join(mods))
                new_mod = input("New modulation (enter to skip): ").strip().upper()
                if new_mod in mods:
                    self.modulation = new_mod
                    self._log(f"Modulation set to {self.modulation}")
                elif new_mod:
                    print(f"{RED}Invalid modulation{RESET}")
            elif choice == "0":
                if self.is_transmitting:
                    self._stop_transmission()
                self._log("Shutting down NexuIO Pro. Goodbye!", "SUCCESS")
                self.running = False
            else:
                print(f"{RED}Invalid choice.{RESET}")

        print(f"{BOLD}{GREEN}System terminated.{RESET}")


# ------------------------------------------------------------------
#  Entry point
# ------------------------------------------------------------------
if __name__ == "__main__":
    app = NexuIOCLI()
    app.run()
