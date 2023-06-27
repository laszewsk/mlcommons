#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# slstr_cloud.py

# Import statements
from cloudmesh.common.util import readfile
import seaborn as sns
import pandas as pd
import matplotlib.pyplot as plt

import json
import sys
import os


def epoch_vs_scimet(mlperf_file):
    # Read file
    content = readfile(mlperf_file).splitlines()

    # Create dataframes
    train_df = pd.DataFrame(columns = ['Run','Epochs','Train Accuracy','Train Loss','Validation Accuracy','Validation Loss'])
    test_df = pd.DataFrame(columns = ['Epochs', 'Test Accuracy'])

    run = 0
    # Appending accuracies to the dataframe
    for line in content:
        # Locate Result line
        if ':::MLLOG' in line and '"key": "result"' in line and 'training' in line:
            # String to a dict using json.loads
            # print(line)
            d = json.loads(line.split(":::MLLOG ")[1])
            
            # Extracting values
            train_acc = d["value"]["training"]["history"]["accuracy"]
            train_loss = d["value"]["training"]["history"]["loss"]
            val_acc = d["value"]["training"]["history"]["val_accuracy"]
            val_loss = d["value"]["training"]["history"]["val_loss"]
            test_acc = d["value"]["inference"]["avg_accuracy"]            

            # Checking length of the lists
            epochs = len(train_acc)
            print(train_acc)
            if epochs == len(train_loss) and epochs == len(val_acc) and epochs == len(val_loss):

                # Appending to dataframe
                for i in range(epochs):
                    train_df.loc[len(train_df.index)] = ["Run " + str(run+1), i, train_acc[i], train_loss[i], val_acc[i], val_loss[i]]
                test_df.loc[len(test_df.index)] = [epochs, test_acc]
            else:
                print("The values for accuracies and losses don't have same length.")
                return
            run+=1

    # print(train_df)
    # print(test_df)

    # Creating images directory
    if not os.path.exists("images"):
        os.makedirs("images")

    # Plotting the graphs
    acc_plot = sns.lineplot(data = train_df , x = "Epochs", y = "Train Accuracy", label = "Train Accuracy")
    acc_plot = sns.lineplot(data = train_df , x = "Epochs", y = "Validation Accuracy", label = "Validation Accuracy")
    acc_plot = sns.lineplot(data = test_df , x = "Epochs" , y = "Test Accuracy", label = "Test Accuracy")
    acc_plot.set(xlabel = "Epochs", ylabel = "Accuracies")
    acc_plot.set_title("Epochs vs. Accuracies")

    # Saving figure in different formats
    acc_plot.figure.savefig("images/epoch_vs_accuracy.svg")
    acc_plot.figure.savefig("images/epoch_vs_accuracy.png", dpi=300)
    acc_plot.figure.savefig("images/epoch_vs_accuracy.pdf")

    # Clearing the figure
    acc_plot.figure.clf()

    loss_plot = sns.lineplot(data = train_df , x = "Epochs", y = "Train Loss", label = "Train Loss")
    loss_plot = sns.lineplot(data = train_df , x = "Epochs", y = "Validation Loss", label = "Validation Loss")
    loss_plot.set(xlabel = "Epochs", ylabel = "Losses")
    loss_plot.set_title("Epochs vs. Losses")

    loss_plot.figure.savefig("images/epoch_vs_loss.svg")
    loss_plot.figure.savefig("images/epoch_vs_loss.png", dpi = 300)
    loss_plot.figure.savefig("images/epoch_vs_loss.pdf")

    loss_plot.figure.clf()

    # Plotting different runs seperately
    if(run>1):
        sns.color_palette("pastel")
        train_acc_plot = sns.lineplot(data = train_df, y = "Train Accuracy", x = "Epochs", hue = "Run", palette="pastel")
        train_acc_plot.set_title("Train Accuracies for different runs")
        train_acc_plot.set(xlabel = "Epochs", ylabel = "Train Accuracy")

        train_acc_plot.figure.savefig("images/train_accuracy_diff_runs.svg")
        train_acc_plot.figure.savefig("images/train_accuracy_diff_runs.png", dpi=300)
        train_acc_plot.figure.savefig("images/train_accuracy_diff_runs.pdf")

        train_acc_plot.figure.clf()

        train_loss_plot = sns.lineplot(data = train_df, y = "Train Loss", x = "Epochs", hue = "Run", palette="pastel")
        train_loss_plot.set_title("Train Losses for different runs")
        train_loss_plot.set(xlabel = "Epochs", ylabel = "Train Loss")

        train_loss_plot.figure.savefig("images/train_loss_diff_runs.svg")
        train_loss_plot.figure.savefig("images/train_loss_diff_runs.png", dpi=300)
        train_loss_plot.figure.savefig("images/train_loss_diff_runs.pdf")

        train_loss_plot.figure.clf()


        val_acc_plot = sns.lineplot(data = train_df, y = "Validation Accuracy", x = "Epochs", hue = "Run", palette="pastel")
        val_acc_plot.set_title("Validation Accuracies for different runs")
        val_acc_plot.set(xlabel = "Epochs", ylabel = "Validation Accuracy")

        val_acc_plot.figure.savefig("images/validation_accuracy_diff_runs.svg")
        val_acc_plot.figure.savefig("images/validation_accuracy_diff_runs.png", dpi=300)
        val_acc_plot.figure.savefig("images/validation_accuracy_diff_runs.pdf")

        val_acc_plot.figure.clf()

        val_loss_plot = sns.lineplot(data = train_df, y = "Validation Loss", x = "Epochs", hue = "Run", palette="pastel")
        val_loss_plot.set_title("Validation Losses for different runs")
        val_loss_plot.set(xlabel = "Epochs", ylabel = "Validation Loss")

        val_loss_plot.figure.savefig("images/validation_loss_diff_runs.svg")
        val_loss_plot.figure.savefig("images/validation_loss_diff_runs.png", dpi=300)
        val_loss_plot.figure.savefig("images/validation_loss_diff_runs.pdf")

        val_loss_plot.figure.clf()


