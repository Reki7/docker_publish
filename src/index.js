// src/index.js
const fs = require('fs');

let buildSecret = 'not found';

if (fs.existsSync('/run/secrets/build_secret')) {
  buildSecret = fs.readFileSync('/run/secrets/build_secret', 'utf8').trim();
} else {
  console.warn('Build secret file not found at /run/secrets/build_secret');
}

const runtimeSecret = process.env.RUNTIME_SECRET || 'not set';

console.log('===================================');
console.log('🔧 Build-time secret:', buildSecret);
console.log('🚀 Runtime secret:', runtimeSecret);
console.log('===================================');
