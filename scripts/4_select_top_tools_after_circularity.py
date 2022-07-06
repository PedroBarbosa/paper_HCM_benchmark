#-----------------------------------------------
#   HCM benchmark (2022)       
#   Author: Pedro Barbosa
#
#   Script to compare performance of tools 
#   across two different datasets that control
#   for circularity issues, weighting them differently
#   based on the total number of variants on each
#-----------------------------------------------
import argparse
import pandas as pd


def average_by_metrics(df: pd.DataFrame, metric: str):
    n_variants = df.total.unique().sum()
    
    sf = df.groupby('dataset').apply(lambda x: x.iloc[0].total / n_variants).to_dict()

    df['scaling_factor'] = df['dataset'].map(sf)
    df[metric] = df[metric] * df.scaling_factor
    df = df[['tool', 'dataset'] + [metric]].copy()
    
    ranked = df.groupby('tool')[metric].sum().sort_values(ascending=False)
    print("Top tools")
    print('\n'.join(ranked.head(5).index.to_list()))
   
def get_data(files: list, dataset_names: list = None):
    dfs = []
    for i, f in enumerate(files):
        _df = pd.read_csv(f, sep="\t")
     
        if dataset_names is not None:
            _df['dataset'] = dataset_names[i]
        else:
            _df['dataset'] = i

        dfs.append(_df)
    
    return pd.concat(dfs)
  
def main():
    parser = argparse.ArgumentParser(add_help=True)
    parser.add_argument('--metrics_files', metavar="", required=True, nargs='+', help='Statistics file generated by a VETA run. Mininum of two files is required.')
    parser.add_argument('--ranking_metric', metavar="", choices=['weighted_F1', 'weighted_accuracy', 'weighted_norm_mcc', 'norm_mcc'])
    parser.add_argument('--dataset_names', metavar="", nargs='+', help="Name of each dataset. Must correspond to the order of 'metrics' files")
    args = parser.parse_args()
    
    if len(args.metrics_files) < 2:
        raise ValueError('At least two metric files are required.')

    if args.dataset_names:
        if len(args.metrics_files) != len(args.dataset_names):
            raise ValueError("--dataset_names must have the same number of names as of the --metrics_files.")

    df = get_data(args.metrics_files, args.dataset_names)
    df = average_by_metrics(df, args.ranking_metric)

    
if __name__ == "__main__":
    main()
