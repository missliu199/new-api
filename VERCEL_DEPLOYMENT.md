# Vercel 部署指南

## 环境变量配置

在 Vercel 项目设置中，需要配置以下环境变量：

### 必需变量

```bash
# PostgreSQL 数据库连接（必须）
SQL_DSN=postgresql://user:password@host:5432/database?sslmode=require

# 示例 - Supabase PostgreSQL
SQL_DSN=postgresql://postgres:YOUR_PASSWORD@db.xxx.supabase.co:5432/postgres?sslmode=require
```

**注意**：密码中如果包含特殊字符（如 `@`, `:`, `/`, `#`, `?` 等），需要进行 URL 编码：
- `@` → `%40`
- `!` → `%21`
- `#` → `%23`
- `%` → `%25`

### 数据库连接池配置（推荐）

```bash
# Supabase 等托管数据库连接数有限，需要调整连接池大小
SQL_MAX_IDLE_CONNS=5
SQL_MAX_OPEN_CONNS=20
SQL_MAX_LIFETIME=60
```

### 可选变量

```bash
# 会话密钥（强烈推荐设置）
SESSION_SECRET=your-random-secret-string

# 内存缓存
MEMORY_CACHE_ENABLED=true
SYNC_FREQUENCY=60

# Redis（可选，提升性能）
REDIS_CONN_STRING=redis://user:password@host:6379/0

# 日志数据库（可选，默认使用主数据库）
LOG_SQL_DSN=postgresql://user:password@host:5432/logdb?sslmode=require

# 调试模式（生产环境建议关闭）
DEBUG=false
GIN_MODE=release
```

## 部署步骤

1. **在 Vercel 中导入项目**
   - 访问 [Vercel Dashboard](https://vercel.com/dashboard)
   - 点击 "New Project"
   - 导入您的 GitHub 仓库

2. **配置环境变量**
   - 进入项目 Settings → Environment Variables
   - 添加上述必需的环境变量
   - 确保 `SQL_DSN` 正确配置

3. **部署**
   - Vercel 会自动检测 `vercel.json` 和 `Dockerfile.vercel`
   - 点击 "Deploy" 开始部署
   - 等待构建完成（首次部署可能需要 5-10 分钟）

4. **验证部署**
   - 访问 Vercel 提供的 URL
   - 检查应用是否正常运行
   - 查看 Runtime Logs 确认没有错误

## 常见问题

### 1. 数据库连接失败

**症状**：500 FUNCTION_INVOCATION_FAILED 错误

**解决方案**：
- 检查 `SQL_DSN` 是否正确配置
- 确认数据库密码中的特殊字符已 URL 编码
- 检查数据库防火墙设置，确保允许 Vercel 的 IP 访问
- Supabase：使用直连端口 5432（不是连接池端口 6543）

### 2. 启动超时

**症状**：部署成功但访问时超时

**解决方案**：
- 减少 `SQL_MAX_OPEN_CONNS` 避免连接数过多
- 确保数据库响应速度正常
- 检查是否有耗时的初始化操作

### 3. 数据持久化

**重要**：Vercel 的容器是无状态的，重启后数据会丢失。

**解决方案**：
- 必须使用外部数据库（PostgreSQL、MySQL）
- 不要使用 SQLite（除非仅用于测试）

### 4. 文件上传/存储

**问题**：Vercel 容器文件系统是只读的（除了 `/tmp`）

**解决方案**：
- 使用对象存储服务（S3、Cloudflare R2、Vercel Blob）
- 配置相应的存储环境变量

## 性能优化

### 数据库连接池

对于 Supabase 等有连接限制的托管数据库：

```bash
SQL_MAX_IDLE_CONNS=5      # 空闲连接数
SQL_MAX_OPEN_CONNS=20     # 最大连接数
SQL_MAX_LIFETIME=60       # 连接生命周期（秒）
```

### 启用缓存

```bash
MEMORY_CACHE_ENABLED=true
REDIS_CONN_STRING=redis://your-redis-url
```

### 调整超时

```bash
RELAY_TIMEOUT=60          # 请求超时（秒）
STREAMING_TIMEOUT=300     # 流式响应超时（秒）
```

## 查看日志

在 Vercel Dashboard 中：
1. 进入项目
2. 点击 "Deployments" → 选择部署
3. 查看 "Runtime Logs"

或使用 Vercel CLI：
```bash
vercel logs <deployment-url>
```

## 回滚

如果部署出现问题：
1. 在 Vercel Dashboard 中找到上一个成功的部署
2. 点击三个点菜单
3. 选择 "Promote to Production"

## 本地测试

在本地测试 Vercel 部署配置：

```bash
# 构建 Docker 镜像
docker build -f Dockerfile.vercel -t new-api-vercel .

# 运行容器
docker run -p 3000:3000 \
  -e SQL_DSN="postgresql://..." \
  -e SESSION_SECRET="your-secret" \
  new-api-vercel
```

## 支持

如果遇到问题：
1. 查看 Vercel Runtime Logs
2. 检查数据库连接和配置
3. 提交 Issue 到项目仓库
