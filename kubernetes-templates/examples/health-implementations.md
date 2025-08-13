# Implementações de Health Checks por Linguagem

## 🐍 Python (Flask/FastAPI)

### Flask
```python
from flask import Flask, jsonify
import psutil
import redis
import subprocess
import time

app = Flask(__name__)
redis_client = redis.Redis(host='redis-service', port=6379, decode_responses=True)

# Liveness Probe - Verifica se aplicação está viva
@app.route('/health')
def liveness():
    try:
        # Verifica se processo principal está funcionando
        cpu_percent = psutil.cpu_percent(interval=1)
        memory_percent = psutil.virtual_memory().percent
        
        # Falha se recursos estão muito altos
        if cpu_percent > 90 or memory_percent > 90:
            return jsonify({
                'status': 'unhealthy',
                'reason': 'high_resource_usage',
                'cpu': cpu_percent,
                'memory': memory_percent
            }), 503
            
        return jsonify({
            'status': 'healthy',
            'timestamp': time.time(),
            'uptime': time.time() - app.start_time
        }), 200
        
    except Exception as e:
        return jsonify({
            'status': 'unhealthy',
            'error': str(e)
        }), 503

# Readiness Probe - Verifica se está pronto para tráfego
@app.route('/ready')
def readiness():
    try:
        # Verifica dependências críticas
        dependencies = {
            'database': check_database(),
            'redis': check_redis(),
            'external_api': check_external_service()
        }
        
        # Se alguma dependência falhar, não está pronto
        failed_deps = [k for k, v in dependencies.items() if not v]
        if failed_deps:
            return jsonify({
                'status': 'not_ready',
                'failed_dependencies': failed_deps,
                'dependencies': dependencies
            }), 503
            
        return jsonify({
            'status': 'ready',
            'dependencies': dependencies
        }), 200
        
    except Exception as e:
        return jsonify({
            'status': 'not_ready',
            'error': str(e)
        }), 503

# Startup Probe - Para inicialização lenta
@app.route('/startup')
def startup():
    try:
        # Verifica se inicialização foi completada
        if not hasattr(app, 'initialization_complete'):
            return jsonify({
                'status': 'starting',
                'message': 'Initialization in progress'
            }), 503
            
        return jsonify({
            'status': 'started',
            'initialization_time': app.initialization_time
        }), 200
        
    except Exception as e:
        return jsonify({
            'status': 'startup_failed',
            'error': str(e)
        }), 503

def check_database():
    try:
        # Implementar verificação de DB
        import psycopg2
        conn = psycopg2.connect(
            host="db-service",
            database="app_db",
            user="app_user",
            password="app_pass"
        )
        conn.close()
        return True
    except:
        return False

def check_redis():
    try:
        redis_client.ping()
        return True
    except:
        return False

def check_external_service():
    try:
        import requests
        response = requests.get('http://external-api:8080/health', timeout=5)
        return response.status_code == 200
    except:
        return False

if __name__ == '__main__':
    app.start_time = time.time()
    # Simular inicialização
    time.sleep(10)
    app.initialization_complete = True
    app.initialization_time = time.time() - app.start_time
    app.run(host='0.0.0.0', port=8080)
```

### FastAPI
```python
from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
import asyncio
import aioredis
import asyncpg
import time
import psutil

app = FastAPI()
startup_time = time.time()

@app.get("/health")
async def liveness():
    try:
        # Verificações básicas de recursos
        cpu_percent = psutil.cpu_percent(interval=1)
        memory_percent = psutil.virtual_memory().percent
        
        if cpu_percent > 90 or memory_percent > 90:
            raise HTTPException(
                status_code=503,
                detail={
                    "status": "unhealthy",
                    "reason": "high_resource_usage",
                    "cpu": cpu_percent,
                    "memory": memory_percent
                }
            )
        
        return {
            "status": "healthy",
            "timestamp": time.time(),
            "uptime": time.time() - startup_time
        }
        
    except Exception as e:
        raise HTTPException(status_code=503, detail={"status": "unhealthy", "error": str(e)})

@app.get("/ready")
async def readiness():
    try:
        # Verificar dependências assíncronas
        redis_ok = await check_redis_async()
        db_ok = await check_database_async()
        
        dependencies = {
            "redis": redis_ok,
            "database": db_ok
        }
        
        if not all(dependencies.values()):
            failed = [k for k, v in dependencies.items() if not v]
            raise HTTPException(
                status_code=503,
                detail={
                    "status": "not_ready",
                    "failed_dependencies": failed
                }
            )
        
        return {"status": "ready", "dependencies": dependencies}
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=503, detail={"status": "not_ready", "error": str(e)})

async def check_redis_async():
    try:
        redis = aioredis.from_url("redis://redis-service:6379")
        await redis.ping()
        await redis.close()
        return True
    except:
        return False

async def check_database_async():
    try:
        conn = await asyncpg.connect(
            host="db-service",
            database="app_db",
            user="app_user",
            password="app_pass"
        )
        await conn.close()
        return True
    except:
        return False
```

