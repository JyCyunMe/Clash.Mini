# 准备压缩

cd $env:BUILD_PATH
mkdir -p ($PUBLISH_PATH_X64="${env:PUBLISH_PATH}\x64")
mkdir -p ($PUBLISH_PATH_X86="${env:PUBLISH_PATH}\x86")
echo "PUBLISH_PATH_X64=$PUBLISH_PATH_X64" >> $env:GITHUB_ENV
echo "PUBLISH_PATH_X86=$PUBLISH_PATH_X86" >> $env:GITHUB_ENV
mkdir -p .\Profile

$packageFiles=@(".\profile", "..\config.yaml", "..\Country.mmdb")

mv ${env:PUBLISH_PATH}\Clash.Mini*64.exe $PUBLISH_PATH_X64\Clash.Mini.exe
$filesX64=$packageFiles
foreach ($file in $filesX64) {
    cp $file $PUBLISH_PATH_X64\
}

mv ${env:PUBLISH_PATH}\Clash.Mini*86.exe $PUBLISH_PATH_X86\Clash.Mini.exe
$filesX86=$packageFiles
foreach ($file in $filesX86) {
    cp $file $PUBLISH_PATH_X86\
}


mkdir -p ($RELEASE_PATH="${env:PUBLISH_PATH}\releases")
echo "RELEASE_PATH=$RELEASE_PATH" >> $env:GITHUB_ENV
$RELEASE_PKG_X64="$RELEASE_PATH\Clash.Mini_${env:GIT_TAG}_x64.7z"
$RELEASE_PKG_X86="$RELEASE_PATH\Clash.Mini_${env:GIT_TAG}_x86.7z"
echo "RELEASE_PKG_X64=$RELEASE_PKG_X64" >> $env:GITHUB_ENV
echo "RELEASE_PKG_X86=$RELEASE_PKG_X86" >> $env:GITHUB_ENV
echo "::set-output name=release-path::$RELEASE_PATH"
