import express from 'express';
import { createProxyMiddleware } from 'http-proxy-middleware';
import { fileURLToPath } from 'url';
import { dirname } from 'path';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3000;
const AUTH_TOKEN = process.env.AUTH_TOKEN || 'default-token';

// Middleware to parse JSON
app.use(express.json());

/**
 * Bearer Token Authentication Middleware
 * Validates Authorization: Bearer ${AUTH_TOKEN}
 */
const authMiddleware = (req, res, next) => {
  // Skip auth for health check endpoint
  if (req.path === '/health') {
    return next();
  }

  const authHeader = req.headers.authorization;
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      error: 'Unauthorized',
      message: 'Missing or invalid Authorization header. Use: Authorization: Bearer <token>'
    });
  }

  const token = authHeader.slice(7); // Remove "Bearer " prefix

  if (token !== AUTH_TOKEN) {
    return res.status(401).json({
      error: 'Unauthorized',
      message: 'Invalid authentication token'
    });
  }

  next();
};

// Apply authentication middleware to all routes except health check
app.use(authMiddleware);

/**
 * Health Check Endpoint
 */
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy', message: 'MCP Gateway is running' });
});

/**
 * Reverse Proxy Configuration for MCP Servers
 * Routes incoming requests to respective MCP server backends
 */

// Git MCP Server
app.use('/git', createProxyMiddleware({
  target: process.env.MCP_GIT_URL || 'http://mcp-git:3001',
  changeOrigin: true,
  pathRewrite: {
    '^/git': ''
  },
  onError: (err, req, res) => {
    console.error(`[Git MCP Error]: ${err.message}`);
    res.status(503).json({
      error: 'Service Unavailable',
      message: 'Git MCP Server is unavailable',
      details: err.message
    });
  }
}));

// GitHub MCP Server
app.use('/github', createProxyMiddleware({
  target: process.env.MCP_GITHUB_URL || 'http://mcp-github:3002',
  changeOrigin: true,
  pathRewrite: {
    '^/github': ''
  },
  onError: (err, req, res) => {
    console.error(`[GitHub MCP Error]: ${err.message}`);
    res.status(503).json({
      error: 'Service Unavailable',
      message: 'GitHub MCP Server is unavailable',
      details: err.message
    });
  }
}));

// Filesystem MCP Server
app.use('/filesystem', createProxyMiddleware({
  target: process.env.MCP_FILESYSTEM_URL || 'http://mcp-filesystem:3003',
  changeOrigin: true,
  pathRewrite: {
    '^/filesystem': ''
  },
  onError: (err, req, res) => {
    console.error(`[Filesystem MCP Error]: ${err.message}`);
    res.status(503).json({
      error: 'Service Unavailable',
      message: 'Filesystem MCP Server is unavailable',
      details: err.message
    });
  }
}));

// PostgreSQL MCP Server
app.use('/postgres', createProxyMiddleware({
  target: process.env.MCP_POSTGRES_URL || 'http://mcp-postgres:3004',
  changeOrigin: true,
  pathRewrite: {
    '^/postgres': ''
  },
  onError: (err, req, res) => {
    console.error(`[PostgreSQL MCP Error]: ${err.message}`);
    res.status(503).json({
      error: 'Service Unavailable',
      message: 'PostgreSQL MCP Server is unavailable',
      details: err.message
    });
  }
}));

// Fetch MCP Server
app.use('/fetch', createProxyMiddleware({
  target: process.env.MCP_FETCH_URL || 'http://mcp-fetch:3005',
  changeOrigin: true,
  pathRewrite: {
    '^/fetch': ''
  },
  onError: (err, req, res) => {
    console.error(`[Fetch MCP Error]: ${err.message}`);
    res.status(503).json({
      error: 'Service Unavailable',
      message: 'Fetch MCP Server is unavailable',
      details: err.message
    });
  }
}));

// Playwright MCP Server
app.use('/playwright', createProxyMiddleware({
  target: process.env.MCP_PLAYWRIGHT_URL || 'http://mcp-playwright:3006',
  changeOrigin: true,
  pathRewrite: {
    '^/playwright': ''
  },
  onError: (err, req, res) => {
    console.error(`[Playwright MCP Error]: ${err.message}`);
    res.status(503).json({
      error: 'Service Unavailable',
      message: 'Playwright MCP Server is unavailable',
      details: err.message
    });
  }
}));

/**
 * Root endpoint - gateway info
 */
app.get('/', (req, res) => {
  res.status(200).json({
    name: 'MCP Gateway',
    version: '1.0.0',
    description: 'Unified gateway for Model Context Protocol servers',
    endpoints: {
      git: '/git',
      github: '/github',
      filesystem: '/filesystem',
      postgres: '/postgres',
      fetch: '/fetch',
      playwright: '/playwright'
    },
    health: '/health',
    authentication: 'Bearer token in Authorization header'
  });
});

/**
 * 404 Handler
 */
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Endpoint ${req.path} not found`,
    availableEndpoints: ['/git', '/github', '/filesystem', '/postgres', '/fetch', '/playwright', '/health']
  });
});

/**
 * Error Handler
 */
app.use((err, req, res, next) => {
  console.error('[Gateway Error]:', err);
  res.status(500).json({
    error: 'Internal Server Error',
    message: err.message || 'An unexpected error occurred'
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`MCP Gateway listening on port ${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
});
