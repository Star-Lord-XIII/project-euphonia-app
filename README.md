# Project Euphonia App

This repository provides an open-source toolkit to build personalized speech recognition solutions, stemming from the broader [Project Euphonia](https://sites.research.google/euphonia/about/) initiative started by Google in 2019. This specific iteration focuses on enabling improved speech-to-text transcription, particularly for individuals with non-standard speech.

## Intended Use

Project Euphonia App is a set of open-source toolkits intended for use by developers to create and customize speech recognition solutions. It provides tools and documentation for collecting speech data, fine-tuning open-source Automatic Speech Recognition (ASR) models, and deploying those models for speech-to-text transcription.The open-source toolkits, in its original form, is not intended to be used without modification for the diagnosis, treatment, mitigation, or prevention of any disease or medical condition. Developers are solely responsible for making substantial changes to Project Euphonia’s open-source toolkits and for ensuring that any applications they create comply with all applicable laws and regulations, including those related to medical devices.

### Indications for Use

Project Euphonia’s open-source toolkits is intended to provide developers with the capability to:

- Collect volunteered speech data using a customizable mobile application.
- Fine-tune open-source Automatic Speech Recognition (ASR) models using provided training recipes and infrastructure.
- Deploy trained ASR models for speech-to-text transcription.
- Create accessibility solutions and other applications that leverage customized speech recognition technology.

### Toolkit Description

Project Euphonia’s open-source toolkits are designed to facilitate the creation of customized speech recognition solutions. The toolkits consists of:

- A **Flutter-based mobile application** for recording speech data and associating it with text phrases. The application stores data in a Firebase Storage instance controlled by the developer.
- **Google Colab notebooks** providing example code and documentation for fine-tuning open-source Automatic Speech Recognition (ASR) models. The notebooks will help inform developers on the following topics: data preparation, model training, and performance evaluation.
- Example code for deploying a **web service** that performs speech-to-text transcription using the fine-tuned ASR models. The web service can be deployed to cloud platforms such as Google Cloud Run.

## Setup

Clone the repository:

```bash
git clone https://github.com/google/project-euphonia-app
cd project-euphonia-app
```

### Flutter-based mobile application

This component consists of a **Flutter-based mobile application**. The application consists on 2 main section:

- a section that allows users to record their voice saying specific phrases.
- a section to capture capture user speech and transcript into text relying on the trained model.

The application comes with a set of 100 default phrases located under `assets/phrases.txt`. You can customize or add more phrases. You can, for example, create training phrases for different languages.

Please create a list of 100 short English phrases such that they have good distribution of all phonemes and their allophones, try to keep the length of each phrase less than 140. Please make sure none of the words in the list are repeated more than thrice. All the phrases don't need to be a valid sentence either, the important task is to ensure coverage over all phonemes and maintain a good distribution of allophones. Please don't add numbering at the beginning of the list.

The recorded speech data is stored in a **Firebase Storage** instance created and controlled by you.

#### Prerequisites

The application requires a [Firebase Storage](https://firebase.google.com/docs/storage). Please follow the following steps:

- Create a project from the [Firebase console](https://console.firebase.google.com/)
- [Create firebase storage](https://firebase.google.com/docs/storage/web/start) (Note: not "database", it needs to be "storage").
- Configure security rules as public. NOTE: This makes your files accessible by anyone. Consider adding autentication to secure your data.

Install the following packages: [curl](https://curl.se/), [unzip](https://linux.die.net/man/1/unzip), [xz-utils](https://xz.tukaani.org/xz-utils/), [zip](https://linux.die.net/man/1/zip), [libglu1-mesa](https://packages.debian.org/buster/libglu1-mesa).

Install [Android Studio](https://developer.android.com/studio/install) 2023.3.1 (Jellyfish) or later to debug and compile Java or Kotlin code for Android. Flutter requires the full version of Android Studio.

Install the [Flutter SDK](https://docs.flutter.dev/get-started/install). When you run the current version of `flutter doctor`, it might list a different version of one of these packages. If it does, install the version it recommends.

### Installation

- Run `firebase login`
- Run `dart pub global activate flutterfire_cli`
- Configure Flutter project running `flutterfire configure --project=<project-id>`

For Android app use Android studio or run `flutter build apk` and `build/app/outputs/flutter-apk/app-release.apk` to install the app on the phone.
For iOS: Run `cd ios` and `run pod install`. Make sure mobile-provisioning profiles are present to install the app on-device.

### Train model

This component consists in an Google Colab notebook to run the training. The Notebook will train ASR opensource model to racognize the speech of the user that recorded the training phrases.

Open the notebook in the [training_colabs](https://github.com/google/project-euphonia-app/tree/main/training_colabs) and follow the steps.

### Web service that performs speech-to-text

This component consist on a simple web application to serve the model trained in the previous step. The app is contenerized and can be run in Google Cloud Run.

#### Deploy

Copy the trained model (e.g. `pytorch_model.bin`) into the `api/custom_tiny_whisper_model/` folder. Place custom tiny whisper model in the custom_tiny_whisper_model directory as pytorch_model.bin.

Deploy the web app into Google Cloud Run following steps reported in the [app README](api/).

## Usege

Following all [Setup](#setup) steps you installed the Euphonia App on your smarphone and the api on Goocle Cloud Run. You can now set the URL of the Google Cloud Run instance in the app configuration and start transcribing your speech.
