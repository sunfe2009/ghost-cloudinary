# Dockerfile
# 使用多阶段构建确保路径准确性
FROM ghost:5-alpine as builder

# 安装构建依赖
RUN apk add --no-cache g++ make python3

# 在构建阶段明确设置工作目录
WORKDIR /var/lib/ghost

# 安装插件到正确路径（注意使用绝对路径）
RUN su-exec node yarn add ghost-storage-cloudinary@latest && \
    mkdir -p /var/lib/ghost/current/content/adapters/storage && \
    cp -r node_modules/ghost-storage-cloudinary /var/lib/ghost/current/content/adapters/storage/

# 最终镜像
FROM ghost:5-alpine

# 从构建阶段复制适配器
COPY --chown=node:node --from=builder /var/lib/ghost/current/content/adapters/storage/ghost-storage-cloudinary /var/lib/ghost/current/content/adapters/storage/

# 配置存储适配器（环境变量优先）
RUN set -ex; \
    su-exec node ghost config storage.active ghost-storage-cloudinary
