# Privacy Policy for QuickNotes

**Last Updated:** October 8, 2026  
**Developer:** Ebram Wagdy  
**Contact Email:** wagdyebram78@gmail.com  
**Application:** QuickNotes (Android Package: `com.ebramwagdy.quicknotes`)

---

## 1. Introduction

Welcome to **QuickNotes** ("we", "our", or "the App"). We respect your privacy and are committed to protecting your personal data. 

QuickNotes is designed as an offline-first, privacy-respecting personal productivity app. We do **not** require you to create an account, register, or provide personal identity details to use the App.

This Privacy Policy explains what data QuickNotes accesses, how it is processed, and your rights regarding your data.

---

## 2. Core Architecture: Local-First Storage

- **On-Device Storage:** All your notes, checklists, subtasks, categories, voice notes, reminder times, and pinned items are stored locally on your device in a secure SQLite database (`quicknotes.db`) and local app storage.
- **No Private Servers:** We do not operate proprietary cloud servers to collect, harvest, monitor, or back up your personal notes.
- **Biometric Security:** If you protect notes using fingerprint or biometric lock, the authentication is processed entirely on-device by Android BiometricPrompt. No biometric data ever leaves your device hardware.

---

## 3. Device Permissions & How They Are Used

QuickNotes only requests permissions that are strictly necessary to deliver specific features initiated by you:

### 3.1 Camera (`android.permission.CAMERA`)
- **Purpose:** Allows you to take photos of printed or handwritten documents, receipts, or whiteboards for OCR (Optical Character Recognition) text extraction.
- **Processing:** Photos are captured only when you explicitly tap the camera scan button. Captured photos are used to extract text into your note and are not uploaded to background tracking servers.

### 3.2 Microphone & Audio (`android.permission.RECORD_AUDIO`)
- **Purpose:** Enables speech-to-text voice dictation to quickly transcribe your thoughts into note text, and allows recording voice memos.
- **Processing:** Audio recording activates only while you press or hold the record button. Transcription is handled via Android system speech recognition. We never record audio in the background or sell audio data.

### 3.3 Location (`ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`)
- **Purpose:** Optional geotagging. If you choose to attach your current location to a note, the App queries your device GPS coordinates once.
- **Processing:** Coordinates are saved locally with that specific note to display its pin on the in-app interactive map. Location is **never** tracked in the background and is never shared with third parties.

### 3.4 Exact Alarms & Full-Screen Ringing (`SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM`, `USE_FULL_SCREEN_INTENT`)
- **Purpose:** Provides a reliable Alarm Clock and reminder system for time-critical tasks, deadlines, and alarms.
- **Processing:** Exact alarm APIs ensure your alarms ring at the exact minute scheduled, even in battery-saving Doze mode. The full-screen intent allows the ringing alarm interface to wake the screen over the lock screen so you can immediately see the alarm label, snooze, or dismiss it.

---

## 4. Third-Party Services & Artificial Intelligence (AI)

### 4.1 Google Gemini Generative AI (Optional Features)
- **What is processed:** QuickNotes includes optional smart productivity features powered by the Google Gemini API (such as AI Note Summary, AI Categorical Tag Suggestions, Multimodal Image OCR, and Semantic Search).
- **When is data transmitted:** Data is transmitted to Google **only** when you explicitly trigger an AI action (e.g., clicking "Summarize with AI" or "Suggest Tags").
- **Security:** Communication with the Google Gemini API occurs over encrypted HTTPS connections. Data processed by Google Gemini is governed by [Google Privacy Policy](https://policies.google.com/privacy) and Google Cloud / API terms.
- **No Advertising Use:** Your note contents sent for AI inference are never sold, rented, or shared with third-party advertisers.

### 4.2 Map Tiles (OpenStreetMap)
- When viewing geotagged notes on the map screen, the App downloads standard map tile graphics from public OpenStreetMap tile servers over secure HTTPS. No personal note data is sent in map tile requests.

---

## 5. Data Retention, Control, and Deletion

You have complete and sovereign control over your data:

- **Individual Note Deletion:** You can move any note to Trash or permanently delete it at any time.
- **Delete All Data:** The App provides a built-in **"Delete All Notes"** option in the main menu, which immediately purges all notes, tasks, and attachments from the local database.
- **App Uninstall:** Because data is stored on-device, uninstalling QuickNotes from your Android device immediately and permanently deletes all local database files and application caches.
- **No Cloud Residue:** Because we do not store your notes on private servers, there is no remote copy to delete.

---

## 6. Children's Privacy

QuickNotes is not directed toward children under the age of 13. We do not knowingly collect or solicit personal information from children.

---

## 7. Changes to This Privacy Policy

We may update our Privacy Policy from time to time. Any changes will be posted in this document with an updated "Last Updated" date, and will be made available inside the App.

---

## 8. Contact Us

If you have any questions, feedback, or concerns regarding this Privacy Policy or your data, please contact:

- **Developer:** Ebram Wagdy
- **Email:** wagdyebram78@gmail.com
- **Repository:** https://github.com/ebramwagdy1/quicknotes
