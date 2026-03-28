#!/usr/bin/env bash

llama_opts=('')

if [[ $FUNCTION == "compute" ]]; then
  echo Starting rpc-server worker node...
  if [[ $USE_CACHE == "true" ]]; then
    llama_opts+=("-c")
  fi
  rpc-server --host ${RPC_HOST} --port ${RPC_PORT} --threads ${NUM_THREADS} ${llama_opts[@]}
elif [[ $FUNCTION == "frontend" ]]; then
  echo Starting llama-server frontend node...
  rpc_list=$(printf "%s:50052," ${RPC_HOST//,/ })
  rpc_list="${rpc_list%,}"  # Trim trailing comma
  llama-server --host ${WEB_HOST} \
	       --port ${WEB_PORT} \
	       --model ${MODEL_PATH} \
	       --threads ${NUM_THREADS}\
	       --rpc ${rpc_list} \
	       --tools ${MCP_URL} \
	       ${llama_opts[@]}
fi
