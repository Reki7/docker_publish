// src/index.js
const fs = require('fs');
const http = require('http');
const os = require('os');

const buildSecretPath = '/run/secrets/build_secret';
const runtimeSecret = process.env.RUNTIME_SECRET || 'not set';

let buildSecret = 'not found';
if (fs.existsSync(buildSecretPath)) {
  buildSecret = fs.readFileSync(buildSecretPath, 'utf8').trim();
}

// Фиксируем время старта
const startTime = Date.now();

// Форматируем аптайм в человекочитаемом виде
function formatUptime(ms) {
  const seconds = Math.floor(ms / 1000);
  const minutes = Math.floor(seconds / 60);
  const hours = Math.floor(minutes / 60);
  const days = Math.floor(hours / 24);

  const secs = seconds % 60;
  const mins = minutes % 60;
  const hrs = hours % 24;

  if (days > 0) return `${days}d ${hrs}h ${mins}m`;
  if (hours > 0) return `${hrs}h ${mins}m ${secs}s`;
  if (minutes > 0) return `${mins}m ${secs}s`;
  return `${secs}s`;
}

const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    const uptimeMs = Date.now() - startTime;
    const healthData = {
      status: 'ok',
      uptime_seconds: Math.floor(uptimeMs / 1000),
      uptime: formatUptime(uptimeMs),
      timestamp: new Date().toISOString(),
      hostname: os.hostname(),
      version: process.env.APP_VERSION || 'unknown',
      node_env: process.env.NODE_ENV || 'unknown',
    };

    res.writeHead(200, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify(healthData, null, 2));
  }

  if (req.url === '/') {
    res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
    res.end(
      `===================================\n` +
      `🔧 Build-time secret: ${buildSecret}\n` +
      `🚀 Runtime secret: ${runtimeSecret}\n` +
      `📊 Uptime: ${formatUptime(Date.now() - startTime)}\n` +
      `🌍 Server is running on port 3000\n` +
      `===================================\n`
    );
  }

  res.writeHead(404);
  res.end('Not found');
});

const PORT = 3000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on http://0.0.0.0:${PORT}`);
  console.log(`Health: http://0.0.0.0:${PORT}/health`);
});
