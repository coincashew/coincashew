# 🔮 Setting Up Dashboards

{% hint style="info" %}
* **Prometheus** is a monitoring platform that collects metrics from monitored targets by scraping metrics HTTP endpoints on these targets. [Official documentation is available here.](https://prometheus.io/docs/introduction/overview/)
* **Grafana** is a dashboard used to visualize the collected data.
{% endhint %}

## :hatching\_chick: Installing Prometheus and Grafana

Install prometheus and prometheus node exporter.

{% tabs %}
{% tab title="relaynode1" %}
```
sudo apt-get install -y prometheus prometheus-node-exporter 
```
{% endtab %}

{% tab title="block producer node" %}
```bash
sudo apt-get install -y prometheus-node-exporter 
```
{% endtab %}
{% endtabs %}

Install grafana.

{% tabs %}
{% tab title="relaynode1" %}
```bash
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
```
{% endtab %}
{% endtabs %}

{% tabs %}
{% tab title="relaynode1" %}
```bash
echo "deb https://packages.grafana.com/oss/deb stable main" > grafana.list
sudo mv grafana.list /etc/apt/sources.list.d/grafana.list
```
{% endtab %}
{% endtabs %}

{% tabs %}
{% tab title="relaynode1" %}
```bash
sudo apt-get update && sudo apt-get install -y grafana
```
{% endtab %}
{% endtabs %}

Enable services so they start automatically.

{% tabs %}
{% tab title="relaynode1" %}
```bash
sudo systemctl enable grafana-server.service
sudo systemctl enable prometheus.service
sudo systemctl enable prometheus-node-exporter.service
```
{% endtab %}

{% tab title="block producer node" %}
```
sudo systemctl enable prometheus-node-exporter.service
```
{% endtab %}
{% endtabs %}

Update **prometheus.yml **located in `/etc/prometheus/prometheus.yml`

Change the** \<block producer ip address>** in the following command.

{% tabs %}
{% tab title="relaynode1" %}
```bash
cat > prometheus.yml << EOF
global:
  scrape_interval:     15s # By default, scrape targets every 15 seconds.

  # Attach these labels to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  external_labels:
    monitor: 'codelab-monitor'

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label job=<job_name> to any timeseries scraped from this config.
  - job_name: 'prometheus'

    static_configs:
      - targets: ['localhost:9100']
      - targets: ['<block producer ip address>:9100']
      - targets: ['<block producer ip address>:12798']
        labels:
          alias: 'block-producer-node'
          type:  'cardano-node'
      - targets: ['localhost:12798']
        labels:
          alias: 'relaynode1'
          type:  'cardano-node'
EOF
sudo mv prometheus.yml /etc/prometheus/prometheus.yml
```
{% endtab %}
{% endtabs %}

Finally, restart the services.

{% tabs %}
{% tab title="relaynode1" %}
```
sudo systemctl restart grafana-server.service
sudo systemctl restart prometheus.service
sudo systemctl restart prometheus-node-exporter.service
```
{% endtab %}
{% endtabs %}

Verify that the services are running properly:

{% tabs %}
{% tab title="relaynode1" %}
```
sudo systemctl status grafana-server.service prometheus.service prometheus-node-exporter.service
```
{% endtab %}
{% endtabs %}

Update `${NODE_CONFIG}-config.json` config files with new `hasEKG`  and `hasPrometheus` ports.

{% tabs %}
{% tab title="block producer node" %}
```bash
cd $NODE_HOME

sed -i ${NODE_CONFIG}-config.json -e "s/127.0.0.1/0.0.0.0/g"  
```
{% endtab %}

{% tab title="relaynodeN" %}
```bash
cd $NODE_HOME

sed -i ${NODE_CONFIG}-config.json -e "s/127.0.0.1/0.0.0.0/g"  
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
Port forwarding and firewall config:&#x20;

On block producer node (or relaynodeN), you need to open ports 12798 and 9100

On relaynode1, you will need to open ports 3000 for grafana.
{% endhint %}

Stop and restart your stake pool.

{% tabs %}
{% tab title="block producer node" %}
```bash
sudo systemctl restart cardano-node
```
{% endtab %}

{% tab title="relaynode1" %}
```bash
sudo systemctl restart cardano-node
```
{% endtab %}
{% endtabs %}

Verify the metrics are working by querying the prometheus port.

{% tabs %}
{% tab title="block producer and relaynodes" %}
```bash
curl -s 127.0.0.1:12798/metrics

# Example output:
# rts_gc_par_tot_bytes_copied 123
# rts_gc_num_gcs 345
# rts_gc_max_bytes_slop 4711111
# cardano_node_metrics_served_block_count_int 8112
# cardano_node_metrics_Stat_threads_int 8
# cardano_node_metrics_density_real 4.67
```
{% endtab %}
{% endtabs %}

## :signal\_strength: Configuring Grafana

1. On relaynode1, open [http://localhost:3000](http://localhost:3000) or http://\<your relaynode1 ip address>:3000 in your local browser. You may need to open up port 3000 in your router and/or firewall.
2. Login with **admin **/ **admin**
3. Change password
4. Click the **configuration gear** icon, then **Add data Source**
5. Select **Prometheus**
6. Set **Name **to **"Prometheus**"
7. Set **URL **to **http://localhost:9090**
8. Click **Save & Test**
9. **Download and save **this [**json file**](https://raw.githubusercontent.com/coincashew/coincashew/master/.gitbook/assets/grafana-monitor-cardano-nodes-by-kaze.json)**.**
10. Click **Create + **icon > **Import**
11. Add dashboard by **Upload JSON file**
12. Click the **Import **button.

![Credits to KAZE stake pool for this dashboard](../../../../.gitbook/assets/dashboard-kaze.jpg)

{% hint style="info" %}
Community contributer **Sansky.de** is sharing a very detailed Grafana tutorial :pray: [https://sanskys.de/dashboard/](https://sanskys.de/dashboard/)
{% endhint %}

{% hint style="success" %}
Congratulations. You're basically done. More great operational and maintenance tips in section 18.
{% endhint %}

{% hint style="info" %}
Be sure to review the [stake pool operator's best practice checklist](18.-operational-and-maintenance-tips.md#18.15-stake-pool-operators-best-practices-checklist) to ensure a smooth sailing with your pool.
{% endhint %}