def epoch_vs_perf(cloudmask_file):
    
    # Create lists
    time_for_training = []
    time_for_inference = []
    epochs = []

    # Read contents in the file
    content = readfile(cloudmask_file).splitlines()
    for line in content:
        split_line = line.split(",")
        for vals in split_line:
            if "CloudMask training" in split_line and 'time_per' in vals.strip():
                time_for_training.append(float(vals.split("=")[1]))
            elif "CloudMask inference" in split_line and 'time_per' in vals.strip():
                time_for_inference.append(float(vals.split("=")[1]))
    
            if "epochs" in vals.strip():
                epochs.append(int(vals.split("=")[1]))

    if len(epochs) == len(time_for_training) and len(epochs) == len(time_for_inference):
        # Construct dataframe
        train_time =  pd.DataFrame(columns = ['Epochs','Average Time Per Epoch (ms)'])
        test_time =  pd.DataFrame(columns = ['Epochs','Average Time Per Epoch (ms)'])

        # Appending values to dataframe
        #print(time_for_training)
        #print(time_for_inference)
        #print(epochs)
        for i in range(len(epochs)):
            train_time.loc[len(train_time.index)] = [epochs[i], time_for_training[i]]
            test_time.loc[len(test_time.index)] = [epochs[i], time_for_inference[i]]

        # Plotting the graphs
        train_time_plot = sns.lineplot(data = train_time , y = "Epochs", x = "Average Time Per Epoch (ms)", label = "Train Avg. time per epoch")
        train_time_plot.set(xlabel = "Epochs", ylabel = "Average Time Per Epoch (ms)")
        train_time_plot.set_title("Epochs vs. Avg. time per epoch")

        train_time_plot.figure.savefig("images/epoch_vs_train_time.svg")
        train_time_plot.figure.savefig("images/epoch_vs_train_time.png", dpi = 300)
        train_time_plot.figure.savefig("images/epoch_vs_train_time.pdf")

        train_time_plot.figure.clf()

        test_time_plot = sns.lineplot(data = test_time , y = "Epochs", x = "Average Time Per Epoch (ms)", label = "Inference Avg. Time per epoch")
        test_time_plot.set(xlabel = "Epochs", ylabel = "Average Time Per Epoch (ms)")
        test_time_plot.set_title("Epochs vs. Avg. time per epoch")

        test_time_plot.figure.savefig("images/epoch_vs_test_time.svg")
        test_time_plot.figure.savefig("images/epoch_vs_test_time.png", dpi = 300)
        test_time_plot.figure.savefig("images/epoch_vs_test_time.pdf")

        test_time_plot.figure.clf()

    else:
        print("The Cloudmask file has extra unsuccessful attempt values.")
        return

def main():

    # Import file paths
    mlperf_file = sys.argv[1]
    cloudmask_file = sys.argv[2]

    # Plot epoch vs accuracy plot
    epoch_vs_scimet(mlperf_file)

    # Plot epoch vs time plot
    epoch_vs_perf(cloudmask_file)


if __name__ == "__main__":
    main()


