// Health check para Docker
// Este arquivo verifica se a aplicação está respondendo corretamente

const http = require('http');

const options = {
  host: 'localhost',
  port: process.env.PORT || 8080,
  path: '/',
  timeout: 2000,
  method: 'GET'
};

const request = http.request(options, (res) => {
  console.log(`Health check: ${res.statusCode}`);
  if (res.statusCode === 200) {
    process.exit(0); // Sucesso
  } else {
    process.exit(1); // Falha
  }
});

request.on('error', (err) => {
  console.error('Health check failed:', err.message);
  process.exit(1);
});

request.on('timeout', () => {
  console.error('Health check timeout');
  request.destroy();
  process.exit(1);
});

request.end();
