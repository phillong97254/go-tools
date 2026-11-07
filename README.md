# go-tools

Image Docker chứa công cụ dev dùng chung cho các service của go-admin-wallet (thay cho `sangnv/bizgroup-go-tools`
ở các dự án trước). Các service gọi nó qua `docker-compose.tools.yml` nên không cần cài gì trên máy ngoài Docker.

| Công cụ | Dùng cho |
|---|---|
| `migrate` (golang-migrate, driver postgres) | `make migrate`, `make redo-migrate` |
| `buf`, `protoc-gen-go`, `protoc-gen-go-grpc` | `make gen-proto` |
| `goimports`, `gentool` (gorm gen) | format import, sinh model gorm từ DB |
| `psql`, `git`, `make`, `openssl` | tiện ích |

Base: `golang:1.26.1-alpine`, version từng công cụ là `ARG` trong `Dockerfile`.

## Dùng trong service

`docker-compose.tools.yml` của mỗi service khai báo:

```yaml
go-tools:
  image: phillong2504/go-tools:v1.0.0
  build:
    context: https://github.com/phillong97254/go-tools.git#v1.0.0
```

Image được push lên Docker Hub (`phillong2504/go-tools`), nên lần đầu `make migrate` / `make gen-proto`
Docker chỉ việc pull. Nếu không pull được thì Docker tự build từ git tag `v1.0.0` của repo này.

Push image mới lên Docker Hub: `make docker-login && make push TAG=v1.0.0`.

## Cập nhật

```bash
# sửa version trong Dockerfile
make build check
git commit -am "..." && make release TAG=v1.1.0
# rồi đổi tag v1.0.0 -> v1.1.0 trong docker-compose.tools.yml của các service
```
