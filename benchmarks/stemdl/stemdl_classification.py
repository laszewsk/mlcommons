
'''
Installation on Summit:
module load python/3.8-anaconda3
conda create --name light3 python=3.8
conda activate light3
pip install pytorch-lightning
pip install torchvision
pip install scikit-learn
'''

import torch
from torch import nn
from torch.nn import functional as F
from torch.utils.data import DataLoader
from torch.utils.data import random_split
from torchvision import transforms
import pytorch_lightning as pl
from pytorch_lightning.plugins import DDPPlugin

# imports from stemdl
import time
import sys
import os
import math
import glob
import argparse
import torch.backends.cudnn as cudnn
import torch.multiprocessing as mp
import torch.nn.functional as F
import torch.optim as optim
import torch.utils.data.distributed
from torch.utils.tensorboard import SummaryWriter
from torchvision import datasets, transforms, models
from tqdm import tqdm
from sklearn.metrics import f1_score
import torch.nn as nn
import numpy as np

from pathlib import Path
from torch.utils.data import Dataset
from torchvision import datasets
from torchvision.transforms import ToTensor

# Custom dataset class
class NPZDataset(Dataset):
    def __init__(self, npz_root):
        self.files = glob.glob(npz_root + "/*.npz")

    def __getitem__(self, index):
        sample = np.load(self.files[index])
        x = torch.from_numpy(sample["data"])
        y = sample["label"][0]
        return (x, y)

    def __len__(self):
        return len(self.files)

# StemdlModel
class StemdlModel(pl.LightningModule):
	def __init__(self):
		super().__init__()
		self.input_size = 128
		num_classes=231
		self.num_classes = 231
		self.model_name = "resnet50"
		self.model = models.resnet50(pretrained=False)
		self.num_ftrs = self.model.fc.in_features
		self.model.fc = nn.Linear(self.num_ftrs, self.num_classes)
		self.params_to_update = self.model.parameters()
		self.feature_extract = False

	# forward step
	def forward(self, x):
			embedding = self.model(x)
			return embedding

	def configure_optimizers(self):
			optimizer = torch.optim.Adam(self.parameters(), lr=1e-3)
			return optimizer

	def training_step(self, train_batch, batch_idx):
			x, y = train_batch
			x_hat = self.model(x)
			y = F.one_hot(y, num_classes=231).float()
			loss = F.mse_loss(x_hat, y)
			self.log('train_loss', loss)
			return loss

	def validation_step(self, val_batch, batch_idx):
			x, y = val_batch
			x_hat = self.model(x)
			y = F.one_hot(y, num_classes=231).float()
			loss = F.mse_loss(x_hat, y)
			self.log('train_loss', loss)
			return loss

def get_dataset():
	parser = argparse.ArgumentParser(description='PyTorch ImageNet Example',
							 formatter_class=argparse.ArgumentDefaultsHelpFormatter)
							 
	parser.add_argument('--train-dir', default=os.path.expanduser('/gpfs/alpine/gen150/proj-shared/jpdata/datasets/stemdl_data/train'),help='path to training data')
	
	parser.add_argument('--val-dir', default=os.path.expanduser('/gpfs/alpine/gen150/proj-shared/jpdata/datasets/stemdl_data/test'),help='path to validation data')
	parser.add_argument('--log-dir', default='./logs', help='tensorboard log directory')
	args = parser.parse_args()

	# Datasets: training (138717 files), validation (48438 files), 197kbytes each
	train_dataset = NPZDataset(args.train_dir)
	test_dataset = NPZDataset(args.val_dir)

	# Retun datasets of DataLoader type
	return train_dataset, test_dataset
	
'''
Command for running the stemdl_classification benchmark:
python stemdl_classification.py --train-dir /gpfs/alpine/gen150/proj-shared/jpdata/datasets/stemdl_data/train \
--val-dir /gpfs/alpine/gen150/proj-shared/jpdata/datasets/stemdl_data/test
'''

def main():
    # data
	train_dataset, test_dataset = get_dataset()
	train_loader = DataLoader(train_dataset, batch_size=32, num_workers=4)
	val_loader = DataLoader(test_dataset, batch_size=32, num_workers=4)

	# model
	model = StemdlModel()

	# training
	trainer = pl.Trainer(gpus=1, num_nodes=1, precision=16, strategy="ddp", max_epochs=2)
	start = time.time()
	trainer.fit(model, train_loader, val_loader)
	end = time.time()
	print(f'Stemdl elapsed time, 4 epoch, bs=32: ', {end - start})

if __name__ == "__main__":
        main()