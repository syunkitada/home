var prometheus = 'Prometheus';

return {
  "id": null,
  "title": "HAproxy Servers | HAproxy",
  "tags": [
    "haproxy",
    "servers"
  ],
  "style": "dark",
  "timezone": "browser",
  "editable": true,
  "hideControls": false,
  "sharedCrosshair": true,
  "rows": [
    {
      "collapse": false,
      "editable": true,
      "height": "250px",
      "panels": [
        {
          "aliasColors": {},
          "bars": false,
          "datasource": prometheus,
          "editable": true,
          "error": false,
          "fill": 1,
          "grid": {
            "threshold1": null,
            "threshold1Color": "rgba(216, 200, 27, 0.27)",
            "threshold2": null,
            "threshold2Color": "rgba(234, 112, 112, 0.22)"
          },
          "id": 15,
          "isNew": true,
          "legend": {
            "alignAsTable": true,
            "avg": true,
            "current": true,
            "max": true,
            "min": true,
            "rightSide": true,
            "show": true,
            "total": false,
            "values": true
          },
          "lines": true,
          "linewidth": 2,
          "links": [],
          "nullPointMode": "connected",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "seriesOverrides": [],
          "span": 12,
          "stack": true,
          "steppedLine": false,
          "targets": [
            {
              "expr": "irate(haproxy_server_http_responses_total{backend=~\"$backend\", server=~\"$server\", code=~\"$code\", alias=\"$alias\"}[$interval])",
              "interval": "$interval",
              "intervalFactor": 1,
              "legendFormat": "{{ backend }}/{{ server }}/{{ code }}",
              "metric": "haproxy_backend_current_queue",
              "refId": "A",
              "step": 300
            }
          ],
          "timeFrom": null,
          "timeShift": null,
          "title": "HTTP Responses",
          "tooltip": {
            "msResolution": true,
            "shared": false,
            "sort": 0,
            "value_type": "individual"
          },
          "type": "graph",
          "xaxis": {
            "show": true
          },
          "yaxes": [
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            },
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            }
          ]
        },
        {
          "aliasColors": {},
          "bars": false,
          "datasource": prometheus,
          "editable": true,
          "error": false,
          "fill": 1,
          "grid": {
            "threshold1": null,
            "threshold1Color": "rgba(216, 200, 27, 0.27)",
            "threshold2": null,
            "threshold2Color": "rgba(234, 112, 112, 0.22)"
          },
          "id": 16,
          "isNew": true,
          "legend": {
            "alignAsTable": false,
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
            "rightSide": false,
            "show": true,
            "total": false,
            "values": false
          },
          "lines": true,
          "linewidth": 2,
          "links": [],
          "nullPointMode": "connected",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "seriesOverrides": [],
          "span": 4,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "avg(haproxy_server_check_duration_milliseconds{backend=~\"$backend\", server=~\"$server\", alias=\"$alias\"}) without (alias)",
              "interval": "$interval",
              "intervalFactor": 1,
              "legendFormat": "{{ backend }}/{{ server }}",
              "metric": "haproxy_backend_current_queue",
              "refId": "A",
              "step": 300
            }
          ],
          "timeFrom": null,
          "timeShift": null,
          "title": "Check Duration (ms)",
          "tooltip": {
            "msResolution": true,
            "shared": false,
            "sort": 0,
            "value_type": "cumulative"
          },
          "type": "graph",
          "xaxis": {
            "show": true
          },
          "yaxes": [
            {
              "format": "ms",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            },
            {
              "format": "none",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            }
          ]
        },
        {
          "aliasColors": {},
          "bars": false,
          "datasource": prometheus,
          "editable": true,
          "error": false,
          "fill": 1,
          "grid": {
            "threshold1": null,
            "threshold1Color": "rgba(216, 200, 27, 0.27)",
            "threshold2": null,
            "threshold2Color": "rgba(234, 112, 112, 0.22)"
          },
          "id": 17,
          "isNew": true,
          "legend": {
            "alignAsTable": false,
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
            "rightSide": false,
            "show": true,
            "total": false,
            "values": false
          },
          "lines": true,
          "linewidth": 2,
          "links": [],
          "nullPointMode": "connected",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "seriesOverrides": [],
          "span": 4,
          "stack": true,
          "steppedLine": false,
          "targets": [
            {
              "expr": "irate(haproxy_server_check_failures_total{backend=~\"$backend\", server=~\"$server\", alias=\"$alias\"}[$interval])",
              "interval": "$interval",
              "intervalFactor": 1,
              "legendFormat": "{{ backend }}/{{ server }}",
              "metric": "haproxy_backend_current_queue",
              "refId": "A",
              "step": 300
            }
          ],
          "timeFrom": null,
          "timeShift": null,
          "title": "Check Failures",
          "tooltip": {
            "msResolution": true,
            "shared": false,
            "sort": 0,
            "value_type": "individual"
          },
          "type": "graph",
          "xaxis": {
            "show": true
          },
          "yaxes": [
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            },
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            }
          ]
        },
        {
          "aliasColors": {},
          "bars": false,
          "datasource": prometheus,
          "editable": true,
          "error": false,
          "fill": 1,
          "grid": {
            "threshold1": null,
            "threshold1Color": "rgba(216, 200, 27, 0.27)",
            "threshold2": null,
            "threshold2Color": "rgba(234, 112, 112, 0.22)"
          },
          "id": 18,
          "isNew": true,
          "legend": {
            "alignAsTable": false,
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
            "rightSide": false,
            "show": true,
            "total": false,
            "values": false
          },
          "lines": true,
          "linewidth": 2,
          "links": [],
          "nullPointMode": "connected",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "seriesOverrides": [],
          "span": 4,
          "stack": true,
          "steppedLine": false,
          "targets": [
            {
              "expr": "irate(haproxy_server_downtime_seconds_total{backend=~\"$backend\", server=~\"$server\", alias=\"$alias\"}[$interval])",
              "interval": "$interval",
              "intervalFactor": 1,
              "legendFormat": "{{ backend }}/{{ server }}",
              "metric": "haproxy_backend_current_queue",
              "refId": "A",
              "step": 300
            }
          ],
          "timeFrom": null,
          "timeShift": null,
          "title": "Downtime (s)",
          "tooltip": {
            "msResolution": true,
            "shared": false,
            "sort": 0,
            "value_type": "individual"
          },
          "type": "graph",
          "xaxis": {
            "show": true
          },
          "yaxes": [
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            },
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            }
          ]
        },
        {
          "aliasColors": {},
          "bars": false,
          "datasource": prometheus,
          "editable": true,
          "error": false,
          "fill": 1,
          "grid": {
            "threshold1": null,
            "threshold1Color": "rgba(216, 200, 27, 0.27)",
            "threshold2": null,
            "threshold2Color": "rgba(234, 112, 112, 0.22)"
          },
          "id": 19,
          "isNew": true,
          "legend": {
            "alignAsTable": false,
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
            "rightSide": false,
            "show": true,
            "total": false,
            "values": false
          },
          "lines": true,
          "linewidth": 2,
          "links": [],
          "nullPointMode": "connected",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "seriesOverrides": [],
          "span": 4,
          "stack": true,
          "steppedLine": false,
          "targets": [
            {
              "expr": "irate(haproxy_server_redispatch_warnings_total{backend=~\"$backend\", server=~\"$server\", alias=\"$alias\"}[$interval])",
              "interval": "$interval",
              "intervalFactor": 1,
              "legendFormat": "{{ backend }}/{{ server }}",
              "metric": "haproxy_backend_current_queue",
              "refId": "A",
              "step": 300
            }
          ],
          "timeFrom": null,
          "timeShift": null,
          "title": "Redispatch Warnings",
          "tooltip": {
            "msResolution": true,
            "shared": false,
            "sort": 0,
            "value_type": "individual"
          },
          "type": "graph",
          "xaxis": {
            "show": true
          },
          "yaxes": [
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            },
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            }
          ]
        },
        {
          "aliasColors": {},
          "bars": false,
          "datasource": prometheus,
          "editable": true,
          "error": false,
          "fill": 1,
          "grid": {
            "threshold1": null,
            "threshold1Color": "rgba(216, 200, 27, 0.27)",
            "threshold2": null,
            "threshold2Color": "rgba(234, 112, 112, 0.22)"
          },
          "id": 20,
          "isNew": true,
          "legend": {
            "alignAsTable": false,
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
            "rightSide": false,
            "show": true,
            "total": false,
            "values": false
          },
          "lines": true,
          "linewidth": 2,
          "links": [],
          "nullPointMode": "connected",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "seriesOverrides": [],
          "span": 4,
          "stack": true,
          "steppedLine": false,
          "targets": [
            {
              "expr": "irate(haproxy_server_response_errors_total{backend=~\"$backend\", server=~\"$server\", alias=\"$alias\"}[$interval])",
              "interval": "$interval",
              "intervalFactor": 1,
              "legendFormat": "{{ backend }}/{{ server }}",
              "metric": "haproxy_backend_current_queue",
              "refId": "A",
              "step": 300
            }
          ],
          "timeFrom": null,
          "timeShift": null,
          "title": "Response Errors",
          "tooltip": {
            "msResolution": true,
            "shared": false,
            "sort": 0,
            "value_type": "individual"
          },
          "type": "graph",
          "xaxis": {
            "show": true
          },
          "yaxes": [
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            },
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            }
          ]
        },
        {
          "aliasColors": {},
          "bars": false,
          "datasource": prometheus,
          "editable": true,
          "error": false,
          "fill": 1,
          "grid": {
            "threshold1": null,
            "threshold1Color": "rgba(216, 200, 27, 0.27)",
            "threshold2": null,
            "threshold2Color": "rgba(234, 112, 112, 0.22)"
          },
          "id": 21,
          "isNew": true,
          "legend": {
            "alignAsTable": false,
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
            "rightSide": false,
            "show": true,
            "total": false,
            "values": false
          },
          "lines": true,
          "linewidth": 2,
          "links": [],
          "nullPointMode": "connected",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "seriesOverrides": [],
          "span": 4,
          "stack": true,
          "steppedLine": false,
          "targets": [
            {
              "expr": "irate(haproxy_server_retry_warnings_total{backend=~\"$backend\", server=~\"$server\", alias=\"$alias\"}[$interval])",
              "interval": "$interval",
              "intervalFactor": 1,
              "legendFormat": "{{ backend }}/{{ server }}",
              "metric": "haproxy_backend_current_queue",
              "refId": "A",
              "step": 300
            }
          ],
          "timeFrom": null,
          "timeShift": null,
          "title": "Retry Warnings",
          "tooltip": {
            "msResolution": true,
            "shared": false,
            "sort": 0,
            "value_type": "individual"
          },
          "type": "graph",
          "xaxis": {
            "show": true
          },
          "yaxes": [
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            },
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            }
          ]
        }
      ],
      "showTitle": true,
      "title": "Backend Responses"
    },
    {
      "collapse": false,
      "editable": true,
      "height": "250px",
      "panels": [
        {
          "aliasColors": {},
          "bars": false,
          "datasource": prometheus,
          "editable": true,
          "error": false,
          "fill": 1,
          "grid": {
            "threshold1": null,
            "threshold1Color": "rgba(216, 200, 27, 0.27)",
            "threshold2": null,
            "threshold2Color": "rgba(234, 112, 112, 0.22)"
          },
          "id": 1,
          "isNew": true,
          "legend": {
            "alignAsTable": true,
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
            "rightSide": true,
            "show": true,
            "total": false,
            "values": false
          },
          "lines": true,
          "linewidth": 2,
          "links": [],
          "nullPointMode": "connected",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "seriesOverrides": [],
          "span": 6,
          "stack": true,
          "steppedLine": false,
          "targets": [
            {
              "expr": "irate(haproxy_server_bytes_in_total{backend=~\"$backend\", server=~\"$server\", alias=\"$alias\"}[$interval])",
              "interval": "$interval",
              "intervalFactor": 1,
              "legendFormat": "{{ backend }}/{{ server }}",
              "metric": "haproxy_backend_",
              "refId": "A",
              "step": 300
            }
          ],
          "timeFrom": null,
          "timeShift": null,
          "title": "Bytes IN",
          "tooltip": {
            "msResolution": true,
            "shared": false,
            "sort": 0,
            "value_type": "individual"
          },
          "type": "graph",
          "xaxis": {
            "show": true
          },
          "yaxes": [
            {
              "format": "bytes",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            },
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            }
          ]
        },
        {
          "aliasColors": {},
          "bars": false,
          "datasource": prometheus,
          "editable": true,
          "error": false,
          "fill": 1,
          "grid": {
            "threshold1": null,
            "threshold1Color": "rgba(216, 200, 27, 0.27)",
            "threshold2": null,
            "threshold2Color": "rgba(234, 112, 112, 0.22)"
          },
          "id": 5,
          "isNew": true,
          "legend": {
            "alignAsTable": true,
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
            "rightSide": true,
            "show": true,
            "total": false,
            "values": false
          },
          "lines": true,
          "linewidth": 2,
          "links": [],
          "nullPointMode": "connected",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "seriesOverrides": [],
          "span": 6,
          "stack": true,
          "steppedLine": false,
          "targets": [
            {
              "expr": "irate(haproxy_server_bytes_out_total{backend=~\"$backend\", server=~\"$server\", alias=\"$alias\"}[$interval])",
              "interval": "$interval",
              "intervalFactor": 1,
              "legendFormat": "{{ backend }}/{{ server }}",
              "metric": "haproxy_backend_",
              "refId": "B",
              "step": 300
            }
          ],
          "timeFrom": null,
          "timeShift": null,
          "title": "Bytes OUT",
          "tooltip": {
            "msResolution": true,
            "shared": false,
            "sort": 0,
            "value_type": "individual"
          },
          "type": "graph",
          "xaxis": {
            "show": true
          },
          "yaxes": [
            {
              "format": "bytes",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            },
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            }
          ]
        }
      ],
      "showTitle": true,
      "title": "Throughput"
    },
    {
      "collapse": false,
      "editable": true,
      "height": "250px",
      "panels": [
        {
          "aliasColors": {},
          "bars": false,
          "datasource": prometheus,
          "editable": true,
          "error": false,
          "fill": 0,
          "grid": {
            "threshold1": null,
            "threshold1Color": "rgba(216, 200, 27, 0.27)",
            "threshold2": null,
            "threshold2Color": "rgba(234, 112, 112, 0.22)"
          },
          "id": 4,
          "isNew": true,
          "legend": {
            "alignAsTable": true,
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
            "rightSide": true,
            "show": true,
            "total": false,
            "values": false
          },
          "lines": true,
          "linewidth": 2,
          "links": [],
          "nullPointMode": "connected",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "seriesOverrides": [
            {
              "alias": "^ERRORS.*$",
              "fill": 2
            }
          ],
          "span": 6,
          "stack": true,
          "steppedLine": false,
          "targets": [
            {
              "expr": "irate(haproxy_server_connections_total{backend=~\"$backend\", server=~\"$server\", alias=\"$alias\"}[$interval])",
              "interval": "$interval",
              "intervalFactor": 1,
              "legendFormat": "{{ backend }}/{{ server }}",
              "metric": "haproxy_backe",
              "refId": "A",
              "step": 300
            }
          ],
          "timeFrom": null,
          "timeShift": null,
          "title": "New Connections Rate",
          "tooltip": {
            "msResolution": true,
            "shared": false,
            "sort": 0,
            "value_type": "individual"
          },
          "type": "graph",
          "xaxis": {
            "show": true
          },
          "yaxes": [
            {
              "format": "none",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            },
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            }
          ]
        },
        {
          "aliasColors": {},
          "bars": false,
          "datasource": prometheus,
          "editable": true,
          "error": false,
          "fill": 0,
          "grid": {
            "threshold1": null,
            "threshold1Color": "rgba(216, 200, 27, 0.27)",
            "threshold2": null,
            "threshold2Color": "rgba(234, 112, 112, 0.22)"
          },
          "id": 6,
          "isNew": true,
          "legend": {
            "alignAsTable": true,
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
            "rightSide": true,
            "show": true,
            "total": false,
            "values": false
          },
          "lines": true,
          "linewidth": 2,
          "links": [],
          "nullPointMode": "connected",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "seriesOverrides": [
            {
              "alias": "^ERRORS.*$",
              "fill": 2
            }
          ],
          "span": 6,
          "stack": true,
          "steppedLine": false,
          "targets": [
            {
              "expr": "irate(haproxy_server_connection_errors_total{backend=~\"$backend\", server=~\"$server\", alias=\"$alias\"}[$interval])",
              "interval": "$interval",
              "intervalFactor": 1,
              "legendFormat": "{{ backend }}/{{ server }}",
              "metric": "haproxy_backe",
              "refId": "B",
              "step": 300
            }
          ],
          "timeFrom": null,
          "timeShift": null,
          "title": "Connection Errors Rate",
          "tooltip": {
            "msResolution": true,
            "shared": false,
            "sort": 0,
            "value_type": "individual"
          },
          "type": "graph",
          "xaxis": {
            "show": true
          },
          "yaxes": [
            {
              "format": "none",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            },
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            }
          ]
        }
      ],
      "showTitle": true,
      "title": "Connections"
    },
    {
      "collapse": false,
      "editable": true,
      "height": "250px",
      "panels": [
        {
          "aliasColors": {},
          "bars": false,
          "datasource": prometheus,
          "editable": true,
          "error": false,
          "fill": 1,
          "grid": {
            "threshold1": null,
            "threshold1Color": "rgba(216, 200, 27, 0.27)",
            "threshold2": null,
            "threshold2Color": "rgba(234, 112, 112, 0.22)"
          },
          "id": 7,
          "isNew": true,
          "legend": {
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
            "show": true,
            "total": false,
            "values": false
          },
          "lines": true,
          "linewidth": 2,
          "links": [],
          "nullPointMode": "connected",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "seriesOverrides": [],
          "span": 6,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "haproxy_server_current_queue{backend=~\"$backend\", server=~\"$server\", alias=\"$alias\"}",
              "interval": "$interval",
              "intervalFactor": 1,
              "legendFormat": "{{ backend }}/{{ server }}",
              "metric": "haproxy_backend_current_queue",
              "refId": "A",
              "step": 300
            }
          ],
          "timeFrom": null,
          "timeShift": null,
          "title": "Current Queue Size",
          "tooltip": {
            "msResolution": true,
            "shared": false,
            "sort": 0,
            "value_type": "cumulative"
          },
          "type": "graph",
          "xaxis": {
            "show": true
          },
          "yaxes": [
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            },
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            }
          ]
        },
        {
          "aliasColors": {},
          "bars": false,
          "datasource": prometheus,
          "editable": true,
          "error": false,
          "fill": 1,
          "grid": {
            "threshold1": null,
            "threshold1Color": "rgba(216, 200, 27, 0.27)",
            "threshold2": null,
            "threshold2Color": "rgba(234, 112, 112, 0.22)"
          },
          "id": 8,
          "isNew": true,
          "legend": {
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
            "show": true,
            "total": false,
            "values": false
          },
          "lines": true,
          "linewidth": 2,
          "links": [],
          "nullPointMode": "connected",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "seriesOverrides": [],
          "span": 6,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "haproxy_server_max_queue{backend=~\"$backend\", server=~\"$server\", alias=\"$alias\"}",
              "interval": "$interval",
              "intervalFactor": 1,
              "legendFormat": "{{ backend }}/{{ server }}",
              "metric": "haproxy_backend_current_queue",
              "refId": "A",
              "step": 300
            }
          ],
          "timeFrom": null,
          "timeShift": null,
          "title": "Max Queue Size",
          "tooltip": {
            "msResolution": true,
            "shared": false,
            "sort": 0,
            "value_type": "cumulative"
          },
          "type": "graph",
          "xaxis": {
            "show": true
          },
          "yaxes": [
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            },
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            }
          ]
        }
      ],
      "showTitle": true,
      "title": "Queues"
    },
    {
      "collapse": false,
      "editable": true,
      "height": "250px",
      "panels": [
        {
          "aliasColors": {},
          "bars": false,
          "datasource": prometheus,
          "editable": true,
          "error": false,
          "fill": 1,
          "grid": {
            "threshold1": null,
            "threshold1Color": "rgba(216, 200, 27, 0.27)",
            "threshold2": null,
            "threshold2Color": "rgba(234, 112, 112, 0.22)"
          },
          "id": 10,
          "isNew": true,
          "legend": {
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
            "show": true,
            "total": false,
            "values": false
          },
          "lines": true,
          "linewidth": 2,
          "links": [],
          "nullPointMode": "connected",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "seriesOverrides": [],
          "span": 6,
          "stack": true,
          "steppedLine": false,
          "targets": [
            {
              "expr": "haproxy_server_current_sessions{backend=~\"$backend\", server=~\"$server\", alias=\"$alias\"}",
              "interval": "$interval",
              "intervalFactor": 1,
              "legendFormat": "{{ backend }}/{{ server }}",
              "metric": "haproxy_backend_current_queue",
              "refId": "A",
              "step": 300
            }
          ],
          "timeFrom": null,
          "timeShift": null,
          "title": "Active Sessions",
          "tooltip": {
            "msResolution": true,
            "shared": false,
            "sort": 0,
            "value_type": "individual"
          },
          "type": "graph",
          "xaxis": {
            "show": true
          },
          "yaxes": [
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            },
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            }
          ]
        },
        {
          "aliasColors": {},
          "bars": false,
          "datasource": prometheus,
          "editable": true,
          "error": false,
          "fill": 1,
          "grid": {
            "threshold1": null,
            "threshold1Color": "rgba(216, 200, 27, 0.27)",
            "threshold2": null,
            "threshold2Color": "rgba(234, 112, 112, 0.22)"
          },
          "id": 11,
          "isNew": true,
          "legend": {
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
            "show": true,
            "total": false,
            "values": false
          },
          "lines": true,
          "linewidth": 2,
          "links": [],
          "nullPointMode": "connected",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "seriesOverrides": [],
          "span": 6,
          "stack": true,
          "steppedLine": false,
          "targets": [
            {
              "expr": "haproxy_server_current_session_rate{backend=~\"$backend\", server=~\"$server\", alias=\"$alias\"}",
              "interval": "$interval",
              "intervalFactor": 1,
              "legendFormat": "{{ backend }}/{{ server }}",
              "metric": "haproxy_backend_current_queue",
              "refId": "A",
              "step": 300
            }
          ],
          "timeFrom": null,
          "timeShift": null,
          "title": "New Session Rate",
          "tooltip": {
            "msResolution": true,
            "shared": false,
            "sort": 0,
            "value_type": "individual"
          },
          "type": "graph",
          "xaxis": {
            "show": true
          },
          "yaxes": [
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            },
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            }
          ]
        },
        {
          "aliasColors": {},
          "bars": false,
          "datasource": prometheus,
          "editable": true,
          "error": false,
          "fill": 0,
          "grid": {
            "threshold1": null,
            "threshold1Color": "rgba(216, 200, 27, 0.27)",
            "threshold2": null,
            "threshold2Color": "rgba(234, 112, 112, 0.22)"
          },
          "id": 12,
          "isNew": true,
          "legend": {
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
            "show": true,
            "total": false,
            "values": false
          },
          "lines": true,
          "linewidth": 2,
          "links": [],
          "nullPointMode": "connected",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "seriesOverrides": [],
          "span": 6,
          "stack": true,
          "steppedLine": false,
          "targets": [
            {
              "expr": "haproxy_server_max_sessions{backend=~\"$backend\", server=~\"$server\", alias=\"$alias\"}",
              "interval": "$interval",
              "intervalFactor": 1,
              "legendFormat": "{{ backend }}/{{ server }}",
              "metric": "haproxy_backend_current_queue",
              "refId": "A",
              "step": 300
            }
          ],
          "timeFrom": null,
          "timeShift": null,
          "title": "Max Active Sessions",
          "tooltip": {
            "msResolution": true,
            "shared": false,
            "sort": 0,
            "value_type": "individual"
          },
          "type": "graph",
          "xaxis": {
            "show": true
          },
          "yaxes": [
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            },
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            }
          ]
        },
        {
          "aliasColors": {},
          "bars": false,
          "datasource": prometheus,
          "editable": true,
          "error": false,
          "fill": 0,
          "grid": {
            "threshold1": null,
            "threshold1Color": "rgba(216, 200, 27, 0.27)",
            "threshold2": null,
            "threshold2Color": "rgba(234, 112, 112, 0.22)"
          },
          "id": 13,
          "isNew": true,
          "legend": {
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
            "show": true,
            "total": false,
            "values": false
          },
          "lines": true,
          "linewidth": 2,
          "links": [],
          "nullPointMode": "connected",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "seriesOverrides": [],
          "span": 6,
          "stack": true,
          "steppedLine": false,
          "targets": [
            {
              "expr": "haproxy_server_max_session_rate{backend=~\"$backend\", server=~\"$server\", alias=\"$alias\"}",
              "interval": "$interval",
              "intervalFactor": 1,
              "legendFormat": "{{ backend }}/{{ server }}",
              "metric": "haproxy_backend_current_queue",
              "refId": "A",
              "step": 300
            }
          ],
          "timeFrom": null,
          "timeShift": null,
          "title": "Max Session Rate",
          "tooltip": {
            "msResolution": true,
            "shared": false,
            "sort": 0,
            "value_type": "individual"
          },
          "type": "graph",
          "xaxis": {
            "show": true
          },
          "yaxes": [
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            },
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            }
          ]
        }
      ],
      "showTitle": true,
      "title": "Sessions"
    },
    {
      "collapse": false,
      "editable": true,
      "height": "250px",
      "panels": [
        {
          "aliasColors": {},
          "bars": false,
          "datasource": prometheus,
          "decimals": 0,
          "editable": true,
          "error": false,
          "fill": 1,
          "grid": {
            "threshold1": null,
            "threshold1Color": "rgba(216, 200, 27, 0.27)",
            "threshold2": null,
            "threshold2Color": "rgba(234, 112, 112, 0.22)"
          },
          "id": 22,
          "isNew": true,
          "legend": {
            "avg": false,
            "current": false,
            "max": false,
            "min": true,
            "show": true,
            "total": false,
            "values": true
          },
          "lines": true,
          "linewidth": 2,
          "links": [],
          "nullPointMode": "connected",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "seriesOverrides": [],
          "span": 6,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "haproxy_server_up{backend=~\"$backend\", server=~\"$server\", alias=\"$alias\"}",
              "intervalFactor": 2,
              "legendFormat": "{{ backend }}/{{ server }}",
              "refId": "A",
              "step": 30
            }
          ],
          "timeFrom": null,
          "timeShift": null,
          "title": "Servers UP",
          "tooltip": {
            "msResolution": true,
            "shared": false,
            "sort": 0,
            "value_type": "cumulative"
          },
          "type": "graph",
          "xaxis": {
            "show": true
          },
          "yaxes": [
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            },
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": 0,
              "show": true
            }
          ]
        },
        {
          "aliasColors": {},
          "bars": false,
          "datasource": prometheus,
          "editable": true,
          "error": false,
          "fill": 1,
          "grid": {
            "threshold1": null,
            "threshold1Color": "rgba(216, 200, 27, 0.27)",
            "threshold2": null,
            "threshold2Color": "rgba(234, 112, 112, 0.22)"
          },
          "id": 23,
          "isNew": true,
          "legend": {
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
            "show": true,
            "total": false,
            "values": false
          },
          "lines": true,
          "linewidth": 2,
          "links": [],
          "nullPointMode": "connected",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "seriesOverrides": [],
          "span": 6,
          "stack": true,
          "steppedLine": false,
          "targets": [
            {
              "expr": "haproxy_server_weight{backend=~\"$backend\", server=~\"$server\", alias=\"$alias\"}",
              "intervalFactor": 2,
              "legendFormat": "{{ backend }}/{{ server }}",
              "refId": "A",
              "step": 30
            }
          ],
          "timeFrom": null,
          "timeShift": null,
          "title": "Servers Weights",
          "tooltip": {
            "msResolution": true,
            "shared": true,
            "sort": 0,
            "value_type": "cumulative"
          },
          "type": "graph",
          "xaxis": {
            "show": true
          },
          "yaxes": [
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": null,
              "show": true
            },
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": null,
              "show": true
            }
          ]
        }
      ],
      "title": "New row"
    }
  ],
  "time": {
    "from": "now-6h",
    "to": "now"
  },
  "timepicker": {
    "refresh_intervals": [
      "5s",
      "10s",
      "30s",
      "1m",
      "5m",
      "15m",
      "30m",
      "1h",
      "2h",
      "1d"
    ],
    "time_options": [
      "5m",
      "15m",
      "1h",
      "6h",
      "12h",
      "24h",
      "2d",
      "7d",
      "30d"
    ]
  },
  "templating": {
    "list": [
      {
        "auto": true,
        "current": {
          "tags": [],
          "text": "5m",
          "value": "5m"
        },
        "datasource": null,
        "hide": 0,
        "includeAll": false,
        "label": "Interval",
        "multi": false,
        "name": "interval",
        "options": [
          {
            "selected": false,
            "text": "auto",
            "value": "$__auto_interval"
          },
          {
            "selected": false,
            "text": "1s",
            "value": "1s"
          },
          {
            "selected": false,
            "text": "5s",
            "value": "5s"
          },
          {
            "selected": false,
            "text": "1m",
            "value": "1m"
          },
          {
            "selected": true,
            "text": "5m",
            "value": "5m"
          },
          {
            "selected": false,
            "text": "1h",
            "value": "1h"
          },
          {
            "selected": false,
            "text": "6h",
            "value": "6h"
          },
          {
            "selected": false,
            "text": "1d",
            "value": "1d"
          }
        ],
        "query": "1s,5s,1m,5m,1h,6h,1d",
        "refresh": 0,
        "type": "interval"
      },
      {
        "current": {},
        "datasource": prometheus,
        "hide": 0,
        "includeAll": false,
        "label": "Load Balancer",
        "multi": false,
        "name": "alias",
        "options": [],
        "query": "label_values(haproxy_up, alias)",
        "refresh": 1,
        "regex": "",
        "type": "query"
      },
      {
        "current": {},
        "datasource": prometheus,
        "hide": 0,
        "includeAll": true,
        "label": "Backend",
        "multi": true,
        "name": "backend",
        "options": [],
        "query": "label_values(haproxy_server_bytes_in_total{alias=\"$alias\"}, backend)",
        "refresh": 1,
        "regex": "",
        "type": "query"
      },
      {
        "current": {},
        "datasource": prometheus,
        "hide": 0,
        "includeAll": true,
        "label": "Server",
        "multi": true,
        "name": "server",
        "options": [],
        "query": "label_values(haproxy_server_bytes_in_total{alias=\"$alias\", backend=~\"$backend\"}, server)",
        "refresh": 1,
        "regex": "",
        "type": "query"
      },
      {
        "current": {},
        "datasource": prometheus,
        "hide": 0,
        "includeAll": true,
        "label": "HTTP Code",
        "multi": true,
        "name": "code",
        "options": [],
        "query": "label_values(haproxy_server_http_responses_total{alias=\"$alias\", backend=~\"$backend\", server=~\"$server\"}, code)",
        "refresh": 1,
        "regex": "",
        "type": "query"
      }
    ]
  },
  "annotations": {
    "list": []
  },
  "refresh": "1m",
  "schemaVersion": 12,
  "version": 2,
  "links": [],
  "gnetId": 367
}
