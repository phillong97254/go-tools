# go-tools: image công cụ dev dùng chung cho các service (thay cho sangnv/bizgroup-go-tools).
# Chạy qua docker-compose.tools.yml của từng service: make migrate, make redo-migrate, make gen-proto...
ARG GO_VERSION=1.26.1

FROM golang:${GO_VERSION}-alpine AS builder
LABEL stage=Builder

ARG MIGRATE_VERSION=v4.20.1
ARG BUF_VERSION=v1.50.0
ARG PROTOC_GEN_GO_VERSION=v1.36.6
ARG PROTOC_GEN_GO_GRPC_VERSION=v1.5.1
ARG GOIMPORTS_VERSION=v0.52.0
ARG GENTOOL_VERSION=v0.0.3

ENV CGO_ENABLED=0 GOBIN=/out
RUN go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@${MIGRATE_VERSION} \
    && go install github.com/bufbuild/buf/cmd/buf@${BUF_VERSION} \
    && go install google.golang.org/protobuf/cmd/protoc-gen-go@${PROTOC_GEN_GO_VERSION} \
    && go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@${PROTOC_GEN_GO_GRPC_VERSION} \
    && go install golang.org/x/tools/cmd/goimports@${GOIMPORTS_VERSION} \
    && go install gorm.io/gen/tools/gentool@${GENTOOL_VERSION}


FROM golang:${GO_VERSION}-alpine AS final
LABEL stage=Final
LABEL org.opencontainers.image.source=https://github.com/phillong97254/go-tools
LABEL org.opencontainers.image.description="Go dev tools: migrate (postgres), buf, protoc-gen-go(-grpc), goimports, gentool"

RUN apk --no-cache add git make bash openssl ca-certificates tzdata postgresql-client \
    && cp /usr/share/zoneinfo/UTC /etc/localtime && echo "UTC" > /etc/timezone

COPY --from=builder /out/ /usr/local/bin/

WORKDIR /tool
CMD ["sh"]
