# Timers

Bullet points under timers are in runtime order. Some timers appear inside of others. They are stated in description if that is the case.

## **Summary of Model timers**

Detailed description of each timer is in next section.

* **CELL_READ_DATA**: Reading data directory files and putting those into a space filling curve and time series. Maps Faults and sets up transformed data. Summed magnitudes in time series.

* **EVAL**: **CELL_READ_DATA** timer inside this timer. There are 2 important lists. **Properties** which include input and predicted time series. **Predictions** which are predictions on the time series. 
Pick input and predicted properties. Calculate futures from properties. Create and calculate predictions, which sets up predictions and removes input quantities. Temporal and Spatial Positional Encoding added to predictions.

* **Data head**: load and split train, validation and test data.

* **RunTFTCustomVersion A**: Full model is under this timer. Every timer name with RunTFTCustomVersion in it is under this timer.

* **RunTFTCustomVersion train**: Trains model. Determines and saves best fit from various epochs.

* **RunTFTCustomVersion bestfit**: Takes best fit model and runs code based on TFTTestpredict, setFFFFmapping, and DLprediction timers.

* **TFTTestpredict**: Computes predictions for TFT dataset and returns formatted dataframes for prediction.

* **setFFFFmapping**: Takes TFTTestpredict dataframes and maps values and index in TFTSaveandInterpret class.

* **DLprediction**: Calculates MSE and NNSE from TFTSaveandInterpret class

**End of model. Printouts and saving of notebook and various text and picture outputs.**

## Detailed description of Model 

Includes functions to be looked at for optimization at end of each timer section where applicable.

1. CELL_READ_DATA
- Data directory files (Magnitude, depth, multiplicity, RundleMultiplicity, Top Earthquakes, Fault Label)
- Calculate space filling curve and plot it.
- Location information
- Time series set up
- Read in data directory files to appropriate type (time series, static props)
- map faults based on data.
- set up Transformed data
- Summed magnitudes as properties for all times used in model.

**For optimization** During reading of data and populating CalculatedTimeSeries.

2. EVAL

There are 2 important data structures. **Properties** which include input and predicted time series. **Predictions** which are predictions on the time series. 

- Everything from CELL_READ_DATA in here.
- Reset time
- E^0.25 to input properties
- Plot earthquake images (fault_discovery graphs)
- Normalize all properties
- Mapping locations
- Set Properties Predictions Encoding
- Pick input and predicted properties
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

Not included in timers – Lasts about 1 minute.
- Convert FFFFWNPF to TFT
- TFT Setup (initialize parameters)
- Setup Classic TFT (initialize more parameters)

3. data head
- Loading and splitting data

data head setup train
- Samples data to create train data

data head setup valid
- Samples data to create valid data

data head setup test
- Samples data to create test data

**Data head**: load and split train, validation and test data.

**For optimization** data head setup (~1hour), Individually call and read in train, validation and test data. Lots of for loops inside TFTdatasetup class which sets up the data.

### **Model starts here**

4. **RunTFTCustomVersion A**: Full model is under this timer.
- Alll RunTFTCustomVersion timers are under this. Full model is under this timer.

5. RunTFTCustomVersion init
- Initialize various flags and variables

6. RunTFTCustomVersion train
- Initialize progress bars
- Trains model
- Validates if train is best fit and saves otherwise keeps best saved fit
- Runs timer RunTFTCustomVersion train Epoch:{e}, RunTFTCustomVersion validation bestfit Epoch:{e}

7. RunTFTCustomVersion bestfit
- Set best possible fit
- Prints out best fit networks
- Make Output Loss v Epoch graph
- Setup TFT
- Runs timers RunTFTCustomVersion bestfit finalize TFTTestpredict, RunTFTCustomVersion bestfit finalize VisualizeTFT

8. RunTFTCustomVersion bestfit finalize TFTTestpredict
- Computes predictions for TFT dataset and returns formatted dataframes for prediction.

**For optimization**. Check function TFTTestpredict

9. RunTFTCustomVersion bestfit finalize VisualizeTFT
- Includes every timer that includes RunTFTCustomVersion bestfit finalize VisualizeTFT in the timer name.

10. RunTFTCustomVersion bestfit finalize VisualizeTFT TFTSaveandInterpret setFFFFmapping
- Takes output from RunTFTCustomVersion bestfit finalize TFTTestpredict and sets an index and mapping for these values in TFTSaveandInterpret class.

**For optimization**. Check class TFTSaveandInterpret function setFFFFmapping

11. RunTFTCustomVersion bestfit finalize VisualizeTFT DLprediction
- Takes TFTSaveandInterpret class
- Calculates MSE on all values (there are 92 million total values with ~900k sequences)
- Calculates NNSE
- Creates DLResults_Graphs

**For optimization**. Check DLprediction function

**End of model. Printouts and saving of notebook and various text and picture outputs.**
