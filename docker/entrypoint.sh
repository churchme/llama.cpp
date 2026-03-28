#!/usr/bin/env bash

extra_llama_opts=('')

if [[ $FUNCTION == "compute" ]]; then
  echo Starting rpc-server worker node...
  if [[ $USE_CACHE == "true" ]]; then
    extra_llama_opts+=("-c")
  fi
  exec rpc-server \
                  --host ${RPC_HOST} \
                  --port ${RPC_PORT} \
                  --threads ${NUM_THREADS} \
                  ${extra_llama_opts[@]}
elif [[ $FUNCTION == "frontend" ]]; then
  echo Starting llama-server frontend node...
  rpc_list=$(printf "%s:50052," ${RPC_HOST//,/ })
  rpc_list="${rpc_list%,}"  # Trim trailing comma

  if [[ -n ${MODEL_CHAT_TEMPLATE} ]]; then
    extra_llama_opts+=("--chat-template ${MODEL_CHAT_TEMPLATE}")
  fi
  exec llama-server \
                  --host ${WEB_HOST} \
                  --port ${WEB_PORT} \
                  --model ${MODEL_PATH} \
                  --threads ${NUM_THREADS}\
                  --rpc ${rpc_list} \
                  --webui-mcp-proxy ${MCP_URL} \
                  ${extra_llama_opts[@]}
fi
