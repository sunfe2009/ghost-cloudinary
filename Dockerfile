FROM ghost:5.100.0-alpine as builder

# 安装构建依赖
RUN apk add --no-cache g++ make python3

# 明确安装适配器及其依赖
RUN su-exec node yarn add ghost-storage-cloudinary@latest cloudinary@latest

# ---
FROM ghost:5.100.0-alpine

# 设置环境变量
ENV GHOST_INSTALL /var/lib/ghost
ENV NODE_ENV production

# 复制适配器及依赖
COPY --chown=node:node --from=builder \
    $GHOST_INSTALL/node_modules/ghost-storage-cloudinary \
    $GHOST_INSTALL/content/adapters/storage/ghost-storage-cloudinary

# 复制 cloudinary SDK
COPY --chown=node:node --from=builder \
    $GHOST_INSTALL/node_modules/cloudinary \
    $GHOST_INSTALL/node_modules/cloudinary

# 配置核心参数
RUN set -ex; \
    su-exec node ghost config storage.active ghost-storage-cloudinary; \
    su-exec node ghost config storage.ghost-storage-cloudinary.upload.use_filename true; \
    su-exec node ghost config storage.ghost-storage-cloudinary.upload.unique_filename false; \
    su-exec node ghost config imageOptimization.__disabled__ true;

# 验证路径（生产环境可移除）
RUN ls -l $GHOST_INSTALL/content/adapters/storage/ && \
    ls -l $GHOST_INSTALL/node_modules/cloudinary/package.json
