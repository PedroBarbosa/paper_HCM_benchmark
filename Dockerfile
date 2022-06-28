FROM docker.io/mambaorg/micromamba:0.24.0
LABEL Name=paperhcmbenchmark Version=0.0.1
COPY --chown=$MAMBA_USER:$MAMBA_USER conda_environment.yml /tmp/env.yaml
RUN micromamba install -y -n base -f /tmp/env.yaml && \
    micromamba clean --all --yes
WORKDIR /work
COPY run_benchmarks.ipynb /work/run_benchmarks.ipynb
VOLUME [ "/work/data" ]
VOLUME [ "/work/scripts" ]
VOLUME [ "/work/out" ]
RUN chmod 777 /work/out
