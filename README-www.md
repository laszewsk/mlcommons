
## Create vanilla hugo


export REPO=mlcommons
rm -rf docsy-example
git clone   https://github.com/google/docsy-example.git
cd docsy-example/
git checkout -b main
mv config.toml config.toml-orig
sed 's/# github_branch/github_branch/g' config.toml-orig > config.toml
diff config.toml-orig config.toml
git remote add origin git@github.com:laszewsk/$REPO.git
git remote set-url origin git@github.com:laszewsk/$REPO.git
git branch -M main
git push -u origin main
cd ..

## Create copy to muve hugo to www

mkdir m
cd m
git clone git@github.com:laszewsk/$REPO.git
cd $REPO
mkdir www
git mv *.* a* c* D* t* LICENSE layouts www
git commit -a
git push
git remote set-url origin git@github.com:laszewsk/$REPO.git

## tst the service

cd www
hugo serve
history

## Checkout

git clone https://github.com/laszewsk/$REPO.git
cd mlcommons
git submodule update --init --recursive
cd www
hugo serve
