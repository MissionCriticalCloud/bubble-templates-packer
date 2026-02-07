#!/bin/bash

set -x

echo "Removing previous artifacts"
rm -rf ./packer_output
echo "Running Packer"
packer init template.pkr.hcl
packer build template.pkr.hcl
