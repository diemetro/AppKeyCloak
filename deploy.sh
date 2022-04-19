#!/bin/bash

cd ${DEPLOY_DIR}
docker network create --driver overlay internal-net || true
envsubst < docker-compose.tpl > docker-compose.yaml
cat docker-compose.yaml
docker stack deploy --compose-file docker-compose.yaml iam-${CI_COMMIT_REF_NAME}
cd
rm -rf ${DEPLOY_DIR}

