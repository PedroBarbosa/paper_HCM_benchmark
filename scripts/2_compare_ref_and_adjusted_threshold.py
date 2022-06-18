#-----------------------------------------------
#   HCM benchmark (2022)       
#   Author: Pedro Barbosa
#
#   Script to compare performance
#   using references vs ajdusted thresholds
#-----------------------------------------------
import argparse
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns 
import numpy as np

def generate_heatmap(_df: pd.DataFrame, dataset_names: list):
    sns.set()
    order = ['ref_threshold', 'beta_0.5', 'beta_1', 'beta_1.5']

    d1 = _df[_df.Dataset == dataset_names[0]]
    df = d1.drop('Dataset', axis=1).pivot(index='tool', columns=['Threshold'])
    df = df.dropna()
    df.columns = df.columns.droplevel()
    df = df[order]
    df = df.sort_values('beta_0.5', ascending=False)

    tool_order = df.index.to_list()
    fig, (ax1, ax2, ax3) = plt.subplots(ncols=3, sharey=True, figsize=(20, 8))

    # s = sns.heatmap(df, 
    #             cmap="crest", 
    #             linewidths=.5,
    #             xticklabels=True, 
    #             yticklabels=True,
    #             annot=True,
    #             ax=ax1, 
    #             vmin=0, 
    #             vmax=1,
    #             cbar_kws={"orientation": "horizontal", "label": "Weighted normalized MCC", "pad": 0.004})
    # s.set(xlabel=dataset_names[0])
   
    # ax1.set_xticklabels(ax1.get_xticklabels())
    # ax1.xaxis.tick_top()  # x axis on top
    # ax1.xaxis.set_label_position('top')
    # cbar = ax1.collections[0].colorbar
    # cbar.set_ticks([0, 50, 100])
    # cbar.set_ticklabels(['0%', '50%', '100%'])

    for i, ax in enumerate([ax1, ax2, ax3]):
       
        dataset = dataset_names[i]
        
        d1 = _df[_df.Dataset == dataset]
        df = d1.drop('Dataset', axis=1).pivot(index='tool', columns=['Threshold'])
        df = df.dropna()
        df.columns = df.columns.droplevel()
        df = df[order]
        
        if i == 0:
            df = df.sort_values('beta_1', ascending=False)
            tool_order = df.index.to_list()
        else:
            df = df.reindex(tool_order)

        g = sns.heatmap(df, 
                    cmap="vlag", 
                    linewidths=.5,
                    xticklabels=True, 
                    yticklabels=True,
                    annot=True,
                    ax=ax, 
                    vmin=0, 
                    vmax=1, 
                    annot_kws={"fontsize":8},
                    cbar_kws={"orientation": "horizontal", "label": "Weighted normalized MCC", "pad": 0.004})
        
        g.set(xlabel=dataset, ylabel="")
        ax.set_xticklabels(ax.get_xticklabels())
        ax.xaxis.tick_top()  # x axis on top
        ax.xaxis.set_label_position('top')
        ax.vlines(range(0, df.shape[1]), ymin=0, ymax=df.shape[0], colors='black', linewidths=1)
        ax.axhline(y=0, color='k', linewidth=3)
        ax.axhline(y=df.shape[0], color='k', linewidth=3)
        ax.axvline(x=0, color='k', linewidth=3)
        ax.axvline(x=df.shape[1], color='k', linewidth=3)
        
    plt.tight_layout()

    fig.savefig("plots/ref_vs_adjusted.pdf", format='pdf', bbox_inches='tight')
    plt.show()

    
def get_data(**kwargs):
    out = []
    metric = kwargs['metric']
    to_loop = ['ref_threshold', 'beta_0.5', 'beta_1', 'beta_1.5']
    
    for threshold in to_loop:
        for i, f in enumerate(kwargs[threshold]):
            df = pd.read_csv(f, sep="\t")
            df = df[['tool', metric]].copy()

            if kwargs['dataset_names'] is not None:
                df['Dataset'] = kwargs['dataset_names'][i]
            else:
                df['Dataset'] = i
            
            df['Threshold'] = threshold
            out.append(df)
    
    return pd.concat(out)
    
  
def main():
    parser = argparse.ArgumentParser(add_help=True)
    parser.add_argument('--metric', default=['weighted_norm_mcc'], help='Metric to evaluate performance.')
    parser.add_argument('--ref_threshold', nargs='+', help="Stats file with metrics using reference threshold")
    parser.add_argument('--beta_0.5', nargs='+', help="Stats file with metrics using adjusted thresholds with beta0.5")
    parser.add_argument('--beta_1', nargs='+', help="Stats file with metrics using adjusted thresholds with beta1")
    parser.add_argument('--beta_1.5', nargs='+', help="Stats file with metrics using adjusted thresholds with beta1.5")
    parser.add_argument('--dataset_names', nargs='+', help="Name of each dataset. Must correspond to the order of the other arguments")
    args = parser.parse_args()
    
    df = get_data(**vars(args))
    generate_heatmap(df, args.dataset_names)
    
if __name__ == "__main__":
    main()