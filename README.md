# 🩺 Skin Disease Detection & Analysis (Flutter)

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![AI/ML](https://img.shields.io/badge/Model-Trained_AI-orange?style=for-the-badge)

An AI-powered mobile application built with Flutter for early-stage skin disease detection. The system integrates a custom-trained machine learning model to analyze skin images and provide actionable health insights.

---

## 🌟 Key Features

- **Mandatory Authentication:** Secure entry via Supabase Auth; core features are locked until the user logs in.
- **AI Image Diagnosis:** Utilizes a custom-trained AI model to detect skin diseases from camera or gallery uploads.
- **Skin Type Assessment:** Interactive quiz to determine skin profiles (Oily, Dry, etc.) for personalized care.
- **Health Recommendations:** Automated "Do's and Don'ts" tailored to the identified skin condition.
- **Specialist Referral:** Integrated database to find and contact professional dermatologists.
- **Progress Tracking:** Securely stores scan history in Supabase for long-term monitoring.

## 🛠️ Tech Stack

- **Framework:** Flutter (Android/iOS)
- **Language:** Dart
- **Backend/Database:** [Supabase](https://supabase.com/) (Auth, Database, Storage)
- **AI Model:** Custom-Trained Image Classification Model
- **Integration:** API-based model inference (or TFLite if on-device)

## 📋 System Workflow

1. **Authentication:** User signs up or logs in via Supabase Auth.
2. **Data Acquisition:** User uploads a skin image or completes the skin assessment quiz.
3. **AI Inference:** The image is processed by the custom-trained AI model to identify specific diseases.
4. **Knowledge Mapping:** Results are matched with the database to retrieve relevant tips and specialist info.
5. **Report Generation:** A comprehensive diagnostic card is displayed to the user.

## 👥 The Team

### Project Members
| Name | Role |
| :--- | :--- |
| **Shah Tanzeem Afsar** | Lead Developer |
| **Samia Tabassum Hrity** | UI/UX & Documentation |
| **Nasrin Sultana** | Data Research & Analysis |

### Supervisor
- **Shahriar Arefin Zummon**
- Lecturer
- Department of CSE, **Leading University**

---

## 🚀 Getting Started

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/your-username/your-repo-name.git](https://github.com/your-username/your-repo-name.git)
