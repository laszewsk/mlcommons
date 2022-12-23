import h5py
import os
import numpy as np
import matplotlib.pyplot as plt

if not os.path.isdir("histograms"):
    os.makedirs("histograms")
hist_dir = os.path.join(os.path.curdir, "histograms")
data_dir = "../../data/one-day"

all_datasets = ["bayes", "bts", "rads", "refs", "summary"]


def main():
    # loop once through day directory and once through night directory
    for file in os.listdir(os.path.join(data_dir, "day")):
        file_name = os.path.join(data_dir, "day/", file)
        make_hist(file_name, "bayes", log=True)
        for elem in all_datasets:
            make_hist(file_name, elem)

    for file in os.listdir(os.path.join(data_dir, "night")):
        file_name = os.path.join(data_dir, "night/", file)

        make_hist(file_name, "bayes", log=True)
        for elem in all_datasets:
            make_hist(file_name, elem)


def format_filename(filename):
    """
    makes all letters lowercase and replaces underscores with dashes
    """
    filename = filename.lower()
    if "_" in filename:
        filename_arr = filename.split(sep="_")
        filename = ""
        for word in filename_arr:
            filename = filename + word + "-"
        if filename[-1] == "-":
            filename = filename[:-1]
    return filename


def save_figure(filename="name", directory="./", format="pdf,png,svg", dpi=300):
    """
    calls format_filename and saves the figure that plt has created
    Must have a figure in plt ready to save
    """
    filename = format_filename(filename)

    for filetype in format.split(sep=","):
        plt.savefig(os.path.join(directory, filename + "." + filetype), format=filetype, dpi=dpi)


def make_hist(file_name, title, log=False):
    """
    creates a histogram for every channel of the selected dataset

    @param file_name: hdf file you want to make histograms from
    @param title: which dataset within the hdf file to use
    @param log: whether you want to have the natural log of the frequency taken
    """
    with h5py.File(file_name, "r") as hdf:
        data = np.array(hdf[title][:])

    # create a histogram for each channel by looking at last dimension
    for i in range(data.shape[-1]):
        hist, bin_edges = np.histogram(data[:, :, i:i + 1], bins=255)

        plt.figure(figsize=[10, 8])

        if log:
            plt.bar(bin_edges[:-1], np.log(hist), width=bin_edges[2] - bin_edges[1],
                    color='blue', alpha=0.7)
        else:
            plt.bar(bin_edges[:-1], hist, width=bin_edges[2] - bin_edges[1],
                    align="edge", color='blue', alpha=0.7)

        plt.xlim(min(bin_edges) - 5, max(bin_edges) + 5)
        plt.xlabel('Value')

        if log:
            plt.ylabel('ln(Frequency)')
            plt.title(title + " dim " + str(i) + " ln")
        else:
            plt.ylabel('Frequency')
            plt.title(title + " dim " + str(i))

        # begin manipulating filename and save figure
        base = os.path.basename(file_name)

        base = format_filename(base)

        base = base.split(sep=".")[0]

        if not os.path.isdir(os.path.join(hist_dir, base)):
            os.makedirs(os.path.join(hist_dir, base))

        if log:
            save_figure(base + "-dim-" + str(i) + "-ln", os.path.join(hist_dir, base), dpi=300)
        else:
            save_figure(base + "-dim-" + str(i), os.path.join(hist_dir, base), dpi=300)
            print(os.path.join(hist_dir, file_name[23:-4], title + "_dim_" + str(i) + "_.pdf"))

        plt.close()


if __name__ == "__main__":
    main()
