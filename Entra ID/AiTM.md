# Harden Entra ID Advisory/Attacker-in-the-Middle (AiTM)

1. If applicable via licensing, enable Entra ID Protection across the entire tenant. - [What is Microsoft Entra ID Protection](https://learn.microsoft.com/en-us/entra/id-protection/overview-identity-protection)

![image](https://github.com/user-attachments/assets/43d46612-40a2-41b9-8816-73d2a668e23d)

   - Configure block and MFA based on organizational requirements in addition to implementing automated responses where possible. This will allow security analysts to focus on higher alerts and detections.
      - **User risk policy** – Focuses on both offline and real-time protections that review user behavior, such as the use of hacking tools, anomalies based on user norms, and threat intelligence provided by the Microsoft Threat Research team.
        - While Microsoft recommends password change for high-level alerts through SSPR, blocking high user alerts and allowing security analysts to review the detection more closely leads to improved security posture and removal of misconfigurations.
          - **Block on High User Risk Alert**
            - Initiate Revoke of Session - *An external link was removed to protect your privacy.*
            - Notify Helpdesk to reset user password and communicate the new password to the end user.
            - Validate that User MFA is at the highest available for the organization. Be sure to retire MFA by SMS/phone call.
            - Review both sign-in and non-interactive logs to ensure no other successful sign-ins have happened.
          - Recommends blocking on high vs. password change if RH has resources. Choosing to block access rather than allowing self-remediation options, like secure password change and multifactor authentication, affects your users and administrators even more. Weigh these choices when configuring your policies.
      - **Sign-in risk policy**
        - Require Microsoft Entra multifactor authentication when sign-in risk level is Medium or High, allowing users to prove it's them by using one of their registered authentication methods, remediating the sign-in risk. Revoking Session for High automatically can be done through Sentinel and will help to reduce AiTM.
          - *An external link was removed to protect your privacy.*
        - Notify user via Teams - *An external link was removed to protect your privacy.*

3. **Enforce Phishing Resistant MFA in Conditional Access where applicable (ideally everywhere).**
   - *An external link was removed to protect your privacy.*
   - *An external link was removed to protect your privacy.*
     - Start to test out Passkey with Authenticator.
   - Transition to Windows Hello for Business (WHfB) for End Users.

4. **Harden Entra ID to find gaps within your environment based on best practices from Microsoft.**
   - **Secure Score and Exposure Management**
     - *An external link was removed to protect your privacy.*
     - Be sure to utilize Defender secure score with MDI data to harden local AD to protect against lateral movement and on-premises attacks.
   - **Restrict access to Microsoft Entra admin center**
     - Restricting Access to Entra Admin portals does not limit access to PowerShell and graph only from the UI. This might help against a user poking around but is not a security practice that will harden the environment - *An external link was removed to protect your privacy.*
     - Block user access with Conditional Access policy.
       - Creating a Conditional Access policy for Windows Azure Service Management API will block non-administrative access.
         - Start with report-only and monitor the behavior of this conditional access policy. Several services utilize this service, so you might impact services like Fabric and Data Lake. *An external link was removed to protect your privacy.*
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
