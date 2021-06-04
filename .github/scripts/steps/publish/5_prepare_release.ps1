# 准备发布Release文件

cd $env:BUILD_PATH
cp .\Clash.Mini_*.exe ${env:PUBLISH_PATH}\
echo "Ready to upload the following file(s):"
ls ${env:PUBLISH_PATH}