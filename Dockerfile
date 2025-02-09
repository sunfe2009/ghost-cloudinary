# Dockerfile 修改版（保留注释）

# 使用官方 Ghost 镜像作为基础镜像
FROM ghost:5-alpine as cloudinary

# 安装构建工具
RUN apk add --no-cache g++ make python3

# 安装 ghost-storage-cloudinary 插件到持久化目录
RUN mkdir -p /var/lib/ghost/content/storage-adapters && \
    su-exec node yarn add ghost-storage-cloudinary@latest --modules-folder /var/lib/ghost/content/storage-adapters

# 创建最终的 Ghost 镜像
FROM ghost:5-alpine

# 复制插件到持久化目录并创建符号链接
COPY --chown=node:node --from=cloudinary /var/lib/ghost/content/storage-adapters /var/lib/ghost/content/storage-adapters
RUN ln -s /var/lib/ghost/content/storage-adapters/ghost-storage-cloudinary /var/lib/ghost/node_modules/ghost-storage-cloudinary

# 设置 Ghost 配置（保持原有配置）
RUN set -ex; \
    su-exec node ghost config storage.active ghost-storage-cloudinary; \
    su-exec node ghost config storage.ghost-storage-cloudinary.upload.use_filename true; \
    su-exec node ghost config storage.ghost-storage-cloudinary.upload.unique_filename false; \
    su-exec node ghost config storage.ghost-storage-cloudinary.upload.overwrite false; \
    su-exec node ghost config storage.ghost-storage-cloudinary.checksums match;
