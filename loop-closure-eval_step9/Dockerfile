FROM ubuntu:24.04
 
ENV DEBIAN_FRONTEND=noninteractive
 
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*
 
WORKDIR /app
 
RUN pip3 install --break-system-packages matplotlib scipy 

COPY loop_clouds_to_edges.py /app/loop_clouds_to_edges.py
COPY compare_loop_edges.py /app/compare_loop_edges.py
COPY plot_gt.py /app/plot_gt.py
 
