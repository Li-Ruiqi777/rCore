docker start rCore

echo "Enter container: rCore"
docker exec \
    -u root \
    -it rCore \
    /bin/bash
