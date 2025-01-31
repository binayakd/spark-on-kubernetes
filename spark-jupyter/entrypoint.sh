#/bin/bash

echo "changing dir"
cd workspace

echo "starting jupyter lab"
jupyter-lab \
  --ip='0.0.0.0' \
  --NotebookApp.token="${TOKEN}" \
  --NotebookApp.password="${PASSWORD}" \
  --port=8888 \
  --no-browser