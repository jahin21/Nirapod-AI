# Nirapod AI

Nirapod AI is a mobile cybersecurity application I developed to help users identify common digital threats such as phishing URLs and scam messages.

The application uses Flutter for the mobile interface, a Python FastAPI backend deployed on Render, and Supabase for database and cloud services.

## Features

- Phishing URL detection using a Random Forest model
- Scam message detection using TF-IDF and machine learning
- Cybersecurity risk assessment
- Detection history
- Responsive Flutter interface
- Cloud-based data storage using Supabase
- REST API backend deployed on Render

## Technology Stack

| Component | Technology |
|-----------|------------|
| Mobile App | Flutter / Dart |
| Backend | Python / FastAPI |
| Backend Hosting | Render |
| Database | Supabase |
| URL Detection | Random Forest |
| Message Detection | TF-IDF + Machine Learning |
| API | REST API |
| Development | Android Studio |

## System Architecture

```text
Flutter Mobile App
        |
        | REST API
        v
FastAPI Backend
     (Render)
        |
        +--- URL Detection
        |       |
        |       +--- Random Forest
        |
        +--- Message Detection
        |       |
        |       +--- TF-IDF + Machine Learning
        |
        v
   Supabase
   Database
