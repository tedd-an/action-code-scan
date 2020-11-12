#!/bin/bash

set -e

if [ -z "$GITHUB_TOKEN" ]; then
    echo "Missing environment variable: GITHUB_TOKEN"
    exit 1
fi

if [ -z "$EMAIL_TOKEN" ]; then
    echo "Missing environment variable: EMAIL_TOKEN"
    exit 1
fi

# Input parameters:
SRC_REPO=$1
SCAN_TOOL=$2

echo ">> SRC_REPO = $SRC_REPO"
echo ">> SCAN_TOOL = $SCAN_TOOL"

git config user.name "$GITHUB_ACTOR"
git config user.email "$GITHUB_ACTOR@users.noreply.github.com"

SRC_TAG=$(git describe)
BUILD_DATE=$(date +"%m-%d-%Y")

echo ">> SRC_TAG: $SRC_TAG"
echo ">> BUILD_DATE: $BUILD_DATE"

if [ "$SCAN_TOOL" = 'coverity' ]; then
    echo ">> Run Coverity Scan"
    /coverity-submit -b $BUILD_DATE -v -t $SRC_TAG -c /coverity-submit.cfg bluez

    if [ $? -eq 0 ]; then
        echo ">> Coverity run completed and result is submitted to coverity website"
    else
        echo ">> ERROR: Failed to run Coverity"
    fi

elif [ "$SCAN_TOOL" = 'clang' ]; then
    SCAN_REPORT_PATH="./scan_report"
    scan-build ./bootstrap-configure --enable-external-ell && scan-build -o $SCAN_REPORT_PATH make -j4

    if [ $? -eq 0 ]; then
        echo ">> Clang Code Scan run completed and result is saved to $SCAN_REPORT_PATH"
        tar -cvzf scan_report.tar.gz $SCAN_REPORT_PATH
        /send-email -c /send-email.cfg -a scan_report.tar.gz
    else
        echo ">> ERROR: Failed to run Clang Code Scan"
    fi

else
    echo "ERROR: Unknown Scan Tool value: $SCAN_TOOL"
    exit 1
fi

echo ">> Completed >>"
