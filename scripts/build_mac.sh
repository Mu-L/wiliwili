set -e

BUILD_DIR=cmake-build-mac

# cd to wiliwili
cd "$(dirname "$0")/.."

cmake -B ${BUILD_DIR} -DPLATFORM_DESKTOP=ON -DCMAKE_BUILD_TYPE=Release
make -C ${BUILD_DIR} wiliwili -j$(nproc)


APP_PATH=${BUILD_DIR}/wiliwili.app

rm -rf ${APP_PATH}

mkdir -p ${APP_PATH}/Contents
mkdir -p ${APP_PATH}/Contents/MacOS
mkdir -p ${APP_PATH}/Contents/Resources


cp ./scripts/mac/Info.plist ${APP_PATH}/Contents/Info.plist

version_major=$(jq .version_major resources/i18n/en-US/version.json)
version_minor=$(jq .version_minor resources/i18n/en-US/version.json)
version_revision=$(jq .version_revision resources/i18n/en-US/version.json)
version=${version_major}.${version_minor}.${version_revision}
git_tag=$(git rev-parse --short HEAD)

sed -i '35c \    <string>'"${version}"'</string>' ${APP_PATH}/Contents/Info.plist
sed -i '39c \    <string>'"${git_tag}"'</string>' ${APP_PATH}/Contents/Info.plist

cp ./scripts/mac/AppIcon.icns ${APP_PATH}/Contents/Resources/AppIcon.icns
cp ${BUILD_DIR}/wiliwili ${APP_PATH}/Contents/MacOS/wiliwili
cp -r ./resources ${APP_PATH}/Contents/Resources/

dylibbundler -cd -b -x ${APP_PATH}/Contents/MacOS/wiliwili \
  -d ${APP_PATH}/Contents/MacOS/lib/ -p @executable_path/lib/

codesign --sign - --force ${APP_PATH}/Contents/MacOS/lib/*