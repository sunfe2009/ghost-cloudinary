# 使用官方 Ghost 镜像作为基础镜像
FROM ghost:5-alpine as cloudinary

# 安装构建工具
RUN apk add --no-cache g++ make python3

# 设置工作目录
WORKDIR /var/lib/ghost/current

# 安装插件并显式创建适配器目录
RUN set -ex; \
    su-exec node yarn add ghost-storage-cloudinary@latest; \
    mkdir -p /var/lib/ghost/current/core/server/adapters/storage; \
    ln -sf /var/lib/ghost/current/node_modules/ghost-storage-cloudinary /var/lib/ghost/current/core/server/adapters/storage/cloudinary

# 创建最终的 Ghost 镜像
FROM ghost:5-alpine

# 复制插件和适配器配置
COPY --chown=node:node --from=cloudinary /var/lib/ghost/current/node_modules/ghost-storage-cloudinary /var/lib/ghost/current/node_modules/ghost-storage-cloudinary
COPY --chown=node:node --from=cloudinary /var/lib/ghost/current/core/server/adapters/storage/cloudinary /var/lib/ghost/current/core/server/adapters/storage/cloudinary

# 配置存储适配器（使用持久化路径）
RUN set -ex; \
    su-exec node ghost config storage.active cloudinary; \
    su-exec node ghost config storage.cloudinary.upload.use_filename true; \
    su-exec node ghost config storage.cloudinary.upload.unique_filename false; \
    su-exec node ghost config storage.cloudinary.upload.overwrite false

# 验证路径
RUN ls -l /var/lib/ghost/current/core/server/adapters/storage
