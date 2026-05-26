# LAN File Transfer Application & Network Traffic Analysis via Wireshark

Final Project — **Data Communications** | Faculty of Electronics and Telecommunications, University of Science (VNU-HCM)

This project successfully implemented a **Client-Server** system on the **MATLAB** platform for transferring multi-format files within a Local Area Network (LAN) using the **TCP/IP** protocol. In addition, **Wireshark** was utilized to monitor, capture and perform in-depth analysis of packet structures at both the Transport Layer and Network Layer.

---

## Team Members (Group 8 - Class 23DTV_CLC1)

* **Tran Thanh Thinh** (Team Leader) — *Main responsibilities:* System architecture design, Socket programming in MATLAB, Wireshark packet configuration and analysis, technical report compilation.
* **Nguyen Phuoc Dang Minh** — *Main responsibilities:* Content editing (PowerPoint + Word) and Wireshark testing execution.
* **Nguyen Van Dat** — *Main responsibilities:* Presentation, Wireshark testing support and PowerPoint report interface design.

---
## System Architecture & Protocol Design

To prevent packet fragmentation and "sticky packets" common in continuous TCP streams, we engineered a **Custom Application Layer Protocol**:

1. **Header (1 byte):** Defines the length of the filename string.
2. **Filename (Variable bytes):** The exact string of the file being sent.
3. **Payload:** The raw binary stream of the file (chunked into 5MB segments to prevent buffer overflow).

The system utilizes a sequential Client-Server model where the **Client** initiates the TCP socket, processes the file into binary chunks, and transmits them, while the **Server** continuously listens on port `5001`, parses the custom header, and reconstructs the byte stream directly into local storage.

---
## Wireshark Network Analysis (Key Highlights)

The core value of this project lies in the empirical validation of the TCP/IP protocol suite using Wireshark.

### 1. The 3-Way Handshake (Connection Establishment)
We successfully captured the strict connection initiation sequence:
* `[SYN]` - Client requests a new connection.
* `[SYN, ACK]` - Server acknowledges and accepts.
* `[ACK]` - Client confirms, establishing a reliable socket.
<img width="891" height="478" alt="image" src="https://github.com/user-attachments/assets/fc9d1fd4-affb-4f86-be2e-d31519b6793d" />

### 2. Error Control & Reliability Testing
Rather than just testing in ideal conditions, we analyzed the network under physical fluctuations. Wireshark successfully captured TCP's self-healing mechanisms:
* **In-order Delivery:** Sequence Numbers incrementing linearly alongside exact `ACK` responses.
* **Fault Tolerance:** Captured `TCP Dup ACK` and `TCP Retransmission` flags, proving the protocol's ability to automatically detect packet loss and retransmit missing payloads without corrupting the final file.
<img width="2539" height="740" alt="Screenshot (547)" src="https://github.com/user-attachments/assets/8e9a3477-f543-402a-8bf6-9e272ce4a856" />

<img width="2560" height="745" alt="Screenshot (540)" src="https://github.com/user-attachments/assets/a6ddfed7-5171-4c80-83b1-ce7bd3447189" />

## Core Implementation Snippets (MATLAB)

**Client-side Chunking Algorithm:**
```matlab
% Limit chunk size to 5MB to optimize network buffer
chunkSize = 5242880; 
for i = 1:chunkSize:totalBytes
    endIdx = min(i + chunkSize - 1, totalBytes);
    write(t, FileData(i:endIdx)); % Push binary stream to TCP socket
end
```
**Server-side Header Parsing:**
```matlab
% Parse custom header to extract filename length before reading payload
while server.NumBytesAvailable < 1, pause(0.1); end
name_length = read(server, 1, "uint8"); 

while server.NumBytesAvailable < name_length, pause(0.1); end
received_filename = char(read(server, name_length, "uint8"));
