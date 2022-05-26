# Running the code on Google Colab
   
Open Google Colab and select Github
   
Search for https://github.com/laszewsk/mlcommons
   
Select the latest notebook *

Mount your Google Drive to Colab
```python
# import the Google Colab helper and mount drive
from google.colab import drive
drive.mount('/content/drive')
```
   
Open the runtime terminal

Create the config file for the run:
1. Open the config file in Github and select "Raw"
2. copy the URL
3. Execute the following commands with the URL from step 2
```bash
wget --no-check-certificate --content-disposition https://raw.githubusercontent.com/laszewsk/mlcommons/main/benchmarks/earthquake/mar2022/config.yaml
echo 'system.host: colab' >> config.yaml
```
   
Make the dataset directory 
   
```bash
cd /content/gdrive/My Drive
mkdir Colab\ Datasets/
```
Make a copy of the data
  
```bash
cd /content/gdrive/MyDrive/Colab\ Datasets/
git clone https://github.com/laszewsk/mlcommons-data-earthquake.git mlcommons-data-earthquake
tar Jxvf mlcommons-data-earthquake/data.tar.xz -C .
```
From the 'Runtime' dropdown menu select 'Run all'
   
When promted, approve the notebook to access your Google Drive
