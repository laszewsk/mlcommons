import h5py
import os
import numpy as np
import matplotlib.pyplot as plt
file_name = "S3A_SL_1_RBT____20190612T004900_20190612T005200_20190612T030639_0179_045_359_1080_LN2_O_NR_003.hdf"

if not os.path.isdir("histograms"):
    os.makedirs("histograms")
hist_dir = os.path.join(os.path.curdir, "histograms")

all_datasets = ["bayes", "bts", "rads", "refs", "summary"]

def main():
    # Have the option to have natural log of frequency taken
    make_hist(file_name, "bayes", log=True)
    for elem in all_datasets:
        make_hist(file_name, elem)

def make_hist(file_name, title, log=False):
    with h5py.File(file_name, "r") as hdf:
        data = np.array(hdf[title][:])

    for i in range(data.shape[-1]):
        hist, bin_edges = np.histogram(data[:,:,i:i+1], bins="auto")
        
        plt.figure(figsize=[10,8])

        if log:
            plt.bar(bin_edges[:-1], np.log(hist), width=bin_edges[2]-bin_edges[1], 
            color='blue',alpha=0.7)
        else:
            plt.bar(bin_edges[:-1], hist, width=bin_edges[2]-bin_edges[1], 
            align="edge", color='blue',alpha=0.7)

        plt.xlim(min(bin_edges)-5, max(bin_edges)+5)
        plt.xlabel('Value')

        if log:
            plt.ylabel('ln(Frequency)')
            plt.title(title+"_dim_"+str(i)+" ln")
        else:
            plt.ylabel('Frequency')
            plt.title(title+"_dim_"+str(i))
        

        if not os.path.isdir(os.path.join(hist_dir, file_name[0:-4])):
            os.makedirs(os.path.join(hist_dir, file_name[0:-4]))
        
        if log:
            plt.savefig(os.path.join(hist_dir, file_name[0:-4], title+"_dim_"+str(i)+"_ln.pdf"))
        else: 
            plt.savefig(os.path.join(hist_dir, file_name[0:-4], title+"_dim_"+str(i)+"_.pdf"))

        plt.close()

if __name__ == "__main__":
    main()