## ☕ Java (Spring Boot)

```java
@RestController
@RequestMapping("/actuator")
public class HealthController {
    
    @Autowired
    private RedisTemplate<String, String> redisTemplate;
    
    @Autowired
    private DataSource dataSource;
    
    private final long startupTime = System.currentTimeMillis();
    
    // Liveness Probe
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> liveness() {
        try {
            Map<String, Object> response = new HashMap<>();
            
            // Verifica recursos do sistema
            MemoryUsage heapUsage = ManagementFactory.getMemoryMXBean().getHeapMemoryUsage();
            double memoryPercent = (double) heapUsage.getUsed() / heapUsage.getMax() * 100;
            
            if (memoryPercent > 90) {
                response.put("status", "unhealthy");
                response.put("reason", "high_memory_usage");
                response.put("memory_percent", memoryPercent);
                return ResponseEntity.status(503).body(response);
            }
            
            response.put("status", "healthy");
            response.put("timestamp", System.currentTimeMillis());
            response.put("uptime", System.currentTimeMillis() - startupTime);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "unhealthy");
            errorResponse.put("error", e.getMessage());
            return ResponseEntity.status(503).body(errorResponse);
        }
    }
    
    // Readiness Probe
    @GetMapping("/ready")
    public ResponseEntity<Map<String, Object>> readiness() {
        try {
            Map<String, Object> response = new HashMap<>();
            Map<String, Boolean> dependencies = new HashMap<>();
            
            // Verifica Redis
            dependencies.put("redis", checkRedis());
            
            // Verifica Database
            dependencies.put("database", checkDatabase());
            
            // Verifica se todas dependências estão ok
            boolean allHealthy = dependencies.values().stream().allMatch(Boolean::booleanValue);
            
            if (!allHealthy) {
                response.put("status", "not_ready");
                response.put("dependencies", dependencies);
                return ResponseEntity.status(503).body(response);
            }
            
            response.put("status", "ready");
            response.put("dependencies", dependencies);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "not_ready");
            errorResponse.put("error", e.getMessage());
            return ResponseEntity.status(503).body(errorResponse);
        }
    }
    
    private boolean checkRedis() {
        try {
            redisTemplate.opsForValue().get("health-check");
            return true;
        } catch (Exception e) {
            return false;
        }
    }
    
    private boolean checkDatabase() {
        try (Connection connection = dataSource.getConnection()) {
            return connection.isValid(5);
        } catch (Exception e) {
            return false;
        }
    }
}
```

## 🟨 Node.js (Express)

