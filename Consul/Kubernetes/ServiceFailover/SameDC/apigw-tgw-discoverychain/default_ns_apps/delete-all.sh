#!/bin/bash

NAMESPACE="default"

for file in *.yaml *.yml; do
    [ -f "$file" ] || continue

    echo "Deleting $file..."
    kubectl delete -n "$NAMESPACE" -f "$file" --ignore-not-found

    if [ $? -ne 0 ]; then
        echo "Failed to delete $file"
    fi
done

echo "Done! All YAML files have been deleted."
