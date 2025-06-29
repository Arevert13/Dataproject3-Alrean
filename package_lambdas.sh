#!/bin/bash

set -e

LAMBDA_DIR="./app/lambdas"
BUILD_DIR="./build/lambdas"

echo "=============================="
echo " Limpiando carpeta de builds"
echo "=============================="
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

echo "=============================="
echo " Empaquetando todas las Lambdas"
echo "=============================="

for FUNCTION in get_product add_product buy_product
do
  echo "-------------------------------------"
  echo "Empaquetando: $FUNCTION"

  docker run --rm \
    -v "$PWD":/var/task \
    amazonlinux:2023 \
    bash -c "\
      yum install -y python3-pip zip && \
      cd /var/task/$LAMBDA_DIR/$FUNCTION && \
      rm -rf .python_packages && \
      mkdir -p .python_packages && \
      pip3 install --platform manylinux2014_x86_64 --target=.python_packages --implementation cp --python-version 3.11 --only-binary=:all: --upgrade -r requirements.txt && \
      cd .python_packages && \
      zip -r /var/task/$BUILD_DIR/${FUNCTION}.zip . && \
      cd .. && \
      zip -g /var/task/$BUILD_DIR/${FUNCTION}.zip lambda_function.py"
  
  echo "✔️  $FUNCTION empaquetado en $BUILD_DIR/${FUNCTION}.zip"
done

echo "✅ Todas las Lambdas empaquetadas con éxito."

