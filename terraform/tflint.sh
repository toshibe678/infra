#!/bin/bash -x
/usr/local/bin/tflint --init
find . -type f -name "*.tf" -exec dirname {} \;| sort -u| while read line; do
  cd $line;
  echo "processing $PWD ..."
  terraform init -backend=false && /usr/local/bin/tflint --config ./.tflint.hcl;
  cd -;
done
