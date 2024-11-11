# Harden Entra ID Advisory/Attacker-in-the-Middle (AiTM)

1. If applicable via licensing, enable Entra ID Protection across the entire tenant. - [What is Microsoft Entra ID Protection](https://learn.microsoft.com/en-us/entra/id-protection/overview-identity-protection)

![image](https://github.com/user-attachments/assets/43d46612-40a2-41b9-8816-73d2a668e23d)

   - Configure block and MFA based on organizational requirements in addition to implementing automated responses where possible. This will allow security analysts to focus on higher alerts and detections.
      - **User risk policy** – Focuses on both offline and real-time protections that review user behavior, such as the use of hacking tools, anomalies based on user norms, and threat intelligence provided by the Microsoft Threat Research team.
        - While Microsoft recommends password change for high-level alerts through SSPR, blocking high user alerts and allowing security analysts to review the detection more closely leads to improved security posture and removal of misconfigurations.
          - **Block on High User Risk Alert**
            -Follow procedure to resolve incident. (below are steps that can be used)
                - Initiate Revoke of Session - [Session Reset](https://github.com/Azure/Azure-Sentinel/tree/master/Solutions/Microsoft%20Entra%20ID/Playbooks/Revoke-AADSignInSessions)
               - Review both sign-in and non-interactive logs to ensure no other successful sign-ins have happened.
               - Validate that User MFA is at the highest available for the organization. Be sure to retire MFA by SMS/phone call.
               - Review both sign-in and non-interactive logs to ensure no other successful sign-ins have happened.
               - Confirm or Dismiss User Risk based on findings
                  - [Confirm](https://github.com/Azure/Azure-Sentinel/tree/master/Solutions/Microsoft%20Entra%20ID%20Protection/Playbooks/Confirm-EntraIDRiskyUser)
                  - [Dismiss](https://github.com/Azure/Azure-Sentinel/tree/master/Solutions/Microsoft%20Entra%20ID%20Protection/Playbooks/Dismiss-EntraIDRiskyUser)
               - Review user mailbox for potential email that had bad URL
               - Review user's devices for potential bad acts done from device
               - Sample Queries - https://github.com/MSJosh/TTTTUB/tree/main/MFA%20Bypass
            -Once resources have cleared user from the event.
               - Reset user password and communicate the new password to the end user, have them change password again. This will dismiss the risk of the user in Entra Portal
               - Security team can also dismiss risk also in Entra Portal or Sentinel/Defender XDR

      - **Sign-in risk policy** - Similar to User based risks, detections happen both Real-time and Offline based on type of detections. Detections related to user travel, sign in location and correlation between Defender for Office help to trigger events.
           - Conditional Access policies should be configured to require Microsoft Entra multifactor authentication when sign-in risk level is Medium or High, allowing users to prove it's them by using one of their registered authentication methods, remediating the sign-in risk.
           - Sign In risk can be triggered by VPN traffic so it is important to configure known location IPs as part of Entra ID and dismiss false postives to help the machine learning modules to learn behavior.
           - For Sign In risk it is recommended to utilize higher levels of MFA validation that require user interaction such as Authenticator where it shows the location of the sign in, or passkey sign in.  While no solution fool proof, you can implement notification of the user by Microsoft Teams via an automation by Sentinel to validate the user did sign into the location and update alert information. [Notifiy User via Teams](https://github.com/Azure/Azure-Sentinel/tree/master/Solutions/Microsoft%20Entra%20ID%20Protection/Playbooks/IdentityProtection-TeamsBotResponse)


# ***Harden Entra ID***
-While ensuring proper detections and mitigations are in place, the first priority of security is hardening the enviroment to prevent such attacks from happening. Below are some methods available to Microsoft customers to secure their enviroment.

- **Enforce Phishing Resistant MFA in Conditional Access where applicable (ideally everywhere).**
   - [Require phishing-resistant multifactor authentication for Microsoft Entra administrator roles](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-admin-phish-resistant-mfa)
   - [Enable passkeys for your organization](https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-enable-passkey-fido2)
   - Entra Customers can start using Authenticator and Android/iOS devices to create a passkey
   - Transition to Windows Hello for Business (WHfB) for End Users.

- **Harden Entra ID to find gaps within your environment based on best practices from Microsoft.**
   - **Secure Score and Exposure Management**
     - [What is the identity secure score?](https://learn.microsoft.com/en-us/entra/identity/monitoring-health/concept-identity-secure-score)
     - Be sure to utilize Defender secure score with MDI data to harden local AD to protect against lateral movement and on-premises attacks.
     - Utilize OpenSource tools like [Maester](https://maester.dev/)
    
- **Restrict access to Microsoft Entra admin center**
     - Restricting Access to Entra Admin portals does not limit access to PowerShell and graph only from the UI. This might help against a user poking around but is not a security practice that will harden the environment - [Restrict User Access](https://learn.microsoft.com/en-us/entra/fundamentals/users-default-permissions#restrict-member-users-default-permissions)
     - Block user access with Conditional Access policy.
       - Creating a Conditional Access policy for Windows Azure Service Management API will block non-administrative access.
![image](https://github.com/user-attachments/assets/5b2df056-b1b1-4c5a-ba1d-936260b67628)

         - Start with report-only and monitor the behavior of this conditional access policy. Several services utilize this service, so you might impact services like Fabric and Data Lake. [RAzure API Management](https://learn.microsoft.com/en-us/azure/api-management/api-management-key-concepts)
   - **Enforce Conditional Access Policies associated with Device Trust and compliance where possible.**
     - Ensure low risk and patch level with MDE and Intune - *An external link was removed to protect your privacy.*
     - Utilize Edge Browser where possible to enforce Cloud Apps seamlessly for external partners and non-company-owned devices.
       - *An external link was removed to protect your privacy.*
       - *An external link was removed to protect your privacy.*

## AiTM Phishing Tool Kits

NakedPages is an adversary-in-the-middle (AiTM) phishing kit used to circumvent multi-factor authentication (MFA) through reverse-proxy. Kits such as NakedPages, EvilProxy, and Evilginx are part of an increasing trend of AiTM phishing and have supplanted many other less advanced forms of phishing. NakedPages is open source, focuses on automating setup and phishing activity, and provides support services to customers. These attributes lower the barrier-to-entry to phishing activity, making the kit attractive to many different actors who have continually leveraged the kit since its first appearance in May-June 2022. Actors using this kit have varying motivations for targeting and could target any industry or sector.

- Evilginx
- Muraena
- Modlishka
- EvilProxy

## AADSignInEventsBeta

```kusto
AADSignInEventsBeta
| where RiskLevelDuringSignIn in (50,100) // Medium and High risk level
//72782ba9-4490-4f03-8d82-562370ea3566 -> Office 365 app used by Evilproxy
//4765445b-32c6-49b0-83e6-1d93765276ca -> Office Home used by Evilginx
| where ApplicationId in ("72782ba9-4490-4f03-8d82-562370ea3566" ,"4765445b-32c6-49b0-83e6-1d93765276ca") 
| where isempty(DeviceTrustType) //Device Authentication doesn't work via reverse-proxy so even AADjoined device will be treated as none-joined device by AAD
| where ClientAppUsed == "Browser" // Only web browser traffic is interesting
| where ErrorCode == 0
| where isnotempty (AccountUpn)
| where isnotempty (IPAddress)
| project Timestamp,AccountObjectId,AccountUpn,IPAddress, SessionId, CorrelationId
