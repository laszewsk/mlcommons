# Timers

This is a list of timers that appear in the benchmark code. The timers are in runtime order. Some timers appear inside of others; this is stated in the timer if that is the case.

## Summary of Model timers

This is a summary of important timers. A detailed description of all timers are below this section.

* **CELL_READ_DATA**: Reads in data directory files and puts data directory files into a space filling curve and time series. Maps Faults and sets up transformed data. Summed magnitudes in time series.

* **EVAL**: **CELL_READ_DATA** timer inside this timer. There are 2 important lists in this timer. **Properties** which include input and predicted time series. **Predictions** which are predictions on the time series. 
  - Picks input and predicted properties.
  - Code calculates futures from properties.
  - Creates and calculates predictions.
      - This sets up predictions from properties and removes input quantities from the newly created predictions. 
  - Temporal and Spatial Positional Encoding added to predictions.

* **Data head**:  Loads and splits train, validation and test data.

* **RunTFTCustomVersion A**:  The full model is run under this timer. Every timer name subset with RunTFTCustomVersion is under this timer.

* **RunTFTCustomVersion train**: Trains the model. Determines and saves best fit from all run epochs.

* **RunTFTCustomVersion bestfit**: Takes the best fit model and runs code based on TFTTestpredict, setFFFFmapping, and DLprediction timers.

* **TFTTestpredict**: Computes predictions for TFT dataset and returns formatted dataframes for prediction.

* **setFFFFmapping**: Takes TFTTestpredict dataframes and maps values and index in TFTSaveandInterpret class.

* **DLprediction**: Calculates MSE and NNSE from TFTSaveandInterpret class.

**End of model. Data printouts and saving of notebook and various figures occur here.**

## Detailed description of Model 

This is a detailed description of the model timers. Some timers include optimization notes which explain where improvements could be made on the code.

1. CELL_READ_DATA

   - Read in the following Data directory files.
      - Magnitude
      - Depth
      - Multiplicity
      - RundleMultiplicity
      - Top Earthquakes
      - Fault Label
   - Calculate and plot space filling curve.
   - Set up Location information.
   - Set up Time series.
   - Read in data directory files to time series or static properties.
   - Map faults based on data.
   - Set up Transformed data.
   - Summed magnitudes as properties for all times used in model.

**For optimization** Optimization opportunity during reading of data directories and populating of the CalculatedTimeSeries.

2. EVAL

   There are two important data structures. **Properties** which include input and predicted 
   time series. **Predictions** which are predictions on the time series. 

   - Everything from CELL_READ_DATA timer is run before this point.
   - Set timer 1 year back for 1 year buffer calculation.
   - E^0.25 multipled into input properties.
   - Plot earthquake images (fault_discovery graphs).
   - Normalize all properties.
   - Mapping locations into properties.
   - Set Properties Predictions Encoding.
   - Pick input and predicted properties.
   - Calculate futures.
   - Start predictions.
   - Set up predictions.
   - Clean-up Input quantities from predictions.
   - Set up sequences and TFT Model. These are various flags and values.
   - Generate sequences from time labeled data.
   - Define and add Temporal and Spatial Positional Encoding to input properties and predictions.
   - Initialize NNSE and plot predictions arrays.
   - Location Based Validation done.
   - LSTM Control Parameters, important parameters defining transformer, General Control Parameters are defined.

   - Following code is not included in the timers. In total the code runs for about 1 minute.
   
     - Convert FFFFWNPF to TFT.
     - TFT Setup is run. This is initialize parameters.
     - Setup Classic TFT. This is initialize more parameters.

3. data head setup
   - Holds all timers with the “data head setup” subset in the timer’s name.
   - Load and split train, validation and test data.

   data head setup train
   - Samples data to create train data

   data head setup valid
   - Samples data to create valid data

   data head setup test
   - Samples data to create test data

   **For optimization** Data head setup runs for  approximately 1hour. This Individually calls and read in train, validation and test data. Reivew TFTdatasetup class which sets up the data.

### **Model starts here**

4. **RunTFTCustomVersion A**: Full model is under this timer. Every timer name that includes a subset of “RunTFTCustomVersion” is in this timer.

5. RunTFTCustomVersion init
   - Initialize multiple flags and variables.

6. “RunTFTCustomVersion train” and “RunTFTCustomVersion validation”
   - Initialize progress bars.
   - Trains the model.
   - Validates if most recent trained epoch is best fit. If the most recent trained epoch is the best fit, saves this epoch as the best fit epoch.

7. RunTFTCustomVersion bestfit
   - Sets the best possible fit model
   - Prints out best fit networks.
   - Make Output Loss v Epoch graph.
   - Setup TFT model.
   - Runs the following timers: RunTFTCustomVersion bestfit finalize TFTTestpredict, RunTFTCustomVersion bestfit finalize VisualizeTFT.

8. RunTFTCustomVersion bestfit finalize TFTTestpredict
   - Computes predictions for TFT dataset and returns formatted dataframes for prediction.

   **For optimization**. Check the function “TFTTestpredict”.

9. RunTFTCustomVersion bestfit finalize VisualizeTFT
   - Every timer name that includes a subset of “RunTFTCustomVersion bestfit finalize VisualizeTFT” is in this timer.

10. RunTFTCustomVersion bestfit finalize VisualizeTFT TFTSaveandInterpret setFFFFmapping
    - Takes the output from RunTFTCustomVersion bestfit finalize TFTTestpredict and sets an index and mapping for these values in TFTSaveandInterpret class.

   **For optimization**. Check the function “setFFFFmapping” under the class “TFTSaveandInterpret”.

11. RunTFTCustomVersion bestfit finalize VisualizeTFT DLprediction
    - Takes the “TFTSaveandInterpret” class
    - Calculates MSE on all values. In total there are 92 million values with about 900k sequences
    - Calculates NNSE.
    - Creates the DLResults_Graphs.

    **For optimization**. Check the “DLprediction” function

    **End of model. Data printouts and saving of notebook and various figures occur here.**
