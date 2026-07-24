#!/bin/bash

NAMESPACE="default"

for file in *.yaml *.yml; do
    [ -f "$file" ] || continue

    echo "Applying $file..."
    kubectl apply -n "$NAMESPACE" -f "$file"

    if [ $? -ne 0 ]; then
        echo "Failed to apply $file"
    fi
done

echo "Done! All YAML files have been applied."
