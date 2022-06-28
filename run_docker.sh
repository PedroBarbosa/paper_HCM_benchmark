#! /bin/sh
mkdir -p out
chmod 777 out
docker run -it -v $PWD/data:/work/data -v $PWD/scripts:/work/scripts -v $PWD/out:/work/out --rm hcm_eval papermill run_benchmarks.ipynb /work/out/out.ipynb
docker run -it -v $PWD/data:/work/data -v $PWD/scripts:/work/scripts -v $PWD/out:/work/out --rm hcm_eval jupyter nbconvert --to html /work/out/out.ipynb
