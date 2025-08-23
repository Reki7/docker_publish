const http = require('http');
const fs = require('fs');
const os = require('os');
const client = require('prom-client');

// === Prometheus метрики ===
const register = new client.Registry();

// Стандартные метрики Node.js
client.collectDefaultMetrics({ register });

// Кастомная метрика: uptime в секундах
const uptimeGauge = new client.Gauge({
  name: 'app_uptime_seconds',
  help: 'Application uptime in seconds',
  registers: [register],
});
// Встроенная метрика: uptime процесса
new client.Gauge({
  name: 'process_uptime_seconds',
  help: 'Process uptime in seconds',
  collect() {
    this.set(process.uptime());
  }
});

// Версия приложения
const versionInfo = new client.Gauge({
  name: 'app_info',
  help: 'App version info',
  labelNames: ['version', 'node_env'],
  registers: [register],
});

// Фиксируем время старта
const startTime = Date.now();

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

// Обновляем метрики каждую секунду
setInterval(() => {
  const uptimeSec = (Date.now() - startTime) / 1000;
  uptimeGauge.set(uptimeSec);
}, 1000);

// Устанавливаем версию при старте
versionInfo.set(
  { version: process.env.APP_VERSION || 'unknown', node_env: process.env.NODE_ENV || 'unknown' },
  1
);

// Секреты
const buildSecretPath = '/run/secrets/build_secret';
let buildSecret = 'not found';
if (fs.existsSync(buildSecretPath)) {
  buildSecret = fs.readFileSync(buildSecretPath, 'utf8').trim();
}
const runtimeSecretPath = '/run/secrets/runtime_secret_2';
let runtimeSecretFile = 'not found';
if (fs.existsSync(runtimeSecretPath)) {
  runtimeSecretFile = fs.readFileSync(runtimeSecretPath, 'utf8').trim();
}
const runtimeSecretEnv = process.env.RUNTIME_SECRET || 'not set';

// HTTP-сервер
const server = http.createServer(async (req, res) => {
  if (req.url === '/metrics') {
    res.setHeader('Content-Type', register.contentType);
    res.end(await register.metrics());
    return;
  }

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
    return res.end(
      `===================================\n` +
      `🔧 Build-time secret: ${buildSecret}\n` +
      `🚀 Runtime secret file: ${runtimeSecretFile}\n` +
      `🚀 Runtime secret env: ${runtimeSecretEnv}\n` +
      `📊 Uptime: ${formatUptime(Date.now() - startTime)}\n` +
      `🌍 Server is running on port 3000\n` +
      `📈 Metrics: http://localhost:3000/metrics\n` +
      `✅ Health: http://localhost:3000/health\n` +
      `Grafana: http://localhost:3001\n` +
      `Prometheus: http://localhost:9090\n` +
      `===================================\n`
    );
  }

  res.writeHead(404);
  return res.end('Not found');
});

const PORT = 3000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on http://0.0.0.0:${PORT}`);
  console.log(`Health: http://0.0.0.0:${PORT}/health`);
  console.log(`Metrics: http://0.0.0.0:${PORT}/metrics`);
});

// setInterval(() => {
//   console.log(`⏱️  Uptime: ${formatUptime(Date.now() - startTime)}`);
// }, 30000);