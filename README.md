# 🔐 SecureText – Caesar Cipher Encryption & Decryption

A 16-bit Assembly Language Project for implementing classical cryptography using NASM and DOSBox.

---
## 📌 Project Description

SecureText is an assembly language-based cryptographic system that implements the **Caesar Cipher algorithm** for encryption and decryption.

The Caesar Cipher is a substitution technique where each character is shifted by a fixed number of positions in the alphabet. This project demonstrates how such logic is implemented at the machine level using x86 Assembly.

---

## ✨ Features

- 🔐 Caesar Cipher Encryption  
- 🔓 Caesar Cipher Decryption  
- 🔁 Brute Force Attack (all 25 shifts)  
- 📊 Character Statistics (uppercase, lowercase, digits, symbols)  
- 🧭 Menu-driven interface  
- ⚡ Step-by-step output display  
- 🚪 Clean exit system  

---

## 🛠️ Tools & Environment

- NASM Assembler (0.98.38)  
- DOSBox Emulator  
- Windows Operating System  
- VS Code / Notepad++

---

## ⚙️ How to Run

### 1️⃣ Assemble
```bash
nasm Cipher.asm -o Cipher.com
````

### 2️⃣ Run in DOSBox

```bash
Cipher.com
```

---

## 🧠 Concepts Used

* CPU Registers (AX, BX, CX, DX, SI, DI)
* Memory Segmentation (CS, DS, ES)
* Interrupts (INT 21h, INT 10h)
* Loops & Conditional Jumps
* Procedures (CALL / RET)
* Stack Operations
* ASCII Arithmetic

---

## 🔐 Caesar Cipher Formula

```
Encrypted = ((Character - 'A') + Shift) % 26 + 'A'
```

---

## 📌 Example

**Input:** PAKISTAN
**Shift:** 2
**Output:** RCMKUVCP

---

## 📊 Result

The system successfully performs:

* Encryption
* Decryption
* Brute-force analysis
* Character statistics

---

## 🚀 Conclusion

This project demonstrates low-level cryptographic implementation using Assembly Language and strengthens understanding of computer architecture and machine-level operations.

---
