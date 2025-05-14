---
title: 家庭宽带使用非标准端口创建https加密
published: 2025-02-20
description: '本文详述在家宽下用Docker部署nginx-proxy-manager及HTTPS配置，含DDNS、端口转发、容器编排等步骤，解决无固定IP、端口被封问题，实现通过https://域名:8443 安全访问，附防火墙及DDNS配置要点，助低成本高效代理。'
image: ''
tags: ['Docker','nginx','DDNS']
category: '指南'
draft: false 
---

在家宽环境下使用 Docker 部署 `nginx-proxy-manager` 并配置 HTTPS，同时使用非标准端口（非80、443）访问，可以按照以下步骤进行：

### 1. 准备工作

- 确保你有一个域名，并且已经解析到你的家宽公网IP。
- 由于家宽通常没有固定的公网IP，建议使用动态DNS（DDNS）服务来绑定域名 [相关连接](/posts/ddns-go/)。
- 确保你的路由器已经配置了端口转发，将外部端口映射到内网服务器的对应端口。

### 2. 安装 Docker 和 Docker Compose

如果你还没有安装 Docker 和 Docker Compose，可以参考以下步骤（ubuntu系统）：

```bash
# 添加阿里云密钥
curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 载入软件源
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] http://mirrors.aliyun.com/docker-ce/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安装
sudo apt update
sudo apt install docker-ce

# 配置非root 用户 (需重载终端)
sudo usermod -aG docker $USER

# 设置镜像加速
sudo vim /etc/docker/daemon.json
```

### 3. 创建 `docker-compose.yml` 文件

创建一个目录来存放 `nginx-proxy-manager` 的配置文件，并在该目录下创建 `docker-compose.yml` 文件：

```bash
mkdir nginx-proxy-manager
cd nginx-proxy-manager
vim docker-compose.yml
```

在 `docker-compose.yml` 文件中添加以下内容：

```yaml
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      - '8080:80'  # 将外部端口8080映射到容器内的80端口
      - '8443:443' # 将外部端口8443映射到容器内的443端口
      - '81:81'    # Nginx Proxy Manager的管理界面端口
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
```

### 4. 启动 Nginx Proxy Manager

在 `docker-compose.yml` 文件所在的目录下，运行以下命令启动服务：

```bash
docker-compose up -d
```

### 5. 配置 Nginx Proxy Manager

1. 打开浏览器，访问 `http://你的服务器IP:81`，进入 Nginx Proxy Manager 的管理界面。

2. 默认的用户名是 `admin@example.com`，密码是 `changeme`。首次登录后会要求你修改密码。

3. 在管理界面中，点击 "Add Proxy Host" 来添加一个新的代理主机。

4. 在 "Domain Names" 中输入你的域名。

5. 在 "Forward Hostname/IP" 中输入你要代理的服务的内网IP和端口。

   1. 可以使用`ip a|grep docker0`获取容器访问主机的ip地址，反代此地址和端口即可。

6. 在 "SSL" 选项卡中，选择 "Let's Encrypt"，并输入你的邮箱地址，然后点击 "Save" 来申请 SSL 证书。

### 6. 配置路由器端口转发

在你的路由器中，配置端口转发规则，将外部端口（例如8080和8443）映射到内网服务器的对应端口（8080和8443）。

### 7. 访问你的服务

现在你可以通过 `https://你的域名:8443` 来访问你的服务，Nginx Proxy Manager 会自动处理 HTTPS 的配置。

### 8. 注意事项

- 由于家宽通常没有固定的公网IP，建议使用动态DNS（DDNS）服务来绑定域名。
- 如果你的ISP屏蔽了80和443端口，你可以使用其他端口（如8080、8443）来替代。
- 确保你的路由器防火墙允许外部访问这些端口。

通过以上步骤，你应该能够在家宽环境下使用 Docker 部署 `nginx-proxy-manager` 并配置 HTTPS，同时使用非标准端口访问你的服务。