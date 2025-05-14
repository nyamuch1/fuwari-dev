---
title: 动态公网DDNS-GO配置
published: 2025-02-20
description: 'DDNS-GO是一款轻量级动态DNS工具，支持多服务商，自动更新域名解析。本文介绍其安装（Docker或二进制文件）、配置（选择服务商、填写API密钥等）、验证及高级设置。解决无固定IP问题，适用于家庭宽带，实现高效域名解析管理。'
image: ''
tags: ['DDNS','Linux']
category: '指南'
draft: false 
---

`DDNS-GO` 是一个轻量级的动态 DNS（DDNS）工具，支持多种 DNS 服务商（如阿里云、腾讯云、Cloudflare 等），能够自动检测本机 IP 变化并更新域名解析记录。以下是 `DDNS-GO` 的使用教程。

## 1. 安装 DDNS-GO

### 方法 1：使用 Docker 安装

如果你已经安装了 Docker，可以通过以下命令快速安装 `DDNS-GO`：

```bash
docker run -d \
  --name ddns-go \
  --restart=always \
  -p 9876:9876 \
  -v /opt/ddns-go:/root \
  jeessy/ddns-go
```

- `-p 9876:9876`：将容器内的 9876 端口映射到宿主机的 9876 端口，用于访问 Web 管理界面。
- `-v /opt/ddns-go:/root`：将配置文件持久化到宿主机的 `/opt/ddns-go` 目录。

### 方法 2：直接下载二进制文件

如果你不想使用 Docker，可以直接下载 `DDNS-GO` 的二进制文件：

1. 访问 [DDNS-GO 的 GitHub 发布页面](https://github.com/jeessy2/ddns-go/releases)，下载适合你系统的二进制文件。

2. 解压并运行：

   ```bash
   chmod +x ddns-go
   ./ddns-go
   ```

3. 默认会监听 `9876` 端口，可以通过浏览器访问 `http://你的服务器IP:9876` 进行配置。

4. 使用`sudo ./ddns-go -s install`创建服务，可以使用`systemctl`管理

## 2. 配置 DDNS-GO

### 步骤 1：访问 Web 管理界面

在浏览器中访问 `http://你的服务器IP:9876`，进入 `DDNS-GO` 的管理界面。

### 步骤 2：选择 DNS 服务商

在管理界面中，选择你使用的 DNS 服务商（如阿里云、腾讯云、Cloudflare 等）。

### 步骤 3：填写 API 密钥

根据你选择的 DNS 服务商，填写对应的 API 密钥：

- **阿里云**：需要 `AccessKey ID` 和 `AccessKey Secret`。
- **腾讯云**：需要 `SecretId` 和 `SecretKey`。
- **Cloudflare**：需要 `API Token` 或 `Global API Key`。

这些密钥可以在你的 DNS 服务商的控制台中获取。

### 步骤 4：添加域名

在 "域名" 栏中填写你需要更新的域名，例如：

- `example.com`：更新根域名。
- `www.example.com`：更新子域名。

### 步骤 5：设置 IP 获取方式

- **默认**：自动检测公网 IP。
- **自定义**：如果你有特殊的网络环境，可以手动指定 IP 地址。

### 步骤 6：保存配置

点击 "保存" 按钮，`DDNS-GO` 会自动检测你的公网 IP，并更新 DNS 解析记录。

## 3. 验证配置

1. 在 `DDNS-GO` 的管理界面中，查看日志，确认 IP 更新是否成功。

2. 使用 `ping` 或 `nslookup` 命令检查域名解析是否正确：

   ```bash
   ping example.com
   nslookup example.com
   ```

## 4. 高级配置

### 定时检测

`DDNS-GO` 默认每 5 分钟检测一次 IP 变化。你可以通过修改配置文件或环境变量调整检测间隔。

### 多域名支持

在管理界面中，可以添加多个域名，`DDNS-GO` 会同时更新这些域名的解析记录。

## 5. 常见问题

### 1. 无法获取公网 IP

- 检查服务器是否能够访问外网。
- 如果你的网络环境有 NAT 或防火墙，可能需要手动配置 IP 获取方式。

### 2. DNS 解析未更新

- 检查 API 密钥是否正确。
- 检查域名是否已经绑定到正确的 DNS 服务商。

### 3. 管理界面无法访问

- 检查防火墙是否放行了 `9876` 端口。
- 检查 Docker 容器是否正常运行。

## 6. 总结

`DDNS-GO` 是一个简单易用的动态 DNS 工具，适合家庭宽带或没有固定公网 IP 的环境。通过 Docker 或二进制文件安装后，只需简单配置即可实现域名解析的自动更新。如果你有多个域名或复杂的网络环境，`DDNS-GO` 也能很好地支持。