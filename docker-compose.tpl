version: '3.7'
services:
  iam:
    image: "quay.io/keycloak/keycloak:17.0.1"
    environment:
        DB_VENDOR: mariadb
        MARIADB_ROOT_PASSWORD: "${MARIADB_ROOT_PASSWORD}"
        DB_ADDR: mysql_mariadb
        DB_PORT: 3306
        DB_DATABASE: iam
        DB_USER: iam
        DB_PASSWORD: password
        KEYCLOAK_USER: admin
        KEYCLOAK_PASSWORD: Pa55w0rd
        KEYCLOAK_ADMIN: "${KEYCLOAK_ADMIN}"
        KEYCLOAK_ADMIN_PASSWORD: "${KEYCLOAK_ADMIN_PASSWORD}"
        #JDBC_PARAMS: "connectTimeout=30000"
    ports:
        - 8080:8080
    networks:
      - internal-net
      - traefik-net
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
        - "traefik.http.routers.${PROJECT_NAME}-${CI_COMMIT_REF_NAME}.entrypoints=websecure"
        - "traefik.http.routers.${PROJECT_NAME}-${CI_COMMIT_REF_NAME}.rule=Host(`${PROJECT_DOMAIN}`)"
        - "traefik.http.services.${PROJECT_NAME}-${CI_COMMIT_REF_NAME}.loadbalancer.server.port=80"
        - "traefik.http.routers.${PROJECT_NAME}-${CI_COMMIT_REF_NAME}.tls.certresolver=myresolver"
        - "traefik.http.routers.${PROJECT_NAME}-${CI_COMMIT_REF_NAME}.middlewares=${PROJECT_NAME}-${CI_COMMIT_REF_NAME}-https"
        - "traefik.http.middlewares.${PROJECT_NAME}-${CI_COMMIT_REF_NAME}-https.redirectscheme.scheme=https"
        - "traefik.docker.network=traefik-net"

networks:
  internal-net:
    driver: overlay
    external: true
  traefik-net:
    driver: overlay
    external: true


