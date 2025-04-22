FROM pytorch/pytorch:2.6.0-cuda12.4-cudnn9-runtime

ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1

RUN apt-get update && apt-get install -y git ffmpeg libsm6 libxext6 gcc g++ && apt-get clean

ENV ROOT=/comfyui
RUN --mount=type=cache,target=/root/.cache/pip \
  git clone https://github.com/comfyanonymous/ComfyUI.git ${ROOT}

WORKDIR ${ROOT}

RUN pip install -r requirements.txt
RUN pip install insightface==0.7.3 opencv-python xformers onnxruntime-gpu --extra-index-url https://aiinfra.pkgs.visualstudio.com/PublicPackages/_packaging/onnxruntime-cuda-12/pypi/simple/

RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git custom_nodes/ComfyUI-Manager
RUN git clone https://github.com/cubiq/ComfyUI_IPAdapter_plus.git custom_nodes/ComfyUI_IPAdapter_plus
RUN git clone https://github.com/ssitu/ComfyUI_UltimateSDUpscale.git custom_nodes/ComfyUI_UltimateSDUpscale --recursive
RUN git clone https://github.com/Fannovel16/comfyui_controlnet_aux.git custom_nodes/comfyui_controlnet_aux
RUN pip install -r custom_nodes/comfyui_controlnet_aux/requirements.txt
RUN git clone https://github.com/crystian/ComfyUI-Crystools.git custom_nodes/ComfyUI-Crystools
RUN pip install -r custom_nodes/ComfyUI-Crystools/requirements.txt
RUN git clone https://github.com/Acly/comfyui-tooling-nodes.git custom_nodes/comfyui-tooling-nodes
RUN git clone https://github.com/Acly/comfyui-inpaint-nodes.git custom_nodes/comfyui-inpaint-nodes

COPY ./extra_model_paths.yaml /docker/
RUN cp /docker/extra_model_paths.yaml ${ROOT}/extra_model_paths.yaml
RUN rm -rf ${ROOT}/output
RUN rm -rf ${ROOT}/input

ENV PYTHONPATH="${PYTHONPATH}:${PWD}" CLI_ARGS=""
ENV NVIDIA_VISIBLE_DEVICES=all
EXPOSE 7860
CMD python -u main.py --listen --port 7860 ${CLI_ARGS}
