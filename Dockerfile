# Dockerfile

# 使用官方 Ghost 镜像作为基础镜像
FROM ghost:5-alpine as cloudinary

# 安装构建工具
RUN apk add --no-cache g++ make python3

# 安装 ghost-storage-cloudinary 插件
RUN su-exec node yarn add ghost-storage-cloudinary@latest

# 创建最终的 Ghost 镜像
FROM ghost:5-alpine

# 从构建阶段复制插件到目标镜像
COPY --chown=node:node --from=cloudinary /var/lib/ghost/node_modules /var/lib/ghost/node_modules

# 新增健康检查
HEALTHCHECK --interval=30s --timeout=10s \
  CMD curl -f http://localhost:2368/ghost || exit 1