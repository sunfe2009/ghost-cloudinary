# Dockerfile 权限修正版
FROM ghost:5-alpine as cloudinary

# 安装构建工具
RUN apk add --no-cache g++ make python3

# 创建插件目录并设置权限
RUN mkdir -p /var/lib/ghost/content/storage-adapters && \
    chown -R node:node /var/lib/ghost/content/storage-adapters

# 以node用户安装插件
USER node
WORKDIR /var/lib/ghost/content/storage-adapters
RUN yarn add ghost-storage-cloudinary@latest

# 最终阶段
FROM ghost:5-alpine

# 复制插件目录
COPY --chown=node:node --from=cloudinary /var/lib/ghost/content/storage-adapters /var/lib/ghost/content/storage-adapters

# 创建符号链接
USER root
RUN ln -s /var/lib/ghost/content/storage-adapters/node_modules/ghost-storage-cloudinary /var/lib/ghost/node_modules/ghost-storage-cloudinary

# 切换回node用户
USER node
