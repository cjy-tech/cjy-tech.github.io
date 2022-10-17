#!/bin/bash

# Init environments
export TARGET_S3_BUCKET_NAME="webbucket.gfin.dev"
export TARGET_CF_DISTRIBUTION_ID="E1HE8ZF98ZMFQD"
export REGION=ap-northeast-2
export AWS_PROFILE=dev-fe

# Step 1: Check prerequisite of user environment
echo "

     []  ,----.___
   __||_/___      '.
  / O||    /|       )
 /   ""   / /   =._/
/________/ /
|________|/   DEPLOY WEB BUCKET

"
echo "[i] Checking prerequisite ..."
which aws
RESULT=$?

if [ $RESULT == 0 ]; then
  echo "[i] You're ready to use aws cli. Good."
else
  echo "[x] Failed. Install awscli before run script."
fi

# Step 2: Upload index file to S3 Bucket on greenlabsfin-dev account
echo "[i] Your target S3 Bucket name is [$TARGET_S3_BUCKET_NAME] now."
echo "[i] Your target bucket region is [$REGION]."
echo "> Enter directory name: "
echo "[i] Support full path or relative path. (e.g. ./test)"
read DIR_NAME

aws s3 cp $DIR_NAME s3://$TARGET_S3_BUCKET_NAME \
  --recursive \
  --region $REGION >> deploy-web-bucket-$(date '+%Y-%m-%d').log
RESULT=$?

if [ $RESULT == 0 ]; then
  echo "[i] Successfully upload your file to S3 bucket."
else
  echo "[x] Failed upload file to S3 bucket."
fi

# Step 3: Create invalidation to CloudFront on greenlabsfin-dev account
echo "[i] Your target cloudfront distribution is [$TARGET_CF_DISTRIBUTION_ID]."

aws cloudfront create-invalidation \
  --distribution-id $TARGET_CF_DISTRIBUTION_ID \
  --paths "/*" >> deploy-web-bucket-$(date '+%Y-%m-%d').log
RESULT=$?

if [ $RESULT == 0 ]; then
  echo "[i] Created invalidation to cloudfront successfully."
else
  echo "[x] Failed create a invalidation. Install awscli before running the script."
  echo "[i] Installation guide: brew install awscli && awscli version"
fi

echo "--- Done. ---" >> deploy-web-bucket-$(date '+%Y-%m-%d').log
echo "" >> deploy-web-bucket-$(date '+%Y-%m-%d').log