```javascript
const express = require('express');
const redis = require('redis');
const { Pool } = require('pg');
const os = require('os');

const app = express();
const startupTime = Date.now();

// Configurar Redis e PostgreSQL
const redisClient = redis.createClient({
    host: 'redis-service',
    port: 6379
});

const pgPool = new Pool({
    host: 'db-service',
    database: 'app_db',
    user: 'app_user',
    password: 'app_pass',
    port: 5432,
});

// Liveness Probe
app.get('/health', async (req, res) => {
    try {
        // Verifica uso de memória
        const memoryUsage = process.memoryUsage();
        const totalMemory = os.totalmem();
        const memoryPercent = (memoryUsage.rss / totalMemory) * 100;
        
        if (memoryPercent > 90) {
            return res.status(503).json({
                status: 'unhealthy',
                reason: 'high_memory_usage',
                memory_percent: memoryPercent
            });
        }
        
        res.json({
            status: 'healthy',
            timestamp: Date.now(),
            uptime: Date.now() - startupTime,
            memory_usage: memoryUsage
        });
        
    } catch (error) {
        res.status(503).json({
            status: 'unhealthy',
            error: error.message
        });
    }
});

// Readiness Probe
app.get('/ready', async (req, res) => {
    try {
        const dependencies = {
            redis: await checkRedis(),
            database: await checkDatabase()
        };
        
        const failedDeps = Object.keys(dependencies).filter(key => !dependencies[key]);
        
        if (failedDeps.length > 0) {
            return res.status(503).json({
                status: 'not_ready',
                failed_dependencies: failedDeps,
                dependencies
            });
        }
        
        res.json({
            status: 'ready',
            dependencies
        });
        
    } catch (error) {
        res.status(503).json({
            status: 'not_ready',
            error: error.message
        });
    }
});

// Startup Probe
app.get('/startup', (req, res) => {
    // Simular verificação de inicialização
    if (Date.now() - startupTime < 30000) { // 30 segundos para inicializar
        return res.status(503).json({
            status: 'starting',
            message: 'Application is still initializing'
        });
    }
    
    res.json({
        status: 'started',
        initialization_time: Date.now() - startupTime
    });
});

async function checkRedis() {
    try {
        await redisClient.ping();
        return true;
    } catch (error) {
        return false;
    }
}

async function checkDatabase() {
    try {
        const client = await pgPool.connect();
        await client.query('SELECT 1');
        client.release();
        return true;
    } catch (error) {
        return false;
    }
}

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
```

## 🔧 .NET Core

```csharp
[ApiController]
[Route("[controller]")]
public class HealthController : ControllerBase
{
    private readonly IConnectionMultiplexer _redis;
    private readonly IDbConnection _dbConnection;
    private static readonly DateTime StartupTime = DateTime.UtcNow;
    
    public HealthController(IConnectionMultiplexer redis, IDbConnection dbConnection)
    {
        _redis = redis;
        _dbConnection = dbConnection;
    }
    
    [HttpGet("health")]
    public async Task<IActionResult> Liveness()
    {
        try
        {
            // Verificar uso de memória
            var process = Process.GetCurrentProcess();
            var memoryUsage = process.WorkingSet64;
            var totalMemory = GC.GetTotalMemory(false);
            
            var response = new
            {
                status = "healthy",
                timestamp = DateTime.UtcNow,
                uptime = DateTime.UtcNow - StartupTime,
                memory_usage = memoryUsage,
                total_memory = totalMemory
            };
            
            return Ok(response);
        }
        catch (Exception ex)
        {
            var errorResponse = new
            {
                status = "unhealthy",
                error = ex.Message
            };
            
            return StatusCode(503, errorResponse);
        }
    }
    
    [HttpGet("ready")]
    public async Task<IActionResult> Readiness()
    {
        try
        {
            var dependencies = new Dictionary<string, bool>
            {
                ["redis"] = await CheckRedisAsync(),
                ["database"] = await CheckDatabaseAsync()
            };
            
            var failedDependencies = dependencies
                .Where(kvp => !kvp.Value)
                .Select(kvp => kvp.Key)
                .ToList();
            
            if (failedDependencies.Any())
            {
                var notReadyResponse = new
                {
                    status = "not_ready",
                    failed_dependencies = failedDependencies,
                    dependencies
                };
                
                return StatusCode(503, notReadyResponse);
            }
            
            var readyResponse = new
            {
                status = "ready",
                dependencies
            };
            
            return Ok(readyResponse);
        }
        catch (Exception ex)
        {
            var errorResponse = new
            {
                status = "not_ready",
                error = ex.Message
            };
            
            return StatusCode(503, errorResponse);
        }
    }
    
    private async Task<bool> CheckRedisAsync()
    {
        try
        {
            var database = _redis.GetDatabase();
            await database.PingAsync();
            return true;
        }
        catch
        {
            return false;
        }
    }
    
    private async Task<bool> CheckDatabaseAsync()
    {
        try
        {
            if (_dbConnection.State != ConnectionState.Open)
                await _dbConnection.OpenAsync();
                
            var command = _dbConnection.CreateCommand();
            command.CommandText = "SELECT 1";
            await command.ExecuteScalarAsync();
            
            return true;
        }
        catch
        {
            return false;
        }
    }
}
