// Importando os módulos necessários
const express = require('express'); // Módulo Express para criar o servidor
const path = require('path'); // Módulo Path para lidar com caminhos de arquivos
const fs = require('fs'); // Módulo File System para ler arquivos
const helmet = require('helmet'); // Módulo Helmet para segurança HTTP

// Criando uma instância do servidor Express
const app = express();

// Configurações de segurança com Helmet
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"]
    }
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  }
}));

// Middleware de segurança customizado
app.use((req, res, next) => {
  // Previne XSS via response.redirect()
  res.locals.redirectSafe = (url) => {
    // Valida URLs para prevenir open redirect
    const allowedDomains = ['localhost', '127.0.0.1'];
    try {
      const parsedUrl = new URL(url);
      if (!allowedDomains.includes(parsedUrl.hostname)) {
        return res.status(400).send('Invalid redirect URL');
      }
      return res.redirect(url);
    } catch {
      // URL relativa válida
      return res.redirect(url);
    }
  };
  next();
});

// Configurações de parsing seguras
app.use(express.json({ 
  limit: '10mb',
  strict: true
}));

// Configuração segura para URL encoded (resolve vulnerabilidade do body-parser)
app.use(express.urlencoded({ 
  extended: false,  // false para usar querystring parser (mais seguro)
  limit: '10mb',
  parameterLimit: 20
}));

// Middleware para servir arquivos estáticos de forma segura
app.use('/static', express.static(path.join(__dirname, 'img'), {
  dotfiles: 'deny',
  index: false,
  setHeaders: (res, path) => {
    // Headers de segurança para arquivos estáticos
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('Cache-Control', 'public, max-age=3600');
  }
}));

// Função para validar e sanitizar caminhos de arquivo
function validateFilePath(filePath) {
  const normalizedPath = path.normalize(filePath);
  const basePath = path.resolve(__dirname);
  const resolvedPath = path.resolve(basePath, normalizedPath);
  
  // Previne path traversal
  if (!resolvedPath.startsWith(basePath)) {
    throw new Error('Invalid file path');
  }
  return resolvedPath;
}

// Rota para a página inicial ("/")
app.get('/', (req, res) => {
  try {
    const filePath = validateFilePath('index.html');
    
    // Verifica se o arquivo existe
    if (!fs.existsSync(filePath)) {
      return res.status(404).send('File not found');
    }
    
    // Headers de segurança
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('X-Frame-Options', 'DENY');
    
    // Enviando o arquivo index.html como resposta
    res.sendFile(filePath);
  } catch (error) {
    console.error('Error serving index.html:', error.message);
    res.status(500).send('Internal Server Error');
  }
});

// Rota para a página de perfil ("/profile") - versão segura
app.get('/profile', (req, res) => {
  try {
    const imagePath = validateFilePath('img/toolbox-playground.png');
    
    // Verifica se o arquivo existe
    if (!fs.existsSync(imagePath)) {
      return res.status(404).send('Image not found');
    }
    
    // Lê o arquivo de forma síncrona (para demonstração - em produção usar streams)
    const img = fs.readFileSync(imagePath);
    
    // Headers seguros para imagem
    res.setHeader('Content-Type', 'image/png'); // Correção: PNG, não JPG
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('Cache-Control', 'public, max-age=3600');
    
    // Enviando a imagem como resposta
    res.end(img);
  } catch (error) {
    console.error('Error serving profile image:', error.message);
    res.status(500).send('Internal Server Error');
  }
});

// Middleware para tratamento de erros
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({
    error: 'Internal Server Error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
  });
});

// Middleware para rotas não encontradas
app.use('*', (req, res) => {
  try {
    const filePath = validateFilePath('index.html');
    
    if (!fs.existsSync(filePath)) {
      return res.status(404).send('Page not found');
    }
    
    // Headers de segurança
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('X-Frame-Options', 'DENY');
    
    res.sendFile(filePath);
  } catch (error) {
    console.error('Error in catch-all route:', error.message);
    res.status(500).send('Internal Server Error');
  }
});

// Configuração da porta com fallback
const PORT = process.env.PORT || 8080;
const HOST = process.env.HOST || '0.0.0.0';

// Iniciando o servidor com error handling
const server = app.listen(PORT, HOST, () => {
  console.log(`🚀 Servidor seguro rodando na porta ${PORT}!`);
  console.log(`📱 Acesse: http://localhost:${PORT}`);
  console.log(`🔒 Segurança ativada com Helmet e validações`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('🔄 Recebido SIGTERM, encerrando servidor...');
  server.close(() => {
    console.log('✅ Servidor encerrado com sucesso');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('🔄 Recebido SIGINT, encerrando servidor...');
  server.close(() => {
    console.log('✅ Servidor encerrado com sucesso');
    process.exit(0);
  });
});