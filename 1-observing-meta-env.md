<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# add examples, tips, sources for best configurations - if there are some github awesome repositories - add them with recommendations

Here are practical examples, configuration tips, and recommended GitHub repositories for setting up Grafana, Prometheus, and Wazuh in a multi-project, multi-server environment. These resources will help you build a robust, scalable, and maintainable monitoring stack for your Debian 13 servers and AI projects.[^1][^2][^3][^4][^5][^6]

### Example Configurations

#### Prometheus + Grafana (Docker Compose)

A simple, production-ready setup using Docker Compose:

```yaml
version: '3'
services:
  prometheus:
    image: prom/prometheus
    ports:
      - 9090:9090
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
  grafana:
    image: grafana/grafana
    ports:
      - 3000:3000
    depends_on:
      - prometheus
```

- Configure `prometheus.yml` to scrape Node Exporter and any custom exporters for your AI projects.[^2][^4]
- Import dashboards from Grafana Labs or community repositories for instant visualization.[^5][^7]


#### Wazuh + Prometheus Exporter

Use the Wazuh Prometheus Exporter to expose Wazuh metrics to Prometheus:

- GitHub: [pyToshka/wazuh-prometheus-exporter](https://github.com/pyToshka/wazuh-prometheus-exporter)[^1]
- This allows you to visualize Wazuh security events in Grafana alongside your infrastructure metrics.


#### Multi-Server Prometheus Federation

For multiple VPS and physical servers, use Prometheus federation:

- Central Prometheus scrapes remote Prometheus instances on each server, aggregating metrics for unified dashboards.[^8][^9]
- Example config for federation:

```yaml
scrape_configs:
  - job_name: 'federate'
    scrape_interval: 15s
    honor_labels: true
    metrics_path: '/federate'
    params:
      'match[]':
        - '{job="node-exporter"}'
    static_configs:
      - targets:
        - 'prometheus-server-1:9090'
        - 'prometheus-server-2:9090'
```

- This is ideal for environments with multiple VPS and physical servers.[^8]


### Recommended GitHub Repositories

| Repository | Description | Use Case |
| :-- | :-- | :-- |
| [samber/workshop-prometheus-grafana](https://github.com/samber/workshop-prometheus-grafana) | Step-by-step Prometheus + Grafana setup, including config files and dashboards[^2] | Learning, quick start, multi-project |
| [systelab/prometheus-monitoring](https://github.com/systelab/prometheus-monitoring) | Docker-compose stack for Prometheus and Grafana[^3] | Easy deployment, multi-server |
| [pyToshka/wazuh-prometheus-exporter](https://github.com/pyToshka/wazuh-prometheus-exporter) | Expose Wazuh metrics to Prometheus[^1] | Security + metrics integration |
| [grafana/mimir](https://github.com/grafana/mimir) | Scalable, multi-tenant Prometheus storage[^10] | Large-scale, multi-project |
| [eagleusb/awesome-repositories](https://github.com/eagleusb/awesome-repositories) | Curated list of monitoring and AI tools[^10] | Discovery, inspiration |

### Tips for Best Configurations

- Use structured labels in Prometheus (e.g., `project`, `environment`, `service`) for easy filtering and dashboarding.[^4][^2]
- Regularly update exporters and dashboards to support new AI frameworks or hardware (e.g., GPU metrics).[^11]
- Secure all monitoring endpoints with TLS and restrict access to trusted IPs.[^4]
- Automate deployment and configuration using Ansible, Terraform, or similar tools for consistency across servers.[^4]
- For Wazuh, use agent groups and Filebeat pipelines to route logs by project or service.[^12][^13]


### Useful Dashboards

- Grafana Labs: [Wazuh Summary](https://grafana.com/grafana/dashboards/22448-wazuh-summary/) and [Wazuh SIEM XDR](https://grafana.com/grafana/dashboards/21565-siem-xdr-wazuh-4-8-0/)[^6][^5]
- Community: [Top Grafana Dashboards for Service Monitoring](https://blog.radwebhosting.com/top-10-best-grafana-dashboards-for-service-monitoring/)[^7]

These resources and tips will help you set up a universal, extensible monitoring stack for your Debian 13 servers and AI projects, with room for project-specific customization and orchestration.[^3][^2][^5][^6][^1][^4]
<span style="display:none">[^14][^15][^16][^17][^18][^19][^20][^21][^22][^23][^24]</span>

<div align="center">⁂</div>

[^1]: https://github.com/pyToshka/wazuh-prometheus-exporter

[^2]: https://github.com/samber/workshop-prometheus-grafana

[^3]: https://github.com/systelab/prometheus-monitoring

[^4]: https://blog.space-cloud.io/posts/how-to-setup-monitoring-using-prometheus-and-grafana/

[^5]: https://grafana.com/grafana/dashboards/22448-wazuh-summary/

[^6]: https://grafana.com/grafana/dashboards/21565-siem-xdr-wazuh-4-8-0/

[^7]: https://blog.radwebhosting.com/top-10-best-grafana-dashboards-for-service-monitoring/

[^8]: https://stackoverflow.com/questions/69824893/how-to-configure-central-prometheus-grafana-to-monitor-scrape-several-k8s-cluste

[^9]: https://last9.io/blog/high-availability-in-prometheus/

[^10]: https://github.com/eagleusb/awesome-repositories

[^11]: https://prometheus.io/docs/instrumenting/exporters/

[^12]: https://wazuh.com/blog/wazuh-multi-site-implementation/

[^13]: https://www.reddit.com/r/Wazuh/comments/1d83ovs/centralized_wazuh_dashboard_for_multiple_clients/

[^14]: https://groups.google.com/g/wazuh/c/XBVoPssuI-A

[^15]: https://grafana.com/docs/grafana-cloud/send-data/metrics/metrics-prometheus/prometheus-config-examples/open-source-projects/security-monitoring/

[^16]: https://mobilelive.ai/blog/mastering-system-monitoring-with-prometheus-and-grafana-your-handy-guide

[^17]: https://dev.to/devcorner/monitoring-with-prometheus-and-grafana-a-comprehensive-guide-48gf

[^18]: https://github.com/giantswarm/prometheus

[^19]: https://community.grafana.com/t/wazuh-on-grafana/78269

[^20]: https://grafana.com/blog/2019/08/22/homelab-security-with-ossec-loki-prometheus-and-grafana-on-a-raspberry-pi/

[^21]: https://www.reddit.com/r/selfhosted/comments/17dq3aq/how_do_you_all_monitor_your_server_performance/

[^22]: https://www.reddit.com/r/Wazuh/comments/1fos079/wazuh_x_grafana_using_elasticseatch_plugin/

[^23]: https://techhut.tv/monitor-home-server-grafana-prometheus-influxdb/

[^24]: https://www.youtube.com/watch?v=XrbPl97w2JQ

