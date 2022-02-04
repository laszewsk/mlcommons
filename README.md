# mlcommon

* Policy document: https://github.com/laszewsk/mlcommon/blob/main/science_training_policy.adoc
* Meeting Notes:
* Summary   



https://github.com/laszewsk
https://github.com/juripapay


## Install locally the web 

```
git clone git@github.com:laszewsk/mlcommons.git
cd mlcommons
git submodule update --init --recursive
```

## Install hugo locally Ubuntu 20.04

```
wget https://github.com/gohugoio/hugo/releases/download/v0.92.1/hugo_extended_0.92.1_Linux-64bit.deb
sudo dpkg --install hugo_extended_0.92.1_Linux-64bit.deb 

```

## Install LTS version of nodejs

```
cd ~
curl -sL https://deb.nodesource.com/setup_16.x | sudo bash -
sudo apt -y install nodejs
node -v
```

## Install PostCSS

```
npm install -D autoprefixer
npm install -D postcss-cli
npm install -D postcss
```