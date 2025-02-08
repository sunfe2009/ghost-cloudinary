# Dockerfile
# 使用官方 Ghost 镜像作为基础镜像
FROM ghost:5-alpine as cloudinary

# 安装构建工具（Alpine 系统使用 apk）
RUN apk add --no-cache g++ make python3

# 安装 ghost-storage-cloudinary 插件到正确路径
RUN su-exec node yarn add ghost-storage-cloudinary@latest && \
    # 创建适配器存储目录
    mkdir -p /var/lib/ghost/content/adapters/storage && \
    # 移动插件到标准适配器目录
    cp -r node_modules/ghost-storage-cloudinary /var/lib/ghost/content/adapters/storage/

# 创建最终的 Ghost 镜像
FROM ghost:5-alpine

# 从构建阶段复制插件到目标镜像的标准适配器目录
COPY --chown=node:node --from=cloudinary /var/lib/ghost/content/adapters/storage/ghost-storage-cloudinary /var/lib/ghost/content/adapters/storage/

# 设置 Ghost 存储配置（使用环境变量覆盖更灵活）
RUN set -ex; \
    su-exec node ghost config storage.active ghost-storage-cloudinary; \
    su-exec node ghost config storage.ghost-storage-cloudinary.upload.use_filename true
