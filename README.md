# Where2Buy (Mobile Client)

A crowdsourced mobile application where users can ask where to find a specific item, and other users can respond with locations and information.

Originally developed as a university project using pure PHP and Java (native Android), this version was rebuilt with Laravel as a REST API backend and a React-based web interface. The API is shared between the React web application and the Flutter mobile application.

This project consists of two applications:
- Laravel + React web application [https://github.com/heyitsmocha/where2buy-laravel]
- Flutter mobile application (this repository)

## Technical Features
- Architecture: Separation of UI and application logic using controller classes and mixins. Controllers extend `ChangeNotifier` to provide reactive state updates to the UI.
- State Management: Provider for tracking authentication status across the app
- REST API Integration: Retrofit and Dio to fetch and send data to the Laravel backend API
- Maps and Location: Google Maps integration for displaying, querying, and reporting item locations

## Demo
<details>
  <summary>Search UI</summary>

  https://github.com/user-attachments/assets/65eb4824-fbee-44f0-b56b-de0bc8ff2600
</details>
<details>
  <summary>Item Search</summary>

  https://github.com/user-attachments/assets/e816baab-7bd2-477a-8970-8b66710a914e
</details>
<details>
  <summary>Posting a New Inquiry</summary>
  
  https://github.com/user-attachments/assets/bc7830a9-bc38-43ca-b973-3846028b88f2
</details>
<details>
  <summary>Responding to an Inquiry</summary>
  
  https://github.com/user-attachments/assets/3c56da26-b21a-46ba-91b6-93d6f1609213
</details>
<details>
  <summary>View Responses</summary>
  
  https://github.com/user-attachments/assets/60379efb-3acf-4f07-aaa9-ea1da2cff1d3
</details>

## Prerequisites
Before getting started, make sure you have:
- Flutter SDK
- Android Studio or Visual Studio Code with the Flutter extension
- Android SDK

## Setup
1. Clone the repository:
    ```
    git clone https://github.com/heyitsmocha/where2buy-flutter
    cd where2buy-flutter
    ```
2. Install dependencies:
    ```
    flutter pub get
    ```
3. Configure environment variables:
    ```
    cp .env.example .env
    ```
    Open the newly created `.env` file and set `API_BASE_URL` to point to your backend.

4. Configure the Google Maps API key (Android):

    This project uses the Google Maps SDK for Android.
    
    1. Create a Google Maps API key in the Google Cloud Console.
    2. Enable **Maps SDK for Android**
    3. Add your API key to `android/local.properties`:
      ```properties
      #Existing properties...
      MAPS_API_KEY=your_api_key_here
      ```
  
    > **Note:** The Google Maps API key is not read from `.env`, it must be provided to the Android build through `local.properties`.

5. Enable **Developer options** and **USB Debugging** on your Android device, then run the app:
    ```
    flutter run
    ```
    > **Note:** Before running the app, make sure the backend server is running and accessible at the `API_BASE_URL` specified in your `.env` file.

## Platform Support
| Platform | Status |
|----------|--------|
| Android | ✅ Supported |
| iOS | ⚠️ Not configured/tested |
| Web | ⚠️ Not configured/tested |

Currently, only Android has been configured and tested. iOS and web support has not yet been implemented.
