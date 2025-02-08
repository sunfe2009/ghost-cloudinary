FROM ghost:5-alpine as builder

RUN apk add --no-cache g++ make python3

# 锁定兼容版本 (Ghost 5.x 需使用 2.1.x 版本)
RUN su-exec node yarn add ghost-storage-cloudinary@2.1.2 cloudinary@1.40.0

# ---
FROM ghost:5-alpine

ENV GHOST_INSTALL /var/lib/ghost

# 创建目标目录 (关键修复)
RUN mkdir -p $GHOST_INSTALL/content/adapters/storage && \
    chown node:node $GHOST_INSTALL/content/adapters/storage

# 复制完整适配器及依赖
COPY --chown=node:node --from=builder \
    $GHOST_INSTALL/node_modules/ghost-storage-cloudinary \
    $GHOST_INSTALL/content/adapters/storage/ghost-storage-cloudinary

# 复制 cloudinary SDK 到全局 node_modules
COPY --chown=node:node --from=builder \
    $GHOST_INSTALL/node_modules/cloudinary \
    $GHOST_INSTALL/node_modules/cloudinary

# 配置路径和存储
RUN set -ex; \
    su-exec node ghost config paths.contentPath "$GHOST_INSTALL/content"; \
    su-exec node ghost config storage.active ghost-storage-cloudinary; \
    su-exec node ghost config storage.ghost-storage-cloudinary.upload.use_filename true; \
    su-exec node ghost config storage.ghost-storage-cloudinary.upload.unique_filename false; \
    su-exec node ghost config imageOptimization.__disabled__ true; \
    su-exec node ghost config storage.ghost-storage-cloudinary.upload.overwrite false; \
    su-exec node ghost config storage.ghost-storage-cloudinary.fetch.quality auto; \
    su-exec node ghost config storage.ghost-storage-cloudinary.fetch.cdn_subdomain true;

    
# 验证路径（生产环境可移除）
RUN ls -l $GHOST_INSTALL/content/adapters/storage/ && \
    ls -l $GHOST_INSTALL/node_modules/cloudinary/package.json
