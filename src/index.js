const fs = require('fs');
const http = require('http');

const buildSecretPath = '/run/secrets/build_secret';
const runtimeSecret = process.env.RUNTIME_SECRET || 'not set';

let buildSecret = 'not found';
if (fs.existsSync(buildSecretPath)) {
  buildSecret = fs.readFileSync(buildSecretPath, 'utf8').trim();
}

// Простой HTTP-сервер
const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({ status: 'ok', version: process.env.APP_VERSION }));
  }

  if (req.url === '/') {
    res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
    res.end(
      `===================================\n` +
      `🔧 Build-time secret: ${buildSecret}\n` +
      `🚀 Runtime secret: ${runtimeSecret}\n` +
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
});
