#!/bin/sh
set -ex

# 确保持久化目录存在
mkdir -p /var/lib/ghost/content-persist/adapters/storage

# 创建双重链接策略（新增核心目录链接）
mkdir -p /var/lib/ghost/current/core/server/adapters/storage
ln -sf /var/lib/ghost/content-persist/adapters/storage/cloudinary \
    /var/lib/ghost/current/core/server/adapters/storage/cloudinary

# 创建数据目录链接
mkdir -p /var/lib/ghost/content/adapters/storage
ln -sf /var/lib/ghost/content-persist/adapters/storage/cloudinary \
    /var/lib/ghost/content/adapters/storage/cloudinary

# 权限修复（新增）
chown -R node:node /var/lib/ghost/content-persist

# 执行原始入口点
exec su-exec node "$@"
