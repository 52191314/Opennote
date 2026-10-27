# Opennote Privacy Policy

**Effective Date:** October 26, 2026  
**Application Name:** Opennote  
**Package Identifier:** `com.woaiyj1314.opennote`  
**Developer / Maintainer:** 52191314 / Opennote Open-Source Project  
**Contact:** [xianspired@gmail.com](mailto:xianspired@gmail.com)  
**Hosted Privacy Policy:** [https://52191314.github.io/Opennote/](https://52191314.github.io/Opennote/)  
**Source Code Repository:** [https://github.com/52191314/Opennote](https://github.com/52191314/Opennote)

---

## 1. Introduction

Opennote is a free and open-source handwritten note-taking and engineering diagram application. Opennote is built with a **local-first and privacy-first** architecture. We believe your handwriting, drawings, mathematical equations, and notes are strictly private. The application works entirely offline without requiring an account or internet connectivity.

This Privacy Policy explains how Opennote handles user data in compliance with Google Play Developer Policies, the General Data Protection Regulation (GDPR), and the California Consumer Privacy Act (CCPA).

---

## 2. Data We Process & Collect

Opennote accesses and processes only the minimum data required to deliver core digital notebook functionality:

| Data Type | Storage Location | Purpose | Shared Externally? |
| :--- | :--- | :--- | :--- |
| **Notes & Handwriting Strokes** | Local App Sandbox | Storing your handwriting vectors, drawings, shapes, and notes. | **No** (Never shared or uploaded without user configuration) |
| **Imported Images & PDFs** | Local App Directory | Rendering imported images or documents inside notes for annotation. | **No** |
| **Application Preferences** | Local SharedPreferences | Saving tool preferences, theme settings, grid styles, and pen presets. | **No** |
| **Cloud Credentials (Optional)** | Android Secure Keystore | Server URL, username, and app password for Nextcloud / WebDAV sync. | **No** (Stored in hardware-backed secure storage) |

Opennote does **not** collect or sell any personal information, location data, biometric data, contacts, or financial information.

---

## 3. Device Permissions & Scopes

Opennote requests minimal runtime permissions strictly aligned with user-initiated actions:

- `android.permission.INTERNET`: Used only when the user voluntarily connects to a self-hosted or third-party Nextcloud / WebDAV server for cloud synchronization, or for opt-in error diagnostics.
- `android.permission.READ_EXTERNAL_STORAGE` / `android.permission.WRITE_EXTERNAL_STORAGE`: Used solely for user-directed file importing (e.g. importing PDF documents or background images) and note exporting (saving notes as PDF, PNG, or `.sbn` backup files). Opennote never scans, indexes, or reads files outside what the user explicitly chooses.
- **Scoped Storage**: On Android 11+ (API 30+), Opennote strictly follows the Android Storage Access Framework (SAF). Broad media permissions (`READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`, `READ_MEDIA_AUDIO`) are explicitly excluded.

---

## 4. Optional Cloud Synchronization (Zero-Knowledge Encryption)

Cloud synchronization is 100% optional. The app functions completely without it.

If you choose to sync your notes using a Nextcloud or WebDAV server:
1. **Client-Side Encryption:** All notes, images, and backgrounds are encrypted on your local device before transmission using strong AES encryption.
2. **Key Storage:** The encryption key is randomly generated on your device and stored in the Android Secure Keystore (`flutter_secure_storage`).
3. **Zero-Knowledge:** The remote server host or administrator cannot decrypt or read your notes. Only encrypted ciphertext is stored on the server.

---

## 5. Crash Reporting & Diagnostics (Sentry)

To ensure application stability across diverse Android hardware:
- Crash reporting is **disabled by default** in Opennote.
- Error reporting is **strictly opt-in**. No crash logs or diagnostics are transmitted without explicit consent granted in the application settings.
- If consented to, telemetry includes only anonymized technical details: Android OS version, device architecture, app version, and exception call stacks.
- **Never Collected:** Personal identity, email addresses, note contents, handwriting vectors, passwords, encryption keys, or advertising identifiers (Google Advertising ID).

---

## 6. Advertisements & Tracking

Opennote is **100% ad-free**. There are no third-party advertisements, advertising tracking SDKs, data brokers, or marketing analytics in the application.

---

## 7. Data Retention & Deletion (Google Play Compliance)

Users maintain total control over their data:

1. **Local Data Deletion:**
   - You can delete any note, folder, or notebook inside the app at any time.
   - To delete all app data, go to Android **Settings > Apps > Opennote > Storage > Clear Storage**, or uninstall the application. All sandboxed data will be permanently wiped.
2. **Cloud Data Deletion:**
   - Deleting a note inside the app marks it for deletion on your connected Nextcloud server during the next sync.
   - You can also log into your Nextcloud web portal to directly delete your synchronized files or close your account.
3. **Assistance & Requests:**
   - For any questions regarding data deletion, contact us at [xianspired@gmail.com](mailto:xianspired@gmail.com).

---

## 8. Children's Privacy (COPPA Compliance)

Opennote is a general productivity application not directed towards children under 13 years of age (or under 16 in the European Union). Because Opennote does not collect personal data, we do not knowingly collect or solicit personal information from children. If you believe a minor has contacted us with personal data, please contact [xianspired@gmail.com](mailto:xianspired@gmail.com) for prompt removal.

---

## 9. Security Safeguards

We implement industry-standard safeguards to secure your data:
- Sandboxed operating system directory access on Android.
- Android Keystore cryptographic key protection.
- TLS 1.3 / HTTPS encryption in transit for all network requests.
- Public, peer-reviewed open-source codebase under the GNU General Public License v3.0 (GPLv3).

---

## 10. User Rights (GDPR & CCPA)

Under GDPR and CCPA, you have the right to:
- Access, view, and export all your data in open, non-proprietary formats (PDF, PNG, JSON/SBN).
- Rectify or modify your data.
- Request complete deletion ("right to be forgotten").
- Revoke diagnostic consent at any time in the app settings.

---

## 11. Point of Contact

If you have questions regarding this Privacy Policy or Opennote data practices, please reach out to:

- **Maintainer:** 52191314 / Opennote Team
- **Email:** [xianspired@gmail.com](mailto:xianspired@gmail.com)
- **Repository:** [https://github.com/52191314/Opennote](https://github.com/52191314/Opennote)
- **Issues:** [https://github.com/52191314/Opennote/issues](https://github.com/52191314/Opennote/issues)
