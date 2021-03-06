version: '3.7'
services:
  keycloak:
    image: "jboss/keycloak:latest"
    environment:
        DB_VENDOR: MARIADB
        MARIADB_ROOT_PASSWORD: "${MARIADB_ROOT_PASSWORD}"
        DB_ADDR: mysql-main_mariadb
        DB_PORT: 3306
        DB_DATABASE: iam
        DB_USER: iam-svc
        DB_PASSWORD: "${DB_PASSWORD}"
        KEYCLOAK_USER: "${KEYCLOAK_USER}"
        KEYCLOAK_PASSWORD: "${KEYCLOAK_PASSWORD}"
        KEYCLOAK_LOGLEVEL: WARN
        PROXY_ADDRESS_FORWARDING: 'true'
        ##JDBC_PARAMS: "connectTimeout=30000"
        TZ: "Europe/Moscow"
    command:
      - "-Djboss.http.port=8081"
      - "-Djboss.https.port=8443"
      - "-Djboss.socket.binding.port-offset=0"
    networks:
      - internal-net
      - traefik-net
    ports:
      - "8081:8081"
      - "8443:8443"
    deploy:
      mode: replicated
      replicas: 1
      restart_policy:
        condition: any
        delay: 5s
        max_attempts: 5
        window: 10s
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.${PROJECT_NAME}-${CI_COMMIT_REF_NAME}.rule=Host(`${PROJECT_DOMAIN}`)"
        - "traefik.http.routers.${PROJECT_NAME}-${CI_COMMIT_REF_NAME}.entrypoints=websecure"
        - "traefik.http.routers.${PROJECT_NAME}-${CI_COMMIT_REF_NAME}.tls=true"
        - "traefik.http.routers.${PROJECT_NAME}-${CI_COMMIT_REF_NAME}.tls.certresolver=myresolver"
        - "traefik.http.routers.${PROJECT_NAME}-${CI_COMMIT_REF_NAME}.middlewares=${PROJECT_NAME}-${CI_COMMIT_REF_NAME}-https"
        - "traefik.http.middlewares.${PROJECT_NAME}-${CI_COMMIT_REF_NAME}-https.redirectscheme.scheme=https"
        - "traefik.docker.network=traefik-net"
        - "traefik.http.services.${PROJECT_NAME}-${CI_COMMIT_REF_NAME}.loadbalancer.server.port=8081"
        - "traefik.http.services.${PROJECT_NAME}-${CI_COMMIT_REF_NAME}.loadbalancer.passhostheader=true"

networks:
  internal-net:
    driver: overlay
    external: true
  traefik-net:
    driver: overlay
    external: true


