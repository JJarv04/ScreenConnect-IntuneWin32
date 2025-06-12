# ScreenConnect-IntuneWin32
A fork of James Vincents: '[How to Deploy ScreenConnect using Intune](https://jamesvincent.co.uk/2024/02/07/how-to-deploy-screenconnect-using-intune/)' scripts.

Adds the ability dynamically detect the version of the source ScreenConnect server and use that to detect whether the installed application is up to date. Additionally, adds some logging options, useful for debugging.

#### Extra
There is another 'generic' variant of this script in the `/Extra` directory which installs ScreenConnect using the same method but without the IntuneExtension install directory, rather via a temp directory. Perhaps of value for other RMMs or deployment methods - have successfully used in MDT deployments.

## Detect-ScreenConnect
Edit the `$scBaseUrl`, `$doTranscribe` & `$logDirectory` variables in the Detect-ScreenConnect.ps1 detection script to set configuration and logging behaviour. 
-  `$scBaseUrl` = The base URL to your ScreenConnect server that is accessible by the client computer which we are installing on.
-  `$doTranscribe` = Toggle on whether or not to start transcribing logs to the machine.
-  `$logDirectory` = The directory in which to deposit said logs.


## Install-ScreenConnect
```powershell
.\Install-ScreenConnect.ps1 -BaseUrl 'https://example.com' -Client "Staff Laptop" -Department "No Consent" -DeviceType "No Consent"
.\Install-ScreenConnect.ps1 -BaseUrl 'https://example.com' -Client "Staff Laptop" -LogDirectory 'C:\Logs'
```
-  `-BaseUrl` = The base URL to your ScreenConnect server that is accessible by the client computer which we are installing on.
-  `-LogDirectory` = The directory in which to deposit logs for the Install-ScreenConnect script.


## Uninstall-ScreenConnect
```powershell
.\Uninstall-ScreenConnect.ps1
.\Uninstall-ScreenConnect.ps1 -LogDirectory "C:\Logs"
```
-  `-LogDirectory` = The directory in which to deposit logs for the Uninstall-ScreenConnect script.
