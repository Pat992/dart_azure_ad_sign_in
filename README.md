# Dart package for Azure AD Sign In

<div>
<a href="https://pub.dev/packages/dart_azure_ad_sign_in"><img src="https://img.shields.io/pub/v/dart_azure_ad_sign_in.svg" alt="Pub"></a>
<img alt="GitHub Workflow Status (branch)" src="https://shields.mitmproxy.org/github/workflow/status/Pat992/dart_azure_ad_sign_in/Dart%20Tests/main">
<a href="https://github.com/Pat992/dart_azure_ad_sign_in"><img src="https://img.shields.io/github/stars/Pat992/dart_azure_ad_sign_in?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>
<a href="https://opensource.org/licenses/BSD-3-Clause"><img src="https://img.shields.io/static/v1?label=license&message=BSD 3-Clause&color=blue" alt="License: BSD 3-Clause"></a>
</div>

## Table of content
- [1 Platform Support](#1-platform-support)
- [2 Features](#2-features)
- [3 Authentication Flow](#3-authentication-flow)
- [4 Getting started](#4-getting-started)
  - [4.1 Installation](#41-installation)
  - [4.2 Import](#42-import)
  - [4.3 Android Settings](#43-android-settings)
    - [4.3.1 Networking](#431-networking)
    - [4.3.2 Cleartext traffic](#432-cleartext-traffic)
  - [4.4 iOS Settings](#44-ios-settings)
    - [4.4.1 Networking](#441-networking)
    - [4.4.2 Cleartext traffic](#442-cleartext-traffic)
  - [4.5 macOS Settings](#45-macos-settings)
    - [4.5.1 Networking](#451-networking)
    - [4.5.2 Cleartext traffic](#452-cleartext-traffic)
  - [4.6 Windows Settings](#46-windows-settings)
  - [4.7 Linux Settings](#47-linux-settings)
- [5 Usage](#5-usage)
  - [5.1 AzureSignIn instance creation and configuration](#51-azuresignin-instance-creation-and-configuration)
    - [5.1.1 Creating an instance without parameters (using az cli default settings) ](#511-creating-an-instance-without-parameters-using-az-cli-default-settings-)
    - [5.1.2 Creating an instance with parameters](#512-creating-an-instance-with-parameters)
  - [5.2 Sign In](#52-sign-in)
    - [5.2.1 Get the Microsoft Sign-In page URL](#521-get-the-microsoft-sign-in-page-url)
    - [5.2.2 Start the Sign In process](#522-start-the-sign-in-process)
  - [5.3 Cancel the Sign In process](#53-cancel-the-sign-in-process)
  - [5.4 Refresh a Token](#54-refresh-a-token)
    - [5.4.1 Refresh Token with an existing `Token`](#541-refresh-token-with-an-existing-token)
    - [5.4.2 Refresh Token with the Refresh-Token String](#542-refresh-token-with-the-refresh-token-string)
  - [5.5 AzureSignIn Variables](#55-azuresignin-variables)
  - [5.6. The Token-Entity](#56-the-token-entity)
- [6 Where to go from here](#6-where-to-go-from-here)
- [7 Bugs and issues](#7-bugs-and-issues)

## 1 Platform Support
|         | Dart                     | Flutter                  | Dart - Tested on                                | Flutter - Tested on                             |
| ------- | ------------------------ | ------------------------ | ----------------------------------------------- | ----------------------------------------------- |
| Android | :heavy_multiplication_x: | :heavy_check_mark:       | -                                               | Tested on Pixel 4 (Emulator) and Xiaomi 9T.     |
| iOS     | :heavy_multiplication_x: | :heavy_minus_sign:       | -                                               | Not yet tested, but should work.                |
| Linux   | :heavy_check_mark:       | :heavy_check_mark:       | Tested on Ubuntu 22.04 LTS.                     | Tested on Ubuntu 22.04 LTS.                     |
| MacOS   | :heavy_minus_sign:       | :heavy_minus_sign:       | Not yet tested, but should work.                | Not yet tested, but should work.                |
| Web     | :heavy_multiplication_x: | :heavy_multiplication_x: | Uses dart.io for the HttpServer, will not work. | Uses dart.io for the HttpServer, will not work. |
| Windows | :heavy_check_mark:       | :heavy_check_mark:       | Tested on Windows 11.                           | Tested on Windows 11.                           |

## 2 Features
**dart_azure_ad_sign_in** allows Flutter and Dart apps to obtain authentication tokens for authorized access to protected resources like Azure web APIs.
The package can simply be used without any configuration to gain the same access you would have with the **[az cli](https://learn.microsoft.com/en-us/cli/azure/)**, or it can be configurated to modify the access.

## 3 Authentication Flow
![SignIn Wokrflow](https://raw.githubusercontent.com/Pat992/readme-images/main/dart_azure_ad_sign_in/workflow.png)


## 4 Getting started

### 4.1 Installation
Add the dependency to the pubspec.yaml for Dart and Flutter
```yaml
dependencies:
  dart_azure_ad_sign_in: ^1.0.0
```
Or Run this command with Dart:
```powershell
dart pub add dart_azure_ad_sign_in
```
With Flutter:
```powershell
flutter pub add dart_azure_ad_sign_in
```

### 4.2 Import
Import the package:
```dart
import 'package:dart_azure_ad_sign_in/dart_azure_ad_sign_in.dart';
```

### 4.3 Android Settings

#### 4.3.1 Networking
As this app uses the internet, networking needs to be enabled in the `AndroidManifest.xml`.
```xml
<manifest xmlns:android...>
  ...
  <uses-permission android:name="android.permission.INTERNET" />
  <application ...
</manifest>
```

#### 4.3.2 Cleartext traffic
This app will open a local HTTP Server, which accepts cleartext traffic, allowing an insecure connection to only the localhost by creating `res/xml/network_security_config.xml` and configuring it as follows.
```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">localhost</domain>
    </domain-config>
</network-security-config>
```
Then load the file into your `AndroidManifest.xml`.
```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest ...>
    <application
        ...
        android:networkSecurityConfig="@xml/network_security_config"
        ...>
        ...
    </application>
</manifest>

```

### 4.4 iOS Settings

#### 4.4.1 Networking
Not necessary for iOS.

#### 4.4.2 Cleartext traffic
This app will open a local HTTP Server, which accepts cleartext traffic, allowing an insecure connection to only the localhost by creating a specific rule as following `info.plist`.
```xml
<key>NSAppTransportSecurity</key>
<dict>
      <key>NSAllowsArbitraryLoads</key> 
      <false/>
       <key>NSExceptionDomains</key>
       <dict>
            <key>localhost</key>
            <dict>
                <key>NSIncludesSubdomains</key>
                <true/>
                <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
                <true/>
                <key>NSTemporaryExceptionMinimumTLSVersion</key>
                <string>TLSv1.1</string>
            </dict>
       </dict>
</dict>

```

### 4.5 macOS Settings

#### 4.5.1 Networking
As this app uses the internet, networking needs to be enabled in the `.entitlements`.
```xml
<key>com.apple.security.network.client</key>
<true/>
```
#### 4.5.2 Cleartext traffic
This app will open a local HTTP Server, which accepts cleartext traffic, allowing an insecure connection to only the localhost by creating a specific rule as following `info.plist`.
```xml
<key>NSAppTransportSecurity</key>
<dict>
      <key>NSAllowsArbitraryLoads</key> 
      <false/>
       <key>NSExceptionDomains</key>
       <dict>
            <key>localhost</key>
            <dict>
                <key>NSIncludesSubdomains</key>
                <true/>
                <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
                <true/>
                <key>NSTemporaryExceptionMinimumTLSVersion</key>
                <string>TLSv1.1</string>
            </dict>
       </dict>
</dict>

```

### 4.6 Windows Settings
No further settings are required.

### 4.7 Linux Settings
No further settings are required.

## 5 Usage

### 5.1 AzureSignIn instance creation and configuration
The class itself is very flexible, no parameters need to be set and it will use the **[az cli](https://learn.microsoft.com/en-us/cli/azure/)** configuration.
For information on all available variables in this class, refer to **5.5 AzureSignIn Variables**

#### 5.1.1 Creating an instance without parameters (using az cli default settings) <a name="paragraph511"></a>
```dart
    final azureSignIn = AzureSignIn();
```

#### 5.1.2 Creating an instance with parameters
Parameters for the Authentication and local Http-Server can be set if needed.
```dart
  final azureSignIn = AzureSignIn(
    // The Application (client) ID that the Azure portal – App registrations page assigned to your app.
    // Optional, uses the az cli client id: '04b07795-8ddb-461a-bbee-02f9e1bf7b46'
    clientId: '04b07795-8ddb-461a-bbee-02f9e1bf7b46',
    // A list of scopes that you want the user to consent to.
    // Optional, uses the az cli scope: ['https://management.core.windows.net//.default', 'offline_access', 'openid', 'profile']
    scope: [
      'https://management.core.windows.net//.default',
      'offline_access',
      'openid',
      'profile',
    ],
    // Port of the Local HttpServer which will receive the code after sign in.
    // Optional, uses the port 5000
    port: 5000,
    // Response of the Local HttpServer, which the user will see in the browser after successful sign in.
    // Optional, uses 'Sign In successful. This window can now be closed.'
    serverSuccessResponse: '<h1>Sign In successful.</h1><p>This window can now be closed.</p>',
    // Response of the Local HttpServer, which the user will see in the browser after sign in failure.
    // Optional, uses 'Sign In failed. Close this window and try again.'
    serverErrorResponse: '<h1>Sign In failed.</h1><p>Close this window and try again.</p>',
    // Duration on how long the local HttpServer waits, for the user to sign in before creating a cancelled-token and closing.
    // Optional, uses Duration(minutes: 5)
    signInTimeoutDuration: Duration(minutes: 5),
  );
```
### 5.2 Sign In

#### 5.2.1 Get the Microsoft Sign-In page URL
The user needs to sign-in to the Browser, to do so the Sign In URL can be received.
If Flutter is being used, this URL could be opened with the **[url_launcher](https://pub.dev/packages/url_launcher)**
```dart
    // Print the SignIn URL, the user has to open in the browser.
    print(azureSignIn.signInUri);
```

#### 5.2.2 Start the Sign In process
The sign-in will return a new `Token`.
In the background an `HttpServer` is started and waits for the code to be received after the sign-in in the Browser, 
then the **Microsoft token Endpoint** will be called with the code and a token is returned.
The `Token` will always be created, but depending on success or error, different values will be set, see the variable `token.status` in **5.6 The Token-Entity**.
```dart
    Token token = await azureSignIn.signIn();
```

### 5.3 Cancel the Sign In process
The Sign In Process itself has the defined timeout set in the variable `azureSignIn.signInTimeoutDuration`, but with the following function the user could cancel the Sign in if needed.
The `azureSignIn.signIn()` will then receive a `Token` with the information of cancellation in the variable `token.status` (See more: **5.6 The Token-Entity**).
```dart
    // Cancels the sign-in process.
    async azureSignIn.cancelSignIn();
```

### 5.4 Refresh a Token
Once the token expires it can be either refreshed by giving it the existing `Token` or just giving it a refresh-token String.
One of the Values needs to be sent, else a `Token` with an error status will be returned, see `token.status` in **5.6 The Token-Entity**.

#### 5.4.1 Refresh Token with an existing `Token`
The Token can be refreshed by using the existing `Token`
```dart
    // refresh a token by giving the previous aquired token object.
    token = await azureSignIn.refreshToken(token: token);
```

#### 5.4.2 Refresh Token with the Refresh-Token String
Or if the `Token` is not available anymore the refresh token can be sent as a String.
```dart
    // refresh a token by giving the refresh-token as a string.
    token = await azureSignIn.refreshToken(refreshToken: refreshTokenString);
```

### 5.5 AzureSignIn Variables
Some class variables can be modified while running, some others are read-only.

<table>
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Default value</th>
<th>Can be modified</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>azureSignIn.clientId</code></td>
<td>String</td>
<td>04b07795-8ddb-461a-bbee-02f9e1bf7b46</td>
<td>&check;</td>
<td>The Application (client) ID that the Azure portal – App registrations page assigned to your app. Uses the <strong><a href="https://learn.microsoft.com/en-us/cli/azure/">az cli</a></strong> client ID by default, no app registration is necessary.</td>
</tr>
<tr>
<td><code>azureSignIn.scope</code></td>
<td>List\<String\></td>
<td>[<br />&#39;<a href="https://management.core.windows.net//.default">https://management.core.windows.net//.default</a>&#39;,<br />&#39;offline_access&#39;,<br />&#39;openid&#39;,<br />&#39;profile&#39;<br />]</td>
<td>&check;</td>
<td>A space-separated list of scopes that you want the user to consent to. For the /authorize leg of the request, this parameter can cover multiple resources. This value allows your app to get consent for multiple web APIs you want to call. Uses the <strong><a href="https://learn.microsoft.com/en-us/cli/azure/">az cli</a></strong> Scopes by default</td>
</tr>
<tr>
<td><code>azureSignIn.grantType</code></td>
<td>String</td>
<td>authorization_code</td>
<td>&cross;</td>
<td>Grant Type for the authorization flow. Must be <strong>authorization_code</strong> for the authorization code flow.</td>
</tr>
<tr>
<td><code>azureSignIn.port</code></td>
<td>int</td>
<td>5000</td>
<td>&check;</td>
<td>Port of the Local <code>HttpServer</code> which will receive the code after sign-in via a web browser.</td>
</tr>
<tr>
<td><code>azureSignIn.signInTimeoutDuration</code></td>
<td>Duration()</td>
<td><code>Duration(minutes: 5)</code></td>
<td>&check;</td>
<td>Duration on how long the local <code>HttpServer</code> waits, for the user to sign in, before closing.</td>
</tr>
<tr>
<td><code>azureSignIn.serverSuccessResponse</code></td>
<td>String</td>
<td>Sign In successful. This window can now be closed.</td>
<td>&check;</td>
<td>Response of the Local HttpServer, which the user will see after successfully logging in, can be simple Text or HTML.</td>
</tr>
<tr>
<td><code>azureSignIn.serverErrorResponse</code></td>
<td>String</td>
<td>Sign In failed. Close this window and try again.</td>
<td>&check;</td>
<td>Response of the Local HttpServer, which the user will see after sign-in failure, can be simple Text or HTML.</td>
</tr>
<tr>
<td><code>azureSignIn.signInUri</code></td>
<td>String</td>
<td>https://login.microsoftonline.com/organizations/oauth2/v2.0/authorize<br />?client_id=[CLIENT_ID]<br />&amp;response_type=code<br />&amp;redirect_uri=http://localhost:[PORT]<br />&amp;scope=[SCOPE]<br />&amp;response_mode=form_post</td>
<td>&cross;</td>
<td>Getter for the Microsoft Sign-In URL used to Sign In via Browser. Combines <code>azureSignIn.clientId</code>, <code>azureSignIn.port</code> and <code>azureSignIn.scope</code>, which can not be directly modified.</td>
</tr>
<tr>
<td><code>azureSignIn.signOutUri</code></td>
<td>String</td>
<td><a href="https://login.microsoftonline.com/common/oauth2/v2.0/logout">https://login.microsoftonline.com/common/oauth2/v2.0/logout</a></td>
<td>&cross;</td>
<td>Azure Auth URL used to Sign out from the Browser.</td>
</tr>
</tbody>
</table>


### 5.6. The Token-Entity
The Token has multiple fields, some are set in case of success, some in case of failure.

<table>
<thead>
<tr>
<th>Name</th>
<th>Type</th>
<th>Example</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>token.tokenType</code></td>
<td>String</td>
<td>Bearer</td>
<td>Indicates the token type value. The only type that Azure AD supports is <strong>Bearer</strong></td>
</tr>
<tr>
<td><code>token.scope</code></td>
<td>String</td>
<td>user_impersonation</td>
<td>The scopes that the <strong>access_token</strong> is valid for. Optional. This parameter is non-standard and, if omitted, the token is for the scopes requested on the initial leg of the flow.</td>
</tr>
<tr>
<td><code>token.expiresIn</code></td>
<td>String</td>
<td>5084</td>
<td>How long the access token is valid, in seconds.</td>
</tr>
<tr>
<td><code>token.extExpiresIn</code></td>
<td>String</td>
<td>5084</td>
<td>Used to indicate an extended lifetime for the access token and to support resiliency when the token issuance service is not responding.</td>
</tr>
<tr>
<td><code>token.expiresOn</code></td>
<td>String</td>
<td>1674580651</td>
<td>Timestamp when the token expires.</td>
</tr>
<tr>
<td><code>token.notBefore</code></td>
<td>String</td>
<td>1674575266</td>
<td>The time at which the token becomes valid, represented in epoch time. This time is usually the same as the time the token was issued. Azure AD B2C validates this value and rejects the token if the token lifetime is not valid.</td>
</tr>
<tr>
<td><code>token.resource</code></td>
<td>String</td>
<td><a href="https://management.core.windows.net/">https://management.core.windows.net/</a></td>
<td>Resource the token has access to.</td>
</tr>
<tr>
<td><code>token.accessToken</code></td>
<td>String</td>
<td>eyJ0eXAiOiJKV1QiLCJhbGciOiJS...</td>
<td>The requested access token. The app can use this token to authenticate to the secured resource, such as a web API.</td>
</tr>
<tr>
<td><code>token.refreshToken</code></td>
<td>String</td>
<td>0.AQUAjHBCWE0CK06v4qgD88sl3Z...</td>
<td>An OAuth 2.0 refresh token. The app can use this token to acquire other access tokens after the current access token expires. Refresh tokens are long-lived. They can maintain access to resources for extended periods.</td>
</tr>
<tr>
<td><code>token.idToken</code></td>
<td>String</td>
<td>eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIs...</td>
<td>A JSON Web Token. The app can decode the segments of this token to request information about the user who signed in. The app can cache the values and display them, and confidential clients can use this token for authorization.</td>
</tr>
<tr>
<td><code>token.foci</code></td>
<td>String</td>
<td>1</td>
<td>Access to Microsoft Office apps while they have a session on a mobile device using FOCI (Family of Client IDs).</td>
</tr>
<tr>
<td><code>token.status</code></td>
<td>int</td>
<td>0: Success<br />1: Azure API error<br />2: HttpServer error<br />3: Sign In canceled</td>
<td>Status of the Token authorization code flow result, can be used for error-handling or giving the user some further information.</td>
</tr>
<tr>
<td><code>token.error</code></td>
<td>String</td>
<td>invalid_grant</td>
<td>An error code string that can be used to classify types of errors, and to react to errors.</td>
</tr>
<tr>
<td><code>token.errorDescription</code></td>
<td>String</td>
<td>AADSTS900144: The request body must contain the following parameter: &#39;code&#39;...</td>
<td>A specific error message that can help a developer identify the root cause of an authentication error.</td>
</tr>
<tr>
<td><code>token.errorCodes</code></td>
<td>List&lsaquo;dynamic&bsol;&rsaquo;</td>
<td>[900144]</td>
<td>A list of STS-specific error codes that can help in diagnostics.</td>
</tr>
<tr>
<td><code>token.errorUri</code></td>
<td>String</td>
<td><a href="https://login.microsoftonline.com/error?code=900144">https://login.microsoftonline.com/error?code=900144</a></td>
<td>URL to a Microsoft documentation, concerning the emerged error.</td>
</tr>
</tbody>
</table>


## 6 Where to go from here
With the `token.accessToken` you now have access to the Microsoft APIs.
Read more on the [Azure Rest API reference](https://learn.microsoft.com/en-us/rest/api/azure/), or check out the [Application IDs of commonly used Microsoft applications](https://learn.microsoft.com/en-us/troubleshoot/azure/active-directory/verify-first-party-apps-sign-in#application-ids-of-commonly-used-microsoft-applications) to add some pre-existing `azureSignIn.clientId`.

## 7 Bugs and issues
Please file feature requests and bugs at the [issue tracker](https://github.com/Pat992/dart_azure_ad_sign_in/issues)