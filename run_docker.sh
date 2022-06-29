#! /bin/sh
mkdir -p out
mkdir -p out/plots
chmod -R 777 out

docker run -v $PWD/data:/work/data -v $PWD/scripts:/work/scripts -v $PWD/out:/work/out --rm hcm_eval papermill -k python3 run_benchmarks.ipynb /work/out/out.ipynb
docker run -v $PWD/data:/work/data -v $PWD/scripts:/work/scripts -v $PWD/out:/work/out --rm hcm_eval jupyter nbconvert --to html /work/out/out.ipynb
