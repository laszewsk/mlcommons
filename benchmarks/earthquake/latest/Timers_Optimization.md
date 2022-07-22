I have put these timers in time order of when they appear. there are some timers that appear inside of others. they are stated in description if that is the case.

# **Summary of Model timers** - Detailed description is below this section.

**CELL_READ_DATA**: reading data directory files and putting those into a space filling curve and time series. Maps Faults and sets up transformed data. Summed magnitudes in time series.

**EVAL**: Everything from CELL_READ_DATA. E^0.25 to input properties, plot fault discovery, Normalize those properties. Map locations. Note there are 2 important lists. Properties which includes input and predicted time series. Predictions which are predictions on the time series. Pick input and predicted properties. Create and calculate predictions which sets up predictions and removes input quantities. Temporal and Spatial Positional Encoding added to predictions. Plot prediction arrays. Set up a location validator. (Location validator isn’t currently used? Maybe used in model)

**Data head**: load and split train, validation and test data.

**RunTFTCustomVersion A**: Full model is under this timer.

**RunTFTCustomVersion train**: trains model and determines and saves best fit from various epochs.

**RunTFTCustomVersion bestfit**: takes best fit model and runs code based on TFTTestpredict, setFFFFmapping, and DLprediction timers.

**TFTTestpredict**: Computes predictions for TFT dataset and returns formatted dataframes for prediction.

**setFFFFmapping**: takes TFTTestpredict dataframes and maps values and index in TFTSaveandInterpret class.

**DLprediction**: Calculates MSE and NNSE from TFTSaveandInterpret class

**End of model. A bunch of printouts and saving happens here.**


# **Detailed description of Model** - includes optimization recommendations and summaries of timer at end of each timer section.

CELL_READ_DATA
- Data directory files (Magnitude, depth, multiplicity, RundleMultiplicity, Top Earthquakes, Fault Label)
- Calculate space filling curve and plot it.
- Location information
- Time series set up
- Read in data directory files to appropriate type (time series, static props)
- map faults based on data.
- set up Transformed data
- Summed magnitudes as properties for all times used in model.

**CELL_READ_DATA**: reading data directory files and putting those into a space filling curve and time series. Maps Faults and sets up transformed data. Summed magnitudes in time series.

**For optimization** CELL_READ_DATA (~7 minutes), when reading in data and populating CalculatedTimeSeries there are a number of nested for loops

EVAL
- everything from CELL_READ_DATA in here + everything below.
- Reset time
- E^0.25 to input properties
- Plot earthquake images (fault_discovery graphs)
- Normalize all properties
- Mapping locations
- Set Properties Predictions Encoding
- Pick input and predicted quantities
- Calculate futures
- Start predictions
- Set up predictions
- Clean-up Input quantities
- Set up sequences and TFT Model (Various flags and values)
- Generate sequences from time labeled data
- Define and add Temporal and Spatial Positional Encoding to input and predictions
- Initialize NNSE and plot predictions arrays
- Location Based Validation
- LSTM Control Parameters, important parameters defining transformer, General Control Parameters defined

**EVAL**: Everything from CELL_READ_DATA. E^0.25 to input properties, plot fault discovery, Normalize those properties. Map locations. 
Note there are 2 important lists. **Properties** which include input and predicted time series. **Predictions** which are predictions on the time series. 
Pick input and predicted properties. Create and calculate predictions which sets up predictions and removes input quantities. 
Temporal and Spatial Positional Encoding added to predictions. Plot prediction arrays.

Not included in timers - Lasts 1 minute at most.

Convert FFFFWNPF to TFT

TFT Setup (initialize a bunch of parameters)

Setup Classic TFT (initialize more parameters)

data head

Loading and splitting data

data head setup train

Samples data to create train data

data head setup valid

Samples data to create valid data

data head setup test

Samples data to create test data

**Data head**: load and split train, validation and test data.

**For optimization** data head setup (~1hour), Individually call and read in train, validation and test data. Lots of for loops inside TFTdatasetup class which sets up the data.

**Model starts here!**

**RunTFTCustomVersion A**: Full model is under this timer.

alll RunTFTCustomVersion timers are under this. Full model is under this timer.

RunTFTCustomVersion init

Initialize various flags and variables

RunTFTCustomVersion train
- Initialize progress bars
- Trains model
- Validates if train is best fit and saves otherwise keeps best saved fit
- Runs timer RunTFTCustomVersion train Epoch:{e}, RunTFTCustomVersion validation bestfit Epoch:{e}

**RunTFTCustomVersion train**: trains model and determines and saves best fit from various epochs.

RunTFTCustomVersion bestfit
- set best possible fit
- prints out best fit networks
- make Ouput Loss v Epoch graph
- Setup TFT
- runs timers RunTFTCustomVersion bestfit finalize TFTTestpredict, RunTFTCustomVersion bestfit finalize VisualizeTFT

**RunTFTCustomVersion bestfit**: takes best fit model and runs code based on TFTTestpredict, setFFFFmapping, and DLprediction timers.

RunTFTCustomVersion bestfit finalize TFTTestpredict (hour long processing, can be looked at for improvement. check function TFTTestpredict)

Computes predictions for TFT dataset and returns formatted dataframes for prediction.

**For optimization**. I think the 2 for loops are the slow down. At least one of them is embarrassingly parallel.

**TFTTestpredict**: Computes predictions for TFT dataset and returns formatted dataframes for prediction.

RunTFTCustomVersion bestfit finalize VisualizeTFT

includes every timer under RunTFTCustomVersion bestfit finalize VisualizeTFT ...

RunTFTCustomVersion bestfit finalize VisualizeTFT TFTSaveandInterpret setFFFFmapping (1 hour long processing, look for parallelization, check class TFTSaveandInterpret function setFFFFmapping)

Takes output from RunTFTCustomVersion bestfit finalize TFTTestpredict and sets a index and mapping for these values in TFTSaveandInterpret class.

**for optimization**. there are alot of nested for loops.

**setFFFFmapping**: takes TFTTestpredict dataframes and maps values and index in TFTSaveandInterpret class.

RunTFTCustomVersion bestfit finalize VisualizeTFT DLprediction (1 hour long processing, check DLprediction function)
- Takes TFTSaveandInterpret class
- Calculates MSE on all values (there are 92 million total values with ~900k sequences)
- Calculates NNSE
- Creates DLResults_Graphs

**for optimization**. a number of nested for loop with alot going on.

**DLprediction**: Calculates MSE and NNSE from TFTSaveandInterpret class

**End of model. A bunch of printouts and saving happens here.**
