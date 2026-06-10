# ⚙ EverGear 

EverGear is a mobile marketplace designed to address the electronic waste crisis by connecting broken gadget owners with independent technicians. Instead of letting dead devices sit in drawers or end up in landfills, technicians use EverGear to source devices, search for functional original components (like OEM LCDs, batteries, back covers, and camera modules), and resell them back into the marketplace.

---

## 🛠️ Tech Stack

| Layer | Technology |
| :--- | :--- |
| **Mobile App** | Flutter (Dart) |
| **Backend REST API** | Python (FastAPI + SQLAlchemy) |
| **State / Storage** | `shared_preferences` |
| **UI & Aesthetics** | Material Design 3, Google Fonts (Poppins), Eco-Stats Tracking |

---

## 🚀 Getting Started

### Prerequisites
Make sure your development environment has the following installed before running from source:
* Flutter SDK `>=3.0.0 <4.0.0`
* Android Studio with a **Pixel 7 (API 34 "UpsideDownCake")** virtual device configured
* Python 3.10+ for the FastAPI backend
* `pip` or a virtual environment manager (`venv`)

---

## 📦 Installation & Deployment Options

### Option A — Install via APK (Recommended for Quick Demos)
If you just want to run the compiled app directly on your emulator without building the frontend tracking lines every time:

1. Open Android Studio and launch your **Pixel 7** emulator from the **Device Manager**.
2. Once the emulator boots to its home screen, drag and drop the `evergear.apk` file directly onto the emulator screen. It will install automatically.

> ⚠️ **Important Troubleshooting Note (Signature Mismatch):**
> If you encounter the `INSTALL_FAILED_UPDATE_INCOMPATIBLE` error, it means an older debug version of the app is already installed on the emulator. Long-press the existing EverGear app icon on the emulator, select **Uninstall**, and then drag-and-drop the new `.apk` file again.

---

### Option B — Run from Source (Full Development Stack)

#### 1. Clone the Repository
```Bash
git clone https://github.com/devin210606-arch/evergear-app.git
cd evergear-app
```

#### 2. Install Frontend Dependencies
```Bash
flutter pub get
```

#### 3. Launch the FastAPI Backend Server
Open a dedicated terminal window, navigate to your backend folder, activate your virtual environment, and fire up Uvicorn:
```Bash
cd evergear_backend
source venv\Scripts\activate  # On Mac use: venv/bin/activate  
pip install -r requirements.txt
uvicorn main:app --reload
````
> The backend local server will run on http://127.0.0.1:8000. Ensure your Flutter service layer maps requests to 10.0.2.2:8000 so the Android emulator can bridge to your local machine.

#### 4. Compile and Run the App
1. Open Android Studio, select File → Open, and pick the root evergear-app directory.
2. From the device dropdown list in the top toolbar, select Pixel 7 (mobile).
3. Click the green Run button (▶) to deploy.
