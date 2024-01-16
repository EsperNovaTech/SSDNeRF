# Start from a base image with CUDA support
FROM nvidia/cuda:11.3.1-base-ubuntu20.04

# Set environment variables for CUDA
ENV PATH=/usr/local/cuda-11.3/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/cuda-11.3/lib64:$LD_LIBRARY_PATH

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    wget \
    unzip \
    git \
    python3.7 \
    python3-pip

# Install Python dependencies
COPY requirements.txt .
RUN pip3 install -r requirements.txt

# Install PyTorch, torchvision, and torchaudio
RUN pip3 install torch==1.12.1 torchvision==0.13.1 torchaudio==0.12.1

# Install MMCV and MMGeneration
RUN pip3 install -U openmim
RUN pip3 install mmcv-full==1.6
RUN git clone https://github.com/open-mmlab/mmgeneration && cd mmgeneration && git checkout v0.7.2
RUN pip3 install -v -e ./mmgeneration

# Compile CUDA packages
WORKDIR /app/lib/ops/raymarching
COPY ./lib/ops/raymarching .
RUN ls -la && cat setup.py
RUN pip3 install -e . || (echo "Installation failed in /app/lib/ops/raymarching" && exit 1)
WORKDIR /app/lib/ops/shencoder
COPY ./lib/ops/shencoder .
RUN pip3 install -e . || (echo "Installation failed in /app/lib/ops/shencoder" && exit 1)
WORKDIR /app

# Copy the rest of the application
COPY . .

# Set the command to run when starting the container
CMD ["python3", "train.py"]