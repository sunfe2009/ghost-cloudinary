# 构建阶段
FROM ghost:5-alpine as builder

# 安装系统依赖
RUN apk add --no-cache g++ make python3

# 在官方镜像的正确位置安装插件
WORKDIR /var/lib/ghost/current
RUN su-exec node yarn add ghost-storage-cloudinary@latest

# 创建持久化目录结构（新增目录验证）
RUN mkdir -p /var/lib/ghost/content-persist/adapters/storage && \
    ln -sf /var/lib/ghost/current/node_modules/ghost-storage-cloudinary \
        /var/lib/ghost/content-persist/adapters/storage/cloudinary && \
    # 验证构建产物
    ls -l /var/lib/ghost/content-persist/adapters/storage

# 最终镜像
FROM ghost:5-alpine

# 复制构建产物（修正目标路径）
COPY --chown=node:node --from=builder \
    /var/lib/ghost/content-persist/adapters \
    /var/lib/ghost/content-persist/

# 配置存储适配器（写入持久化目录）
RUN set -ex; \
    mkdir -p /var/lib/ghost/content-persist/config && \
    ghost config --dir /var/lib/ghost/content-persist \
        storage.active cloudinary && \
    ghost config --dir /var/lib/ghost/content-persist \
        storage.cloudinary.upload.use_filename true

# 启动脚本解决路径冲突
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["node", "current/index.js"]
