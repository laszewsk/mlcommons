# Setup

## Programs

v29 https://colab.research.google.com/drive/12zEv08wvwRhQEwYWy641j9dLSDskxooG
v28continue https://colab.research.google.com/drive/1_zG84kahrTgkiVGcoFVrgi4VF07YHeL_?usp=sharing

# Variable setup

## V28 from scratch

IN "TFT Setup" One needs to set variables below

```
DLAnalysisOnly = False
DLRestorefromcheckpoint = False
DLinputRunName = RunName
DLinputCheckpointpostfix = ''

TFTTransformerepochs = 40
```

## V28 Continue

Here is v28continue which trains for 25 more epochs extending current
run. These jobs have same value for RunName

```
DLAnalysisOnly = False
DLRestorefromcheckpoint = True
DLinputRunName = RunName
DLinputCheckpointpostfix = '-41'

TFTTransformerepochs = 25
```

## V29

Here is v29 which has a different RunName to other two

```
DLAnalysisOnly = True
DLRestorefromcheckpoint = True
DLinputRunName = RunName
DLinputRunName = 'EARTHQ-newTFTv28'
DLinputCheckpointpostfix = '-67'

TFTTransformerepochs = 40
```
TFTTransformerepochs is ignored as no training
-67 is last saved weight set of v28

## Setup we want if using v29

Same as v29 but with the folowing values changed

```
DLAnalysisOnly = False
DLRestorefromcheckpoint = False
DLinputRunName = RunName
DLinputCheckpointpostfix = ''

TFTTransformerepochs = 66
```

