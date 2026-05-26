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

### 2. Error Control & Edge Case Testing

Rather than just testing in ideal conditions, we analyzed the network under physical fluctuations and edge cases. Wireshark successfully captured TCP's self-healing mechanisms in action:

* **Test Case 1: High Latency & Spurious Retransmission**
  * **Scenario:** The network experiences sudden high latency. The Server successfully receives the payload and sends an `[ACK]`, but it takes longer than the Client's Retransmission Timeout (RTO) to arrive.
  * **Wireshark Analysis:** Thinking the packet was lost, the Client resends the payload (flagged by Wireshark as **`[TCP Spurious Retransmission]`**). Upon receiving this redundant data, the Server immediately replies with a **`[TCP Dup ACK]`**, indicating exactly which sequence it has already successfully processed and requesting the next unseen data block.
<img width="2539" height="740" alt="Screenshot (547)" src="https://github.com/user-attachments/assets/8e9a3477-f543-402a-8bf6-9e272ce4a856" />

* **Test Case 2: Connection Timeout (Server Unreachable)**
  * **Scenario:** The Client attempts to initiate the 3-way handshake while the Server application is either not yet running or blocked by a firewall.
  * **Wireshark Analysis:** The Client sends the initial `[SYN]` packet but receives no `[SYN, ACK]` response. The Client's timer expires, triggering consecutive **`[TCP Retransmission]`** of the `[SYN]` packet to actively probe the destination until the Server comes online and the connection is successfully established.
<img width="2560" height="763" alt="Screenshot (510)" src="https://github.com/user-attachments/assets/5f93aa95-9199-4f6c-aa96-2889355d759d" />


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
while server.NumBytesAvailable < 1
    pause(0.1);
end
name_length = read(server, 1, "uint8"); 

while server.NumBytesAvailable < name_length
    pause(0.1);
end
received_filename = char(read(server, name_length, "uint8"));
```

---


## Results & Future Scope

* **Performance:** Achieved a 100% transmission success rate within the LAN environment with zero data corruption.
* **Flexibility:** Successfully transferred plain text (`.txt`), multimedia, and source code files by relying strictly on binary byte-stream transmission.
* **Future Improvements:** Transition from a single-threaded architecture to an asynchronous **Multi-threaded Server**.
  * Integrate payload encryption (AES) and Application-layer compression (GZIP) to optimize bandwidth.
  * Expand network simulation using tools like NS-3 to evaluate TCP Congestion Control algorithms (Reno, Cubic) under extreme jitter.
