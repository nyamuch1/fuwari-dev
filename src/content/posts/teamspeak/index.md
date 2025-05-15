---
title: Teamspeak安装部署,docker多开并修改文件端口
published: 2025-01-20
description: "这篇教程详细讲解了在Linux系统上使用Docker部署TeamSpeak语音服务器的完整流程。内容涵盖基础Docker命令部署、UDP/TCP端口配置、文件传输端口定制，以及通过Docker Compose实现数据库集成的高阶方案。教程特别提供了带宽计算参考、多实例部署方法和数据持久化配置，附有环境变量详解和可视化端口说明表，适合需要快速搭建语音通信服务的运维人员及开发者参考。"
image: ""
tags: ["Teamspeak", "Docker", "Linux"]
category: '指南'
draft: false
---
---

# TeamSpeak 服务器部署指南

## 基础安装

### Linux 系统
#### Docker 快速部署
```bash
# 1. 启动容器（自动下载镜像）
docker run -d \
  -e TS3SERVER_LICENSE=accept \
  -p 9987:9987/udp \
  -p 30033:30033 \
  -p 10011:10011 \
  --name=ts teamspeak

# 2. 查看初始化日志（获取管理员凭证）
docker logs ts | grep -E "API Key|Admin Token"
```
⚠️ **重要提示**  
日志中的 `ServerAdmin` 账号密码、`API Key` 和 `Admin Token` 请永久保存

#### 手动安装
本文暂不涵盖手动安装流程，推荐使用 Docker 方案

---

### Windows 系统
#### 原生程序安装
1. 从官网下载 `.exe` 安装包
2. 解压后双击安装程序
3. 首次启动时保存生成的凭证文件

🔧 **网络配置要求**  
- 有公网 IP：需在路由器配置 UDP 端口转发（9987/udp）
- 无公网 IP：推荐使用樱花穿透等工具进行 UDP 转发

#### WSL+Docker 方案
操作步骤与 Linux 的 Docker 安装方式完全一致

---

## 进阶配置

### Linux 定制化部署
创建 `docker-compose.yml` 文件：
```yaml
services:
  teamspeak:
    image: teamspeak:latest
    container_name: ts3
    restart: unless-stopped
    ports:
      - "9987:9987/udp"
      # - "30333:30333"  # 文件传输端口 不推荐开放 虽然无法上传文件，但可以有效防止跑流量。不妨碍语音
      - "10011:10011"  # ServerQuery 端口
    environment:
      TS3SERVER_SERVERADMIN_PASSWORD: "Pa$$w0rd"  # 强密码建议包含大小写/数字/符号
      TS3SERVER_LICENSE: accept
      # 自定义文件传输端口示例：
      # TS3SERVER_FILETRANSFER_IP: 0.0.0.0
      # TS3SERVER_FILETRANSFER_PORT: 30333
    volumes:
      - ./ts_data:/var/ts3server
```

启动服务：`docker-compose up -d`

---

### Windows 高级配置
#### 修改服务端口
1. 使用 Telnet 连接管理接口：
```bat
telnet 127.0.0.1 10011
login serveradmin 你的管理员密码
use sid=1
serveredit virtualserver_port=新端口号
quit
```
2. 重启 TeamSpeak 服务生效

#### Docker 方案
配置方法与 Linux 的 docker-compose 方案相同

---

## 客户端配置

### TeamSpeak3 客户端
- 官方安装包：  
  [3.6.2 Windows 64位版](https://files.teamspeak-services.com/releases/client/3.6.2/TeamSpeak3-Client-win64-3.6.2.exe)
- 中文汉化包：  
  [最新汉化文件](https://github.com/VigorousPro/TS3-Translation_zh-CN/releases/download/snapshot/Chinese_Translation_zh-CN.ts3_translation)

📌 汉化方法：双击运行

❗ **身份文件备份**  
身份文件丢失将导致无法恢复管理员权限，如使用匿名登录，优先导出备份

---

### TeamSpeak6 客户端 (Beta)
- 测试版安装包：  
  [6.0 Beta 版本](https://files.teamspeak-services.com/pre_releases/client/6.0.0-beta2/teamspeak-client.msi)
- 重要特性：
  - 内置中文界面（设置中切换）
  - 匿名登录功能
  - 身份凭证自动保存于 `%AppData%\Teamspeak` 

❗ **身份文件备份**  
身份文件丢失将导致无法恢复管理员权限，如使用匿名登录，请定期备份

---

更多配置可以查看[docker](https://hub.docker.com/_/teamspeak)  [github](https://github.com/TeamSpeak-Systems/teamspeak-linux-docker-images/blob/master/alpine/entrypoint.sh)

---

## Docker 环境准备
### Ubuntu 系统安装
```bash
# 配置阿里云镜像源
curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安装组件
sudo apt update && sudo apt install -y docker-ce

# 配置用户组（需重新登录生效）
sudo usermod -aG docker $USER

# 配置镜像加速
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://镜像编码.mirror.aliyuncs.com"]
}
EOF
systemctl restart docker
```
