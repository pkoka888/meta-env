#!/usr/bin/env node

/**
 * Custom MCP Server for Prometheus Integration
 *
 * Provides monitoring and metrics capabilities for Claude Code
 * integrating with Prometheus, Grafana, and other observability tools
 *
 * Reference: 3-deep-dive.md - Monitoring Integration
 */

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
  ListResourcesRequestSchema,
  ReadResourceRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';
import fetch from 'node-fetch';

// Configuration
const PROMETHEUS_URL = process.env.PROMETHEUS_URL || 'http://localhost:9090';
const GRAFANA_URL = process.env.GRAFANA_URL || 'http://localhost:3000';
const GRAFANA_API_KEY = process.env.GRAFANA_API_KEY || '';

class PrometheusServer {
  constructor() {
    this.server = new Server(
      {
        name: 'prometheus-mcp-server',
        version: '1.0.0',
      },
      {
        capabilities: {
          resources: {},
          tools: {},
        },
      }
    );

    this.setupHandlers();
    this.setupErrorHandling();
  }

  setupErrorHandling() {
    this.server.onerror = (error) => {
      console.error('[MCP Error]', error);
    };

    process.on('SIGINT', async () => {
      await this.server.close();
      process.exit(0);
    });
  }

  setupHandlers() {
    // List available tools
    this.server.setRequestHandler(ListToolsRequestSchema, async () => ({
      tools: [
        {
          name: 'query_metrics',
          description: 'Execute PromQL query to retrieve metrics from Prometheus',
          inputSchema: {
            type: 'object',
            properties: {
              query: {
                type: 'string',
                description: 'PromQL query string',
              },
              time: {
                type: 'string',
                description: 'Evaluation timestamp (RFC3339 or Unix timestamp)',
              },
            },
            required: ['query'],
          },
        },
        {
          name: 'query_range',
          description: 'Execute PromQL query over a time range',
          inputSchema: {
            type: 'object',
            properties: {
              query: {
                type: 'string',
                description: 'PromQL query string',
              },
              start: {
                type: 'string',
                description: 'Start timestamp',
              },
              end: {
                type: 'string',
                description: 'End timestamp',
              },
              step: {
                type: 'string',
                description: 'Query resolution step width (e.g., "15s", "1m")',
                default: '15s',
              },
            },
            required: ['query', 'start', 'end'],
          },
        },
        {
          name: 'list_metrics',
          description: 'List all available metrics in Prometheus',
          inputSchema: {
            type: 'object',
            properties: {
              match: {
                type: 'string',
                description: 'Optional metric name pattern to filter',
              },
            },
          },
        },
        {
          name: 'get_targets',
          description: 'Get current state of Prometheus targets',
          inputSchema: {
            type: 'object',
            properties: {
              state: {
                type: 'string',
                enum: ['active', 'dropped', 'any'],
                description: 'Target state filter',
                default: 'active',
              },
            },
          },
        },
        {
          name: 'get_alerts',
          description: 'Get active alerts from Prometheus',
          inputSchema: {
            type: 'object',
            properties: {},
          },
        },
        {
          name: 'create_grafana_dashboard',
          description: 'Create or update Grafana dashboard',
          inputSchema: {
            type: 'object',
            properties: {
              title: {
                type: 'string',
                description: 'Dashboard title',
              },
              panels: {
                type: 'array',
                description: 'Dashboard panels configuration',
              },
            },
            required: ['title'],
          },
        },
        {
          name: 'get_grafana_dashboards',
          description: 'List all Grafana dashboards',
          inputSchema: {
            type: 'object',
            properties: {
              tag: {
                type: 'string',
                description: 'Filter by tag',
              },
            },
          },
        },
        {
          name: 'analyze_performance',
          description: 'Analyze system performance metrics and provide insights',
          inputSchema: {
            type: 'object',
            properties: {
              service: {
                type: 'string',
                description: 'Service name to analyze',
              },
              timeRange: {
                type: 'string',
                description: 'Time range (e.g., "1h", "24h", "7d")',
                default: '1h',
              },
            },
            required: ['service'],
          },
        },
      ],
    }));

    // List available resources
    this.server.setRequestHandler(ListResourcesRequestSchema, async () => ({
      resources: [
        {
          uri: 'prometheus://metrics',
          name: 'Available Metrics',
          description: 'List of all metrics in Prometheus',
          mimeType: 'application/json',
        },
        {
          uri: 'prometheus://targets',
          name: 'Prometheus Targets',
          description: 'Current state of monitored targets',
          mimeType: 'application/json',
        },
        {
          uri: 'prometheus://alerts',
          name: 'Active Alerts',
          description: 'Currently firing alerts',
          mimeType: 'application/json',
        },
      ],
    }));

    // Handle tool calls
    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      try {
        switch (name) {
          case 'query_metrics':
            return await this.queryMetrics(args.query, args.time);

          case 'query_range':
            return await this.queryRange(args.query, args.start, args.end, args.step);

          case 'list_metrics':
            return await this.listMetrics(args.match);

          case 'get_targets':
            return await this.getTargets(args.state);

          case 'get_alerts':
            return await this.getAlerts();

          case 'create_grafana_dashboard':
            return await this.createGrafanaDashboard(args.title, args.panels);

          case 'get_grafana_dashboards':
            return await this.getGrafanaDashboards(args.tag);

          case 'analyze_performance':
            return await this.analyzePerformance(args.service, args.timeRange);

          default:
            throw new Error(`Unknown tool: ${name}`);
        }
      } catch (error) {
        return {
          content: [
            {
              type: 'text',
              text: `Error: ${error.message}`,
            },
          ],
          isError: true,
        };
      }
    });
  }

  async queryMetrics(query, time) {
    const url = new URL(`${PROMETHEUS_URL}/api/v1/query`);
    url.searchParams.set('query', query);
    if (time) url.searchParams.set('time', time);

    const response = await fetch(url);
    const data = await response.json();

    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify(data, null, 2),
        },
      ],
    };
  }

  async queryRange(query, start, end, step = '15s') {
    const url = new URL(`${PROMETHEUS_URL}/api/v1/query_range`);
    url.searchParams.set('query', query);
    url.searchParams.set('start', start);
    url.searchParams.set('end', end);
    url.searchParams.set('step', step);

    const response = await fetch(url);
    const data = await response.json();

    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify(data, null, 2),
        },
      ],
    };
  }

  async listMetrics(match) {
    const url = new URL(`${PROMETHEUS_URL}/api/v1/label/__name__/values`);
    const response = await fetch(url);
    const data = await response.json();

    let metrics = data.data || [];
    if (match) {
      const pattern = new RegExp(match, 'i');
      metrics = metrics.filter((m) => pattern.test(m));
    }

    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify({ metrics, count: metrics.length }, null, 2),
        },
      ],
    };
  }

  async getTargets(state = 'active') {
    const url = new URL(`${PROMETHEUS_URL}/api/v1/targets`);
    if (state !== 'any') {
      url.searchParams.set('state', state);
    }

    const response = await fetch(url);
    const data = await response.json();

    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify(data, null, 2),
        },
      ],
    };
  }

  async getAlerts() {
    const url = new URL(`${PROMETHEUS_URL}/api/v1/alerts`);
    const response = await fetch(url);
    const data = await response.json();

    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify(data, null, 2),
        },
      ],
    };
  }

  async createGrafanaDashboard(title, panels = []) {
    if (!GRAFANA_API_KEY) {
      throw new Error('GRAFANA_API_KEY not configured');
    }

    const dashboard = {
      dashboard: {
        title,
        panels,
        schemaVersion: 16,
        version: 0,
      },
      overwrite: true,
    };

    const response = await fetch(`${GRAFANA_URL}/api/dashboards/db`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${GRAFANA_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(dashboard),
    });

    const data = await response.json();

    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify(data, null, 2),
        },
      ],
    };
  }

  async getGrafanaDashboards(tag) {
    const url = new URL(`${GRAFANA_URL}/api/search`);
    url.searchParams.set('type', 'dash-db');
    if (tag) url.searchParams.set('tag', tag);

    const response = await fetch(url, {
      headers: GRAFANA_API_KEY
        ? { 'Authorization': `Bearer ${GRAFANA_API_KEY}` }
        : {},
    });

    const data = await response.json();

    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify(data, null, 2),
        },
      ],
    };
  }

  async analyzePerformance(service, timeRange = '1h') {
    const now = Math.floor(Date.now() / 1000);
    const ranges = {
      '1h': 3600,
      '24h': 86400,
      '7d': 604800,
    };
    const seconds = ranges[timeRange] || 3600;
    const start = now - seconds;

    // Query multiple metrics for comprehensive analysis
    const queries = [
      `rate(http_requests_total{service="${service}"}[5m])`,
      `histogram_quantile(0.95, rate(http_request_duration_seconds_bucket{service="${service}"}[5m]))`,
      `up{service="${service}"}`,
      `process_resident_memory_bytes{service="${service}"}`,
      `rate(process_cpu_seconds_total{service="${service}"}[5m])`,
    ];

    const results = await Promise.all(
      queries.map((query) =>
        this.queryRange(query, start.toString(), now.toString(), '1m')
      )
    );

    const analysis = {
      service,
      timeRange,
      metrics: results,
      summary: 'Performance analysis complete',
    };

    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify(analysis, null, 2),
        },
      ],
    };
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error('Prometheus MCP server running on stdio');
  }
}

// Start the server
const server = new PrometheusServer();
server.run().catch(console.error);
