# paper_HCM_benchmark
This repo contains the necessary code to reproduce the results obtained in the benchmark of prediction tools to predict Hypertrophic Cardiomyopathy associated variants.

Please check the jupyter notebook `run_benchmarks.ipynb` created for the task, where the steps to generate results and corresponding figures are displayed.

To fully reproduce the analysis, you can simply follow the steps below. The only requirement is to have Docker installed.

``` 
git clone https://github.com/PedroBarbosa/paper_HCM_benchmark
cd paper_HCM_benchmark
./build_docker.sh
./run_docker.sh
```

Results should appear in the `out` folder.
