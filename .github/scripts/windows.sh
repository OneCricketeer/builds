#!/usr/bin/env bash

set -o errexit -o pipefail -o nounset -x
IFS=$'\t\n'

FX="https://gluonhq.com/download/javafx-14-jmods-windows"

CURRENT_DIR=$(pwd)
echo "Current dir: $CURRENT_DIR"

VERSION="$1"
echo "Will build Conduktor $VERSION"

########################################################################################################################

echo "Downloading JavaFX Jmods..."
curl -sLO $FX
unzip -oq javafx-*-jmods-windows
FX_MODS_PATH="./javafx-jmods-14"

CONDUKTOR_DISTRIBUTION_PATH="$(pwd)/conduktor-$VERSION"

echo "Building custom JRE..."
CUSTOM_JRE_NAME="runtime"
jlink --module-path "$FX_MODS_PATH" \
    --add-modules "$CDK_JLINK_MODULES" \
    --bind-services --output "$CUSTOM_JRE_NAME" \
    --strip-debug --compress 2 --no-header-files --no-man-pages --strip-native-commands

DEPLOY_RESOURCES_PATH=".github/resources"

###############################################################################

echo "Packaging .msi"
jpackage --name "$CDK_APP_NAME" \
              --app-version "$VERSION" \
              --description "$CDK_APP_DESCRIPTION" \
              --type msi \
              --icon "$DEPLOY_RESOURCES_PATH/Conduktor.ico" \
              --vendor "$CDK_VENDOR" \
              --main-class io.conduktor.app.ConduktorLauncher \
              --copyright "$CDK_COPYRIGHT" \
              --resource-dir "$DEPLOY_RESOURCES_PATH" \
              --verbose \
              --dest . \
              --input "$CONDUKTOR_DISTRIBUTION_PATH/lib" \
              --main-jar "desktop-$VERSION.jar" \
              --runtime-image "$CUSTOM_JRE_NAME" \
              --win-dir-chooser \
              --win-menu \
              --win-shortcut \
              --win-upgrade-uuid 3a60b525-6f18-4c22-8070-d08efcc89b95 \
              --java-options "$CDK_JAVA_OPTIONS"

echo "Packaging .exe"
jpackage --name "$CDK_APP_NAME" \
              --app-version "$VERSION" \
              --description "$CDK_APP_DESCRIPTION" \
              --type exe \
              --icon "$DEPLOY_RESOURCES_PATH/Conduktor.ico" \
              --vendor "$CDK_VENDOR" \
              --main-class io.conduktor.app.ConduktorLauncher \
              --copyright "$CDK_COPYRIGHT" \
              --resource-dir "$DEPLOY_RESOURCES_PATH" \
              --verbose \
              --dest . \
              --input "$CONDUKTOR_DISTRIBUTION_PATH/lib" \
              --main-jar "desktop-$VERSION.jar" \
              --runtime-image "$CUSTOM_JRE_NAME" \
              --win-dir-chooser \
              --win-menu \
              --win-shortcut \
              --win-upgrade-uuid 3a60b525-6f18-4c22-8070-d08efcc89b95 \
              --java-options "$CDK_JAVA_OPTIONS"
