# 使用官方 Ghost 镜像作为基础镜像
FROM ghost:5-alpine as cloudinary

# 安装构建工具
RUN apk add --no-cache g++ make python3

# 安装 ghost-storage-cloudinary 插件最新版
RUN su-exec node yarn add ghost-storage-cloudinary@latest

# 创建最终的 Ghost 镜像
FROM ghost:5-alpine

# 从构建阶段复制插件到目标镜像
COPY --chown=node:node --from=cloudinary /var/lib/ghost/node_modules/ghost-storage-cloudinary /var/lib/ghost/current/node_modules/ghost-storage-cloudinary

# 设置 Ghost 配置
RUN set -ex; \
    # 强制创建配置目录
    mkdir -p /var/lib/ghost/content/adapters/storage; \
    # 创建符号链接
    ln -sf /var/lib/ghost/current/node_modules/ghost-storage-cloudinary /var/lib/ghost/content/adapters/storage/ghost-storage-cloudinary; \
    # 写入配置
    su-exec node ghost config storage.active ghost-storage-cloudinary; \
    su-exec node ghost config storage.ghost-storage-cloudinary.upload.use_filename true; \
    su-exec node ghost config storage.ghost-storage-cloudinary.upload.unique_filename false; \
    su-exec node ghost config storage.ghost-storage-cloudinary.upload.overwrite false; \
    su-exec node ghost config storage.ghost-storage-cloudinary.fetch.quality auto; \
    su-exec node ghost config storage.ghost-storage-cloudinary.fetch.cdn_subdomain true;
