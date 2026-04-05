#!/usr/bin/env bash

extra_llama_opts=('')

echo Checking for numactl...
numactl --version
numa_exists=$?

if [[ $FUNCTION == "compute" ]]; then
  echo Starting rpc-server worker node...
  if [[ $USE_CACHE == "true" ]]; then
    extra_llama_opts+=("-c")
  fi

  if [[ $numa_exists -ne 0 ]]; then
    echo numactl not found...
    exec rpc-server \
              --host ${RPC_HOST} \
              --port ${RPC_PORT} \
              --threads ${NUM_THREADS} \
              ${extra_llama_opts[@]}
  else
    echo found numactl...starting on node ${NUMA_NODE}
    echo 0 > /proc/sys/kernel/numa_balancing
    exec numactl \
              --cpunodebind=${NUMA_NODE} \
              --membind=${NUMA_NODE} \
              rpc-server \
                    --host ${RPC_HOST} \
                    --port ${RPC_PORT} \
                    --threads ${NUM_THREADS} \
                    ${extra_llama_opts[@]}
  fi

elif [[ $FUNCTION == "frontend" ]]; then
  echo Starting llama-server frontend node...

  if [[ ! -z ${MODEL_CHAT_TEMPLATE} ]]; then
    extra_llama_opts+=("--chat-template ${MODEL_CHAT_TEMPLATE}")
  fi
  if [[ $numa_exists -eq 0 ]]; then
    extra_llama_opts+=("--numa numactl")
    echo 0 > /proc/sys/kernel/numa_balancing
  fi

  exec llama-server \
        --host ${WEB_HOST} \
        --port ${WEB_PORT} \
        --model ${MODEL_PATH} \
        --threads ${NUM_THREADS}\
        --rpc ${RPC_CLIENTS} \
        --webui-mcp-proxy \
        ${extra_llama_opts[@]}
fi
