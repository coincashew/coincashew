# :ocean: 6.4 Monitoring with Uptime Check by Google Cloud

{% hint style="info" %}
Who watches the watcher? With an external 3rd party tool like Uptime Check, you can have greater reassurance your validator is functioning in case of disasters such as power failure, hardware failure or internet outage. In these scenarios, the previously mentioned monitoring by Prometheus and Grafana would likely cease to function as well.

Credits to [Mohamed Mansour for inspiring this how-to guide](https://www.youtube.com/watch?v=txgOVDTemPQ).
{% endhint %}

Here's how to setup a no-cost monitoring service called Uptime Check by Google.

{% hint style="info" %}
For a video demo, watch [MohamedMansour's eth2 education videos](https://www.youtube.com/watch?v=txgOVDTemPQ). Please support his [GITCOIN grant](https://gitcoin.co/grants/1709/video-educational-grant). :pray:
{% endhint %}

1. Visit [cloud.google.com](https://cloud.google.com)
2. Search for **Monitoring** in the search field.
3. Click **Select a Project to Start Monitoring**.
4. Click **New Project.**
5. **Name your project and click Create.**
6. From the notifications menu, select your new project.
7. On the right column, there's a Monitoring Card. Click **Go to Monitoring**.
8. On the left menu, click \*\*Uptime checks \*\*and then **CREATE UPTIME CHECK.**
9. Type in a title i.e. _**Geth node**_
10. Select protocol as _**TCP**_
11. Enter your public IP address and port number. i.e. ip=**7.55.6.3** and port=**30303**
12. Select your desired frequency to check i.e. **5 minutes.**
13. Choose the region closest to you to check from. Click Next.
14. Create a Notification Channel. Click **Manage Notification Channels.**
15. Choose your desired settings. Pick from any or all of Slack, Webhook, Email or SMS.
16. Go back to Create Uptime Check window.
17. Within the notifications field, click the refresh button to load your new notification channels.
18. Select desired notifications.
19. Click **TEST **to verify your notifications are setup correctly.
20. Click **CREATE **to finish.