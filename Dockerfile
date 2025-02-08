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
COPY --chown=node:node --from=cloudinary /var/lib/ghost/node_modules/ghost-storage-cloudinary /

# 设置 Ghost 配置
RUN set -ex; \
    su-exec node ghost config storage.active ghost-storage-cloudinary; \
    su-exec node ghost config storage.ghost-storage-cloudinary.upload.use_filename true; \
    su-exec node ghost config storage.ghost-storage-cloudinary.upload.unique_filename false; \
    su-exec node ghost config storage.ghost-storage-cloudinary.upload.overwrite false; \
    su-exec node ghost config storage.ghost-storage-cloudinary.checksums match; \

# 配置内容 - persist 目录映射到本地
COPY ../files/ghost_test_persist:/var/lib/ghost/content-persist

# 配置构建所需的插件目录映射
COPY ../files/ghost_test_persist:/var/lib/ghost/content-adapters/storage/ghost-storage-cloudinary