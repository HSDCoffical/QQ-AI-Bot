# QQ-AI-Bot

基于 NapCat + AstrBot + DeepSeek 官方 API 的 QQ AI 群聊机器人。

## 功能

- QQ 个人账号接入
- 群聊 @ 回复
- 群聊主动回复
- 对话上下文
- DeepSeek 官方 API
- 支持 Docker Compose 部署

## 服务

- NapCat：QQ 消息接入
- AstrBot：AI 消息处理
- DeepSeek：模型服务

## 数据持久化

- data/
- napcat/config/
- ntqq/

## 安全

不要提交以下内容：

- DeepSeek API Key
- QQ 登录凭证
- NapCat Token
- 个人隐私数据

NapCat WebUI 不应无保护地暴露到公网。