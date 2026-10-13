# PacketSentinel
### Low-Level Network Packet Inspection & Protocol Analysis

Monitor packet streams captured with **Wireshark**, analyse the **TCP three-way handshake**, rebuild
individual TCP streams, and automatically flag **clear-text authentication exposure (FTP, HTTP, Telnet, POP3, IMAP)**
and **data-exfiltration behaviour** (bulk uploads, DNS tunnelling, ICMP tunnelling, C2 beaconing) plus
reconnaissance (SYN / NULL / Xmas scans).

* Pure Python standard library - **no dependencies**, works on Windows, Linux and macOS
* Reads **.pcap and .pcapng** (Wireshark's default format), Ethernet / VLAN / loopback / Linux-cooked
* Outputs: console report, **HTML**, **JSON**, **CSV**
* CLI + simple **GUI**, and a one-command **.exe build**
* Built-in **threat-simulation generator** + **live lab** (insecure FTP/Telnet/HTTP) for practising with Wireshark
* Passwords are **masked by default** in every report

> **Legal / ethical use:** capture and analyse only networks and systems you own or have written permission to test.
> The lab services are intentionally insecure - run them on `127.0.0.1` or an isolated VM only.

---

## 1. Project layout

```
PacketSentinel/
├── main.py                    CLI entry point  (no arguments = opens the GUI)
├── gui_main.py                GUI entry point (used for PacketSentinel-GUI.exe)
├── build_exe.bat              Build PacketSentinel.exe + PacketSentinel-GUI.exe  (Windows)
├── build_exe.sh               Build a native binary on Linux/macOS
├── run_demo.bat / run_demo.sh One-click demo: simulate -> analyze -> HTML report
├── requirements.txt           (only pyinstaller, needed for the .exe build)
├── packetsentinel/
│   ├── pcap_reader.py         pcap + pcapng readers
│   ├── decoder.py             Ethernet/IP/TCP/UDP/ICMP + DNS decoding
│   ├── streams.py             flow table, handshake state machine, stream reassembly
│   ├── detectors.py           all security detections
│   ├── analyzer.py            pipeline + statistics
│   ├── report.py              text / HTML / JSON / CSV reports
│   ├── simulate.py            threat-simulation capture generator
│   ├── config.py              thresholds and options
│   ├── cli.py, gui.py
├── lab/lab_server.py          insecure FTP / Telnet / HTTP services for live capture
├── lab/lab_client.py          generates login, upload and scan traffic
├── samples/                   threat_simulation.pcap and .pcapng (ready to open in Wireshark)
├── reports/                   example HTML / JSON / CSV output
├── docs/                      USAGE, WIRESHARK_GUIDE, METHODOLOGY, PROJECT_REPORT_TEMPLATE
└── tests/test_packetsentinel.py
```

## 2. Quick start (2 minutes)

Requires **Python 3.8+** (python.org, tick *Add Python to PATH*).

```bash
# Windows (double-click run_demo.bat) or:
python main.py demo
```

This creates `samples/threat_simulation.pcap`, analyses it, prints the report and writes
`reports/threat_simulation_report.html` (open it in a browser).

Other commands:

```bash
python main.py simulate --out samples/threat_simulation.pcap     # only write the capture
python main.py analyze  samples/threat_simulation.pcap            # analyse any pcap/pcapng
python main.py analyze  mycapture.pcapng --min-severity HIGH --show-secrets
python main.py gui                                                # graphical interface
python -m unittest discover -s tests -v                           # run the tests
```

## 3. Build the .exe (Windows)

```bat
build_exe.bat
```

Creates in `dist\`:

| File | Purpose |
|------|---------|
| `PacketSentinel.exe` | command-line tool (`PacketSentinel.exe analyze file.pcapng`, double-click opens the GUI) |
| `PacketSentinel-GUI.exe` | window-only version, no console |

A Windows `.exe` can only be produced on Windows (PyInstaller does not cross-compile), which is why the build
script is provided instead of a pre-built binary.

## 4. What it detects

| Category | Detection | Severity | MITRE ATT&CK |
|----------|-----------|----------|--------------|
| Clear-text credentials | FTP `USER/PASS`, HTTP Basic auth, HTTP login forms (`password=`), Telnet, POP3, IMAP `LOGIN`, secrets on odd ports | CRITICAL / HIGH | T1040, T1552 |
| Unencrypted protocols | HTTP / FTP / Telnet / POP3 / IMAP usage summary | LOW-HIGH | T1040 |
| Reconnaissance | SYN port scan, network sweep, NULL / FIN / Xmas scans, SYN flood | HIGH / MEDIUM | T1046, T1498 |
| Exfiltration | large asymmetric upload to external host, FTP `STOR`, big HTTP POST, DNS tunnelling, ICMP tunnelling | CRITICAL / HIGH | T1048, T1041, T1071.004, T1095 |
| Command & control | periodic beaconing to an external host | MEDIUM | T1071, T1573 |

Plus a full **TCP handshake report**: ESTABLISHED / CLOSED / RESET / REFUSED / SYN_ONLY / HALF_OPEN / MIDSTREAM
flows and SYN->SYN-ACK round-trip time.

## 5. Live workflow with Wireshark

1. `python lab/lab_server.py` (terminal 1)
2. Start Wireshark on the loopback adapter (Windows needs **Npcap** with loopback support) - see `docs/WIRESHARK_GUIDE.md`
3. `python lab/lab_client.py` (terminal 2)
4. Stop capture, **File -> Save As -> .pcapng**
5. `python main.py analyze lab_capture.pcapng` (in a private-IP VM lab add `--external-host <server-ip>` so uploads count as exfiltration)
6. Compare the report with Wireshark filters from the guide (e.g. `ftp.request.command == "PASS"`).

## 6. Documentation

* `docs/USAGE.md` - every option, GUI walkthrough, output files, troubleshooting
* `docs/WIRESHARK_GUIDE.md` - capture steps, display filters, Follow TCP Stream, handshake analysis, tshark one-liners
* `docs/METHODOLOGY.md` - how each detection works, thresholds, false positives, remediation
* `docs/PROJECT_REPORT_TEMPLATE.md` - ready-to-fill report for submission

## 7. Limitations

* IPv4/IPv6 TCP/UDP/ICMP only; no TLS decryption (encrypted traffic is judged by volume and timing only)
* IP fragments are ignored; very out-of-order or lossy captures may reduce reassembly accuracy
* Heuristics can raise false positives (CDN-style DNS names, backup jobs, monitoring beacons) - tune thresholds
* Whole stream payload is kept up to 512 KB per direction per flow (configurable in `config.py`)
