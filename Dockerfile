FROM ghost:5-alpine as cloudinary

RUN apk add --no-cache g++ make python3
RUN su-exec node yarn add ghost-storage-cloudinary@latest

# ---
FROM ghost:5-alpine

ENV GHOST_INSTALL /var/lib/ghost

# 复制插件
COPY --chown=node:node --from=cloudinary $GHOST_INSTALL/node_modules/ghost-storage-cloudinary $GHOST_INSTALL/content/adapters/storage/ghost-storage-cloudinary

# 通过 Ghost CLI 配置所有参数
RUN set -ex; \
    # 核心配置
    su-exec node ghost config url "https://\${GHOST_HOST}"; \
    su-exec node ghost config server.host '::'; \
    # 存储配置
    su-exec node ghost config storage.active ghost-storage-cloudinary; \
    su-exec node ghost config storage.ghost-storage-cloudinary.upload.use_filename true; \
    su-exec node ghost config storage.ghost-storage-cloudinary.upload.unique_filename false; \
    su-exec node ghost config storage.ghost-storage-cloudinary.upload.overwrite false; \
    su-exec node ghost config storage.ghost-storage-cloudinary.upload.folder "my-blog"; \
    su-exec node ghost config storage.ghost-storage-cloudinary.fetch.quality "auto"; \
    su-exec node ghost config storage.ghost-storage-cloudinary.fetch.cdn_subdomain true; \
    # 禁用图片优化
    su-exec node ghost config imageOptimization.__disabled__ true;
