#!/bin/bash

echo "Empaquetando Lambdas con dependencias..."

for dir in app/lambdas/*; do
  if [ -d "$dir" ]; then
    echo "Empaquetando $dir"

    rm -rf "$dir/build"
    mkdir -p "$dir/build"
    cp "$dir/lambda_function.py" "$dir/build/"

    pip install --target "$dir/build" -r "$dir/requirements.txt"

    (cd "$dir/build" && zip -r ../function.zip .)

    echo "Empaquetado: $dir/function.zip"
  fi
done
