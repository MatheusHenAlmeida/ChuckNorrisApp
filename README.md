# Chuck Norris App
This is a simple iOS/Swift appplication. Basicly, the user can click on a button and see a hilarious joke about the famous actor Chuck Norris.

## Technologies
1. Swift
2. iOS
3. Alamofire
4. Swinject
5. MockingBird

## Instructions
Follow the steps below to run the application:

#### Downloadind dependencies
```bash
pod install
```

#### Configure Mocks for unit testing
```bash
Pods/MockingbirdFramework/mockingbird configure ChuckNorrisAppTests -- --targets ChuckNorrisApp
```