# vuegpt

Azure OpenAI的最基本的聊天客户端，使用Vue3.0开发，使用了Azure的认证和OpenAI的API，可以在Azure上部署，也可以在本地部署。
 - 支持gpt-35-turbo和gpt-4模型
 - 支持格式化显示。
 - 支持流式(Stream)响应，加快响应显示速度。
 - 聊天记录没做任何处理，不会在服务器保留。可以本地浏览器按Ctrl + S保存聊天记录。


## 部署到Azure Web App
准备好本机的环境

- 安装Azure CLI， 参考 https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli
- 安装Docker Desktop， 参考 https://docs.docker.com/get-docker/
- 安装Node.js , npm， 参考 https://nodejs.org/en/download/
- 一个Azure订阅， 参考 https://azure.microsoft.com/en-us/free/


在Powershell中， 运行[deploy.ps1](./deploy/deploy.ps1)
```powershell
git clone https://github.com/radezheng/vuegpt
cd vuegpt
# 参考env.example修改环境变量, 存储为 .env.local 或 .env
./deploy/deploy.ps1
```
按提示输入相关信息，即可部署到Azure Web App，过程中会创建:
- 一个资源组
- 一个容器注册表（ACR）, 可以用现有的ACR
- 按Dockerfile构建容器镜像，并推送到ACR
- 一个应用服务计划，默认B1
- 一个Web App <br/>
完成后自动打开浏览器，即可访问。

**注意：不建议将容器镜像推送到公共Docker Hub，以免泄露信息。**

## 部署到本地


## Project setup
```
git clone https://github.com/radezheng/vuegpt
cd vuegpt
```
### 参考env.example修改环境变量
存储为 .env.local 或 .env

```
npm install
```


### Compiles and hot-reloads for development
```
npm run serve
```
按提示URL, 本地即可访问

