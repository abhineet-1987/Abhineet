#!/bin/bash

NAMESPACE="backup"

for file in *.yaml *.yml; do
    [ -f "$file" ] || continue

    echo "Applying $file to namespace $NAMESPACE..."
    kubectl apply -n "$NAMESPACE" -f "$file"
done

echo "Done! Applied all YAML files to namespace $NAMESPACE."
