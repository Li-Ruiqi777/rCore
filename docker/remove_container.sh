# 停止并删除同名容器
echo "stop and rm docker" 
docker stop rCore > /dev/null
docker rm -v -f rCore
