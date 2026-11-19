# Security Policy

## 🛡️ Supported Versions

Calculator is actively maintained. Security patches and updates are provided for the following releases:

| Version | Supported |
|:---|:---|
| 1.0.x (Latest Git) | ✅ Yes |
| < 1.0.0 | ❌ No |

---

## 🔒 Security Architecture & Threat Model

Calculator is designed with an **adversarial, zero-trust, offline-first** security model:

1. **Zero Cloud Network Surface**: The application contains no backend APIs, no cloud synchronization servers, and no remote endpoints. Network exfiltration is architecturally impossible.
2. **Zero Telemetry or Analytics**: No user tracking, analytics packages, or third-party ad networks exist in the codebase.
3. **AST Parser Isolation**: The mathematical expression engine uses a structured lexer/parser pipeline with typed error handling. It does not use `eval()`, JavaScript bridges, or shell execution. Malformed or pathological inputs are caught and presented as safe error chips without stack trace leakage.
4. **Local Data Sovereign**: Calculation history and user preferences are persisted exclusively to local Hive binary storage (`kreate_history_box_v2`). Data never leaves the host device.
5. **No Dangerous Permissions**: The application requests zero sensitive operating system permissions (no location, no camera, no microphone, no contacts, no background services).

---

## 🚨 Reporting a Vulnerability

If you discover a security vulnerability or mathematical parsing exploit within Calculator:

1. **Do not open a public GitHub issue.**
2. Send an email to the project maintainers with a detailed description of the issue, reproduction steps, and proof-of-concept input.
3. We will acknowledge receipt within 48 hours and work on a prompt patch.
4. A public security advisory and fix will be released in the subsequent Git tag release.
