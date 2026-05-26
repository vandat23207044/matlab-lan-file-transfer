# LAN File Transfer Application & Network Traffic Analysis via Wireshark

Final Project — **Data Communications** | Faculty of Electronics and Telecommunications, University of Science (VNU-HCM)

This project successfully implemented a **Client-Server** system on the **MATLAB** platform for transferring multi-format files within a Local Area Network (LAN) using the **TCP/IP** protocol. In addition, **Wireshark** was utilized to monitor, capture and perform in-depth analysis of packet structures at both the Transport Layer and Network Layer.

---

## Team Members (Group 8 - Class 23DTV_CLC1)

* **Tran Thanh Thinh** (Team Leader) — *Main responsibilities:* System architecture design, Socket programming in MATLAB, Wireshark packet configuration and analysis, technical report compilation.
* **Nguyen Phuoc Dang Minh** — *Main responsibilities:* Content editing (PowerPoint + Word) and Wireshark testing execution.
* **Nguyen Van Dat** — *Main responsibilities:* Presentation, Wireshark testing support and PowerPoint report interface design.

---
## 🏗️ System Architecture & Protocol Design

To prevent packet fragmentation and "sticky packets" common in continuous TCP streams, we engineered a **Custom Application Layer Protocol**:

1. **Header (1 byte):** Defines the length of the filename string.
2. **Filename (Variable bytes):** The exact string of the file being sent.
3. **Payload:** The raw binary stream of the file (chunked into 5MB segments to prevent buffer overflow).

The system utilizes a sequential Client-Server model where the **Client** initiates the TCP socket, processes the file into binary chunks, and transmits them, while the **Server** continuously listens on port `5001`, parses the custom header, and reconstructs the byte stream directly into local storage.

---
## 🔍 Wireshark Network Analysis (Key Highlights)

The core value of this project lies in the empirical validation of the TCP/IP protocol suite using Wireshark.

### 1. The 3-Way Handshake (Connection Establishment)
We successfully captured the strict connection initiation sequence:
* `[SYN]` - Client requests a new connection.
* `[SYN, ACK]` - Server acknowledges and accepts.
* `[ACK]` - Client confirms, establishing a reliable socket.
<img width="975" height="548" alt="image" src="https://github.com/user-attachments/assets/1c13828a-5ba2-4f66-bd50-d273c72abbf7" />
