# 使用官方 Ghost 镜像作为基础镜像
FROM ghost:5-alpine

# 安装构建工具和插件
RUN set -ex; \
    apk add --no-cache g++ make python3; \
    su-exec node yarn add ghost-storage-cloudinary@latest; \
    mkdir -p /var/lib/ghost/content/adapters/storage/ghost-storage-cloudinary; \
    cp -r /var/lib/ghost/node_modules/ghost-storage-cloudinary/* /var/lib/ghost/content/adapters/storage/ghost-storage-cloudinary/; \
    su-exec node ghost config storage.active ghost-storage-cloudinary; \
    su-exec node ghost config storage.ghost-storage-cloudinary.upload.use_filename true; \
    su-exec node ghost config storage.ghost-storage-cloudinary.upload.unique_filename false; \
    su-exec node ghost config storage.ghost-storage-cloudinary.upload.overwrite false; \
    su-exec node ghost config storage.ghost-storage-cloudinary.fetch.quality auto; \
    su-exec node ghost config storage.ghost-storage-cloudinary.fetch.cdn_subdomain true;
