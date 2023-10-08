import os

import pandas as pd
from bokeh.models import Legend
from bokeh.plotting import figure, show
from bokeh.models import HoverTool, ColumnDataSource
from cloudmesh.common.FlatDict import FlatDict
from bokeh.palettes import Category20  # Import a color palette

# Define the directory where you want to start the search
start_directory = 'project/'

# Initialize an empty dictionary to store the results
result = []

# Use a recursive search to find all files matching the pattern
for root, dirs, files in os.walk(start_directory):
    for file in files:
        if file.startswith('result') and file.endswith('.out'):
            file_path = os.path.join(root, file)
            with open(file_path, 'r') as f:
                lines = f.readlines()
                csv_lines = [line.strip() for line in lines if line.startswith("# csv")]
                try:
                    result_line = [line.replace(":::MLLOG", "").strip() for line in lines if
                                   line.startswith(":::MLLOG") and '"result"' in line][0]
                    result_line = eval(result_line)

                    for k in ['event_type', 'key', 'metadata', 'namespace', 'time_ms']:
                        del result_line[k]

                except:
                    result_line = None
                csv_dict = {}
                for line in csv_lines[1:]:  # Skip the header line
                    line_parts = line.split(',')
                    timer_key = line_parts[1]
                    csv_dict[timer_key] = float(line_parts[3])

                if csv_lines:
                    config_path = os.path.join(root, 'config.yaml')
                    config = FlatDict()
                    try:
                        config.loadf(filename=config_path)
                    except:
                        config = None
                    # filter only the "experiment." values

                    filtered = {key.replace("experiment.", ""): value
                                for key, value in dict(config).items() if key.startswith('experiment.')}
                    entry = {
                        'name': file
                    }
                    entry.update(csv_dict)
                    entry.update(filtered)
                    entry.update({"result": result_line})
                    result.append(entry)

# Print the dictionary with the results, including the config
# for filename, data in result_dict.items():
#     print(f'File: {filename}')
#     print('CSV Lines:')
#     for line in data['csv_lines']:
#         print(line)
#    print('Config:')
#    for key, value in data['config'].items():
#        print(f'{key}: {value}')

# pprint(result_dict)

df = pd.DataFrame(result)
print(df.columns)

for c in ['epoch', 'repeat']:
    df[c] = df[c].astype(int)
for c in ['total', 'training', 'loaddata', 'inference']:
    df[c] = df[c].astype(float)

df = df.drop(columns=['name', 'mem', 'gpu_count', 'cpu_num', 'seed', 'batch_size', 'clip_offset', 'no_cache', 'gpu', 'nodes',
                      'train_split', 'learning_rate', 'early_stoppage_patience', 'card_name', 'training_on_mutiple_GPU'])

df['name'] = df['directive'].astype(str) + ',' + df['epoch'].astype(str) + ',' + df['early_stoppage'].astype(str)
df = df[['name'] + [col for col in df.columns if col != 'name']]
df['name'] = df['name'].str.replace(',False', '')
df['name'] = df['name'].str.replace(',True', '.es')


# df


# %%
def exctract(df, newkey='test_accuracy', key1='value', key2='inference', key3='accuracy', key4=None):
    def extract_accuracy(row):
        try:
            if key4 is None:
                return row[key1][key2][key3]
            else:
                return row[key1][key2][key3][key4]
        except KeyError:
            return None

    df[newkey] = df['result'].apply(extract_accuracy)
    return df


df = exctract(df, 'test_accuraccy', 'value', 'inference', 'accuracy')

df = exctract(df, 'training_accuracy', 'value', 'training', 'history', 'accuracy')
df = exctract(df, 'training_loss', 'value', 'training', 'history', 'loss')
df = exctract(df, 'training_val_loss', 'value', 'training', 'history', 'val_loss')
df = exctract(df, 'training_val_accuracy', 'value', 'training', 'history', 'val_accuracy')

df.drop(columns=['result'], inplace=True)

# df

es_false_df = df[df['early_stoppage'] == 'False'].copy()
es_true_df = df[df['early_stoppage'] == 'True'].copy()
df_all = df.copy()

from bokeh.models import HoverTool

from bokeh.models import HoverTool, ColumnDataSource


def plot_accuracy_history(df, selected_directive, selected_epoch):
    # Filter rows with valid directive names
    df = df[df['directive'].notna()]

    # Filter the DataFrame for the selected directive and epoch
    filtered_df = df[
        (df['directive'] == selected_directive) & (df['training_accuracy'].apply(lambda x: len(x)) >= selected_epoch)]

    # Create a Bokeh figure
    p = figure(width=1200, height=800, title=f'Accuracy History for Directive: {selected_directive} at Epoch {selected_epoch}')
    colors = Category20[20]

    # Create a ColumnDataSource from the filtered DataFrame

    # Define a list of colors for the lines
    legend_items = []

    # Iterate through accuracy histories and plot each line
    for idx, row in enumerate(filtered_df.iterrows()):

        accuracy_history = row[1]['training_accuracy'][:selected_epoch]

        x = list(range(1, selected_epoch + 1))
        y = accuracy_history

        line_color = colors[idx % len(colors)]
        display_df = pd.DataFrame()
        display_df['x'] = x
        display_df['y'] = y
        display_df['epoch'] = selected_epoch
        display_df['directive'] = selected_directive
        for k in ['name', 'total', 'training', 'inference', 'loaddata']:
            display_df[k] = row[1][k]
        display_df['line_color'] = str(line_color)

        source = ColumnDataSource(display_df)

        line = p.line(x='x', y='y', source=source, line_width=2, line_color=line_color)
        # legend_items.append((f'Result {idx + 1}', [line]))

    # Add legend
    #legend = Legend(items=legend_items, location="top_left")
    #p.add_layout(legend, 'right')

    # Set axis labels and plot limits
    p.xaxis.axis_label = 'Epoch'
    p.yaxis.axis_label = 'Accuracy'

    # Add a hover tool to display the name, epoch, total, training, inference, and load data
    hover = HoverTool()
    hover.tooltips = [("Name", "@name"),
                      ("Epochs", "@epoch"),
                      ("Directive", "@directive"),
                      ("Epoch", "@x"),
                      ("Accuracy", "@y"),
                      ("Total", "@total{0.00}"),
                      ("Training", "@training{0.00}"),
                      ("Inference", "@inference{0.00}"),
                      ("Load Data", "@loaddata{0.00}"),
                      ("Line Color", "@line_color"),
                      ]
    hover.mode = 'mouse'
    p.add_tools(hover)

    # Display the plot
    show(p)


# Example usage:
plot_accuracy_history(df, 'v100', 100)
